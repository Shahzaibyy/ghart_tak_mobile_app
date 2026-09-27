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
    this.ratingCount = '1k+',
    this.deliveryFeeRupees = 75,
    this.minOrderRupees = 400,
    this.blurb = 'Local favorites',
    this.badge = 'Open',
    this.perk = '',
    this.etaLabel = '',
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

  /// Compact rating volume, such as 1.2k.
  final String ratingCount;

  /// Typical delivery fee in rupees.
  final int deliveryFeeRupees;

  /// Minimum basket.
  final int minOrderRupees;

  /// Short menu line.
  final String blurb;

  /// Open, direct mart, or verified.
  final String badge;

  /// Extra promise, empty when there is none.
  final String perk;

  /// Range such as 25-30 min. Falls back to a single ETA.
  final String etaLabel;

  /// Time chip on the photo.
  String get etaSpan {
    if (etaLabel.isEmpty) return '$etaMinutes min';
    return etaLabel;
  }
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
