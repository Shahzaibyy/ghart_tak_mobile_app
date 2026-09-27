import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/orders/data/sample_orders.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/repositories/order_repository.dart';
import 'package:attock_xpress/features/orders/domain/usecases/list_orders.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'orders_controller.g.dart';

/// Order repository.
@Riverpod(keepAlive: true)
OrderRepository orderRepository(Ref ref) {
  return SampleOrderRepository();
}

/// List-orders use case.
@riverpod
ListOrders listOrders(Ref ref) {
  return ListOrders(ref.watch(orderRepositoryProvider));
}

/// Customer order list.
@riverpod
class OrdersController extends _$OrdersController {
  @override
  Future<List<Order>> build() async {
    final result = await ref.watch(listOrdersProvider).call();
    return switch (result) {
      Success(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }
}
