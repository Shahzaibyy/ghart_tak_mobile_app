import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_draft.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_quote.dart';

/// Customer orders.
abstract interface class OrderRepository {
  /// Returns locally tracked placed orders (API has no list endpoint).
  Future<Result<List<Order>>> listOrders();

  /// Places [draft] and returns the new order.
  Future<Result<Order>> placeOrder(OrderDraft draft);

  /// Quotes fees for [draft].
  Future<Result<OrderQuote>> quote(OrderDraft draft);

  /// Loads one order by id.
  Future<Result<Order>> getOrder(String id);
}
