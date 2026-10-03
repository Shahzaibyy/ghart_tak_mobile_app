import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/remote_image.dart';
import 'package:attock_xpress/features/catalog/domain/entities/catalog_item.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/cart_controller.dart';
import 'package:attock_xpress/features/catalog/presentation/widgets/item_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Store menu matching v2: hero, chips, sticky categories, cart bar.
class MerchantScreen extends ConsumerStatefulWidget {
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
  ConsumerState<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends ConsumerState<MerchantScreen> {
  var _category = 'Sab ki pasand';
  var _saved = false;

  static const _categories = [
    'Sab ki pasand',
    'Pulao',
    'BBQ',
    'Karahi',
    'Naan',
    'Drinks',
  ];

  @override
  Widget build(BuildContext context) {
    final merchant = widget.merchant;
    final cart = ref.watch(cartControllerProvider);
    final forStore = cart.merchant?.id == merchant.id;
    final count = forStore
        ? cart.lines.fold<int>(0, (sum, line) => sum + line.quantity)
        : 0;
    final total = forStore ? cart.total : 0;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Hero(
                merchant: merchant,
                saved: _saved,
                onBack: () => Navigator.of(context).pop(),
                onSave: () => setState(() => _saved = !_saved),
              )),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              merchant.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          _OpenTag(label: merchant.badge),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Open till 11 PM · ${merchant.blurb} · ${merchant.area}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _InfoChip(
                              icon: GhIcons.starFill,
                              label: '${merchant.rating} (120+)',
                              gold: true,
                            ),
                            _InfoChip(
                              icon: GhIcons.clock,
                              label: merchant.etaSpan,
                            ),
                            _InfoChip(
                              label: '${rupees(merchant.deliveryFeeRupees)} delivery',
                            ),
                            _InfoChip(
                              label: 'Min ${rupees(merchant.minOrderRupees)}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _PromoStrip(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryHeader(
                  categories: _categories,
                  selected: _category,
                  onSelect: (value) => setState(() => _category = value),
                  background: dark ? AppColors.darkBackground : AppColors.background,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, count > 0 ? 100 : 28),
                sliver: SliverList.builder(
                  itemCount: merchant.items.length,
                  itemBuilder: (context, index) {
                    final item = merchant.items[index];
                    final qty = forStore
                        ? cart.lines
                            .where((line) => line.item.id == item.id)
                            .fold<int>(0, (sum, line) => sum + line.quantity)
                        : 0;
                    return _MenuItem(
                      item: item,
                      quantity: qty,
                      highlight: index == 0,
                      onAdd: () => _openOptions(item),
                      onPlus: () {
                        ref
                            .read(cartControllerProvider.notifier)
                            .add(merchant, item);
                      },
                      onMinus: () {
                        ref
                            .read(cartControllerProvider.notifier)
                            .removeOne(item.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (count > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _CartBar(
                count: count,
                total: total,
                onTap: widget.onCheckout,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openOptions(CatalogItem item) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ItemOptionsSheet(
          merchant: widget.merchant,
          item: item,
        );
      },
    );
    if (added == true && mounted) {
      // Cart already updated inside the sheet.
    }
  }
}

class _Hero extends StatelessWidget {
  const new({
    required this.merchant,
    required this.saved,
    required this.onBack,
    required this.onSave,
  });

  final Merchant merchant;
  final bool saved;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemoteImage(url: merchant.photoUrl, radius: 0),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x44000000), Color(0x00000000)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _RoundIcon(icon: GhIcons.caretLeft, onTap: onBack),
                  const Spacer(),
                  _RoundIcon(
                    icon: saved ? GhIcons.heartFill : GhIcons.heart,
                    onTap: onSave,
                    color: saved ? AppColors.primary : null,
                  ),
                  const SizedBox(width: 8),
                  _RoundIcon(icon: GhIcons.broadcast, onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const new({required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _OpenTag extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.success,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const new({required this.label, this.icon, this.gold = false});

  final String label;
  final IconData? icon;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: gold ? AppColors.gold : null,
                ),
                const SizedBox(width: 4),
              ],
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoStrip extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(GhIcons.tag, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pehle 3 orders par delivery free',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Code BHOOKFREE. Checkout par apply ho jata hai.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryHeader extends SliverPersistentHeaderDelegate {
  new({
    required this.categories,
    required this.selected,
    required this.onSelect,
    required this.background,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  final Color background;

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: background,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = categories[index];
          final on = label == selected;
          return GestureDetector(
            onTap: () => onSelect(label),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: on ? AppColors.tint : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: on ? AppColors.primary : AppColors.line,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: on ? FontWeight.w500 : FontWeight.w400,
                    color: on ? AppColors.primary : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryHeader oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.background != background;
  }
}

class _MenuItem extends StatelessWidget {
  const new({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onPlus,
    required this.onMinus,
    this.highlight = false,
  });

  final CatalogItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onPlus;
  final VoidCallback onMinus;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.detail.isEmpty
                          ? 'Fresh from the kitchen.'
                          : item.detail,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          rupees(item.priceRupees),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (highlight) ...[
                          const SizedBox(width: 8),
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
                                'Bestseller',
                                style: TextStyle(
                                  color: Color(0xFF8A6A2E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: RemoteImage(url: item.photoUrl, radius: 14),
                    ),
                    Positioned(
                      right: -6,
                      bottom: -8,
                      child: quantity == 0
                          ? _AddBtn(onTap: onAdd)
                          : _QtyPill(
                              quantity: quantity,
                              onPlus: onPlus,
                              onMinus: onMinus,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBtn extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(GhIcons.plus, size: 18, color: AppColors.text),
        ),
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  const new({
    required this.quantity,
    required this.onPlus,
    required this.onMinus,
  });

  final int quantity;
  final VoidCallback onPlus;
  final VoidCallback onMinus;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
        boxShadow: const [AppShadow.floating],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onMinus,
              child: const Icon(GhIcons.minus, size: 16),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '$quantity',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            InkWell(
              onTap: onPlus,
              child: const Icon(GhIcons.plus, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const new({
    required this.count,
    required this.total,
    required this.onTap,
  });

  final int count;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryDeep,
      borderRadius: BorderRadius.circular(14),
      elevation: 6,
      shadowColor: const Color(0x2E1C1917),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '$count items',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  'View cart · ${rupees(total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
