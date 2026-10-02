import 'dart:async';

import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/core/polyline_math.dart';
import 'package:attock_xpress/features/map/presentation/bhook_map.dart';
import 'package:attock_xpress/features/map/presentation/desktop_fallback_map.dart';
import 'package:attock_xpress/features/map/presentation/map_session.dart';
import 'package:attock_xpress/features/map/presentation/providers/map_providers.dart';
import 'package:attock_xpress/features/map/presentation/widgets/route_unavailable_chip.dart';
import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/presentation/providers/tracking_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Live customer tracking map with road-following route + progress split.
class TrackingMap extends ConsumerStatefulWidget {
  /// Creates the tracking map for [orderId].
  const new({required this.orderId, super.key});

  /// Order whose rider is followed.
  final String orderId;

  @override
  ConsumerState<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends ConsumerState<TrackingMap> {
  final _session = MapSession();
  var _ready = false;
  var _routeUnavailable = false;
  var _almostThere = false;
  var _etaMinutes = 0;
  GeoPoint _rider = MapConstants.samplePickup;
  List<GeoPoint> _route = const [];
  List<GeoPoint> _travelled = const [];
  int _offRouteStreak = 0;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<RiderLocation>>(
      riderLocationProvider(widget.orderId),
      (previous, next) {
        next.whenData((fix) {
          unawaited(_onFix(GeoPoint(lat: fix.lat, lng: fix.lng)));
        });
      },
    );

    if (!AppConfig.canUseMapbox) {
      return Stack(
        children: [
          DesktopFallbackMap(
            center: _rider,
            zoom: 15,
            route: _route,
            travelledRoute: _travelled,
            markers: [
              const DesktopMapMarker(
                point: MapConstants.samplePickup,
                color: AppColors.gold,
                icon: Icons.storefront,
                label: 'Store',
              ),
              DesktopMapMarker(
                point: MapConstants.sampleDrop,
                color: AppColors.primary,
                icon: Icons.home,
                label: _etaMinutes > 0 ? '$_etaMinutes min' : 'You',
                pulse: true,
              ),
              DesktopMapMarker(
                point: _rider,
                color: AppColors.primary,
                icon: Icons.two_wheeler,
                ring: true,
              ),
            ],
          ),
          if (_routeUnavailable)
            const Positioned(
              top: 12,
              left: 12,
              child: RouteUnavailableChip(),
            ),
          if (_almostThere)
            const Positioned(
              top: 12,
              right: 12,
              child: RouteUnavailableChip(label: 'Your rider is almost there'),
            ),
        ],
      );
    }

    return Stack(
      children: [
        BhookMap(
          center: MapConstants.zoneCenter,
          zoom: 15,
          onReady: _onReady,
        ),
        if (_routeUnavailable)
          const Positioned(
            top: 12,
            left: 12,
            child: RouteUnavailableChip(),
          ),
        if (_almostThere)
          const Positioned(
            top: 12,
            right: 12,
            child: RouteUnavailableChip(label: 'Your rider is almost there'),
          ),
      ],
    );
  }

  Future<void> _onReady(MapboxMap map) async {
    await _session.attach(map);
    await _session.setStops(
      pickup: MapConstants.samplePickup,
      drop: MapConstants.sampleDrop,
      emphasizePickup: false,
    );
    await _loadRoute(
      origin: MapConstants.samplePickup,
      destination: MapConstants.sampleDrop,
      legKey: 'customer-${widget.orderId}-drop',
    );
    final first = ref.read(riderLocationProvider(widget.orderId)).asData?.value;
    final start = first == null
        ? MapConstants.samplePickup
        : GeoPoint(lat: first.lat, lng: first.lng);
    await _session.setRider(start);
    await _session.fitPoints(
      [start, MapConstants.sampleDrop],
      top: 120,
      bottom: 280,
    );
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _loadRoute({
    required GeoPoint origin,
    required GeoPoint destination,
    required String legKey,
    bool forceRefresh = false,
  }) async {
    final route = await ref.read(routingServiceProvider).fetchLeg(
          legKey: legKey,
          origin: origin,
          destination: destination,
          forceRefresh: forceRefresh,
        );
    if (!mounted) return;
    if (route == null) {
      setState(() {
        _routeUnavailable = true;
        _route = const [];
        _travelled = const [];
        _etaMinutes = 0;
      });
      if (AppConfig.canUseMapbox) await _session.clearRoute();
      return;
    }
    setState(() {
      _routeUnavailable = false;
      _route = route.points;
      _travelled = const [];
      _etaMinutes = route.durationMinutes;
    });
    if (AppConfig.canUseMapbox) {
      await _session.drawRoadRoute(route);
    }
  }

  Future<void> _onFix(GeoPoint raw) async {
    if (!AppConfig.canUseMapbox) {
      await _onDesktopFix(raw);
      return;
    }
    if (!_ready) return;

    if (_route.length >= 2) {
      final snap = PolylineMath.snapToRoute(raw, _route, maxMeters: 30);
      final off = PolylineMath.snapToRoute(raw, _route, maxMeters: 40) == null;
      if (off) {
        _offRouteStreak++;
      } else {
        _offRouteStreak = 0;
      }
      if (_offRouteStreak >= 3) {
        _offRouteStreak = 0;
        if (mounted) {
          setState(() => _routeUnavailable = false);
        }
        await _loadRoute(
          origin: raw,
          destination: MapConstants.sampleDrop,
          legKey: 'customer-${widget.orderId}-drop',
          forceRefresh: true,
        );
      }
      final point = snap?.point ?? raw;
      final dist = PolylineMath.distanceMeters(point, MapConstants.sampleDrop);
      if (mounted) {
        setState(() => _almostThere = dist < 300);
      }
      await _session.moveRider(point);
      await _session.fitPoints(
        [point, MapConstants.sampleDrop],
        top: 120,
        bottom: 280,
      );
      return;
    }
    await _session.moveRider(raw);
  }

  Future<void> _onDesktopFix(GeoPoint raw) async {
    var point = raw;
    if (_route.length >= 2) {
      final snap = PolylineMath.snapToRoute(raw, _route, maxMeters: 30);
      point = snap?.point ?? raw;
      final split = PolylineMath.splitAt(_route, point);
      final dist = PolylineMath.distanceMeters(point, MapConstants.sampleDrop);
      if (mounted) {
        setState(() {
          _rider = point;
          _travelled = split.travelled;
          _almostThere = dist < 300;
        });
      }
      return;
    }
    if (mounted) setState(() => _rider = point);
  }
}
