/// A cached latitude and longitude pair.
class GeoPoint {
  /// Creates a point.
  const new({required this.lat, required this.lng});

  /// Latitude in degrees.
  final double lat;

  /// Longitude in degrees.
  final double lng;
}
