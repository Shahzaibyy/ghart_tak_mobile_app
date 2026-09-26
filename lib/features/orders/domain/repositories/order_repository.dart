import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';

/// Read access to the signed-in customer's orders.
abstract interface class OrderRepository {
  /// Returns the current order list.
  Future<Result<List<Order>>> listOrders();
}
