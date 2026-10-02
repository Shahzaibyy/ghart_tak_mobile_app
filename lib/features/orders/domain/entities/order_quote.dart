import 'dart:convert';

import 'package:attock_xpress/core/utils/money_parse.dart';

/// Fee preview from `POST /orders/quote`.
class OrderQuote {
  /// Creates a quote.
  const new({
    required this.distanceKm,
    required this.durationMin,
    required this.itemTotal,
    required this.deliveryFee,
    required this.total,
    required this.approximate,
    this.routeGeoJson,
  });

  final String distanceKm;
  final int durationMin;
  final String itemTotal;
  final String deliveryFee;
  final String total;
  final bool approximate;

  /// Optional GeoJSON Feature with a LineString for the map.
  final String? routeGeoJson;

  /// Delivery fee in whole rupees for UI chips.
  int get deliveryFeeRupees => MoneyParse.rupees(deliveryFee);

  /// Parses the inner `data` object from a quote response.
  factory fromJson(Map<String, dynamic> json) {
    final route = json['route'];
    String? routeGeoJson;
    if (route is Map) {
      routeGeoJson = jsonEncode({
        'type': 'Feature',
        'properties': <String, Object?>{},
        'geometry': route,
      });
    }
    return OrderQuote(
      distanceKm: (json['distance_km'] as String?) ?? '0',
      durationMin: (json['duration_min'] as num?)?.toInt() ?? 0,
      itemTotal: (json['item_total'] as String?) ?? '0.00',
      deliveryFee: (json['delivery_fee'] as String?) ?? '0.00',
      total: (json['total'] as String?) ?? '0.00',
      approximate: json['approximate'] == true,
      routeGeoJson: routeGeoJson,
    );
  }
}
