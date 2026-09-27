import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/catalog/data/sample_catalog.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:attock_xpress/features/catalog/domain/usecases/browse_merchants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_controller.g.dart';

/// Catalog repository. Sample data until the merchant API is live.
@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) {
  return const SampleCatalogRepository();
}

/// Browse use case.
@riverpod
BrowseMerchants browseMerchants(Ref ref) {
  return BrowseMerchants(ref.watch(catalogRepositoryProvider));
}

/// Filtered home feed.
@riverpod
class CatalogController extends _$CatalogController {
  List<Merchant> _all = const [];

  @override
  Future<CatalogFeed> build() async {
    final result = await ref.watch(browseMerchantsProvider).call();
    final merchants = switch (result) {
      Success(:final value) => value,
      Err(:final failure) => throw failure,
    };
    _all = merchants;
    return _feed(const Restaurants(), '');
  }

  /// Shows merchants in [category].
  void select(FeedCategory category) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(_feed(category, current.query));
  }

  /// Filters the current category by [query].
  void search(String query) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(_feed(current.category, query));
  }

  CatalogFeed _feed(FeedCategory category, String query) {
    final needle = query.trim().toLowerCase();
    final merchants = _all.where((merchant) {
      final sameCategory = _same(merchant.category, category);
      final named = merchant.name.toLowerCase().contains(needle);
      return sameCategory && (needle.isEmpty || named);
    }).toList();
    return CatalogFeed(
      category: category,
      query: query,
      merchants: merchants,
    );
  }

  bool _same(FeedCategory left, FeedCategory right) {
    return left.runtimeType == right.runtimeType;
  }
}
