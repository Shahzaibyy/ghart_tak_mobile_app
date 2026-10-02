import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/domain/entities/road_route.dart';
import 'package:attock_xpress/features/map/domain/routing_engine.dart';
import 'package:dio/dio.dart';

/// Public OSRM demo server — used when Mapbox Directions is unavailable.
///
/// Replace [baseUrl] with a self-hosted Pakistan extract in production.
class OsrmRoutingEngine implements RoutingEngine {
  /// Creates the engine.
  new({
    Dio? dio,
    this.baseUrl = 'https://router.project-osrm.org',
  }) : _dio = dio ?? Dio();

  final Dio _dio;
  final String baseUrl;

  @override
  Future<RoadRoute> route({
    required GeoPoint origin,
    required GeoPoint destination,
  }) async {
    final path =
        '${origin.lng},${origin.lat};${destination.lng},${destination.lat}';
    final uri = Uri.parse(
      '$baseUrl/route/v1/driving/$path'
      '?overview=full&geometries=geojson&steps=true',
    );
    try {
      final response = await _dio.getUri<Map<String, dynamic>>(uri);
      final data = response.data;
      if (data == null) {
        throw const RoutingFailure('Empty OSRM response');
      }
      if (data['code'] != 'Ok') {
        throw RoutingFailure('OSRM code: ${data['code']}');
      }
      final routes = data['routes'];
      if (routes is! List || routes.isEmpty || routes.first is! Map) {
        throw const RoutingFailure('No OSRM routes');
      }
      return _parse(Map<String, dynamic>.from(routes.first as Map));
    } on DioException catch (error) {
      throw RoutingFailure(error.message ?? 'OSRM network error');
    }
  }

  RoadRoute _parse(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    if (geometry is! Map) {
      throw const RoutingFailure('Missing OSRM geometry');
    }
    final coords = geometry['coordinates'];
    if (coords is! List || coords.length < 2) {
      throw const RoutingFailure('OSRM route too short');
    }
    final points = <GeoPoint>[];
    for (final raw in coords) {
      if (raw is! List || raw.length < 2) continue;
      final lng = raw[0];
      final lat = raw[1];
      if (lng is! num || lat is! num) continue;
      points.add(GeoPoint(lat: lat.toDouble(), lng: lng.toDouble()));
    }
    if (points.length < 2) {
      throw const RoutingFailure('OSRM route too short');
    }
    final steps = <RouteStep>[];
    final legs = json['legs'];
    if (legs is List) {
      for (final leg in legs) {
        if (leg is! Map) continue;
        final legSteps = leg['steps'];
        if (legSteps is! List) continue;
        for (final step in legSteps) {
          if (step is! Map) continue;
          final m = Map<String, dynamic>.from(step);
          final man = m['maneuver'];
          var type = '';
          var modifier = '';
          var lat = 0.0;
          var lng = 0.0;
          if (man is Map) {
            type = (man['type'] as String?) ?? '';
            modifier = (man['modifier'] as String?) ?? '';
            final loc = man['location'];
            if (loc is List && loc.length >= 2) {
              final a = loc[0];
              final b = loc[1];
              if (a is num && b is num) {
                lng = a.toDouble();
                lat = b.toDouble();
              }
            }
          }
          steps.add(
            RouteStep(
              maneuverType: type,
              modifier: modifier,
              streetName: (m['name'] as String?) ?? '',
              distanceMeters: (m['distance'] as num?)?.toDouble() ?? 0,
              location: GeoPoint(lat: lat, lng: lng),
            ),
          );
        }
      }
    }
    return RoadRoute(
      points: points,
      distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0,
      durationSeconds: ((json['duration'] as num?)?.toDouble() ?? 0).round(),
      steps: steps,
    );
  }
}
