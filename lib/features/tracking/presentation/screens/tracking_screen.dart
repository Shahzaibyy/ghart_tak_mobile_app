import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/presentation/providers/tracking_providers.dart';
import 'package:attock_xpress/features/tracking/presentation/widgets/rider_marker_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live rider map for one order.
class TrackingScreen extends ConsumerWidget {
  /// Creates the tracking screen for [orderId].
  const new({
    required this.orderId,
    required this.title,
    required this.status,
    super.key,
  });

  /// Order whose rider is being followed.
  final String orderId;

  /// Merchant or errand name.
  final String title;

  /// How far the order has moved.
  final OrderStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(riderLocationProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AsyncValueView<RiderLocation>(
        value: location,
        onRetry: () => ref.invalidate(riderLocationProvider(orderId)),
        data: (fix) => _MapAndCard(location: fix, status: status),
      ),
    );
  }
}

class _MapAndCard extends StatelessWidget {
  const new({required this.location, required this.status});

  final RiderLocation location;
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: RiderMarkerMap(location: location)),
        Align(
          alignment: Alignment.bottomCenter,
          child: _StatusCard(status: status),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const new({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [AppShadow.floating],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    GhIcons.moped,
                    color: dark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    orderStatusLabel(status),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Timeline(status: status),
            ],
          ),
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const new({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final reached = _reached(status);
    return Column(
      children: [
        for (final step in _steps)
          _Step(label: step, done: _steps.indexOf(step) <= reached),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const new({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = done
        ? (dark ? AppColors.darkPrimary : AppColors.primary)
        : (dark ? AppColors.darkTextMuted : AppColors.textMuted);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            done
                ? GhIcons.checkFill
                : GhIcons.circle,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

const List<String> _steps = [
  'Order placed',
  'Rider accepted',
  'On the way',
  'Delivered',
];

int _reached(OrderStatus status) {
  return switch (status) {
    Placed() => 0,
    Accepted() => 1,
    PickedUp() => 2,
    Delivered() => 3,
    Cancelled() => 0,
  };
}
