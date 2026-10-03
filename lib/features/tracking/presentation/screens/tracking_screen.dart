import 'dart:async';

import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/features/map/presentation/tracking_map.dart';
import 'package:attock_xpress/features/orders/data/demo_merchant_advance.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:attock_xpress/features/orders/presentation/providers/orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live order card over the tracking map (customer).
///
/// Polls `GET /orders/{id}` so kitchen / rider status updates appear.
class TrackingScreen extends ConsumerStatefulWidget {
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

  /// Initial status when the screen opens.
  final OrderStatus status;

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  late OrderStatus _status = widget.status;
  String? _deliveryOtp;
  Timer? _poll;
  var _advancing = false;
  String? _advanceNote;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_refresh());
    });
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final result =
        await ref.read(orderRepositoryProvider).getOrder(widget.orderId);
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        final statusChanged =
            value.status.runtimeType != _status.runtimeType;
        final otpChanged = value.deliveryOtp != _deliveryOtp;
        if (statusChanged || otpChanged) {
          setState(() {
            _status = value.status;
            _deliveryOtp = value.deliveryOtp;
          });
        }
      case Err():
        break;
    }
  }

  Future<void> _advanceMerchant() async {
    setState(() {
      _advancing = true;
      _advanceNote = null;
    });
    final note =
        await const DemoMerchantAdvance().advanceToReady(widget.orderId);
    if (!mounted) return;
    setState(() {
      _advancing = false;
      _advanceNote = note ??
          'Kitchen ready + dispatch requested. '
              'Open the rider app as Usman and check for a live offer.';
    });
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: TrackingMap(orderId: widget.orderId, status: _status),
          ),
          SafeArea(
            child: Column(
              children: [
                _Bar(title: widget.title),
                const Spacer(),
                _Sheet(
                  title: widget.title,
                  status: _status,
                  orderId: widget.orderId,
                  deliveryOtp: _deliveryOtp,
                  advancing: _advancing,
                  advanceNote: _advanceNote,
                  onAdvance: AppConfig.isDemo && _status is Placed
                      ? () => unawaited(_advanceMerchant())
                      : null,
                ),
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
    required this.deliveryOtp,
    required this.advancing,
    required this.advanceNote,
    required this.onAdvance,
  });

  final String title;
  final OrderStatus status;
  final String orderId;
  final String? deliveryOtp;
  final bool advancing;
  final String? advanceNote;
  final VoidCallback? onAdvance;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
    final showRider = status is Accepted || status is PickedUp;
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
                  Text(
                    '#$shortId',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
              if (deliveryOtp != null && deliveryOtp!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Door code for rider: $deliveryOtp',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
              const SizedBox(height: 16),
              _Stepper(status: status),
              if (showRider) ...[
                const SizedBox(height: 16),
                const _Rider(),
              ] else if (status is Placed) ...[
                const SizedBox(height: 16),
                const _FindingRider(),
                if (onAdvance != null) ...[
                  const SizedBox(height: 12),
                  GhButton(
                    label: advancing
                        ? 'Advancing kitchen…'
                        : 'Demo: mark kitchen ready + dispatch',
                    onPressed: advancing ? null : onAdvance,
                  ),
                ],
                if (advanceNote != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    advanceNote!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FindingRider extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tint.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Kitchen must accept → prepare → ready, then dispatch '
                'creates a rider offer. Status refreshes every few seconds.',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
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
        const GhAvatar(name: 'Usman Ali', online: true),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usman Ali',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                'Honda 125 · Fateh Jang',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _sheet(context, 'Message rider. Preview only.'),
          icon: const Icon(GhIcons.chatCircle),
        ),
        IconButton(
          onPressed: () => _sheet(context, 'Calling rider. Preview only.'),
          icon: const Icon(GhIcons.phone),
        ),
      ],
    );
  }
}

String _headline(OrderStatus status) {
  return switch (status) {
    Placed() => 'Finding rider',
    Accepted() => '8 min',
    PickedUp() => '12 min',
    Delivered() => 'Done',
    Cancelled() => 'Stopped',
  };
}

String _detail(OrderStatus status, String title) {
  return switch (status) {
    Placed() => 'Waiting for $title / a nearby rider',
    Accepted() => 'Rider is heading to $title',
    PickedUp() => 'Rider is on the way to your door',
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
