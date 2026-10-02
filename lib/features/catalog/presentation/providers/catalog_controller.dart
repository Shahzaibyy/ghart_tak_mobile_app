import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/network_providers.dart';
import 'package:attock_xpress/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:attock_xpress/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:attock_xpress/features/catalog/domain/usecases/browse_merchants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_controller.g.dart';

/// Catalog repository wired to the live zone merchants + menus.
@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) {
  return CatalogRepositoryImpl(
    CatalogRemoteDataSource(ref.watch(dioProvider)),
  );
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
    final inCategory = _all.where((merchant) {
      return _same(merchant.category, category);
    }).toList();
    // Seeded Attock currently has restaurants only — show them under other
    // food-adjacent tabs so the home feed is never empty during demos.
    final pool = inCategory.isNotEmpty ? inCategory : _all;
    final merchants = pool.where((merchant) {
      final named = merchant.name.toLowerCase().contains(needle);
      return needle.isEmpty || named;
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
