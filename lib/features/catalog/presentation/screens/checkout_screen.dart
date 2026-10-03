import 'dart:async';

import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/failure_view.dart';
import 'package:attock_xpress/core/widgets/gh_skeleton.dart';
import 'package:attock_xpress/features/catalog/domain/entities/cart.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/cart_controller.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/checkout_controller.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_quote.dart';
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
      body: switch (step) {
        EditingCart() => _Review(
          cart: cart,
          walletRupees: walletRupees,
        ),
        SubmittingCart() => const SafeArea(child: GhSkeletonList()),
        CartFailed(:final failure) => SafeArea(
          child: FailureView(
            failure: failure,
            onRetry: () {
              ref.read(checkoutControllerProvider.notifier).editAgain();
            },
          ),
        ),
        CartPlaced(:final orderId, :final title) => _Placed(
          title: title,
          orderId: orderId,
          onTrack: () => onTrack(orderId, title),
          onHome: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      },
    );
  }
}

class _Review extends ConsumerStatefulWidget {
  const new({required this.cart, required this.walletRupees});

  final Cart cart;
  final int walletRupees;

  @override
  ConsumerState<_Review> createState() => _ReviewState();
}

class _ReviewState extends ConsumerState<_Review> {
  var _schedule = false;
  var _instruction = 2; // Call karo
  var _tip = 50;
  var _voucherApplied = true;
  final _landmark = TextEditingController();
  final _riderNote = TextEditingController();

  static const _tips = [0, 20, 50, 100];
  static const _instructions = [
    'Bell bajao',
    'Gate pe chhor do',
    'Call karo',
  ];

  @override
  void dispose() {
    _landmark.dispose();
    _riderNote.dispose();
    super.dispose();
  }

  int _deliveryFee(OrderQuote? quote) {
    if (widget.cart.isEmpty) return 0;
    final server = quote?.deliveryFeeRupees ?? widget.cart.deliveryFee;
    return _voucherApplied ? 0 : server;
  }

  int _itemTotal(OrderQuote? quote) {
    return quote?.itemTotalRupees ?? widget.cart.itemTotal;
  }

