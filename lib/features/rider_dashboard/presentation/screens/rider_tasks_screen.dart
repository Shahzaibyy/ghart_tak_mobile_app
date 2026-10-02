import 'dart:async';

import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_dashboard_state.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/providers/rider_dashboard_controller.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/screens/rider_offer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tasks tab: a ready state, the incoming offer, or a way back into the trip.
class RiderTasksScreen extends ConsumerWidget {
  /// Creates the tasks tab.
  const new({required this.onResume, super.key});

  /// Reopens the active trip.
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(riderDashboardControllerProvider);
    return AsyncValueView<RiderDashboardState>(
      value: dashboard,
      onRetry: () => ref.invalidate(riderDashboardControllerProvider),
      data: (value) => _Body(state: value, onResume: onResume),
    );
  }
}

class _Body extends ConsumerWidget {
  const new({required this.state, required this.onResume});

  final RiderDashboardState state;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(riderDashboardControllerProvider.notifier);
    return switch (state.phase) {
      Waiting() => _Ready(
        online: state.isOnline,
        hint: state.hint,
        onRequest: () => unawaited(notifier.presentOffer()),
      ),
      Offering(:final task, :final secondsLeft) => RiderOfferScreen(
        task: task,
        secondsLeft: secondsLeft,
        onDecline: () => unawaited(notifier.decline()),
        onAccept: () => unawaited(notifier.accept()),
      ),
      OfferExpired(:final task) => RiderOfferScreen(
        task: task,
        secondsLeft: null,
        onDecline: () => unawaited(notifier.decline()),
        onAccept: () => unawaited(notifier.decline()),
      ),
      Riding(:final task) => _Resume(task: task, onResume: onResume),
    };
  }
}

class _Ready extends StatelessWidget {
  const new({
    required this.online,
    required this.onRequest,
    this.hint,
  });

  final bool online;
  final VoidCallback onRequest;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final title = online ? 'Listening for live offers' : 'You are offline';
    final body = online
        ? 'Offers come from GET /riders/offers after a real customer order is '
            'ready_for_pickup and dispatched. This is not the old sample '
            '“Tandoor House” card.'
        : 'Go online from Home before you take a task.';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Tasks', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(body, style: Theme.of(context).textTheme.bodySmall),
        if (hint != null) ...[
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.peach.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(hint!, style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        ],
        const SizedBox(height: 20),
        GhButton(
          label: 'Check for live offer',
          onPressed: online ? onRequest : null,
        ),
      ],
    );
  }
}

class _Resume extends StatelessWidget {
  const new({required this.task, required this.onResume});

  final RiderTask task;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Tasks', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text(task.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '${task.pickupDetail} → ${task.dropoffDetail}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Order #${task.orderCode}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          rupees(task.payoutRupees),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.success,
              ),
        ),
        const SizedBox(height: 20),
        GhButton(label: 'Open navigation', onPressed: onResume),
      ],
    );
  }
}
