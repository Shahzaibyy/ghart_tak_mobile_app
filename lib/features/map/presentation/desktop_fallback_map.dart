import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Desktop / unsupported-platform map using Mapbox raster tiles (or OSM).
class DesktopFallbackMap extends StatelessWidget {
  /// Creates a fallback map.
  const new({
    required this.center,
    this.zoom = MapConstants.defaultZoom,
    this.markers = const [],
    this.route = const [],
    this.travelledRoute = const [],
    this.onMapEvent,
    this.mapController,
    super.key,
  });

  final GeoPoint center;
  final double zoom;
  final List<DesktopMapMarker> markers;
  final List<GeoPoint> route;
  final List<GeoPoint> travelledRoute;
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
        initialZoom: zoom.clamp(
          MapConstants.trackingMinZoom,
          MapConstants.trackingMaxZoom,
        ),
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
                points: [for (final p in route) LatLng(p.lat, p.lng)],
                color: AppColors.text.withValues(alpha: 0.45),
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
              Polyline(
                points: [for (final p in route) LatLng(p.lat, p.lng)],
                color: AppColors.primary,
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            ],
          ),
        if (travelledRoute.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  for (final p in travelledRoute) LatLng(p.lat, p.lng),
                ],
                color: const Color(0xFFA8A29E),
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            ],
          ),
        if (markers.isNotEmpty)
          MarkerLayer(
            markers: [
              for (final m in markers) _marker(m),
            ],
          ),
      ],
    );
  }

  Marker _marker(DesktopMapMarker m) {
    final size = m.ring ? 44.0 : 40.0;
    return Marker(
      point: LatLng(m.point.lat, m.point.lng),
      width: m.label == null ? size : 88,
      height: m.label == null ? size : 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (m.label != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                boxShadow: const [AppShadow.floating],
              ),
              child: Text(
                m.label!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
          if (m.ring)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
                boxShadow: const [AppShadow.floating],
              ),
              child: Icon(m.icon, color: AppColors.primary, size: 22),
            )
          else
            _PulseIcon(
              pulse: m.pulse,
              child: Icon(m.icon, color: m.color, size: 32),
            ),
        ],
      ),
    );
  }
}

class _PulseIcon extends StatefulWidget {
  const _PulseIcon({required this.child, required this.pulse});
  final Widget child;
  final bool pulse;

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.pulse) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulse && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) return widget.child;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.55, end: 1).animate(_controller),
      child: widget.child,
    );
  }
}

/// A coloured pin for [DesktopFallbackMap].
class DesktopMapMarker {
  /// Creates a marker.
  const new({
    required this.point,
    this.color = AppColors.primary,
    this.icon = Icons.location_on,
    this.label,
    this.pulse = false,
    this.ring = false,
  });

  final GeoPoint point;
  final Color color;
  final IconData icon;
  final String? label;
  final bool pulse;
  final bool ring;
}
