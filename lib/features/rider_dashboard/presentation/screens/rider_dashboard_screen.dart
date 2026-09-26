import 'dart:async';

import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_dashboard_state.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/providers/rider_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rider home. Queued actions show a banner, not a blocking dialog.
class RiderDashboardScreen extends ConsumerWidget {
  /// Creates the rider dashboard.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(riderDashboardControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rider')),
      body: AsyncValueView<RiderDashboardState>(
        value: dashboard,
        onRetry: () => ref.invalidate(riderDashboardControllerProvider),
        data: (value) => _DashboardBody(
          state: value,
          onToggle: (isOnline) {
            unawaited(
              ref
                  .read(riderDashboardControllerProvider.notifier)
                  .setOnline(isOnline: isOnline),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const new({required this.state, required this.onToggle});

  final RiderDashboardState state;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SwitchListTile(
          title: Text(state.isOnline ? 'Online' : 'Offline'),
          value: state.isOnline,
          onChanged: onToggle,
        ),
        if (state.pendingSyncCount > 0) const _SyncBanner(),
      ],
    );
  }
}

class _SyncBanner extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Saved on this phone. Will sync when you are back online.',
    );
  }
}
