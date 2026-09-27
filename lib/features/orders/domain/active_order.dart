import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';

/// The order still moving through delivery, if there is one.
Order? activeOrder(List<Order> orders) {
  for (final order in orders) {
    final moving = switch (order.status) {
      Placed() || Accepted() || PickedUp() => true,
      Delivered() || Cancelled() => false,
    };
    if (moving) return order;
  }
  return null;
}
