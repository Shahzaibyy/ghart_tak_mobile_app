import 'package:attock_xpress/core/widgets/remote_image.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_type.dart';
import 'package:flutter/material.dart';

/// One row in the order list.
class OrderTile extends StatelessWidget {
  /// Creates a tile that calls [onTap] with the order id.
  const new({required this.order, required this.onTap, super.key});

  /// Order to show.
  final Order order;

  /// Opens tracking for this order.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _Leading(url: order.photoUrl),
      title: Text(orderTypeLabel(order.type)),
      subtitle: Text(orderStatusLabel(order.status)),
      trailing: Text('Rs ${order.deliveryFee.toStringAsFixed(0)}'),
      onTap: onTap,
    );
  }
}

class _Leading extends StatelessWidget {
  const new({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final photo = url;
    if (photo == null) return const Icon(Icons.storefront);
    return RemoteImage(url: photo);
  }
}
