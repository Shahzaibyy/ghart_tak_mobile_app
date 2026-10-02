import 'dart:async';

import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/features/map/presentation/tracking_map.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';

/// Live order card over the Mapbox tracking map.
class TrackingScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: TrackingMap(orderId: orderId)),
          SafeArea(
            child: Column(
              children: [
                _Bar(title: title),
                const Spacer(),
                _Sheet(title: title, status: status, orderId: orderId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const new({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
      child: Row(
        children: [
          const BackButton(),
          Expanded(
            child: Text(
              'Live order',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const GhAvatar(name: 'Ayesha', size: 36),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const new({
    required this.title,
    required this.status,
    required this.orderId,
  });

  final String title;
  final OrderStatus status;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [AppShadow.floating],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(GhIcons.circle, size: 8, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      orderStatusLabel(status),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Text(orderId, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _headline(status),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                _detail(status, title),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _Stepper(status: status),
              const SizedBox(height: 16),
              const _Rider(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const new({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    const labels = ['Placed', 'Accepted', 'Picked up', 'Delivered'];
    final reached = _reached(status);
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(child: _Step(label: labels[i], done: i <= reached)),
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
    final color = done ? AppColors.primary : AppColors.line;
    return Column(
      children: [
        Icon(
          done ? GhIcons.checkFill : GhIcons.circle,
          size: 16,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Rider extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const GhAvatar(name: 'Tariq Mahmood', online: true),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tariq Mahmood',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                'Honda 125 · 4.9',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _sheet(context, 'Message Tariq. This is a preview.'),
          icon: const Icon(GhIcons.chatCircle),
        ),
        IconButton(
          onPressed: () => _sheet(context, 'Calling Tariq. This is a preview.'),
          icon: const Icon(GhIcons.phone),
        ),
      ],
    );
  }
}

String _headline(OrderStatus status) {
  return switch (status) {
    Placed() => 'Soon',
    Accepted() => '8 min',
    PickedUp() => '12 min',
    Delivered() => 'Done',
    Cancelled() => 'Stopped',
  };
}

String _detail(OrderStatus status, String title) {
  return switch (status) {
    Placed() => 'We are matching $title with a rider',
    Accepted() => 'Rider is heading to $title',
    PickedUp() => 'Estimated at your door by 2:45 PM',
    Delivered() => '$title has arrived',
    Cancelled() => 'This order was cancelled',
  };
}

int _reached(OrderStatus status) {
  return switch (status) {
    Placed() => 0,
    Accepted() => 1,
    PickedUp() => 2,
    Delivered() => 3,
    Cancelled() => 0,
  };
}

void _sheet(BuildContext context, String message) {
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Text(message),
        );
      },
    ),
  );
}
