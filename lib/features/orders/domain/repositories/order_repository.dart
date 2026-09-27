import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_draft.dart';

/// Customer orders.
abstract interface class OrderRepository {
  /// Returns the current order list.
  Future<Result<List<Order>>> listOrders();

  /// Places [draft] and returns the new order.
  Future<Result<Order>> placeOrder(OrderDraft draft);
}
