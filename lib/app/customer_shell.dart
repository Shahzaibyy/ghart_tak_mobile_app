import 'dart:async';

import 'package:attock_xpress/features/auth/presentation/providers/auth_controller.dart';
import 'package:attock_xpress/features/orders/presentation/screens/orders_screen.dart';
import 'package:attock_xpress/features/payments/presentation/screens/payments_screen.dart';
import 'package:attock_xpress/features/profile/presentation/screens/profile_screen.dart';
import 'package:attock_xpress/features/tracking/presentation/screens/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer tabs. This is the composition root for customer features.
class CustomerShell extends ConsumerStatefulWidget {
  /// Creates the customer shell.
  const new({super.key});

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _index == 0 ? _orders() : _profile(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _orders() {
    return OrdersScreen(
      onTrack: (orderId) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TrackingScreen(orderId: orderId),
          ),
        );
      },
    );
  }

  Widget _profile() {
    return ProfileScreen(
      onOpenWallet: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PaymentsScreen()),
        );
      },
      onLogout: () {
        unawaited(ref.read(authControllerProvider.notifier).logout());
      },
    );
  }
}
