import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:attock_xpress/core/utils/money_parse.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_draft.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_quote.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_type.dart';
import 'package:dio/dio.dart';

/// HTTP access to quote / place / get order.
class OrderRemoteDataSource {
  /// Creates a data source over Dio.
  const new(this._dio);

  final Dio _dio;

  /// Prices an order without saving it.
  Future<OrderQuote> quote(OrderDraft draft) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/orders/quote',
      data: draft.toQuoteJson(),
    );
    final data = unwrapData<Map<String, dynamic>>(response);
    return OrderQuote.fromJson(data);
  }

  /// Places an order (idempotent via `client_request_id`).
  Future<Order> placeOrder(OrderDraft draft) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/orders',
      data: draft.toPlaceJson(),
    );
    final data = unwrapData<Map<String, dynamic>>(response);
    return _orderFrom(
      data,
      fallbackTitle: draft.title,
      photoUrl: draft.photoUrl,
    );
  }

  /// Loads one order by id.
  Future<Order> getOrder(
    String id, {
    String? title,
    String? photoUrl,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>('/orders/$id');
    final data = unwrapData<Map<String, dynamic>>(response);
    return _orderFrom(
      data,
      fallbackTitle: title ?? 'Order',
      photoUrl: photoUrl,
    );
  }

  Order _orderFrom(
    Map<String, dynamic> json, {
    required String fallbackTitle,
    String? photoUrl,
  }) {
    final id = json['id'];
    final type = json['type'];
    final status = json['status'];
    final fee = json['delivery_fee'];
    if (id is! String || type is! String || status is! String) {
      throw const FormatException('Invalid order payload');
    }
    final feeValue = switch (fee) {
      final String s => MoneyParse.amount(s),
      final num n => n.toDouble(),
      _ => 0.0,
    };
    final items = json['items'];
    var title = fallbackTitle;
    if (items is List && items.isNotEmpty) {
      final first = items.first;
      if (first is Map && first['item_name'] is String) {
        title = first['item_name'] as String;
      }
    }
    return Order(
      id: id,
      title: title,
      type: parseOrderType(type),
      status: _status(status),
      deliveryFee: feeValue,
      photoUrl: photoUrl,
    );
  }

  OrderStatus _status(String raw) {
    try {
      return parseOrderStatus(raw);
    } on FormatException {
      return switch (raw) {
        'preparing' || 'ready' || 'assigned' || 'offered' => const Accepted(),
        'picked_up' || 'on_the_way' || 'enroute' => const PickedUp(),
        _ => const Placed(),
      };
    }
  }
}
