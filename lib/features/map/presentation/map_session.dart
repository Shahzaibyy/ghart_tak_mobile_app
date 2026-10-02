import 'dart:math' as math;

import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/core/mapbox_codec.dart';
import 'package:attock_xpress/features/map/core/polyline_math.dart';
import 'package:attock_xpress/features/map/domain/entities/road_route.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Owns [MapboxMap] + annotations + dual-layer route (casing + progress split).
class MapSession {
  /// Creates an empty session; call [attach] from `onMapCreated`.
  new();

  MapboxMap? _map;
  CircleAnnotationManager? _circles;
  CircleAnnotation? _rider;
  CircleAnnotation? _pickup;
  CircleAnnotation? _drop;
  GeoPoint? _lastRider;
  double _lastBearing = 0;
  List<GeoPoint> _routePoints = const [];
  DateTime? _lastSplitAt;
  int _moveGen = 0;

  /// Underlying map once [attach] has run.
  MapboxMap? get map => _map;

  /// Active route vertices (empty when unavailable).
  List<GeoPoint> get routePoints => _routePoints;

  /// Last rider position used for progress split.
  GeoPoint? get lastRider => _lastRider;

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

  /// Draws or updates pickup / drop circles (store + customer).
  Future<void> setStops({
    required GeoPoint pickup,
    required GeoPoint drop,
    bool emphasizePickup = true,
  }) async {
    final circles = _circles;
    if (circles == null) return;
    _pickup = await _upsert(
      existing: _pickup,
      point: pickup,
      color: AppColors.gold.toARGB32(),
      radius: emphasizePickup ? 11 : 8,
      stroke: AppColors.surface.toARGB32(),
      strokeWidth: 2.5,
    );
    _drop = await _upsert(
      existing: _drop,
      point: drop,
      color: AppColors.primary.toARGB32(),
      radius: emphasizePickup ? 8 : 11,
      stroke: AppColors.surface.toARGB32(),
      strokeWidth: 2.5,
    );
  }

  /// Places or updates the rider circle (white fill + terracotta ring).
  Future<void> setRider(GeoPoint point, {double? bearing}) async {
    _lastRider = point;
    if (bearing != null) _lastBearing = bearing;
    _rider = await _upsert(
      existing: _rider,
      point: point,
      color: AppColors.surface.toARGB32(),
      radius: 14,
      stroke: AppColors.primary.toARGB32(),
      strokeWidth: 3.5,
    );
  }

  /// Smoothly interpolates the rider marker toward [next].
  Future<void> moveRider(GeoPoint next, {double? bearing}) async {
    final from = _lastRider;
    final fromBearing = _lastBearing;
    if (from == null) {
      await setRider(next, bearing: bearing);
      return;
    }
    final snapped = _routePoints.length >= 2
        ? PolylineMath.snapToRoute(next, _routePoints, maxMeters: 30)
        : null;
    final target = snapped?.point ?? next;
    final targetBearing = bearing ??
        PolylineMath.bearingDegrees(from, target);
    final gen = ++_moveGen;
    const steps = 18;
    const total = Duration(milliseconds: 900);
    for (var i = 1; i <= steps; i++) {
      if (gen != _moveGen) return;
      final t = i / steps;
      final cur = GeoPoint(
        lat: from.lat + (target.lat - from.lat) * t,
        lng: from.lng + (target.lng - from.lng) * t,
      );
      final br = PolylineMath.lerpBearing(fromBearing, targetBearing, t);
      await setRider(cur, bearing: br);
      if (i == steps || i % 3 == 0) {
        await updateRouteProgress(cur);
      }
      await Future<void>.delayed(total ~/ steps);
    }
    if (gen == _moveGen) _lastRider = target;
  }

