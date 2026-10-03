import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/media/demo_media.dart';
import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:attock_xpress/core/utils/money_parse.dart';
import 'package:attock_xpress/features/catalog/domain/entities/catalog_item.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/domain/entities/zone.dart';
import 'package:dio/dio.dart';

/// HTTP access to zones, merchants, and menus.
class CatalogRemoteDataSource {
  /// Creates a data source over Dio.
  const new(this._dio);

  final Dio _dio;

  /// Active zones (`GET /zones?active=true`).
  Future<List<Zone>> listActiveZones() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/zones',
      queryParameters: const {'active': true},
    );
    final data = unwrapData<List<dynamic>>(response);
    return [
      for (final row in data) Zone.fromJson(_asMap(row)),
    ];
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
    final grocery = category is Marts || category is Pharmacies;
    final photo = _mediaUrl(json) ??
        DemoMedia.merchantPhoto(id, grocery: grocery);
    final rating = _asDouble(json['rating']) ?? 4.8;
    final fee = _moneyRupees(json['delivery_fee']) ?? 80;
    final minOrder = _moneyRupees(json['min_order']) ?? 200;
    return Merchant(
      id: id,
      name: name,
      category: category,
      photoUrl: photo,
      rating: rating,
      ratingCount: (json['rating_count'] as String?) ?? 'seed',
      etaMinutes: (json['eta_minutes'] as num?)?.toInt() ?? 25,
      etaLabel: (json['eta_label'] as String?) ?? '20-30 min',
      area: address,
      blurb: items.isEmpty
          ? 'Local kitchen'
          : items.map((i) => i.name).take(3).join(' · '),
      badge: id == DemoConfig.demoMerchantId ? 'Demo' : 'Open',
      deliveryFeeRupees: fee,
      minOrderRupees: minOrder,
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
      photoUrl: _mediaUrl(json) ?? DemoMedia.itemPhoto(name),
    );
  }

  FeedCategory _categoryFor(String? raw) {
    return switch (raw) {
      'mart' => const Marts(),
      'pharmacy' => const Pharmacies(),
      _ => const Restaurants(),
    };
  }

  /// Prefers backend media when present (`photo_url`, `cover_image_url`, …).
  String? _mediaUrl(Map<String, dynamic> json) {
    for (final key in const [
      'photo_url',
      'cover_image_url',
      'image_url',
      'avatar_url',
    ]) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  int? _moneyRupees(Object? raw) {
    return switch (raw) {
      final String s => MoneyParse.rupees(s),
      final num n => n.round(),
      _ => null,
    };
  }

  Map<String, dynamic> _asMap(Object? raw) {
    if (raw is! Map) throw const FormatException('Expected an object');
    return Map<String, dynamic>.from(raw);
  }
}
