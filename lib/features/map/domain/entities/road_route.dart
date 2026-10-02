import 'package:attock_xpress/core/utils/geo_point.dart';

/// One road-following leg (rider→store or rider→customer).
class RoadRoute {
  /// Creates a route.
  const new({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.steps = const [],
  });

  /// Polyline vertices in order (lat/lng). Never fewer than 2 when valid.
  final List<GeoPoint> points;

  /// Total length along the road network.
  final double distanceMeters;

  /// Estimated travel time.
  final int durationSeconds;

  /// Optional turn-by-turn steps from the engine.
  final List<RouteStep> steps;

  /// Minutes rounded up for ETA chips.
  int get durationMinutes {
    if (durationSeconds <= 0) return 0;
    return (durationSeconds + 59) ~/ 60;
  }

  /// GeoJSON Feature with a LineString (coordinates are lng, lat).
  String get lineStringGeoJson {
    final coords = [
      for (final p in points) '[${p.lng},${p.lat}]',
    ].join(',');
    return '{"type":"Feature","properties":{},'
        '"geometry":{"type":"LineString","coordinates":[$coords]}}';
  }

  /// GeoJSON for a subset of [points] (travelled / remaining).
  static String lineStringFrom(List<GeoPoint> pts) {
    if (pts.length < 2) {
      return '{"type":"Feature","properties":{},'
          '"geometry":{"type":"LineString","coordinates":[]}}';
    }
    final coords = [
      for (final p in pts) '[${p.lng},${p.lat}]',
    ].join(',');
    return '{"type":"Feature","properties":{},'
        '"geometry":{"type":"LineString","coordinates":[$coords]}}';
  }
}

/// A single maneuver along a [RoadRoute].
class RouteStep {
  /// Creates a step.
  const new({
    required this.maneuverType,
    required this.modifier,
    required this.streetName,
    required this.distanceMeters,
    required this.location,
  });

  final String maneuverType;
  final String modifier;
  final String streetName;
  final double distanceMeters;
  final GeoPoint location;
}
