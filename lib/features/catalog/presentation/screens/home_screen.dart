import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/core/widgets/gh_empty.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/catalog_controller.dart';
import 'package:attock_xpress/features/catalog/presentation/widgets/active_order_card.dart';
import 'package:attock_xpress/features/catalog/presentation/widgets/category_strip.dart';
import 'package:attock_xpress/features/catalog/presentation/widgets/merchant_card.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer home. Merchants, search, and the live order.
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
    required this.onSearch,
  });

  final String displayName;
  final CatalogFeed feed;
  final Order? active;
  final VoidCallback onTrack;
  final ValueChanged<Merchant> onOpenMerchant;
  final ValueChanged<FeedCategory> onCategory;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _Header(
              displayName: displayName,
              feed: feed,
              active: active,
              onTrack: onTrack,
              onCategory: onCategory,
              onSearch: onSearch,
            ),
          ),
        ),
        _MerchantSliver(feed: feed, onOpenMerchant: onOpenMerchant),
      ],
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
    required this.onSearch,
  });

  final String displayName;
  final CatalogFeed feed;
  final Order? active;
  final VoidCallback onTrack;
  final ValueChanged<FeedCategory> onCategory;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Attock City', style: muted),
            ),
            GhAvatar(name: displayName),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'What do you need?',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 16),
        _SearchField(onSearch: onSearch),
        const SizedBox(height: 16),
        CategoryStrip(selected: feed.category, onSelected: onCategory),
        const SizedBox(height: 20),
        ActiveOrderCard(order: active, onTap: onTrack),
        Text('Nearby', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
      ],
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
      decoration: const InputDecoration(
        hintText: 'Search kitchens and stores',
        prefixIcon: Icon(
          GhIcons.magnifyingGlass,
          color: AppColors.textMuted,
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
