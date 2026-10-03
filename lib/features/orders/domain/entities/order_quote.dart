import 'dart:convert';

import 'package:attock_xpress/core/utils/money_parse.dart';

/// Fee preview from `POST /orders/quote`.
///
/// Money fields stay as decimal **strings** from the API (`"450.00"`).
class OrderQuote {
  /// Creates a quote.
  const new({
    required this.distanceKm,
    required this.durationMin,
    required this.itemTotal,
    required this.deliveryFee,
    required this.total,
    required this.approximate,
    this.commissionAmount = '0.00',
    this.riderEarning = '0.00',
    this.surgeMultiplier = '1.00',
    this.routeGeoJson,
  });

  /// Road distance as returned by the server (`"3.42"`).
  final String distanceKm;

  /// Estimated minutes.
  final int durationMin;

  /// Basket item total (`"900.00"`).
  final String itemTotal;

  /// Delivery fee (`"80.00"`).
  final String deliveryFee;

  /// Commission amount (display / audit).
  final String commissionAmount;

  /// Rider earning (display / audit).
  final String riderEarning;

  /// Surge multiplier (`"1.00"`).
  final String surgeMultiplier;

  /// Grand total the customer pays (`"…"`).
  final String total;

  /// True when Mapbox was unavailable and fees are approximate.
  final bool approximate;

  /// Optional GeoJSON Feature with a LineString for the map.
  final String? routeGeoJson;

  /// Delivery fee in whole rupees for UI chips.
  int get deliveryFeeRupees => MoneyParse.rupees(deliveryFee);

  /// Item total in whole rupees.
  int get itemTotalRupees => MoneyParse.rupees(itemTotal);

  /// Grand total in whole rupees.
  int get totalRupees => MoneyParse.rupees(total);

  /// Parses the inner `data` object from a quote response.
  factory fromJson(Map<String, dynamic> json) {
    final route = json['route'];
    String? routeGeoJson;
    if (route is Map) {
      routeGeoJson = jsonEncode({
        'type': 'Feature',
        'properties': <String, Object?>{},
        'geometry': Map<String, dynamic>.from(route),
      });
    }
    return OrderQuote(
      distanceKm: _moneyOrText(json['distance_km']) ?? '0',
      durationMin: (json['duration_min'] as num?)?.toInt() ?? 0,
      itemTotal: _moneyOrText(json['item_total']) ?? '0.00',
      deliveryFee: _moneyOrText(json['delivery_fee']) ?? '0.00',
      commissionAmount: _moneyOrText(json['commission_amount']) ?? '0.00',
      riderEarning: _moneyOrText(json['rider_earning']) ?? '0.00',
      surgeMultiplier: _moneyOrText(json['surge_multiplier']) ?? '1.00',
      total: _moneyOrText(json['total']) ?? '0.00',
      approximate: json['approximate'] == true,
      routeGeoJson: routeGeoJson,
    );
  }

  /// Accepts API money as string **or** number (never invent fees client-side).
  static String? _moneyOrText(Object? raw) {
    if (raw is String) return raw;
    if (raw is num) return raw.toStringAsFixed(2);
    return null;
  }
}
