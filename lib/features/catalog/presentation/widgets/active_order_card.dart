import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';

/// Live order strip (Foodpanda-style) shown on Home when an order is active.
class ActiveOrderCard extends StatelessWidget {
  /// Creates the strip. Hidden when [order] is null.
  const new({required this.order, required this.onTap, super.key});

  /// In-progress order, if any.
  final Order? order;

  /// Opens tracking.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final current = order;
    if (current == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: AppColors.tint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.primary),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(GhIcons.moped, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${current.title} is on the way',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        '${_eta(current.status)}. Chai bana lo.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    child: Text(
                      'Track',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF8A6A2E),
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _eta(OrderStatus status) {
  return switch (status) {
    Placed() => 'Finding rider',
    Accepted() => '8 min door',
    PickedUp() => '12 min door',
    Delivered() => 'Arrived',
    Cancelled() => 'Stopped',
  };
}
