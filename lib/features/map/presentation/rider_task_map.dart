import 'dart:async';

import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/data/sample_route.dart';
import 'package:attock_xpress/features/map/presentation/bhook_map.dart';
import 'package:attock_xpress/features/map/presentation/map_session.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/widgets/route_sketch.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Rider active-task map with route + Google Maps hand-off.
class RiderTaskMap extends StatefulWidget {
  /// Creates the rider task map.
  const new({
    required this.toDropoff,
    super.key,
  });

  /// Whether the current leg is drop-off.
  final bool toDropoff;

  @override
  State<RiderTaskMap> createState() => _RiderTaskMapState();
}

class _RiderTaskMapState extends State<RiderTaskMap> {
  final _session = MapSession();

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasMapboxToken) {
      return RouteSketch(toDropoff: widget.toDropoff);
    }
    return Stack(
      children: [
        BhookMap(
          center: MapConstants.attockCenter,
          zoom: 14,
          onReady: _onReady,
        ),
        Positioned(
          right: 16,
          bottom: 280,
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
    );
    await _session.drawRoute(SampleRoute.lineStringGeoJson);
    await _session.fitStops(
      MapConstants.samplePickup,
      MapConstants.sampleDrop,
    );
    await _session.setRider(
      widget.toDropoff
          ? MapConstants.attockCenter
          : MapConstants.samplePickup,
    );
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      await _session.enablePuck();
    }
  }

  Future<void> _openExternalNav() async {
    final target = widget.toDropoff
        ? MapConstants.sampleDrop
        : MapConstants.samplePickup;
    await openGoogleNavigation(target);
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
