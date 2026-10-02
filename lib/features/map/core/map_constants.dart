import 'package:attock_xpress/core/utils/geo_point.dart';

/// Attock-district map defaults used by camera, bounds, and sample routes.
abstract final class MapConstants {
  /// Zone centre for Attock City (faster first tile load).
  static const attockCenter = GeoPoint(lat: 33.7665, lng: 72.3607);

  /// Sample merchant / pickup (Mall Road).
  static const samplePickup = GeoPoint(lat: 33.7680, lng: 72.3650);

  /// Sample customer drop (Peoples Colony).
  static const sampleDrop = GeoPoint(lat: 33.7620, lng: 72.3550);

  /// Generous Attock district camera limits (lng, lat order in Mapbox only).
  static const southwestLng = 72.0;
  static const southwestLat = 33.2;
  static const northeastLng = 73.1;
  static const northeastLat = 34.0;

  static const minZoom = 8.0;
  static const maxZoom = 19.0;
  static const defaultZoom = 13.0;
  static const pickerZoom = 16.0;

  static const routeSourceId = 'route-src';
  static const routeLayerId = 'route-layer';
}
