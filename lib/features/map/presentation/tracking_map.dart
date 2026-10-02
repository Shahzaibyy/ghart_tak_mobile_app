import 'dart:async';

import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/data/sample_route.dart';
import 'package:attock_xpress/features/map/presentation/bhook_map.dart';
import 'package:attock_xpress/features/map/presentation/desktop_fallback_map.dart';
import 'package:attock_xpress/features/map/presentation/map_session.dart';
import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/presentation/providers/tracking_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Live customer tracking map.
///
/// Uses the Maps SDK on Android/iOS; on Linux shows Mapbox raster tiles via
/// [DesktopFallbackMap] so the seeded Fateh Jang route is still visible.
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
  GeoPoint _rider = MapConstants.samplePickup;

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
          final point = GeoPoint(lat: fix.lat, lng: fix.lng);
          if (!AppConfig.canUseMapbox) {
            if (mounted) setState(() => _rider = point);
            return;
          }
          if (!_ready) return;
          unawaited(_session.moveRider(point));
        });
      },
    );

    if (!AppConfig.canUseMapbox) {
      final live =
          ref.watch(riderLocationProvider(widget.orderId)).asData?.value;
      final rider = live == null
          ? _rider
          : GeoPoint(lat: live.lat, lng: live.lng);
      return DesktopFallbackMap(
        center: MapConstants.zoneCenter,
        zoom: 14,
        route: SampleRoute.points,
        markers: [
          DesktopMapMarker(
            point: MapConstants.samplePickup,
            color: AppColors.gold,
            icon: Icons.storefront,
          ),
          DesktopMapMarker(
            point: MapConstants.sampleDrop,
            color: AppColors.primary,
          ),
          DesktopMapMarker(
            point: rider,
            color: AppColors.text,
            icon: Icons.delivery_dining,
          ),
        ],
      );
    }

    return BhookMap(
      center: MapConstants.zoneCenter,
      zoom: 14,
      onReady: _onReady,
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
    final first = ref.read(riderLocationProvider(widget.orderId)).asData?.value;
    if (first != null) {
      await _session.setRider(GeoPoint(lat: first.lat, lng: first.lng));
    } else {
      await _session.setRider(MapConstants.samplePickup);
    }
    if (mounted) setState(() => _ready = true);
  }
}
