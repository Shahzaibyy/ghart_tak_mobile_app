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
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _homeAddress = 'House 18, Street 4, Peoples Colony';

/// Customer home. Address, categories, and featured merchants.
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
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _Header(
              displayName: displayName,
              active: active,
              onTrack: onTrack,
              onCategory: onCategory,
              onQuickOrder: onQuickOrder,
              onSearch: onSearch,
            ),
          ),
        ),
        _MerchantSliver(feed: feed, onOpenMerchant: onOpenMerchant),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverToBoxAdapter(child: _Promise()),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const new({
    required this.displayName,
    required this.active,
    required this.onTrack,
    required this.onCategory,
    required this.onQuickOrder,
    required this.onSearch,
  });

  final String displayName;
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
        const SizedBox(height: 14),
        const _Address(),
        const SizedBox(height: 12),
        _SearchField(onSearch: onSearch),
        const SizedBox(height: 18),
        _Explore(onQuickOrder: onQuickOrder, onCategory: onCategory),
        const SizedBox(height: 16),
        const _Promo(),
        const SizedBox(height: 16),
        ActiveOrderCard(order: active, onTap: onTrack),
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
              child: const Text('See all'),
            ),
          ],
        ),
        Text(
          'Kitchens, marts, and pharmacies around Attock',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _Top extends StatelessWidget {
  const new({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(GhIcons.truck, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DELIVER TO', style: Theme.of(context).textTheme.bodySmall),
              Text('Home', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _note(context, 'No new alerts'),
          icon: const Icon(GhIcons.bell),
        ),
        GhAvatar(name: name),
      ],
    );
  }
}

class _Address extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        onTap: () => _note(context, _homeAddress),
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(GhIcons.mapPin, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(child: Text(_homeAddress)),
            ],
          ),
        ),
      ),
    );
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
      decoration: InputDecoration(
        hintText: 'Search kitchens, marts, or a parcel',
        prefixIcon: const Icon(GhIcons.magnifyingGlass),
        suffixIcon: IconButton(
          onPressed: () => _note(context, 'Voice search is a preview'),
          icon: const Icon(GhIcons.microphone),
        ),
      ),
    );
  }
}

class _Explore extends StatelessWidget {
  const new({required this.onQuickOrder, required this.onCategory});

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
                'EXPLORE GHARTAK',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: onQuickOrder,
              child: const Text('Quick order'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Tile(
                icon: GhIcons.forkKnife,
                title: 'Restaurants',
                caption: 'Kitchens nearby',
                onTap: () => onCategory(const Restaurants()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Tile(
                icon: GhIcons.storefront,
                title: 'Marts',
                caption: 'Instant pantry',
                onTap: () => onCategory(const Marts()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Tile(
                icon: GhIcons.firstAid,
                title: 'Pharmacy',
                caption: 'Prescriptions',
                onTap: () => onCategory(const Pharmacies()),
              ),
            ),
          ],
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              Text(
                caption,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
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
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(GhIcons.tag, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free deliveries on first 3 orders',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    'Apply GHARTAKFREE at checkout',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const _ActivePill(),
          ],
        ),
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          'Active',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.surface,
          ),
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
                  Text('GharTak neighbourhood promise'),
                  Text(
                    'Fair rider pay, short routes, no shelf markup',
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
