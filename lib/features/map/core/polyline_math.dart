import 'dart:math' as math;

import 'package:attock_xpress/core/utils/geo_point.dart';

/// Local polyline helpers (snap / split / distance). No paid Map Matching API.
abstract final class PolylineMath {
  static const _earthRadiusM = 6371000.0;

  /// Great-circle distance in metres.
  static double distanceMeters(GeoPoint a, GeoPoint b) {
    final dLat = _rad(b.lat - a.lat);
    final dLng = _rad(b.lng - a.lng);
    final lat1 = _rad(a.lat);
    final lat2 = _rad(b.lat);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * _earthRadiusM * math.asin(math.sqrt(h));
  }

  /// Bearing in degrees [0, 360).
  static double bearingDegrees(GeoPoint from, GeoPoint to) {
    final lat1 = _rad(from.lat);
    final lat2 = _rad(to.lat);
    final dLng = _rad(to.lng - from.lng);
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (_deg(math.atan2(y, x)) + 360) % 360;
  }

  /// Shortest-angle lerp between two bearings.
  static double lerpBearing(double from, double to, double t) {
    var delta = (to - from) % 360;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    return (from + delta * t + 360) % 360;
  }

  /// Nearest point on [polyline] to [fix], if within [maxMeters].
  static SnapResult? snapToRoute(
    GeoPoint fix,
    List<GeoPoint> polyline, {
    double maxMeters = 30,
  }) {
    if (polyline.length < 2) return null;
    var bestDist = double.infinity;
    GeoPoint? bestPoint;
    var bestIndex = 0;
    var travelled = 0.0;
    var bestTravelled = 0.0;

    for (var i = 0; i < polyline.length - 1; i++) {
      final a = polyline[i];
      final b = polyline[i + 1];
      final projected = _projectOnSegment(fix, a, b);
      final d = distanceMeters(fix, projected.point);
      if (d < bestDist) {
        bestDist = d;
        bestPoint = projected.point;
        bestIndex = i;
        bestTravelled = travelled + projected.alongMeters;
      }
      travelled += distanceMeters(a, b);
    }

    if (bestPoint == null || bestDist > maxMeters) return null;
    return SnapResult(
      point: bestPoint,
      distanceFromFix: bestDist,
      segmentIndex: bestIndex,
      travelledMeters: bestTravelled,
    );
  }

  /// Splits [polyline] at the nearest vertex/projection to [at].
  static RouteSplit splitAt(List<GeoPoint> polyline, GeoPoint at) {
    if (polyline.length < 2) {
      return RouteSplit(travelled: polyline, remaining: polyline);
    }
    final snap = snapToRoute(at, polyline, maxMeters: double.infinity);
    if (snap == null) {
      return RouteSplit(travelled: const [], remaining: polyline);
    }
    final travelled = <GeoPoint>[
      ...polyline.sublist(0, snap.segmentIndex + 1),
      snap.point,
    ];
    final remaining = <GeoPoint>[
      snap.point,
      ...polyline.sublist(snap.segmentIndex + 1),
    ];
    return RouteSplit(travelled: travelled, remaining: remaining);
  }

  static _Projection _projectOnSegment(GeoPoint p, GeoPoint a, GeoPoint b) {
    final ax = a.lng;
    final ay = a.lat;
    final bx = b.lng;
    final by = b.lat;
    final px = p.lng;
    final py = p.lat;
    final dx = bx - ax;
    final dy = by - ay;
    if (dx == 0 && dy == 0) {
      return _Projection(point: a, alongMeters: 0);
    }
    final t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);
    final clamped = t.clamp(0.0, 1.0);
    final point = GeoPoint(
      lat: ay + dy * clamped,
      lng: ax + dx * clamped,
    );
    return _Projection(
      point: point,
      alongMeters: distanceMeters(a, point),
    );
  }

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;
}

/// Result of snapping a GPS fix onto a route.
class SnapResult {
  /// Creates a snap result.
  const new({
    required this.point,
    required this.distanceFromFix,
    required this.segmentIndex,
    required this.travelledMeters,
  });

  final GeoPoint point;
  final double distanceFromFix;
  final int segmentIndex;
  final double travelledMeters;
}

/// Travelled vs remaining polyline parts.
class RouteSplit {
  /// Creates a split.
  const new({required this.travelled, required this.remaining});

  final List<GeoPoint> travelled;
  final List<GeoPoint> remaining;
}

class _Projection {
  const _Projection({required this.point, required this.alongMeters});
  final GeoPoint point;
  final double alongMeters;
}
