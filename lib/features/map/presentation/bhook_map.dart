import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/core/mapbox_codec.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Reusable Mapbox map shell. Stable key; Mapbox types stay in this feature.
class BhookMap extends StatefulWidget {
  /// Creates the map centred on [center].
  const new({
    required this.center,
    required this.onReady,
    this.zoom = MapConstants.defaultZoom,
    this.onMapIdle,
    this.styleUri = MapboxStyles.MAPBOX_STREETS,
    super.key,
  });

  /// Initial camera centre (app GeoPoint: lat, lng).
  final GeoPoint center;

  /// Initial zoom.
  final double zoom;

  /// Style URI — Streets by default for low–mid devices.
  final String styleUri;

  /// Called once after gestures / ornaments are configured.
  final void Function(MapboxMap map) onReady;

  /// Optional idle callback (address picker debounce).
  final VoidCallback? onMapIdle;

  @override
  State<BhookMap> createState() => _BhookMapState();
}

class _BhookMapState extends State<BhookMap> {
  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey('bhook-map'),
      styleUri: widget.styleUri,
      viewport: CameraViewportState(
        center: toMapbox(widget.center),
        zoom: widget.zoom,
      ),
      onMapCreated: _onMapCreated,
      onMapIdleListener: widget.onMapIdle == null
          ? null
          : (_) => widget.onMapIdle!(),
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    await map.gestures.updateSettings(
      GesturesSettings(rotateEnabled: false, pitchEnabled: false),
    );
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await map.setBounds(
      CameraBoundsOptions(
        bounds: CoordinateBounds(
          southwest: Point(
            coordinates: Position(
              MapConstants.southwestLng,
              MapConstants.southwestLat,
            ),
          ),
          northeast: Point(
            coordinates: Position(
              MapConstants.northeastLng,
              MapConstants.northeastLat,
            ),
          ),
          infiniteBounds: false,
        ),
        minZoom: MapConstants.minZoom,
        maxZoom: MapConstants.maxZoom,
      ),
    );
    widget.onReady(map);
  }
}
