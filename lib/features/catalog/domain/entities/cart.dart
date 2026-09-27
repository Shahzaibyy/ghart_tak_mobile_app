import 'package:attock_xpress/features/catalog/domain/entities/catalog_item.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';

/// One line in the basket.
class CartLine {
  /// Creates a line.
  const new({required this.item, required this.quantity});

  /// Item being bought.
  final CatalogItem item;

  /// How many.
  final int quantity;

  /// Line total in rupees.
  int get totalRupees => item.priceRupees * quantity;

  /// Returns a copy with a new quantity.
  CartLine copyWith({int? quantity}) {
    return CartLine(item: item, quantity: quantity ?? this.quantity);
  }
}

/// Basket for a single merchant.
class Cart {
  /// Creates a basket.
  const new({this.merchant, this.lines = const []});

  /// Store the items belong to. Null when the basket is empty.
  final Merchant? merchant;

  /// Lines in the basket.
  final List<CartLine> lines;

  /// Item total.
  int get itemTotal {
    return lines.fold(0, (sum, line) => sum + line.totalRupees);
  }

  /// Flat in-city delivery fee once the basket has items.
  int get deliveryFee => lines.isEmpty ? 0 : 80;

  /// What the customer pays.
  int get total => itemTotal + deliveryFee;

  /// Whether anything is in the basket.
  bool get isEmpty => lines.isEmpty;
}
