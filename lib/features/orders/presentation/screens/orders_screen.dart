import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/core/widgets/gh_empty.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/presentation/providers/orders_controller.dart';
import 'package:attock_xpress/features/orders/presentation/widgets/order_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer order history. Tracking is opened through [onTrack].
class OrdersScreen extends ConsumerWidget {
  /// Creates the orders screen.
  const new({required this.onTrack, super.key});

  /// Called when the customer opens tracking.
  final ValueChanged<Order> onTrack;

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
  final ValueChanged<Order> onTrack;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const GhEmpty(
        title: 'No orders yet',
        body: 'When you order, it will show up here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderTile(order: order, onTap: () => onTrack(order));
      },
    );
  }
}