  int _displayTotal(OrderQuote? quote) {
    // Server `total` already includes delivery; tip stays local UI add-on.
    final base = quote != null
        ? (_voucherApplied
            ? quote.itemTotalRupees
            : quote.totalRupees)
        : widget.cart.itemTotal + _deliveryFee(null);
    return base + _tip;
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final method = ref.watch(payChoiceProvider);
    final quoteAsync = ref.watch(checkoutQuoteProvider);
    final quote = quoteAsync.asData?.value;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final line = dark ? AppColors.darkLine : AppColors.line;
    final muted = dark ? AppColors.darkTextMuted : AppColors.textMuted;
    final storeName = cart.merchant?.name ?? 'Store';
    final deliveryFee = _deliveryFee(quote);
    final itemTotal = _itemTotal(quote);
    final displayTotal = _displayTotal(quote);
    final serverDelivery = quote?.deliveryFeeRupees ?? cart.deliveryFee;

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(GhIcons.caretLeft),
                  style: IconButton.styleFrom(
                    backgroundColor: surface,
                    side: BorderSide(color: line),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Checkout',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        storeName,
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _Box(
                surface: surface,
                line: line,
                child: Column(
                  children: [
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.tint,
                            borderRadius:
                                BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: line),
                          ),
                          child: const SizedBox(
                            width: 64,
                            height: 64,
                            child: Icon(
                              GhIcons.mapPin,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Home',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Near Bismillah Restaurant',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(GhIcons.caretRight, size: 18, color: muted),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _landmark,
                      decoration: InputDecoration(
                        hintText: 'Landmark: masjid ke saamne',
                        prefixIcon: const Icon(GhIcons.mapPin, size: 18),
                        filled: true,
                        fillColor: surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                          borderSide: BorderSide(color: line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                          borderSide: BorderSide(color: line),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Box(
                surface: surface,
                line: line,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Seg(
                      labels: const ['Standard', 'Schedule'],
                      selected: _schedule ? 1 : 0,
                      onSelect: (i) => setState(() => _schedule = i == 1),
                      line: line,
                      surface: surface,
                      muted: muted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _schedule
                          ? 'Pick a slot at checkout later'
                          : 'Arrives in ${cart.merchant?.etaSpan ?? '20 to 30 min'}',
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Delivery instructions',
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _instructions.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final on = _instruction == i;
                          return GestureDetector(
                            onTap: () => setState(() => _instruction = i),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: on ? AppColors.tint : surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: on ? AppColors.primary : line,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                child: Text(
                                  _instructions[i],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        on ? FontWeight.w500 : FontWeight.w400,
                                    color: on ? AppColors.primary : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _riderNote,
                      decoration: InputDecoration(
                        hintText: 'Rider ke liye note',
                        prefixIcon: const Icon(GhIcons.fileText, size: 18),
                        filled: true,
                        fillColor: surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                          borderSide: BorderSide(color: line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                          borderSide: BorderSide(color: line),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Payment', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _Box(
                surface: surface,
                line: line,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    _PayRow(
                      icon: GhIcons.wallet,
                      title: 'Cash on delivery',
                      subtitle: 'Rider ko cash dein',
                      selected: method is CashOnDelivery,
                      onTap: () {
                        ref
                            .read(payChoiceProvider.notifier)
                            .choose(const CashOnDelivery());
                      },
                      line: line,
                      muted: muted,
                    ),
                    _PayRow(
                      icon: GhIcons.wallet,
                      title: 'Wallet',
                      subtitle: '${rupees(widget.walletRupees)} available',
                      selected: method is WalletPayment,
                      onTap: () {
                        ref
                            .read(payChoiceProvider.notifier)
                            .choose(const WalletPayment());
                      },
                      line: line,
                      muted: muted,
                    ),
                    _PayRow(
                      icon: GhIcons.phone,
                      title: 'JazzCash',
                      subtitle: '0312 ••• 4821',
                      selected: method is JazzCash,
                      onTap: () {
                        ref
                            .read(payChoiceProvider.notifier)
                            .choose(const JazzCash());
                      },
                      line: line,
                      muted: muted,
                      last: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Box(
                surface: surface,
                line: line,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: InkWell(
                  onTap: () =>
                      setState(() => _voucherApplied = !_voucherApplied),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(GhIcons.tag, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BHOOKFREE'),
                              Text(
                                _voucherApplied
                                    ? 'Free delivery applied'
                                    : 'Tap to apply free delivery',
                                style: TextStyle(fontSize: 12, color: muted),
                              ),
                            ],
                          ),
                        ),
                        if (_voucherApplied)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              child: Text(
                                '-Rs 80',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Box(
                surface: surface,
                line: line,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rider ko chai pilao (optional tip)',
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                    const SizedBox(height: 8),
                    _Seg(
                      labels: [
                        for (final tip in _tips) rupees(tip),
                      ],
                      selected: _tips.indexOf(_tip).clamp(0, _tips.length - 1),
                      onSelect: (i) => setState(() => _tip = _tips[i]),
                      line: line,
                      surface: surface,
                      muted: muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Box(
                surface: surface,
                line: line,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (quote?.approximate == true) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Estimated fees (route approximate)',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                    if (quoteAsync.isLoading) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Refreshing live quote…',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                    const SizedBox(height: 8),
                    for (final lineItem in cart.lines)
                      _SumRow(
                        label:
                            '${lineItem.quantity}x ${lineItem.item.name}',
                        value: rupees(lineItem.totalRupees),
                        muted: muted,
                      ),
                    _SumRow(
                      label: 'Subtotal',
                      value: rupees(itemTotal),
                      muted: muted,
                    ),
                    _SumRow(
                      label: 'Delivery fee',
                      valueWidget: _voucherApplied && serverDelivery > 0
                          ? Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${rupees(serverDelivery)} ',
                                    style: TextStyle(
                                      color: muted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const TextSpan(text: 'Rs 0'),
                                ],
                              ),
                            )
                          : null,
                      value: _voucherApplied
                          ? null
                          : rupees(deliveryFee),
                      muted: muted,
                    ),
                    _SumRow(
                      label: 'Rider tip',
                      value: rupees(_tip),
                      muted: muted,
                    ),
                    Divider(color: line, height: 20),
                    _SumRow(
                      label: 'Total',
                      value: rupees(displayTotal),
                      muted: muted,
                      strong: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Koi hidden charges nahi. Jo likha hai, wohi dena hai.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: muted),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: surface,
            border: Border(top: BorderSide(color: line)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  Text(
                    '${paymentMethodLabel(method)} · '
                    '${rupees(displayTotal)} '
                    '${method is CashOnDelivery ? 'rider ko dein' : ''}',
                    style: TextStyle(fontSize: 13, color: muted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: cart.isEmpty
                          ? null
                          : () {
                              unawaited(
                                ref
                                    .read(checkoutControllerProvider.notifier)
                                    .submit(),
                              );
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.text,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                        ),
                      ),
                      child: Text(
                        'Place order · ${rupees(displayTotal)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Placed extends StatelessWidget {
  const new({
    required this.title,
    required this.orderId,
    required this.onTrack,
    required this.onHome,
  });

  final String title;
  final String orderId;
  final VoidCallback onTrack;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final line = dark ? AppColors.darkLine : AppColors.line;
    final muted = dark ? AppColors.darkTextMuted : AppColors.textMuted;
    final shortId = orderId.length > 4
        ? orderId.substring(orderId.length - 4).toUpperCase()
        : orderId.toUpperCase();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            children: [
              const GhDuotone(
                front: GhIcons.checkCircleFront,
                back: GhIcons.checkCircleBack,
                size: 84,
                color: AppColors.success,
              ),
              const SizedBox(height: 16),
              Text(
                'Order place ho gaya!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$title ne order dekh liya hai. Ab bas thori si sabr.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: muted, height: 1.4),
              ),
              const SizedBox(height: 20),
              _Box(
                surface: surface,
                line: line,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Order #$shortId',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            child: Text(
                              'Preparing',
                              style: TextStyle(
                                color: Color(0xFF8A6A2E),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (var i = 0; i < 4; i++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: i == 0
                                      ? AppColors.primary
                                      : line,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const SizedBox(height: 4),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          '20 to 30 min',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          'ETA soon',
                          style: TextStyle(fontSize: 13, color: muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Box(
                surface: surface,
                line: line,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Pay on delivery', style: TextStyle(color: muted)),
                        const Spacer(),
                        const Text(
                          'See tracking',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Deliver to', style: TextStyle(color: muted)),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            DemoConfig.demoDropAddress,
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.tint,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(GhIcons.moped, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pet mein chuhay?',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Bas 25 min aur. Rider dhoond rahe hain.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: surface,
            border: Border(top: BorderSide(color: line)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: onTrack,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.text,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                        ),
                      ),
                      child: const Text(
                        'Track order',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: onHome,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: dark
                            ? AppColors.darkText
                            : AppColors.text,
                        side: BorderSide(color: line),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                        ),
                      ),
                      child: const Text(
                        'Back to home',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const new({
    required this.surface,
    required this.line,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Color surface;
  final Color line;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: line),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _Seg extends StatelessWidget {
  const new({
    required this.labels,
    required this.selected,
    required this.onSelect,
    required this.line,
    required this.surface,
    required this.muted,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;
  final Color line;
  final Color surface;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: line,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: selected == i ? surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected == i ? null : muted,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.line,
    required this.muted,
    this.last = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Color line;
  final Color muted;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: line)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15)),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : line,
                    width: selected ? 6 : 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SumRow extends StatelessWidget {
  const new({
    required this.label,
    required this.muted,
    this.value,
    this.valueWidget,
    this.strong = false,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color muted;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: strong ? 17 : 14,
                fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
                color: strong ? null : null,
              ),
            ),
          ),
          if (valueWidget != null)
            DefaultTextStyle(
              style: TextStyle(
                fontSize: strong ? 17 : 14,
                fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              child: valueWidget!,
            )
          else
            Text(
              value ?? '',
              style: TextStyle(
                fontSize: strong ? 17 : 14,
                fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