  /// Draws casing + remaining (terracotta) + empty travelled layers from [route].
  Future<void> drawRoadRoute(RoadRoute route) async {
    final map = _map;
    if (map == null) return;
    _routePoints = route.points;
    final full = route.lineStringGeoJson;
    await _upsertLineSource(MapConstants.routeSourceId, full);
    await _ensureLineLayer(
      id: MapConstants.routeCasingLayerId,
      sourceId: MapConstants.routeSourceId,
      color: const ColorValue(0xFF1C1917),
      width: 8,
      opacity: 0.55,
    );
    await _ensureLineLayer(
      id: MapConstants.routeLayerId,
      sourceId: MapConstants.routeSourceId,
      color: ColorValue(AppColors.primary.toARGB32()),
      width: 5,
      opacity: 1,
    );
    // Travelled source starts as a no-op until progress updates.
    if (!await map.styleSourceExists(MapConstants.routeTravelledSourceId)) {
      final seed = RoadRoute.lineStringFrom([route.points.first, route.points.first]);
      await map.addSource(
        GeoJsonSource(id: MapConstants.routeTravelledSourceId, data: seed),
      );
    }
    await _ensureLineLayer(
      id: MapConstants.routeTravelledLayerId,
      sourceId: MapConstants.routeTravelledSourceId,
      color: const ColorValue(0xFFA8A29E),
      width: 5,
      opacity: 0.85,
    );
  }

  /// Clears all route layers (used when routing fails).
  Future<void> clearRoute() async {
    final map = _map;
    if (map == null) return;
    _routePoints = const [];
    for (final id in [
      MapConstants.routeTravelledLayerId,
      MapConstants.routeLayerId,
      MapConstants.routeCasingLayerId,
    ]) {
      if (await map.styleLayerExists(id)) {
        await map.removeStyleLayer(id);
      }
    }
    for (final id in [
      MapConstants.routeTravelledSourceId,
      MapConstants.routeSourceId,
    ]) {
      if (await map.styleSourceExists(id)) {
        await map.removeStyleSource(id);
      }
    }
  }

  /// Updates travelled / remaining split at [rider] (throttled ~400ms).
  Future<void> updateRouteProgress(GeoPoint rider) async {
    final map = _map;
    if (map == null || _routePoints.length < 2) return;
    final now = DateTime.now();
    if (_lastSplitAt != null &&
        now.difference(_lastSplitAt!) < const Duration(milliseconds: 400)) {
      return;
    }
    _lastSplitAt = now;
    final split = PolylineMath.splitAt(_routePoints, rider);
    if (split.travelled.length >= 2) {
      await _upsertLineSource(
        MapConstants.routeTravelledSourceId,
        RoadRoute.lineStringFrom(split.travelled),
      );
    }
    if (split.remaining.length >= 2) {
      await _upsertLineSource(
        MapConstants.routeSourceId,
        RoadRoute.lineStringFrom(split.remaining),
      );
    }
  }

  /// Legacy single-layer draw — prefer [drawRoadRoute].
  Future<void> drawRoute(String lineStringGeoJson) async {
    final map = _map;
    if (map == null) return;
    await _upsertLineSource(MapConstants.routeSourceId, lineStringGeoJson);
    await _ensureLineLayer(
      id: MapConstants.routeLayerId,
      sourceId: MapConstants.routeSourceId,
      color: ColorValue(AppColors.primary.toARGB32()),
      width: 5,
      opacity: 1,
    );
  }

