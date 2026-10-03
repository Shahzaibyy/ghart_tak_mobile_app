/// Curated Unsplash images for demo UI (food, grocery, pharmacy).
///
/// Backend catalog often has no photos yet — these fill merchant cards and
/// menu rows so the app matches the v2 screen designs.
abstract final class DemoMedia {
  static const biryani =
      'https://images.unsplash.com/photo-1589302168068-964664d93dc0'
      '?auto=format&fit=crop&w=900&q=70';
  static const karahi =
      'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398'
      '?auto=format&fit=crop&w=900&q=70';
  static const pizza =
      'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3'
      '?auto=format&fit=crop&w=900&q=70';
  static const burger =
      'https://images.unsplash.com/photo-1568901346375-23c9450c58cd'
      '?auto=format&fit=crop&w=900&q=70';
  static const naan =
      'https://images.unsplash.com/photo-1565557623262-b51c2513a641'
      '?auto=format&fit=crop&w=900&q=70';
  static const coffee =
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085'
      '?auto=format&fit=crop&w=900&q=70';
  static const fries =
      'https://images.unsplash.com/photo-1573080496219-bb080dd4f877'
      '?auto=format&fit=crop&w=900&q=70';
  static const grocery =
      'https://images.unsplash.com/photo-1542838132-92c53300491e'
      '?auto=format&fit=crop&w=900&q=70';
  static const milk =
      'https://images.unsplash.com/photo-1563636619-e9143da7973b'
      '?auto=format&fit=crop&w=900&q=70';
  static const eggs =
      'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f'
      '?auto=format&fit=crop&w=900&q=70';
  static const tomatoes =
      'https://images.unsplash.com/photo-1546470427-227c7369a9e0'
      '?auto=format&fit=crop&w=900&q=70';
  static const flour =
      'https://images.unsplash.com/photo-1628088062852-bd4395688176'
      '?auto=format&fit=crop&w=900&q=70';
  static const pharmacy =
      'https://images.unsplash.com/photo-1587854692152-cbe660dbde88'
      '?auto=format&fit=crop&w=900&q=70';
  static const restaurantHero =
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4'
      '?auto=format&fit=crop&w=900&q=70';

  static const _foodCycle = <String>[
    biryani,
    karahi,
    pizza,
    burger,
    naan,
    coffee,
    fries,
    restaurantHero,
  ];

  static const _groceryCycle = <String>[
    grocery,
    milk,
    eggs,
    tomatoes,
    flour,
  ];

  /// Stable photo for a merchant by id hash + grocery flag.
  static String merchantPhoto(String id, {required bool grocery}) {
    final list = grocery ? _groceryCycle : _foodCycle;
    return list[id.hashCode.abs() % list.length];
  }

  /// Stable photo for a catalog [name].
  static String itemPhoto(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('pizza') || lower.contains('fajita')) return pizza;
    if (lower.contains('burger') || lower.contains('zinger')) return burger;
    if (lower.contains('biryani') || lower.contains('pulao')) return biryani;
    if (lower.contains('karahi') || lower.contains('tikka')) return karahi;
    if (lower.contains('naan') || lower.contains('roti')) return naan;
    if (lower.contains('milk') || lower.contains('doodh')) return milk;
    if (lower.contains('egg')) return eggs;
    if (lower.contains('tomato') || lower.contains('sabzi')) return tomatoes;
    if (lower.contains('atta') || lower.contains('flour')) return flour;
    if (lower.contains('pharma') || lower.contains('syrup') || lower.contains('tablet')) {
      return pharmacy;
    }
    if (lower.contains('mart') || lower.contains('grocery')) return grocery;
    return _foodCycle[name.hashCode.abs() % _foodCycle.length];
  }
}
