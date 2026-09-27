import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/core/widgets/remote_image.dart';
import 'package:attock_xpress/features/catalog/domain/entities/catalog_item.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Store menu. Adding an item stays on this screen.
class MerchantScreen extends ConsumerWidget {
  /// Creates the store page.
  const new({
    required this.merchant,
    required this.onCheckout,
    super.key,
  });

  /// Store being viewed.
  final Merchant merchant;

  /// Opens checkout.
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final count = cart.merchant?.id == merchant.id ? cart.lines.length : 0;
    return Scaffold(
      appBar: AppBar(title: Text(merchant.name)),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        itemCount: merchant.items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _Hero(merchant: merchant);
          final item = merchant.items[index - 1];
          return _ItemRow(
            item: item,
            onAdd: () {
              ref.read(cartControllerProvider.notifier).add(merchant, item);
            },
          );
        },
      ),
      bottomNavigationBar: count == 0
          ? null
          : _BasketBar(total: cart.total, onCheckout: onCheckout),
    );
  }
}

class _Hero extends StatelessWidget {
  const new({required this.merchant});

  final Merchant merchant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: RemoteImage(url: merchant.photoUrl),
        ),
        const SizedBox(height: 16),
        Text(
          '${merchant.area} · ${merchant.etaMinutes} min',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const new({required this.item, required this.onAdd});

  final CatalogItem item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: RemoteImage(url: item.photoUrl, radius: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.labelLarge),
                Text(item.detail, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(rupees(item.priceRupees)),
              ],
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(GhIcons.plus, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _BasketBar extends StatelessWidget {
  const new({required this.total, required this.onCheckout});

  final int total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        boxShadow: const [AppShadow.floating],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: GhButton(
            label: 'Checkout · ${rupees(total)}',
            onPressed: onCheckout,
          ),
        ),
      ),
    );
  }
}
