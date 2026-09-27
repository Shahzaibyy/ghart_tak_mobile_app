import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/failure_view.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/core/widgets/gh_skeleton.dart';
import 'package:attock_xpress/features/catalog/domain/entities/cart.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/cart_controller.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/checkout_controller.dart';
import 'package:attock_xpress/features/orders/presentation/providers/orders_controller.dart';
import 'package:attock_xpress/features/payments/domain/entities/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Basket review, payment choice, and the placed confirmation.
class CheckoutScreen extends ConsumerWidget {
  /// Creates checkout.
  const new({required this.onTrack, super.key});

  /// Opens tracking for the new order.
  final void Function(String orderId, String title) onTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(checkoutControllerProvider);
    final cart = ref.watch(cartControllerProvider);
    ref.listen(checkoutControllerProvider, (previous, next) {
      if (next is CartPlaced) ref.invalidate(ordersControllerProvider);
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: switch (step) {
        EditingCart() => _Review(cart: cart),
        SubmittingCart() => const GhSkeletonList(),
        CartFailed(:final failure) => FailureView(
          failure: failure,
          onRetry: () {
            ref.read(checkoutControllerProvider.notifier).editAgain();
          },
        ),
        CartPlaced(:final orderId, :final title) => _Placed(
          title: title,
          onTrack: () => onTrack(orderId, title),
        ),
      },
    );
  }
}

class _Review extends ConsumerWidget {
  const new({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final method = ref.watch(payChoiceProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          cart.merchant?.name ?? 'Basket',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        for (final line in cart.lines)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(line.item.name),
            subtitle: Text('${line.quantity} · ${rupees(line.totalRupees)}'),
          ),
        const SizedBox(height: 8),
        Text('Delivery ${rupees(cart.deliveryFee)}'),
        const SizedBox(height: 20),
        Text('Pay with', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final option in availablePaymentMethods)
          _PayRow(
            method: option,
            selected: option.runtimeType == method.runtimeType,
            onTap: () => ref.read(payChoiceProvider.notifier).choose(option),
          ),
        const SizedBox(height: 24),
        GhButton(
          label: 'Place order · ${rupees(cart.total)}',
          onPressed: cart.isEmpty
              ? null
              : () => ref.read(checkoutControllerProvider.notifier).submit(),
        ),
      ],
    );
  }
}

class _PayRow extends StatelessWidget {
  const new({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(
        selected
            ? GhIcons.checkFill
            : GhIcons.circle,
      ),
      title: Text(paymentMethodLabel(method)),
    );
  }
}

class _Placed extends StatelessWidget {
  const new({required this.title, required this.onTrack});

  final String title;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GhDuotone(
            front: GhIcons.checkCircleFront,
            back: GhIcons.checkCircleBack,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Order placed',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '$title is confirmed. We are finding a rider nearby.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          GhButton(label: 'Track order', onPressed: onTrack),
        ],
      ),
    );
  }
}
