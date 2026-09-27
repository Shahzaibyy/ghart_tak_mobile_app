import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/remote_image.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';

/// One row in the order list.
class OrderTile extends StatelessWidget {
  /// Creates a tile that opens tracking.
  const new({required this.order, required this.onTap, super.key});

  /// Order to show.
  final Order order;

  /// Opens tracking for this order.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final line = dark ? AppColors.darkLine : AppColors.line;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _Thumb(url: order.photoUrl),
                const SizedBox(width: 12),
                Expanded(child: _Copy(order: order)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const new({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final photo = url;
    if (photo == null) {
      return const SizedBox(
        width: 72,
        height: 72,
        child: Icon(GhIcons.package),
      );
    }
    return SizedBox(
      width: 72,
      height: 72,
      child: RemoteImage(url: photo, radius: 12),
    );
  }
}

class _Copy extends StatelessWidget {
  const new({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(order.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        _StatusChip(status: order.status),
        const SizedBox(height: 6),
        Text(
          rupees(order.deliveryFee.round()),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const new({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkPeach : AppColors.peach,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          orderStatusLabel(status),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: dark ? AppColors.darkPrimary : AppColors.primaryPressed,
          ),
        ),
      ),
    );
  }
}
