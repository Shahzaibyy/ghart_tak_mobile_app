import 'dart:async';

import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/presentation/bhook_map.dart';
import 'package:attock_xpress/features/map/presentation/desktop_fallback_map.dart';
import 'package:attock_xpress/features/map/presentation/map_session.dart';
import 'package:attock_xpress/features/map/presentation/providers/map_providers.dart';
import 'package:attock_xpress/features/map/presentation/widgets/route_unavailable_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Rider active-task map with road route + Google Maps hand-off.
class RiderTaskMap extends ConsumerStatefulWidget {
  /// Creates the rider task map.
  const new({
    required this.toDropoff,
    super.key,
  });

  /// Whether the current leg is drop-off.
  final bool toDropoff;

  @override
  ConsumerState<RiderTaskMap> createState() => _RiderTaskMapState();
}

class _RiderTaskMapState extends ConsumerState<RiderTaskMap> {
  final _session = MapSession();
  var _routeUnavailable = false;
  var _etaMinutes = 0;
  var _rerouting = false;
  List<GeoPoint> _route = const [];
  List<GeoPoint> _travelled = const [];
  late GeoPoint _rider;
  late GeoPoint _destination;

  @override
  void initState() {
    super.initState();
    _destination = widget.toDropoff
        ? MapConstants.sampleDrop
        : MapConstants.samplePickup;
    _rider = widget.toDropoff
        ? MapConstants.samplePickup
        : MapConstants.zoneCenter;
  }

  @override
  void didUpdateWidget(covariant RiderTaskMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.toDropoff != widget.toDropoff) {
      _destination = widget.toDropoff
          ? MapConstants.sampleDrop
          : MapConstants.samplePickup;
      unawaited(_loadRoute(forceRefresh: true));
    }
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapBody = !AppConfig.canUseMapbox
        ? DesktopFallbackMap(
            center: _rider,
            zoom: 16.5,
            route: _route,
            travelledRoute: _travelled,
            markers: [
              DesktopMapMarker(
                point: MapConstants.samplePickup,
                color: AppColors.gold,
                icon: Icons.storefront,
                label: widget.toDropoff ? '1' : '1 · Pickup',
              ),
              DesktopMapMarker(
                point: MapConstants.sampleDrop,
                color: AppColors.primary,
                icon: Icons.home,
                label: widget.toDropoff
                    ? (_etaMinutes > 0 ? '2 · $_etaMinutes min' : '2')
                    : '2',
                pulse: widget.toDropoff,
              ),
              DesktopMapMarker(
                point: _rider,
                color: AppColors.primary,
                icon: Icons.two_wheeler,
                ring: true,
              ),
            ],
          )
        : BhookMap(
            center: _rider,
            zoom: 16.5,
            onReady: _onReady,
          );

    return Stack(
      children: [
        Positioned.fill(child: mapBody),
        if (_routeUnavailable || _rerouting)
          Positioned(
            top: 12,
            left: 12,
            child: RouteUnavailableChip(
              label: _rerouting ? 'Rerouting…' : 'Route unavailable',
            ),
          ),
        Positioned(
          right: 16,
          bottom: 300,
          child: FloatingActionButton.extended(
            heroTag: 'rider-navigate',
            backgroundColor: AppColors.text,
            foregroundColor: AppColors.surface,
            onPressed: _openExternalNav,
            icon: const Icon(Icons.navigation),
            label: const Text('Navigate'),
          ),
        ),
      ],
    );
  }

  Future<void> _onReady(MapboxMap map) async {
    await _session.attach(map);
    await _session.setStops(
      pickup: MapConstants.samplePickup,
      drop: MapConstants.sampleDrop,
      emphasizePickup: !widget.toDropoff,
    );
    await _session.setRider(_rider);
    await _loadRoute();
    await _session.followRider(_rider, pitch: 50, zoom: 16.5);
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      await _session.enablePuck();
    }
  }

  Future<void> _loadRoute({bool forceRefresh = false}) async {
    if (mounted) setState(() => _rerouting = forceRefresh);
    final legKey =
        'rider-${widget.toDropoff ? 'drop' : 'pickup'}-${_destination.lat}';
    final route = await ref.read(routingServiceProvider).fetchLeg(
          legKey: legKey,
          origin: _rider,
          destination: _destination,
          forceRefresh: forceRefresh,
        );
    if (!mounted) return;
    if (route == null) {
      setState(() {
        _routeUnavailable = true;
        _rerouting = false;
        _route = const [];
        _travelled = const [];
        _etaMinutes = 0;
      });
      if (AppConfig.canUseMapbox) await _session.clearRoute();
      return;
    }
    setState(() {
      _routeUnavailable = false;
      _rerouting = false;
      _route = route.points;
      _travelled = const [];
      _etaMinutes = route.durationMinutes;
    });
    if (AppConfig.canUseMapbox) {
      await _session.drawRoadRoute(route);
      await _session.fitPoints(
        [_rider, _destination],
        top: 160,
        bottom: 320,
      );
    }
  }

  Future<void> _openExternalNav() async {
    await openGoogleNavigation(_destination);
  }
}

/// Hands off turn-by-turn to Google Maps (Maps SDK has no navigation).
Future<void> openGoogleNavigation(GeoPoint p) async {
  final uri = Uri.parse('google.navigation:q=${p.lat},${p.lng}&mode=d');
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (ok) return;
  final web = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=${p.lat},${p.lng}&travelmode=driving',
  );
  await launchUrl(web, mode: LaunchMode.externalApplication);
}
