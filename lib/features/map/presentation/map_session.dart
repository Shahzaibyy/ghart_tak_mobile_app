import 'dart:math' as math;

import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/core/mapbox_codec.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Owns [MapboxMap] + circle annotations + route layer.
/// Keep Mapbox imports here.
class MapSession {
  /// Creates an empty session; call [attach] from `onMapCreated`.
  new();

  MapboxMap? _map;
  CircleAnnotationManager? _circles;
  CircleAnnotation? _rider;
  CircleAnnotation? _pickup;
  CircleAnnotation? _drop;
  GeoPoint? _lastRider;
  int _moveGen = 0;

  /// Underlying map once [attach] has run.
  MapboxMap? get map => _map;

  /// Wire managers after the platform view is ready.
  Future<void> attach(MapboxMap map) async {
    _map = map;
    _circles = await map.annotations.createCircleAnnotationManager();
  }

  /// Shows the blue location puck when permission is already granted.
  Future<void> enablePuck() async {
    final map = _map;
    if (map == null) return;
    await map.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
  }

  /// Draws or updates pickup / drop circles.
  Future<void> setStops({
    required GeoPoint pickup,
    required GeoPoint drop,
  }) async {
    final circles = _circles;
    if (circles == null) return;
    _pickup = await _upsert(
      existing: _pickup,
      point: pickup,
      color: AppColors.success.toARGB32(),
      radius: 10,
    );
    _drop = await _upsert(
      existing: _drop,
      point: drop,
      color: AppColors.error.toARGB32(),
      radius: 10,
    );
  }

  /// Places or updates the rider circle without animation.
  Future<void> setRider(GeoPoint point) async {
    _lastRider = point;
    _rider = await _upsert(
      existing: _rider,
      point: point,
      color: AppColors.primary.toARGB32(),
      radius: 12,
      stroke: AppColors.surface.toARGB32(),
    );
  }

  /// Smoothly interpolates the rider marker toward [next].
  Future<void> moveRider(GeoPoint next) async {
    final from = _lastRider;
    if (from == null) {
      await setRider(next);
      return;
    }
    final gen = ++_moveGen;
    const steps = 20;
    const total = Duration(milliseconds: 1500);
    for (var i = 1; i <= steps; i++) {
      if (gen != _moveGen) return;
      final t = i / steps;
      final cur = GeoPoint(
        lat: from.lat + (next.lat - from.lat) * t,
        lng: from.lng + (next.lng - from.lng) * t,
      );
      await setRider(cur);
      await Future<void>.delayed(total ~/ steps);
    }
    if (gen == _moveGen) _lastRider = next;
  }

  /// Draws / updates the route LineString GeoJSON from the backend.
  Future<void> drawRoute(String lineStringGeoJson) async {
    final map = _map;
    if (map == null) return;
    const srcId = MapConstants.routeSourceId;
    const layerId = MapConstants.routeLayerId;
    final exists = await map.styleSourceExists(srcId);
    if (exists) {
      final src = await map.getSource(srcId);
      if (src is GeoJsonSource) {
        await src.updateGeoJSON(lineStringGeoJson);
      }
      return;
    }
    await map.addSource(GeoJsonSource(id: srcId, data: lineStringGeoJson));
    await map.addLayer(
      LineLayer(
        id: layerId,
        sourceId: srcId,
        lineColor: AppColors.primary.toARGB32(),
        lineWidth: 5,
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
      ),
    );
  }

  /// Fits pickup + drop with padding for a bottom sheet.
  Future<void> fitStops(GeoPoint a, GeoPoint b) async {
    final map = _map;
    if (map == null) return;
    final sw = Point(
      coordinates: Position(
        math.min(a.lng, b.lng),
        math.min(a.lat, b.lat),
      ),
    );
    final ne = Point(
      coordinates: Position(
        math.max(a.lng, b.lng),
        math.max(a.lat, b.lat),
      ),
    );
    final cam = await map.cameraForCoordinateBounds(
      CoordinateBounds(southwest: sw, northeast: ne, infiniteBounds: false),
      MbxEdgeInsets(top: 120, left: 48, bottom: 320, right: 48),
      null,
      null,
      null,
      null,
    );
    await map.setCamera(cam);
  }

  /// Animated camera move.
  Future<void> flyTo(GeoPoint point, {double zoom = 16}) async {
    final map = _map;
    if (map == null) return;
    await map.flyTo(
      CameraOptions(center: toMapbox(point), zoom: zoom),
      MapAnimationOptions(duration: 800, startDelay: 0),
    );
  }

  /// Current camera centre as app [GeoPoint].
  Future<GeoPoint?> cameraCenter() async {
    final map = _map;
    if (map == null) return null;
    final state = await map.getCameraState();
    return fromMapbox(state.center);
  }

  Future<CircleAnnotation> _upsert({
    required CircleAnnotation? existing,
    required GeoPoint point,
    required int color,
    required double radius,
    int? stroke,
  }) async {
    final circles = _circles!;
    final geometry = toMapbox(point);
    if (existing != null) {
      existing.geometry = geometry;
      await circles.update(existing);
      return existing;
    }
    return await circles.create(
      CircleAnnotationOptions(
        geometry: geometry,
        circleColor: color,
        circleRadius: radius,
        circleStrokeColor: stroke,
        circleStrokeWidth: stroke == null ? null : 2,
      ),
    );
  }

  /// Cancels in-flight rider animation.
  void dispose() {
    _moveGen++;
    _map = null;
    _circles = null;
    _rider = null;
    _pickup = null;
    _drop = null;
  }
}
