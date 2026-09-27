import 'dart:async';

import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/features/rider_dashboard/data/sample_rider.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_dashboard_state.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/providers/rider_dashboard_controller.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/widgets/waiting_pulse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rider home: availability, today's numbers, and surge areas.
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        _Header(name: displayName),
        if (state.pendingSyncCount > 0) const _SyncNote(),
        const SizedBox(height: 16),
        _OnlineCard(online: state.isOnline, onToggle: onToggle),
        if (state.phase is Offering) ...[
          const SizedBox(height: 12),
          _IncomingBanner(phase: state.phase, onTap: onOpenTasks),
        ],
        const SizedBox(height: 16),
        const _Stats(),
        const SizedBox(height: 16),
        _Waiting(online: state.isOnline),
        const SizedBox(height: 12),
        const _SafetyRow(),
        const SizedBox(height: 24),
        const _Zones(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const new({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.headlineMedium),
              Text(
                'Attock City',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        GhAvatar(name: name, online: true),
      ],
    );
  }
}

class _SyncNote extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        'Saved on this phone. Will sync when you are back online.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _OnlineCard extends StatelessWidget {
  const new({required this.online, required this.onToggle});

  final bool online;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final title = online ? "You're online" : "You're offline";
    final detail = online
        ? 'Looking for nearby orders in ${previewDesk.listening}'
        : 'Go online when you are ready to ride';
    return _Surface(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      GhIcons.circle,
                      size: 10,
                      color: online ? AppColors.success : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 4),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: online,
            activeThumbColor: AppColors.surface,
            activeTrackColor: AppColors.success,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}

class _IncomingBanner extends StatelessWidget {
  const new({required this.phase, required this.onTap});

  final RiderPhase phase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final seconds = switch (phase) {
      Offering(:final secondsLeft) => secondsLeft,
      _ => 0,
    };
    return _Surface(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        title: const Text('Incoming request'),
        subtitle: Text('$seconds seconds to respond'),
        trailing: const Icon(GhIcons.caretRight),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _Stat(
            label: "Today's",
            value: '1,850',
            caption: 'Rs earned',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _Stat(label: 'Completed', value: '6', caption: 'orders done'),
        ),
        SizedBox(width: 8),
        Expanded(child: _RatingStat()),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RatingStat extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rating', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                previewDesk.rating.toStringAsFixed(2),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 4),
              const Icon(GhIcons.starFill, size: 14, color: AppColors.gold),
            ],
          ),
          Text('Top tier', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const new({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final title = online
        ? 'Waiting for a task near you'
        : 'You are offline';
    final body = online
        ? previewDesk.demand
        : 'Turn online to hear from kitchens nearby';
    return _Surface(
      child: Column(
        children: [
          const SizedBox(height: 12),
          const WaitingPulse(),
          const SizedBox(height: 18),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (online) ...[
            const SizedBox(height: 14),
            const _QueueChip(),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _QueueChip extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          previewDesk.queueNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _SafetyRow extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 5, child: _Checklist()),
        SizedBox(width: 8),
        Expanded(flex: 2, child: _Signal()),
        SizedBox(width: 8),
        Expanded(flex: 2, child: _Sos()),
      ],
    );
  }
}

class _Checklist extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _Surface(
      onTap: () => _sheet(context, const _CheckSheet()),
      child: Row(
        children: [
          const Icon(GhIcons.shieldCheck, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety checklist',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  'Helmet and kit verified',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Signal extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const _Surface(
      child: Column(
        children: [
          Icon(GhIcons.broadcast, size: 18),
          SizedBox(height: 4),
          Text('4G'),
        ],
      ),
    );
  }
}

class _Sos extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _Surface(
      onTap: () => _sheet(context, const _SosSheet()),
      color: AppColors.error.withValues(alpha: 0.08),
      child: const Column(
        children: [
          Icon(GhIcons.siren, color: AppColors.error, size: 18),
          SizedBox(height: 4),
          Text('SOS', style: TextStyle(color: AppColors.error)),
        ],
      ),
    );
  }
}

class _Zones extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Surge heatzones',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              'Attock City',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final zone in previewDesk.zones) ...[
          _ZoneTile(zone: zone),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ZoneTile extends StatelessWidget {
  const new({required this.zone});

  final SurgeZone zone;

  @override
  Widget build(BuildContext context) {
    final icon = zone.iconFood ? GhIcons.storefront : GhIcons.package;
    return _Surface(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(zone.name),
                Text(zone.detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '+${rupees(zone.extraRupees)}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const new({required this.child, this.onTap, this.color});

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = color ?? (dark ? AppColors.darkSurface : AppColors.surface);
    final line = dark ? AppColors.darkLine : AppColors.line;
    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    );
  }
}

class _CheckSheet extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Safety checklist'),
          SizedBox(height: 12),
          Text('Helmet on'),
          SizedBox(height: 8),
          Text('Insulated bag packed'),
          SizedBox(height: 8),
          Text('Phone charged'),
        ],
      ),
    );
  }
}

class _SosSheet extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SOS sent'),
          SizedBox(height: 8),
          Text(
            'Dispatch in Attock City has this alert. '
            'Stay where you are if you can.',
          ),
        ],
      ),
    );
  }
}

void _sheet(BuildContext context, Widget child) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => child,
    ),
  );
}
