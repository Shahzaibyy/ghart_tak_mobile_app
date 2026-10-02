import 'dart:async';

import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/data/sample_route.dart';
import 'package:attock_xpress/features/map/presentation/bhook_map.dart';
import 'package:attock_xpress/features/map/presentation/map_session.dart';
import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/presentation/providers/tracking_providers.dart';
import 'package:attock_xpress/features/tracking/presentation/widgets/customer_route_sketch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Live customer tracking map.
/// Falls back to the sketch when the token is missing.
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

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasMapboxToken) {
      return const CustomerRouteSketch();
    }

    ref.listen<AsyncValue<RiderLocation>>(
      riderLocationProvider(widget.orderId),
      (previous, next) {
        next.whenData((fix) {
          if (!_ready) return;
          unawaited(
            _session.moveRider(GeoPoint(lat: fix.lat, lng: fix.lng)),
          );
        });
      },
    );

    return BhookMap(
      center: MapConstants.attockCenter,
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
