import 'package:attock_xpress/core/utils/geo_point.dart';

/// Delivery zone from `GET /zones`.
class Zone {
  /// Creates a zone.
  const new({
    required this.id,
    required this.name,
    required this.center,
    required this.serviceRadiusKm,
    this.slug = '',
    this.isActive = true,
  });

  /// Zone UUID.
  final String id;

  /// City / display name.
  final String name;

  /// Optional slug.
  final String slug;

  /// Map camera centre.
  final GeoPoint center;

  /// Service radius in km (pin must be inside).
  final double serviceRadiusKm;

  /// Whether the zone accepts new orders.
  final bool isActive;

  /// Parses one zone row from the API `data` list.
  factory fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Zone missing id');
    }
    final lat = _num(json['center_lat']) ?? 0;
    final lng = _num(json['center_lng']) ?? 0;
    final radius = _num(json['service_radius_km']) ?? 8;
    final name = (json['city_name'] as String?) ??
        (json['name'] as String?) ??
        (json['slug'] as String?) ??
        id;
    return Zone(
      id: id,
      name: name,
      slug: (json['slug'] as String?) ?? '',
      center: GeoPoint(lat: lat, lng: lng),
      serviceRadiusKm: radius,
      isActive: json['is_active'] != false,
    );
  }

  static double? _num(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }
}
