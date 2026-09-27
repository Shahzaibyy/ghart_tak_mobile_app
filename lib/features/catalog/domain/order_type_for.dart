import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_type.dart';

/// Maps a feed category onto the order type the backend expects.
OrderType orderTypeFor(FeedCategory category) {
  return switch (category) {
    Restaurants() => const FoodOrder(),
    Marts() || Pharmacies() => const MartOrder(),
    Parcels() => const CourierOrder(),
    Errands() => const ErrandOrder(),
  };
}
