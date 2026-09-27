/// What the customer is browsing.
sealed class FeedCategory {
  const new();
}

/// Restaurants in the customer's city.
final class Restaurants extends FeedCategory {
  /// Creates the restaurant category.
  const new();
}

/// Marts and groceries.
final class Marts extends FeedCategory {
  /// Creates the mart category.
  const new();
}

/// Pharmacies.
final class Pharmacies extends FeedCategory {
  /// Creates the pharmacy category.
  const new();
}

/// Send a parcel.
final class Parcels extends FeedCategory {
  /// Creates the parcel category.
  const new();
}

/// A custom errand.
final class Errands extends FeedCategory {
  /// Creates the errand category.
  const new();
}

/// Short label for a category chip.
String feedCategoryLabel(FeedCategory category) {
  return switch (category) {
    Restaurants() => 'Food',
    Marts() => 'Mart',
    Pharmacies() => 'Pharmacy',
    Parcels() => 'Parcel',
    Errands() => 'Errand',
  };
}

/// Categories shown on the home feed, in order.
const List<FeedCategory> homeCategories = [
  Restaurants(),
  Marts(),
  Pharmacies(),
  Parcels(),
  Errands(),
];
