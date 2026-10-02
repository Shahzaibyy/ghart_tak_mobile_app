import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/domain/entities/road_route.dart';
import 'package:attock_xpress/features/map/domain/routing_engine.dart';

/// Tries engines in order until one returns a road route.
class FallbackRoutingEngine implements RoutingEngine {
  /// Creates a chain of [engines].
  const new(this.engines);

  final List<RoutingEngine> engines;

  @override
  Future<RoadRoute> route({
    required GeoPoint origin,
    required GeoPoint destination,
  }) async {
    Object? last;
    for (final engine in engines) {
      try {
        return await engine.route(origin: origin, destination: destination);
      } on Object catch (error) {
        last = error;
      }
    }
    throw RoutingFailure('All routing engines failed: $last');
  }
}
