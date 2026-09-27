import 'dart:async';

import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/widgets/route_sketch.dart';
import 'package:flutter/material.dart';

/// Active trip. Pickup first, then the drop-off and the customer code.
class RiderNavigationScreen extends StatefulWidget {
  /// Creates the navigation screen.
  const new({
    required this.task,
    required this.leg,
    required this.displayName,
    required this.onBack,
    required this.onPickedUp,
    required this.onConfirm,
    super.key,
  });

  /// Trip in progress.
  final RiderTask task;

  /// Pickup or drop-off.
  final TripLeg leg;

  /// Rider name for the avatar.
  final String displayName;

  /// Returns to the tabs without ending the trip.
  final VoidCallback onBack;

  /// Marks the goods collected.
  final VoidCallback onPickedUp;

  /// Confirms delivery with the customer code.
  final Future<void> Function(String otp) onConfirm;

  @override
  State<RiderNavigationScreen> createState() => _RiderNavigationScreenState();
}

class _RiderNavigationScreenState extends State<RiderNavigationScreen> {
  final _otp = TextEditingController();

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropoff = widget.leg is ToDropoff;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: RouteSketch(toDropoff: dropoff)),
          SafeArea(
            child: Column(
              children: [
                _TopBar(name: widget.displayName, onBack: widget.onBack),
                _NextStop(task: widget.task, dropoff: dropoff),
                const Spacer(),
                _Sheet(
                  task: widget.task,
                  dropoff: dropoff,
                  otp: _otp,
                  onPickedUp: widget.onPickedUp,
                  onConfirm: () {
                    unawaited(widget.onConfirm(_otp.text));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const new({required this.name, required this.onBack});

  final String name;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
      child: Row(
        children: [
          IconButton(onPressed: onBack, icon: const Icon(GhIcons.caretLeft)),
          Expanded(
            child: Text(
              'Active trip',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          GhAvatar(name: name, size: 36),
        ],
      ),
    );
  }
}

class _NextStop extends StatelessWidget {
  const new({required this.task, required this.dropoff});

  final RiderTask task;
  final bool dropoff;

  @override
  Widget build(BuildContext context) {
    final title = dropoff ? task.dropoff : task.title;
    final minutes = dropoff ? 12 : 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.text,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [AppShadow.floating],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(GhIcons.navigationArrow, color: AppColors.surface),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT STOP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.peach,
                      ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$minutes min',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const new({
    required this.task,
    required this.dropoff,
    required this.otp,
    required this.onPickedUp,
    required this.onConfirm,
  });

  final RiderTask task;
  final bool dropoff;
  final TextEditingController otp;
  final VoidCallback onPickedUp;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [AppShadow.floating],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Eyebrow(dropoff: dropoff),
            const SizedBox(height: 8),
            Text(
              dropoff ? 'Head to drop-off' : 'Head to pickup',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              dropoff ? task.dropoffDetail : task.pickupDetail,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _Goods(task: task),
            if (dropoff) ...[
              const SizedBox(height: 12),
              TextField(
                controller: otp,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Customer code'),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Call(
                    label: 'Call merchant',
                    onTap: () => _call(context, 'Tandoor House'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Call(
                    label: 'Call customer',
                    onTap: () => _call(context, task.customerName),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GhButton(
              label: dropoff ? 'Confirm delivery' : 'Mark as picked up',
              onPressed: dropoff ? onConfirm : onPickedUp,
            ),
          ],
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const new({required this.dropoff});

  final bool dropoff;

  @override
  Widget build(BuildContext context) {
    final label = dropoff ? 'TASK 2 OF 2 · DROP-OFF' : 'TASK 1 OF 2 · PICKUP';
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text('12:35 PM', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Goods extends StatelessWidget {
  const new({required this.task});

  final RiderTask task;

  @override
  Widget build(BuildContext context) {
    final pay = task.prepaid ? 'PAID' : 'COD';
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(GhIcons.shoppingBag, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('3 items · ${rupees(task.orderAmount)}'),
                  Text(
                    task.items,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              pay,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Call extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

void _call(BuildContext context, String who) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.surface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Text('Calling $who. This preview does not place a real call.'),
        );
      },
    ),
  );
}
