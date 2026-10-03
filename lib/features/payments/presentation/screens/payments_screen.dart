import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/features/payments/domain/entities/payment_method.dart';
import 'package:attock_xpress/features/payments/domain/entities/wallet_balance.dart';
import 'package:attock_xpress/features/payments/presentation/providers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wallet balance and payment methods (v2 hero + methods + vouchers).
class PaymentsScreen extends ConsumerWidget {
  /// Creates the payments screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: AsyncValueView<WalletBalance>(
          value: wallet,
          onRetry: () => ref.invalidate(walletControllerProvider),
          data: (balance) => _PaymentBody(balance: balance),
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text('Wallet', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryDeep,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aap ka bhook budget',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  rupees(balance.amount.round()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.background,
                          foregroundColor: const Color(0xFF8F3F20),
                        ),
                        onPressed: () {},
                        child: const Text('Add money'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.background,
                          foregroundColor: const Color(0xFF8F3F20),
                        ),
                        onPressed: () {},
                        child: const Text('History'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Payment methods',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _Box(
          child: Column(
            children: [
              const _MethodRow(
                method: CashOnDelivery(),
                caption: 'Default',
                selected: true,
              ),
              const _MethodRow(
                method: WalletPayment(),
                caption: 'Available in wallet',
              ),
              _StubMethod(
                icon: GhIcons.phone,
                title: 'JazzCash',
                caption: '0312 ••• 4821',
              ),
              _StubMethod(
                icon: GhIcons.phone,
                title: 'Easypaisa',
                caption: 'Add account',
                trailing: Icon(GhIcons.plus, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Vouchers', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const _Box(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(GhIcons.tag, color: AppColors.primary),
            title: Text('BHOOKFREE'),
            subtitle: Text('Free delivery, 3 orders left'),
            trailing: _Tag(label: 'Active', ok: true),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Recent activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const _Box(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(GhIcons.plus, color: AppColors.primary),
                title: Text('Top up via JazzCash'),
                subtitle: Text('1 Oct'),
                trailing: Text(
                  '+Rs 500',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(GhIcons.receipt, color: AppColors.primary),
                title: Text('Order #A7F3'),
                subtitle: Text('29 Sep'),
                trailing: Text(
                  '-Rs 640',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MethodRow extends StatelessWidget {
  const new({
    required this.method,
    required this.caption,
    this.selected = false,
  });

  final PaymentMethod method;
  final String caption;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(GhIcons.wallet, color: AppColors.primary),
      title: Text(paymentMethodLabel(method)),
      subtitle: Text(caption),
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.primary : AppColors.line,
      ),
    );
  }
}

class _StubMethod extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.caption,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String caption;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(caption),
      trailing: trailing ??
          const Icon(Icons.radio_button_off, color: AppColors.line),
    );
  }
}

class _Box extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _Tag extends StatelessWidget {
  const new({required this.label, required this.ok});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ok
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.line,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: TextStyle(
            color: ok ? AppColors.success : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
