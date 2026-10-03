import 'dart:async';

import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/core/widgets/gh_empty.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/catalog_controller.dart';
import 'package:attock_xpress/features/catalog/presentation/widgets/active_order_card.dart';
import 'package:attock_xpress/features/catalog/presentation/widgets/merchant_card.dart';
import 'package:attock_xpress/features/catalog/presentation/widgets/zone_merchants_map.dart';
import 'package:attock_xpress/features/map/presentation/address_picker_page.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _homeAddress = 'Near Bismillah Restaurant, Fateh Jang';

/// Customer home. Address, categories, map, and featured merchants.
class HomeScreen extends ConsumerWidget {
  /// Creates the home feed.
  const new({
    required this.displayName,
    required this.active,
    required this.onOpenMerchant,
    required this.onTrack,
    required this.onCompose,
    super.key,
  });

  /// Signed-in name.
  final String displayName;

  /// Order still on the way.
  final Order? active;

  /// Opens a store.
  final ValueChanged<Merchant> onOpenMerchant;

  /// Opens tracking for the live order.
  final VoidCallback onTrack;

  /// Opens the parcel or errand composer.
  final ValueChanged<FeedCategory> onCompose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(catalogControllerProvider);
    return AsyncValueView<CatalogFeed>(
      value: feed,
      onRetry: () => ref.invalidate(catalogControllerProvider),
      data: (value) => _Feed(
        displayName: displayName,
        feed: value,
        active: active,
        onTrack: onTrack,
        onOpenMerchant: onOpenMerchant,
        onCategory: (category) => _choose(ref, category),
        onQuickOrder: () => onCompose(const Errands()),
        onSearch: (query) {
          ref.read(catalogControllerProvider.notifier).search(query);
        },
      ),
    );
  }

  void _choose(WidgetRef ref, FeedCategory category) {
    switch (category) {
      case Parcels() || Errands():
        onCompose(category);
      case Restaurants() || Marts() || Pharmacies():
        ref.read(catalogControllerProvider.notifier).select(category);
    }
  }
}

class _Feed extends StatelessWidget {
  const new({
    required this.displayName,
    required this.feed,
    required this.active,
    required this.onTrack,
    required this.onOpenMerchant,
    required this.onCategory,
    required this.onQuickOrder,
    required this.onSearch,
  });

