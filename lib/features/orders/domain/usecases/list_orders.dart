import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/repositories/order_repository.dart';

/// Loads the order list.
class ListOrders {
  /// Creates a use case over the repository.
  const new(this._repository);

  final OrderRepository _repository;

  /// Fetches orders.
  Future<Result<List<Order>>> call() => _repository.listOrders();
}
