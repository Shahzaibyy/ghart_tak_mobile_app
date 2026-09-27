import 'package:attock_xpress/features/catalog/domain/entities/catalog_item.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';

/// A store the customer can order from.
class Merchant {
  /// Creates a merchant.
  const new({
    required this.id,
    required this.name,
    required this.category,
    required this.photoUrl,
    required this.rating,
    required this.etaMinutes,
    required this.area,
    required this.items,
  });

  /// Merchant id.
  final String id;

  /// Store name.
  final String name;

  /// Feed category.
  final FeedCategory category;

  /// 4:3 storefront photo.
  final String photoUrl;

  /// Average rating from 1 to 5.
  final double rating;

  /// Typical delivery time.
  final int etaMinutes;

  /// Neighbourhood in Attock district.
  final String area;

  /// Menu or catalog.
  final List<CatalogItem> items;
}

/// Home feed after category and search filters.
class CatalogFeed {
  /// Creates a feed.
  const new({
    required this.category,
    required this.query,
    required this.merchants,
  });

  /// Selected browse category.
  final FeedCategory category;

  /// Current search text.
  final String query;

  /// Merchants that match.
  final List<Merchant> merchants;
}
