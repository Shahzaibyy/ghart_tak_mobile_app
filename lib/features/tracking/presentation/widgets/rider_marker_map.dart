import 'dart:async';

import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Map that moves the rider marker without recreating the platform view.
class RiderMarkerMap extends StatefulWidget {
  /// Creates a map centered on [location].
  const new({required this.location, super.key});

  /// Latest rider fix.
  final RiderLocation location;

  @override
  State<RiderMarkerMap> createState() => _RiderMarkerMapState();
}

class _RiderMarkerMapState extends State<RiderMarkerMap> {
  GoogleMapController? _controller;
  Set<Marker> _markers = const {};

  @override
  void initState() {
    super.initState();
    _markers = _markerFor(widget.location);
  }

  @override
  void didUpdateWidget(RiderMarkerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.location;
    final previous = oldWidget.location;
    if (next.lat == previous.lat && next.lng == previous.lng) return;
    _markers = _markerFor(next);
    _panTo(next);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = LatLng(widget.location.lat, widget.location.lng);
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: target, zoom: 15),
      markers: _markers,
      myLocationButtonEnabled: false,
      onMapCreated: (controller) => _controller = controller,
    );
  }

  void _panTo(RiderLocation location) {
    final controller = _controller;
    if (controller == null) return;
    unawaited(
      controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(location.lat, location.lng)),
      ),
    );
  }

  Set<Marker> _markerFor(RiderLocation location) {
    return {
      Marker(
        markerId: const MarkerId('rider'),
        position: LatLng(location.lat, location.lng),
      ),
    };
  }
}
