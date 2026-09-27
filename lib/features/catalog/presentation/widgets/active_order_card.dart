import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';

/// Floating card for the order that is still on the way.
class ActiveOrderCard extends StatelessWidget {
  /// Creates the card. Hidden when [order] is null.
  const new({required this.order, required this.onTap, super.key});

  /// In-progress order, if any.
  final Order? order;

  /// Opens tracking.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final current = order;
    if (current == null) return const SizedBox.shrink();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final accent = dark ? AppColors.darkPrimary : AppColors.primary;
    final muted = dark ? AppColors.darkTextMuted : AppColors.textMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [AppShadow.floating],
        ),
        child: Material(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(GhIcons.moped, color: accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          orderStatusLabel(current.status),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(GhIcons.caretRight, color: muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