  final String displayName;
  final CatalogFeed feed;
  final Order? active;
  final VoidCallback onTrack;
  final ValueChanged<Merchant> onOpenMerchant;
  final ValueChanged<FeedCategory> onCategory;
  final VoidCallback onQuickOrder;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _Header(
                displayName: displayName,
                feed: feed,
                active: active,
                onTrack: onTrack,
                onCategory: onCategory,
                onQuickOrder: onQuickOrder,
                onSearch: onSearch,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            sliver: SliverToBoxAdapter(
              child: ZoneMerchantsMap(merchants: feed.merchants),
            ),
          ),
          _MerchantSliver(feed: feed, onOpenMerchant: onOpenMerchant),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 40),
            sliver: SliverToBoxAdapter(child: _Promise()),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const new({
    required this.displayName,
    required this.feed,
    required this.active,
    required this.onTrack,
    required this.onCategory,
    required this.onQuickOrder,
    required this.onSearch,
  });

  final String displayName;
  final CatalogFeed feed;
  final Order? active;
  final VoidCallback onTrack;
  final ValueChanged<FeedCategory> onCategory;
  final VoidCallback onQuickOrder;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Top(name: displayName),
        const SizedBox(height: 12),
        const _Address(),
        const SizedBox(height: 10),
        _SearchField(onSearch: onSearch),
        const SizedBox(height: 16),
        _Explore(
          selected: feed.category,
          onQuickOrder: onQuickOrder,
          onCategory: onCategory,
        ),
        const SizedBox(height: 14),
        const _Promo(),
        if (active != null) ...[
          const SizedBox(height: 14),
          ActiveOrderCard(order: active, onTap: onTrack),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Featured merchants',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => onCategory(const Restaurants()),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('See all'),
            ),
          ],
        ),
        Text(
          'Kitchens, marts, and pharmacies around Attock',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Top extends StatelessWidget {
  const new({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    GhIcons.truck,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text('DELIVER TO', style: muted),
                ],
              ),
              const SizedBox(height: 2),
              Text('Home', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        _RoundIcon(
          icon: GhIcons.bell,
          onTap: () => _note(context, 'No new alerts'),
        ),
        const SizedBox(width: 8),
        GhAvatar(name: name),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const new({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? AppColors.darkSurface : AppColors.surface,
      shape: CircleBorder(
        side: BorderSide(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _Address extends StatefulWidget {
  const new();

  @override
  State<_Address> createState() => _AddressState();
}

class _AddressState extends State<_Address> {
  String _label = _homeAddress;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        side: BorderSide(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: InkWell(
        onTap: () => unawaited(_pick(context)),
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              const Icon(GhIcons.mapPin, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(
                GhIcons.caretRight,
                size: 16,
                color: dark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final result = await Navigator.of(context).push<PickedAddress>(
      MaterialPageRoute(
        builder: (_) => AddressPickerPage(initialLabel: _label),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _label = result.label);
  }
}

class _SearchField extends StatefulWidget {
  const new({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onSearch,
      decoration: const InputDecoration(
        hintText: 'Search kitchens or marts',
        prefixIcon: Icon(GhIcons.magnifyingGlass),
        suffixIcon: Icon(GhIcons.microphone),
      ),
    );
  }
}

class _Explore extends StatelessWidget {
  const new({
    required this.selected,
    required this.onQuickOrder,
    required this.onCategory,
  });

  final FeedCategory selected;
  final VoidCallback onQuickOrder;
  final ValueChanged<FeedCategory> onCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'EXPLORE BHOOK LAGI',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: onQuickOrder,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Quick order'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Tile(
                  icon: GhIcons.forkKnife,
                  title: 'Restaurants',
                  caption: 'Nearby',
                  selected: selected is Restaurants,
                  onTap: () => onCategory(const Restaurants()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Tile(
                  icon: GhIcons.storefront,
                  title: 'Marts',
                  caption: 'Pantry',
                  selected: selected is Marts,
                  onTap: () => onCategory(const Marts()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Tile(
                  icon: GhIcons.firstAid,
                  title: 'Pharmacy',
                  caption: 'Meds',
                  selected: selected is Pharmacies,
                  onTap: () => onCategory(const Pharmacies()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.caption,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = selected
        ? AppColors.tint
        : (dark ? AppColors.darkSurface : AppColors.surface);
    final border = selected
        ? AppColors.primary
        : (dark ? AppColors.darkLine : AppColors.line);
    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 12,
                      color: selected ? AppColors.primary : null,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Promo extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryDeep,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            const Icon(GhIcons.tag, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free deliveries on first 3 orders',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Apply BHOOKFREE at checkout',
                    style: TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'Active',
                  style: TextStyle(
                    color: Color(0xFF8F3F20),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
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

class _Promise extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(GhIcons.shieldCheck, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bhook Lagi neighbourhood promise'),
                  Text('Fair rider pay, short routes, no shelf markup'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MerchantSliver extends StatelessWidget {
  const new({required this.feed, required this.onOpenMerchant});

  final CatalogFeed feed;
  final ValueChanged<Merchant> onOpenMerchant;

  @override
  Widget build(BuildContext context) {
    if (feed.merchants.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: GhEmpty(
          title: 'Nothing nearby',
          body: 'Try another category, or send a parcel across town.',
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      sliver: SliverList.builder(
        itemCount: feed.merchants.length,
        itemBuilder: (context, index) {
          final merchant = feed.merchants[index];
          return MerchantCard(
            merchant: merchant,
            onTap: () => onOpenMerchant(merchant),
          );
        },
      ),
    );
  }
}

void _note(BuildContext context, String message) {
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Text(message),
        );
      },
    ),
  );
}
