import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:attock_xpress/core/utils/money_parse.dart';
import 'package:attock_xpress/features/catalog/domain/entities/catalog_item.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:dio/dio.dart';

const _fallbackPhoto =
    'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a'
    '?auto=format&fit=crop&w=900&q=60';

/// HTTP access to zones, merchants, and menus.
class CatalogRemoteDataSource {
  /// Creates a data source over Dio.
  const new(this._dio);

  final Dio _dio;

  /// Active zones (`GET /zones?active=true`).
  Future<List<Map<String, dynamic>>> listActiveZones() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/zones',
      queryParameters: const {'active': true},
    );
    final data = unwrapData<List<dynamic>>(response);
    return data.map(_asMap).toList(growable: false);
  }

  /// Approved merchants in [zoneId].
  Future<List<Merchant>> listMerchants(String zoneId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/merchants',
      queryParameters: {'zone_id': zoneId},
    );
    final data = unwrapData<List<dynamic>>(response);
    final merchants = <Merchant>[];
    for (final row in data) {
      final map = _asMap(row);
      final id = map['id'];
      if (id is! String) continue;
      final items = await listCatalog(id);
      merchants.add(_merchantFrom(map, items));
    }
    return merchants;
  }

  /// Menu for one merchant.
  Future<List<CatalogItem>> listCatalog(String merchantId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/merchants/$merchantId/catalog',
    );
    final data = unwrapData<List<dynamic>>(response);
    return data.map(_itemFrom).toList(growable: false);
  }

  Merchant _merchantFrom(Map<String, dynamic> json, List<CatalogItem> items) {
    final id = json['id'] as String;
    final name = (json['name'] as String?) ?? 'Merchant';
    final category = _categoryFor(json['category'] as String?);
    final address = (json['address_text'] as String?) ?? 'Fateh Jang';
    return Merchant(
      id: id,
      name: name,
      category: category,
      photoUrl: _fallbackPhoto,
      rating: 4.8,
      ratingCount: 'seed',
      etaMinutes: 25,
      etaLabel: '20-30 min',
      area: address,
      blurb: items.isEmpty
          ? 'Local kitchen'
          : items.map((i) => i.name).take(3).join(' · '),
      badge: id == DemoConfig.demoMerchantId ? 'Demo' : 'Open',
      deliveryFeeRupees: 80,
      minOrderRupees: 200,
      items: items,
      lat: _asDouble(json['lat']),
      lng: _asDouble(json['lng']),
    );
  }

  double? _asDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  CatalogItem _itemFrom(Object? raw) {
    final json = _asMap(raw);
    final id = json['id'];
    final name = json['name'];
    final price = json['price'];
    if (id is! String || name is! String || price is! String) {
      throw const FormatException('Invalid catalog item');
    }
    return CatalogItem(
      id: id,
      name: name,
      detail: (json['description'] as String?) ?? '',
      priceRupees: MoneyParse.rupees(price),
      photoUrl: _fallbackPhoto,
    );
  }

  FeedCategory _categoryFor(String? raw) {
    return switch (raw) {
      'mart' => const Marts(),
      'pharmacy' => const Pharmacies(),
      _ => const Restaurants(),
    };
  }

  Map<String, dynamic> _asMap(Object? raw) {
    if (raw is! Map) throw const FormatException('Expected an object');
    return Map<String, dynamic>.from(raw);
  }
}
