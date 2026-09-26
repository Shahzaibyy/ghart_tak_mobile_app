/// Kind of task a customer can place.
sealed class OrderType {
  const new();
}

/// Restaurant order.
final class FoodOrder extends OrderType {
  /// Creates a food order type.
  const new();
}

/// Grocery or mart order.
final class MartOrder extends OrderType {
  /// Creates a mart order type.
  const new();
}

/// Parcel delivery.
final class CourierOrder extends OrderType {
  /// Creates a courier order type.
  const new();
}

/// Free-text errand.
final class ErrandOrder extends OrderType {
  /// Creates an errand order type.
  const new();
}

const Map<String, OrderType> _types = {
  'food': FoodOrder(),
  'mart': MartOrder(),
  'courier': CourierOrder(),
  'errand': ErrandOrder(),
};

/// Parses the API order type once.
OrderType parseOrderType(String raw) {
  final type = _types[raw];
  if (type == null) throw const FormatException('Unknown order type');
  return type;
}

/// Short label for [type].
String orderTypeLabel(OrderType type) {
  return switch (type) {
    FoodOrder() => 'Food',
    MartOrder() => 'Mart',
    CourierOrder() => 'Parcel',
    ErrandOrder() => 'Errand',
  };
}
