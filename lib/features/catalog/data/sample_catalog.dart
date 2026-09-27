import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/catalog/domain/entities/catalog_item.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/domain/repositories/catalog_repository.dart';

const _biryani =
    'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a'
    '?auto=format&fit=crop&w=900&q=60';
const _karahi =
    'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398'
    '?auto=format&fit=crop&w=900&q=60';
const _mart =
    'https://images.unsplash.com/photo-1542838132-92c53300491e'
    '?auto=format&fit=crop&w=900&q=60';
const _pharmacy =
    'https://images.unsplash.com/photo-1587854692152-cbe660dbde88'
    '?auto=format&fit=crop&w=900&q=60';
const _naan =
    'https://images.unsplash.com/photo-1565557623262-b51c2513a641'
    '?auto=format&fit=crop&w=600&q=60';

/// Local Attock merchants so the home feed can be reviewed offline.
class SampleCatalogRepository implements CatalogRepository {
  /// Creates the sample catalog.
  const new();

  @override
  Future<Result<List<Merchant>>> listMerchants() async {
    return const Success(_merchants);
  }
}

const List<Merchant> _merchants = [
  Merchant(
    id: 'm-tandoor',
    name: 'Tandoor House',
    category: Restaurants(),
    photoUrl: _biryani,
    rating: 4.8,
    etaMinutes: 28,
    area: 'Attock City',
    items: [
      CatalogItem(
        id: 'i-karahi',
        name: 'Chicken karahi',
        detail: 'Half, for two',
        priceRupees: 1450,
        photoUrl: _karahi,
      ),
      CatalogItem(
        id: 'i-naan',
        name: 'Roghni naan',
        detail: 'Baked to order',
        priceRupees: 80,
        photoUrl: _naan,
      ),
    ],
  ),
  Merchant(
    id: 'm-hazro',
    name: 'Hazro Mart',
    category: Marts(),
    photoUrl: _mart,
    rating: 4.6,
    etaMinutes: 22,
    area: 'Hazro',
    items: [
      CatalogItem(
        id: 'i-milk',
        name: 'Fresh milk',
        detail: '1 litre',
        priceRupees: 280,
        photoUrl: _mart,
      ),
      CatalogItem(
        id: 'i-bread',
        name: 'Whole wheat bread',
        detail: 'Large loaf',
        priceRupees: 180,
        photoUrl: _naan,
      ),
    ],
  ),
  Merchant(
    id: 'm-hasan',
    name: 'Hasan Pharmacy',
    category: Pharmacies(),
    photoUrl: _pharmacy,
    rating: 4.9,
    etaMinutes: 18,
    area: 'Hasan Abdal',
    items: [
      CatalogItem(
        id: 'i-kit',
        name: 'Care kit',
        detail: 'Daily essentials',
        priceRupees: 640,
        photoUrl: _pharmacy,
      ),
    ],
  ),
];
