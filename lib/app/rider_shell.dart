import 'dart:async';

import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/providers/rider_dashboard_controller.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/screens/rider_account_screen.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/screens/rider_earnings_screen.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/screens/rider_home_screen.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/screens/rider_navigation_screen.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/screens/rider_tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rider tabs. A live trip covers the tabs until the rider steps back.
class RiderShell extends ConsumerStatefulWidget {
  /// Creates the rider portal for [displayName].
  const new({
    required this.displayName,
    required this.onLogout,
    super.key,
  });

  /// Rider's name.
  final String displayName;

  /// Ends the session.
  final VoidCallback onLogout;

  @override
  ConsumerState<RiderShell> createState() => _RiderShellState();
}

class _RiderShellState extends ConsumerState<RiderShell> {
  var _index = 0;
  var _tripOpen = false;

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(riderDashboardControllerProvider).value?.phase;
    ref.listen(riderDashboardControllerProvider, (previous, next) {
      final wasRiding = previous?.value?.phase is Riding;
      final nowRiding = next.value?.phase is Riding;
      if (!wasRiding && nowRiding) setState(() => _tripOpen = true);
    });
    final riding = phase is Riding ? phase : null;
    if (riding != null && _tripOpen) return _trip(riding);
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            RiderHomeScreen(
              displayName: widget.displayName,
              onOpenTasks: () => setState(() => _index = 1),
            ),
            RiderTasksScreen(onResume: () => setState(() => _tripOpen = true)),
            RiderEarningsScreen(displayName: widget.displayName),
            RiderAccountScreen(
              displayName: widget.displayName,
              onLogout: widget.onLogout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(GhIcons.bicycle), label: 'Home'),
          NavigationDestination(icon: Icon(GhIcons.list), label: 'Tasks'),
          NavigationDestination(icon: Icon(GhIcons.wallet), label: 'Earnings'),
          NavigationDestination(icon: Icon(GhIcons.user), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _trip(Riding riding) {
    return RiderNavigationScreen(
      task: riding.task,
      leg: riding.leg,
      displayName: widget.displayName,
      onBack: () => setState(() {
        _tripOpen = false;
        _index = 1;
      }),
      onPickedUp: () {
        unawaited(
          ref.read(riderDashboardControllerProvider.notifier).markPickedUp(),
        );
      },
      onConfirm: (otp) {
        return ref
            .read(riderDashboardControllerProvider.notifier)
            .confirm(otp);
      },
    );
  }
}
