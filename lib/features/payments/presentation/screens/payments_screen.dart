import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/features/payments/domain/entities/payment_method.dart';
import 'package:attock_xpress/features/payments/domain/entities/wallet_balance.dart';
import 'package:attock_xpress/features/payments/presentation/providers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wallet balance and the payment methods a customer can choose.
class PaymentsScreen extends ConsumerWidget {
  /// Creates the payments screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: AsyncValueView<WalletBalance>(
        value: wallet,
        onRetry: () => ref.invalidate(walletControllerProvider),
        data: (balance) => _PaymentBody(balance: balance),
      ),
    );
  }
}

class _PaymentBody extends StatelessWidget {
  const new({required this.balance});

  final WalletBalance balance;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Wallet Rs ${balance.amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        const _MethodList(),
      ],
    );
  }
}

class _MethodList extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final method in availablePaymentMethods)
          ListTile(
            title: Text(paymentMethodLabel(method)),
            leading: const Icon(Icons.payments_outlined),
          ),
      ],
    );
  }
}