  /// Fits [points] with padding for top card + bottom sheet. Clamps zoom 14–17.
  Future<void> fitPoints(
    List<GeoPoint> points, {
    double top = 140,
    double bottom = 300,
    double left = 48,
    double right = 48,
  }) async {
    final map = _map;
    if (map == null || points.isEmpty) return;
    if (points.length == 1) {
      await flyTo(points.first, zoom: 16);
      return;
    }
    var minLat = points.first.lat;
    var maxLat = points.first.lat;
    var minLng = points.first.lng;
    var maxLng = points.first.lng;
    for (final p in points.skip(1)) {
      minLat = math.min(minLat, p.lat);
      maxLat = math.max(maxLat, p.lat);
      minLng = math.min(minLng, p.lng);
      maxLng = math.max(maxLng, p.lng);
    }
    // Pad tiny bounds so fit doesn't explode to city level.
    if ((maxLat - minLat).abs() < 0.002) {
      minLat -= 0.003;
      maxLat += 0.003;
    }
    if ((maxLng - minLng).abs() < 0.002) {
      minLng -= 0.003;
      maxLng += 0.003;
    }
    final cam = await map.cameraForCoordinateBounds(
      CoordinateBounds(
        southwest: Point(coordinates: Position(minLng, minLat)),
        northeast: Point(coordinates: Position(maxLng, maxLat)),
        infiniteBounds: false,
      ),
      MbxEdgeInsets(top: top, left: left, bottom: bottom, right: right),
      null,
      null,
      null,
      null,
    );
    final zoom = (cam.zoom ?? MapConstants.defaultZoom)
        .clamp(MapConstants.trackingMinZoom, MapConstants.trackingMaxZoom);
    await map.easeTo(
      CameraOptions(
        center: cam.center,
        zoom: zoom,
        bearing: cam.bearing,
        pitch: cam.pitch,
      ),
      MapAnimationOptions(duration: 800, startDelay: 0),
    );
  }

  /// Fits pickup + drop with padding for a bottom sheet.
  Future<void> fitStops(GeoPoint a, GeoPoint b) => fitPoints([a, b]);

  /// Rider follow mode: zoom ~17, pitch 50, bearing along heading.
  Future<void> followRider(
    GeoPoint rider, {
    double bearing = 0,
    double zoom = 16.5,
    double pitch = 50,
  }) async {
    final map = _map;
    if (map == null) return;
    await map.easeTo(
      CameraOptions(
        center: toMapbox(rider),
        zoom: zoom.clamp(
          MapConstants.trackingMinZoom,
          MapConstants.trackingMaxZoom,
        ),
        bearing: bearing,
        pitch: pitch,
      ),
      MapAnimationOptions(duration: 700, startDelay: 0),
    );
  }

  /// Animated camera move.
  Future<void> flyTo(GeoPoint point, {double zoom = 16}) async {
    final map = _map;
    if (map == null) return;
    await map.flyTo(
      CameraOptions(
        center: toMapbox(point),
        zoom: zoom.clamp(
          MapConstants.trackingMinZoom,
          MapConstants.trackingMaxZoom,
        ),
      ),
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

  Future<void> _upsertLineSource(String id, String geoJson) async {
    final map = _map!;
    if (await map.styleSourceExists(id)) {
      final src = await map.getSource(id);
      if (src is GeoJsonSource) {
        await src.updateGeoJSON(geoJson);
      }
      return;
    }
    await map.addSource(GeoJsonSource(id: id, data: geoJson));
  }

  Future<void> _ensureLineLayer({
    required String id,
    required String sourceId,
    required ColorValue color,
    required double width,
    required double opacity,
  }) async {
    final map = _map!;
    if (await map.styleLayerExists(id)) return;
    await map.addLayer(
      LineLayer(
        id: id,
        sourceId: sourceId,
        lineColor: color.value,
        lineWidth: width,
        lineOpacity: opacity,
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
      ),
    );
  }

  Future<CircleAnnotation> _upsert({
    required CircleAnnotation? existing,
    required GeoPoint point,
    required int color,
    required double radius,
    int? stroke,
    double strokeWidth = 2,
  }) async {
    final circles = _circles!;
    final geometry = toMapbox(point);
    if (existing != null) {
      existing.geometry = geometry;
      existing.circleColor = color;
      existing.circleRadius = radius;
      existing.circleStrokeColor = stroke;
      existing.circleStrokeWidth = stroke == null ? null : strokeWidth;
      await circles.update(existing);
      return existing;
    }
    return await circles.create(
      CircleAnnotationOptions(
        geometry: geometry,
        circleColor: color,
        circleRadius: radius,
        circleStrokeColor: stroke,
        circleStrokeWidth: stroke == null ? null : strokeWidth,
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
    _routePoints = const [];
  }
}

/// Tiny wrapper so Mapbox line color ints stay typed in call sites.
class ColorValue {
  const ColorValue(this.value);
  final int value;
}
