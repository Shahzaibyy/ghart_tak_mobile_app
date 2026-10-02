import 'package:attock_xpress/core/utils/geo_point.dart';

/// Place suggestion from backend geocoding (`GET /geo/search`).
class PlaceSuggestion {
  /// Creates a suggestion.
  const new({
    required this.label,
    required this.point,
  });

  /// Human-readable label (may include landmark text).
  final String label;

  /// Resolved coordinates.
  final GeoPoint point;
}

/// Geocoding / reverse-geocoding against OUR backend — never Mapbox from the app.
abstract class GeoApi {
  /// Reverse-geocode a pin (`GET /geo/reverse?lat=&lng=`).
  Future<String> reverse(GeoPoint point);

  /// Forward search with district bias (`GET /geo/search?q=&proximity_…`).
  Future<List<PlaceSuggestion>> search(
    String query, {
    required GeoPoint proximity,
  });
}
