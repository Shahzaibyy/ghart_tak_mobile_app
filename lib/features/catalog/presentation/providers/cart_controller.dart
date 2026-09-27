import 'package:attock_xpress/features/catalog/domain/entities/cart.dart';
import 'package:attock_xpress/features/catalog/domain/entities/catalog_item.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_controller.g.dart';

/// The customer's basket. Local until checkout.
@riverpod
class CartController extends _$CartController {
  @override
  Cart build() => const Cart();

  /// Adds [item] from [merchant]. A different store replaces the basket.
  void add(Merchant merchant, CatalogItem item) {
    final current = state;
    final sameStore = current.merchant?.id == merchant.id;
    final lines = sameStore ? List<CartLine>.of(current.lines) : <CartLine>[];
    final index = lines.indexWhere((line) => line.item.id == item.id);
    if (index < 0) {
      lines.add(CartLine(item: item, quantity: 1));
    } else {
      final line = lines[index];
      lines[index] = line.copyWith(quantity: line.quantity + 1);
    }
    state = Cart(merchant: merchant, lines: lines);
  }

  /// Removes one of [itemId].
  void removeOne(String itemId) {
    final lines = <CartLine>[];
    for (final line in state.lines) {
      if (line.item.id != itemId) {
        lines.add(line);
        continue;
      }
      if (line.quantity > 1) {
        lines.add(line.copyWith(quantity: line.quantity - 1));
      }
    }
    state = Cart(
      merchant: lines.isEmpty ? null : state.merchant,
      lines: lines,
    );
  }

  /// Empties the basket after a successful order.
  void clear() => state = const Cart();
}
