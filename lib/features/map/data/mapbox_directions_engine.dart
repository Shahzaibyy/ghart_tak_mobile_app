import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/domain/entities/road_route.dart';
import 'package:attock_xpress/features/map/domain/routing_engine.dart';
import 'package:dio/dio.dart';

/// Mapbox Directions v5 driving profiles (public token).
///
/// Swap this for a self-hosted OSRM engine behind [RoutingEngine] when ready.
class MapboxDirectionsEngine implements RoutingEngine {
  /// Creates the engine. Uses [AppConfig.mapboxAccessToken] when [token] is null.
  new({Dio? dio, String? token})
      : _dio = dio ?? Dio(),
        _token = token ?? AppConfig.mapboxAccessToken;

  final Dio _dio;
  final String _token;

  @override
  Future<RoadRoute> route({
    required GeoPoint origin,
    required GeoPoint destination,
  }) async {
    if (_token.isEmpty) {
      throw const RoutingFailure('Mapbox access token missing');
    }
    final path =
        '${origin.lng},${origin.lat};${destination.lng},${destination.lat}';
    final uri = Uri.https(
      'api.mapbox.com',
      '/directions/v5/mapbox/driving/$path',
      {
        'geometries': 'geojson',
        'overview': 'full',
        'steps': 'true',
        'access_token': _token,
      },
    );
    try {
      final response = await _dio.getUri<Map<String, dynamic>>(uri);
      final data = response.data;
      if (data == null) {
        throw const RoutingFailure('Empty Directions response');
      }
      final code = data['code'] as String?;
      if (code != 'Ok') {
        throw RoutingFailure('Directions code: ${code ?? 'unknown'}');
      }
      final routes = data['routes'];
      if (routes is! List || routes.isEmpty) {
        throw const RoutingFailure('No routes returned');
      }
      final first = routes.first;
      if (first is! Map) {
        throw const RoutingFailure('Malformed route');
      }
      return _parse(Map<String, dynamic>.from(first));
    } on DioException catch (error) {
      throw RoutingFailure(error.message ?? 'Directions network error');
    }
  }

  RoadRoute _parse(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    if (geometry is! Map) {
      throw const RoutingFailure('Missing geometry');
    }
    final coords = geometry['coordinates'];
    if (coords is! List || coords.length < 2) {
      throw const RoutingFailure('Route has no coordinates');
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
      throw const RoutingFailure('Route too short');
    }
    final distance = (json['distance'] as num?)?.toDouble() ?? 0;
    final duration = (json['duration'] as num?)?.toDouble() ?? 0;
    final steps = <RouteStep>[];
    final legs = json['legs'];
    if (legs is List) {
      for (final leg in legs) {
        if (leg is! Map) continue;
        final legSteps = leg['steps'];
        if (legSteps is! List) continue;
        for (final step in legSteps) {
          if (step is! Map) continue;
          steps.add(_step(Map<String, dynamic>.from(step)));
        }
      }
    }
    return RoadRoute(
      points: points,
      distanceMeters: distance,
      durationSeconds: duration.round(),
      steps: steps,
    );
  }

  RouteStep _step(Map<String, dynamic> json) {
    final maneuver = json['maneuver'];
    var type = '';
    var modifier = '';
    var lat = 0.0;
    var lng = 0.0;
    if (maneuver is Map) {
      type = (maneuver['type'] as String?) ?? '';
      modifier = (maneuver['modifier'] as String?) ?? '';
      final loc = maneuver['location'];
      if (loc is List && loc.length >= 2) {
        final a = loc[0];
        final b = loc[1];
        if (a is num && b is num) {
          lng = a.toDouble();
          lat = b.toDouble();
        }
      }
    }
    return RouteStep(
      maneuverType: type,
      modifier: modifier,
      streetName: (json['name'] as String?) ?? '',
      distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0,
      location: GeoPoint(lat: lat, lng: lng),
    );
  }
}
