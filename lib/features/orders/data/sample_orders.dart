import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_draft.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_type.dart';
import 'package:attock_xpress/features/orders/domain/repositories/order_repository.dart';

const _tandoorPhoto =
    'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a'
    '?auto=format&fit=crop&w=1200&q=70';

/// Orders shown before the API is available, so the UI can be reviewed.
class SampleOrderRepository implements OrderRepository {
  /// Creates a repository seeded with Attock sample orders.
  new() : _orders = List.of(_seed);

  final List<Order> _orders;

  @override
  Future<Result<List<Order>>> listOrders() async => Success(List.of(_orders));

  @override
  Future<Result<Order>> placeOrder(OrderDraft draft) async {
    final order = Order(
      id: 'ord-${_orders.length + 1}',
      title: draft.title,
      type: draft.type,
      status: const Placed(),
      deliveryFee: draft.deliveryFee.toDouble(),
      photoUrl: draft.photoUrl,
    );
    _orders.insert(0, order);
    return Success(order);
  }
}

final List<Order> _seed = [
  const Order(
    id: 'ord-live',
    title: 'Tandoor House',
    type: FoodOrder(),
    status: PickedUp(),
    deliveryFee: 80,
    photoUrl: _tandoorPhoto,
  ),
  const Order(
    id: 'ord-done',
    title: 'Hazro Mart',
    type: MartOrder(),
    status: Delivered(),
    deliveryFee: 60,
    photoUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=1200&q=70',
  ),
];
