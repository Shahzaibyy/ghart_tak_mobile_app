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
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/presentation/providers/tracking_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Customer live-tracking map (Uber / Foodpanda style by [status] phase).
class TrackingMap extends ConsumerStatefulWidget {
  /// Creates the tracking map.
  const new({
    required this.orderId,
    required this.status,
    super.key,
  });

  /// Order whose rider is followed.
  final String orderId;

  /// Current order lifecycle — controls which leg and markers are shown.
  final OrderStatus status;

  @override
  ConsumerState<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends ConsumerState<TrackingMap> {
  final _session = MapSession();
  var _ready = false;
  var _attached = false;
  var _loadingRoute = true;
  var _routeUnavailable = false;
  var _almostThere = false;
  var _rerouting = false;
  var _etaMinutes = 0;
  GeoPoint _rider = MapConstants.samplePickup;
  List<GeoPoint> _route = const [];
  List<GeoPoint> _travelled = const [];
  int _offRouteStreak = 0;

  GeoPoint get _store => MapConstants.samplePickup;
  GeoPoint get _home => MapConstants.sampleDrop;

  bool get _showRider {
    return switch (widget.status) {
      Accepted() || PickedUp() => true,
      _ => false,
    };
  }

  bool get _toCustomer => widget.status is PickedUp;

  GeoPoint get _destination => _toCustomer ? _home : _store;

  @override
  void initState() {
    super.initState();
    // Load road route for both Mapbox SDK and flutter_map paths.
    unawaited(_bootstrap());
  }

  @override
  void didUpdateWidget(covariant TrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status.runtimeType != widget.status.runtimeType) {
      unawaited(_reloadForStatus());
    }
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showRider) {
      ref.listen<AsyncValue<RiderLocation>>(
        riderLocationProvider(widget.orderId),
        (previous, next) {
          next.whenData((fix) {
            unawaited(_onFix(GeoPoint(lat: fix.lat, lng: fix.lng)));
          });
        },
      );
    }

    final markers = <DesktopMapMarker>[
      DesktopMapMarker(
        point: _store,
        color: AppColors.gold,
        icon: Icons.storefront,
        label: 'Store',
      ),
      DesktopMapMarker(
        point: _offsetIfClose(_home, _store),
        color: AppColors.primary,
        icon: Icons.home,
        label: _etaMinutes > 0 && _toCustomer
            ? '$_etaMinutes min'
            : 'Home',
        pulse: _toCustomer || widget.status is Placed,
      ),
      if (_showRider)
        DesktopMapMarker(
          point: _rider,
          color: AppColors.primary,
          icon: Icons.two_wheeler,
          ring: true,
          label: _etaMinutes > 0 && !_toCustomer ? '$_etaMinutes min' : null,
        ),
    ];

    final chip = _loadingRoute
        ? const RouteUnavailableChip(label: 'Getting road route…')
        : _rerouting
            ? const RouteUnavailableChip(label: 'Rerouting…')
            : _routeUnavailable
                ? const RouteUnavailableChip()
                : _almostThere
                    ? const RouteUnavailableChip(
                        label: 'Your rider is almost there',
                      )
                    : null;

    if (!AppConfig.canUseMapbox) {
      return Stack(
        children: [
          DesktopFallbackMap(
            center: _showRider ? _rider : _midpoint(_store, _home),
            zoom: 15.2,
            route: _route,
            travelledRoute: _travelled,
            markers: markers,
          ),
          if (chip != null)
            Positioned(top: 12, left: 12, child: chip),
        ],
      );
    }

