import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';

/// District map defaults used by camera, bounds, and sample routes.
abstract final class MapConstants {
  /// Active demo zone centre (Fateh Jang).
  static const GeoPoint zoneCenter = DemoConfig.zoneCenter;

  /// Alias kept for older call sites.
  static const GeoPoint attockCenter = zoneCenter;

  /// Sample merchant / pickup (Bismillah Restaurant).
  static const samplePickup = GeoPoint(lat: 33.567565, lng: 72.641856);

  /// Sample customer drop near town centre.
  static const GeoPoint sampleDrop = DemoConfig.demoDrop;

  /// Camera limits covering Attock district including Fateh Jang.
  static const southwestLng = 72.0;
  static const southwestLat = 33.2;
  static const northeastLng = 73.1;
  static const northeastLat = 34.0;

  static const minZoom = 8.0;
  static const maxZoom = 19.0;
  static const defaultZoom = 13.5;
  static const pickerZoom = 15.5;

  static const routeSourceId = 'route-src';
  static const routeLayerId = 'route-layer';
  static const routeCasingLayerId = 'route-casing-layer';
  static const routeTravelledSourceId = 'route-travelled-src';
  static const routeTravelledLayerId = 'route-travelled-layer';

  /// Live-tracking camera clamp (never town-level).
  static const trackingMinZoom = 14.0;
  static const trackingMaxZoom = 17.0;
}
