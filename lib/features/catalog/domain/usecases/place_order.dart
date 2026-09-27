import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_draft.dart';
import 'package:attock_xpress/features/orders/domain/repositories/order_repository.dart';

/// Turns a basket into an order.
class PlaceOrder {
  /// Creates a use case over the order repository.
  const new(this._orders);

  final OrderRepository _orders;

  /// Places [draft].
  Future<Result<Order>> call(OrderDraft draft) => _orders.placeOrder(draft);
}
