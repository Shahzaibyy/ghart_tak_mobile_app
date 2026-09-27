/// One thing a merchant sells.
class CatalogItem {
  /// Creates an item.
  const new({
    required this.id,
    required this.name,
    required this.detail,
    required this.priceRupees,
    required this.photoUrl,
  });

  /// Item id.
  final String id;

  /// Name on the menu.
  final String name;

  /// Short description.
  final String detail;

  /// Price in whole rupees.
  final int priceRupees;

  /// Square product photo.
  final String photoUrl;
}
