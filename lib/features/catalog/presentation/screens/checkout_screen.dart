import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
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
  const new({required this.onTrack, required this.walletRupees, super.key});

  /// Opens tracking for the new order.
  final void Function(String orderId, String title) onTrack;

  /// Wallet balance shown on the wallet tile.
  final int walletRupees;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(checkoutControllerProvider);
    final cart = ref.watch(cartControllerProvider);
    ref.listen(checkoutControllerProvider, (previous, next) {
      if (next is CartPlaced) ref.invalidate(ordersControllerProvider);
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Cart & Checkout')),
      body: switch (step) {
        EditingCart() => _Review(cart: cart, walletRupees: walletRupees),
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
  const new({required this.cart, required this.walletRupees});

  final Cart cart;
  final int walletRupees;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final method = ref.watch(payChoiceProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('DELIVERY ADDRESS', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        const Text('House 18, Street 4, Peoples Colony'),
        Text(
          'Estimated delivery in 25-35 mins',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        Text('Order items', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final line in cart.lines) _Line(line: line),
        const SizedBox(height: 12),
        _MoneyRow(label: 'Subtotal', amount: cart.itemTotal),
        _MoneyRow(label: 'Delivery fee', amount: cart.deliveryFee),
        const SizedBox(height: 8),
        _MoneyRow(label: 'Total', amount: cart.total, strong: true),
        const SizedBox(height: 20),
        Text('Payment method', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _PayGrid(
          selected: method,
          walletRupees: walletRupees,
          onSelect: (option) {
            ref.read(payChoiceProvider.notifier).choose(option);
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Bhook Lagi safe guarantee · ${rupees(cart.total)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
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

class _Line extends StatelessWidget {
  const new({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text('${line.quantity}x ${line.item.name}')),
          Text(rupees(line.totalRupees)),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const new({required this.label, required this.amount, this.strong = false});

  final String label;
  final int amount;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(rupees(amount), style: style),
        ],
      ),
    );
  }
}

class _PayGrid extends StatelessWidget {
  const new({
    required this.selected,
    required this.walletRupees,
    required this.onSelect,
  });

  final PaymentMethod selected;
  final int walletRupees;
  final ValueChanged<PaymentMethod> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in availablePaymentMethods)
          _PayTile(
            method: option,
            hint: _hint(option, walletRupees),
            selected: option.runtimeType == selected.runtimeType,
            onTap: () => onSelect(option),
          ),
      ],
    );
  }

  String _hint(PaymentMethod method, int wallet) {
    return switch (method) {
      JazzCash() => 'Mobile wallet',
      EasyPaisa() => 'Instant pay',
      CashOnDelivery() => 'Pay at door',
      WalletPayment() => '${rupees(wallet)} available',
    };
  }
}

class _PayTile extends StatelessWidget {
  const new({
    required this.method,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = selected
        ? AppColors.peach
        : (dark ? AppColors.darkSurface : AppColors.surface);
    final line = selected
        ? AppColors.primary
        : (dark ? AppColors.darkLine : AppColors.line);
    return SizedBox(
      width: 160,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          side: BorderSide(color: line),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.control),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(GhIcons.wallet, size: 18),
                const SizedBox(height: 8),
                Text(
                  paymentMethodLabel(method),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(hint, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
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
