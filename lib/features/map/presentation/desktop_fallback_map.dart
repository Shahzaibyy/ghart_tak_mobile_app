import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Desktop / unsupported-platform map using Mapbox raster tiles (or OSM).
///
/// `mapbox_maps_flutter` has no Linux plugin — this is the Linux showcase path
/// so seed merchant pins and tracking still show a real basemap.
class DesktopFallbackMap extends StatelessWidget {
  /// Creates a fallback map.
  const new({
    required this.center,
    this.zoom = MapConstants.defaultZoom,
    this.markers = const [],
    this.route = const [],
    this.onMapEvent,
    this.mapController,
    super.key,
  });

  final GeoPoint center;
  final double zoom;
  final List<DesktopMapMarker> markers;
  final List<GeoPoint> route;
  final void Function(MapEvent event)? onMapEvent;
  final MapController? mapController;

  @override
  Widget build(BuildContext context) {
    final token = AppConfig.mapboxAccessToken;
    final hasToken = token.isNotEmpty;
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(center.lat, center.lng),
        initialZoom: zoom,
        minZoom: MapConstants.minZoom,
        maxZoom: MapConstants.maxZoom,
        onMapEvent: onMapEvent,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: hasToken
              ? 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}@2x?access_token=$token'
              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ghartak.bhooklagi',
          maxZoom: 19,
          tileDimension: hasToken ? 512 : 256,
          zoomOffset: hasToken ? -1 : 0,
        ),
        if (route.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  for (final p in route) LatLng(p.lat, p.lng),
                ],
                color: AppColors.primary,
                strokeWidth: 4,
              ),
            ],
          ),
        if (markers.isNotEmpty)
          MarkerLayer(
            markers: [
              for (final m in markers)
                Marker(
                  point: LatLng(m.point.lat, m.point.lng),
                  width: 36,
                  height: 36,
                  child: Icon(m.icon, color: m.color, size: 32),
                ),
            ],
          ),
      ],
    );
  }
}

/// A simple coloured pin for [DesktopFallbackMap].
class DesktopMapMarker {
  /// Creates a marker.
  const new({
    required this.point,
    this.color = AppColors.primary,
    this.icon = Icons.location_on,
  });

  final GeoPoint point;
  final Color color;
  final IconData icon;
}
