import 'dart:async';

import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_controller.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/domain/order_type_for.dart';
import 'package:attock_xpress/features/catalog/presentation/screens/checkout_screen.dart';
import 'package:attock_xpress/features/catalog/presentation/screens/errand_screen.dart';
import 'package:attock_xpress/features/catalog/presentation/screens/home_screen.dart';
import 'package:attock_xpress/features/catalog/presentation/screens/merchant_screen.dart';
import 'package:attock_xpress/features/orders/domain/active_order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_type.dart';
import 'package:attock_xpress/features/orders/presentation/providers/orders_controller.dart';
import 'package:attock_xpress/features/orders/presentation/screens/orders_screen.dart';
import 'package:attock_xpress/features/payments/presentation/providers/wallet_controller.dart';
import 'package:attock_xpress/features/payments/presentation/screens/payments_screen.dart';
import 'package:attock_xpress/features/profile/presentation/screens/profile_screen.dart';
import 'package:attock_xpress/features/tracking/presentation/screens/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer tabs. This is the composition root for customer features.
class CustomerShell extends ConsumerStatefulWidget {
  /// Creates the customer shell for [displayName].
  const new({required this.displayName, super.key});

  /// Name shown on the home header.
  final String displayName;

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersControllerProvider).value ?? const [];
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _home(activeOrder(orders)),
          _orders(),
          const PaymentsScreen(),
          _profile(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(GhIcons.house), label: 'Home'),
          NavigationDestination(icon: Icon(GhIcons.receipt), label: 'Orders'),
          NavigationDestination(icon: Icon(GhIcons.wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(GhIcons.user), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _home(Order? active) {
    return HomeScreen(
      displayName: widget.displayName,
      active: active,
      onOpenMerchant: _openMerchant,
      onTrack: () {
        if (active == null) return;
        _openTracking(active);
      },
      onCompose: _openComposer,
    );
  }

  Widget _orders() {
    return OrdersScreen(onTrack: _openTracking);
  }

  Widget _profile() {
    return ProfileScreen(
      onOpenWallet: () => setState(() => _index = 2),
      onLogout: () {
        unawaited(ref.read(authControllerProvider.notifier).logout());
      },
    );
  }

  void _openMerchant(Merchant merchant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MerchantScreen(
          merchant: merchant,
          onCheckout: _openCheckout,
        ),
      ),
    );
  }

  void _openCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(
          onTrack: _openFreshTracking,
          walletRupees: _walletRupees(),
        ),
      ),
    );
  }

  void _openComposer(FeedCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ErrandScreen(
          category: category,
          onPlaced: (orderId, title) {
            ref.invalidate(ordersControllerProvider);
            Navigator.of(context).pop();
            _openTracking(
              Order(
                id: orderId,
                title: title,
                type: orderTypeFor(category),
                status: const Placed(),
                deliveryFee: 120,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openFreshTracking(String orderId, String title) {
    _openTracking(
      Order(
        id: orderId,
        title: title,
        type: const FoodOrder(),
        status: const Placed(),
        deliveryFee: 80,
      ),
    );
  }

  int _walletRupees() {
    final amount = ref.read(walletControllerProvider).value?.amount;
    return amount?.round() ?? 1240;
  }

  void _openTracking(Order order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrackingScreen(
          orderId: order.id,
          title: order.title,
          status: order.status,
        ),
      ),
    );
  }
}
