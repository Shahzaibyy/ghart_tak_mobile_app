import 'dart:async';

import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/features/rider_dashboard/data/sample_rider.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_dashboard_state.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/providers/rider_dashboard_controller.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/widgets/waiting_pulse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rider home matching v2: online toggle, goal bar, KPIs, pulse, surge, SOS.
class RiderHomeScreen extends ConsumerWidget {
  /// Creates the home tab.
  const new({required this.displayName, required this.onOpenTasks, super.key});

  /// Rider's name.
  final String displayName;

  /// Opens the tasks tab.
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(riderDashboardControllerProvider);
    return AsyncValueView<RiderDashboardState>(
      value: dashboard,
      onRetry: () => ref.invalidate(riderDashboardControllerProvider),
      data: (value) => _Home(
        displayName: displayName,
        state: value,
        onToggle: (isOnline) {
          unawaited(
            ref
                .read(riderDashboardControllerProvider.notifier)
                .setOnline(isOnline: isOnline),
          );
        },
        onOpenTasks: onOpenTasks,
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const new({
    required this.displayName,
    required this.state,
    required this.onToggle,
    required this.onOpenTasks,
  });

  final String displayName;
  final RiderDashboardState state;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _Header(
              name: displayName,
              online: state.isOnline,
              onToggle: onToggle,
            ),
            if (state.pendingSyncCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Saved on this phone. Will sync when you are back online.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 14),
            const _GoalCard(),
            const SizedBox(height: 12),
            const _Kpis(),
            const SizedBox(height: 12),
            _Waiting(online: state.isOnline, onOpenTasks: onOpenTasks),
            const SizedBox(height: 12),
            const _ChaiBreak(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Surge zones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  'Fateh Jang',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _SurgeList(),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Material(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(22),
            elevation: 4,
            child: InkWell(
              onTap: () => _sheet(
                context,
                'SOS sent. Dispatch has this alert.',
              ),
              borderRadius: BorderRadius.circular(22),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(GhIcons.shieldCheck, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const new({
    required this.name,
    required this.online,
    required this.onToggle,
  });

  final String name;
  final bool online;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GhAvatar(name: name, online: online),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rider · Fateh Jang',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(name, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        if (online)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'Online',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        Switch(
          value: online,
          activeThumbColor: AppColors.surface,
          activeTrackColor: AppColors.success,
          onChanged: onToggle,
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Goal', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Text(
                  'Rs 1,850 / 2,500',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: const LinearProgressIndicator(
                value: 0.74,
                minHeight: 6,
                color: AppColors.primary,
                backgroundColor: AppColors.line,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '2 more orders for a Rs 150 bonus',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Kpis extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _Kpi(value: '6', label: 'Orders')),
        SizedBox(width: 8),
        Expanded(child: _Kpi(value: '4.92', label: 'Rating')),
        SizedBox(width: 8),
        Expanded(child: _Kpi(value: '1.2x', label: 'Boost')),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const new({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const new({required this.online, required this.onOpenTasks});

  final bool online;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const WaitingPulse(),
            const SizedBox(height: 14),
            Text(
              online
                  ? 'Looking for orders near you'
                  : 'You are offline',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              online
                  ? 'Sabr karo, order aane wala hai'
                  : 'Turn online when you are ready to ride',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (online) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onOpenTasks,
                child: const Text('Open Tasks'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChaiBreak extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chai break', style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    '15 min ke liye requests pause',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _sheet(context, 'Chai break started (preview)'),
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurgeList extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: Column(
        children: [
          for (final zone in previewDesk.zones)
            ListTile(
              leading: const Icon(GhIcons.mapPin, color: AppColors.primary),
              title: Text(zone.name),
              subtitle: Text(zone.detail),
              trailing: Text(
                '+${rupees(zone.extraRupees)}',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void _sheet(BuildContext context, String message) {
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Text(message),
      ),
    ),
  );
}
