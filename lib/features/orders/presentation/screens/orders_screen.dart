import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/presentation/providers/orders_controller.dart';
import 'package:attock_xpress/features/orders/presentation/widgets/order_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer order history. Tracking is opened through [onTrack].
class OrdersScreen extends ConsumerWidget {
  /// Creates the orders screen.
  const new({required this.onTrack, super.key});

  /// Called with an order id when the customer opens tracking.
  final ValueChanged<String> onTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: AsyncValueView<List<Order>>(
        value: orders,
        onRetry: () => ref.invalidate(ordersControllerProvider),
        data: (items) => _OrderList(orders: items, onTrack: onTrack),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const new({required this.orders, required this.onTrack});

  final List<Order> orders;
  final ValueChanged<String> onTrack;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders yet'));
    }
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderTile(
          order: order,
          onTap: () => onTrack(order.id),
        );
      },
    );
  }
}