    return Stack(
      children: [
        BhookMap(
          center: _midpoint(_store, _home),
          zoom: 15.2,
          onReady: _onReady,
        ),
        if (chip != null)
          Positioned(top: 12, left: 12, child: chip),
      ],
    );
  }

  Future<void> _bootstrap() async {
    await _reloadForStatus();
    if (!AppConfig.canUseMapbox && mounted) {
      setState(() => _ready = true);
    }
  }

  Future<void> _reloadForStatus() async {
    switch (widget.status) {
      case Accepted():
        // Rider en route to the store (Uber pickup leg).
        final approaching = GeoPoint(
          lat: _store.lat - 0.004,
          lng: _store.lng - 0.003,
        );
        _rider = approaching;
        await _loadRoute(
          origin: approaching,
          destination: _store,
          legKey: 'customer-${widget.orderId}-to-store',
          forceRefresh: true,
        );
        await _fitLive();
      case PickedUp():
        // Rider en route to the customer (delivery leg).
        _rider = _store;
        await _loadRoute(
          origin: _store,
          destination: _home,
          legKey: 'customer-${widget.orderId}-to-home',
          forceRefresh: true,
        );
        await _fitLive();
      case Placed() || Delivered() || Cancelled():
        // Preview store → home corridor while matching a rider.
        _rider = _store;
        await _loadRoute(
          origin: _store,
          destination: _home,
          legKey: 'customer-${widget.orderId}-preview',
        );
        await _fitPreview();
    }
  }

  Future<void> _onReady(MapboxMap map) async {
    await _session.attach(map);
    _attached = true;
    await _session.setStops(
      pickup: _store,
      drop: _home,
      emphasizePickup: widget.status is Accepted,
    );
    if (_route.length >= 2) {
      final cached = await ref.read(routingServiceProvider).fetchLeg(
            legKey: _legKeyForStatus(),
            origin: switch (widget.status) {
              Accepted() => _rider,
              PickedUp() => _store,
              _ => _store,
            },
            destination: _destinationForStatus(),
          );
      if (cached != null) await _session.drawRoadRoute(cached);
    } else {
      await _reloadForStatus();
    }
    if (_showRider) {
      await _session.setRider(_rider);
    }
    if (mounted) setState(() => _ready = true);
    await _fitForSdk();
  }

  String _legKeyForStatus() {
    return switch (widget.status) {
      Accepted() => 'customer-${widget.orderId}-to-store',
      PickedUp() => 'customer-${widget.orderId}-to-home',
      _ => 'customer-${widget.orderId}-preview',
    };
  }

  GeoPoint _destinationForStatus() {
    return switch (widget.status) {
      Accepted() => _store,
      PickedUp() => _home,
      _ => _home,
    };
  }

  Future<void> _loadRoute({
    required GeoPoint origin,
    required GeoPoint destination,
    required String legKey,
    bool forceRefresh = false,
  }) async {
    if (mounted) {
      setState(() {
        _loadingRoute = true;
        _routeUnavailable = false;
        _rerouting = forceRefresh;
      });
    }
    final route = await ref.read(routingServiceProvider).fetchLeg(
          legKey: legKey,
          origin: origin,
          destination: destination,
          forceRefresh: forceRefresh,
        );
    if (!mounted) return;
    if (route == null) {
      setState(() {
        _loadingRoute = false;
        _rerouting = false;
        _routeUnavailable = true;
        _route = const [];
        _travelled = const [];
        _etaMinutes = 0;
      });
      if (AppConfig.canUseMapbox && _attached) await _session.clearRoute();
      return;
    }
    setState(() {
      _loadingRoute = false;
      _rerouting = false;
      _routeUnavailable = false;
      _route = route.points;
      _travelled = const [];
      _etaMinutes = route.durationMinutes;
    });
    if (AppConfig.canUseMapbox && _attached) {
      await _session.drawRoadRoute(route);
    }
  }

  Future<void> _fitPreview() async {
    if (AppConfig.canUseMapbox && _ready) {
      await _session.fitPoints(
        [_store, _home],
        top: 100,
        bottom: 300,
      );
    }
  }

  Future<void> _fitLive() async {
    if (AppConfig.canUseMapbox && _ready) {
      await _session.fitPoints(
        [_rider, _destination],
        top: 100,
        bottom: 300,
      );
    }
  }

  Future<void> _fitForSdk() async {
    final points = _showRider ? [_rider, _destination] : [_store, _home];
    await _session.fitPoints(points, top: 100, bottom: 300);
  }

  Future<void> _onFix(GeoPoint raw) async {
    if (!_showRider) return;
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
        await _loadRoute(
          origin: raw,
          destination: _destination,
          legKey: _legKeyForStatus(),
          forceRefresh: true,
        );
      }
      final point = snap?.point ?? raw;
      final target = _destination;
      final dist = PolylineMath.distanceMeters(point, target);
      if (mounted) {
        setState(() {
          _rider = point;
          _almostThere = _toCustomer && dist < 300;
        });
      }
      await _session.moveRider(point);
      await _session.fitPoints([point, target], top: 100, bottom: 300);
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
      final dist = PolylineMath.distanceMeters(point, _destination);
      if (mounted) {
        setState(() {
          _rider = point;
          _travelled = split.travelled;
          _almostThere = _toCustomer && dist < 300;
        });
      }
      return;
    }
    if (mounted) setState(() => _rider = point);
  }

  GeoPoint _midpoint(GeoPoint a, GeoPoint b) {
    return GeoPoint(lat: (a.lat + b.lat) / 2, lng: (a.lng + b.lng) / 2);
  }

  /// Nudge home pin when it sits on top of the store.
  GeoPoint _offsetIfClose(GeoPoint a, GeoPoint b) {
    final d = PolylineMath.distanceMeters(a, b);
    if (d > 40) return a;
    return GeoPoint(lat: a.lat + 0.00035, lng: a.lng + 0.00035);
  }
}
