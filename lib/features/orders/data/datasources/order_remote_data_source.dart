import 'package:attock_xpress/features/orders/data/models/order_model.dart';
import 'package:dio/dio.dart';

/// HTTP access to orders.
class OrderRemoteDataSource {
  /// Creates a data source over the HTTP client.
  const new(this._dio);

  final Dio _dio;

  /// Fetches the order list.
  Future<List<OrderModel>> listOrders() async {
    final response = await _dio.get<List<dynamic>>('/orders');
    final raw = response.data;
    if (raw is! List) {
      throw const FormatException('Expected a list of orders');
    }
    return raw.map(_decode).toList();
  }

  OrderModel _decode(Object? item) {
    if (item is! Map) {
      throw const FormatException('Expected an order object');
    }
    return OrderModel.fromJson(Map<String, dynamic>.from(item));
  }
}
