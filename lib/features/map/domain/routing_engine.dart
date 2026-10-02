import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/domain/entities/road_route.dart';

/// Pluggable road-routing backend (OSRM / Mapbox / Google).
///
/// Implementations must return a road-following polyline. Callers must **never**
/// fall back to a straight A→B line when this fails.
abstract class RoutingEngine {
  /// Resolves a driving route from [origin] to [destination].
  Future<RoadRoute> route({
    required GeoPoint origin,
    required GeoPoint destination,
  });
}

/// Thrown when no road geometry could be obtained.
class RoutingFailure implements Exception {
  /// Creates a failure.
  const new(this.message);

  final String message;

  @override
  String toString() => 'RoutingFailure: $message';
}
