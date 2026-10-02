import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// The only place lat/lng order is converted for Mapbox (`Position(lng, lat)`).
Point toMapbox(GeoPoint p) => Point(coordinates: Position(p.lng, p.lat));

/// Reads a Mapbox [Point] back into app [GeoPoint] (lat, lng).
GeoPoint fromMapbox(Point p) => GeoPoint(
  lat: p.coordinates.lat.toDouble(),
  lng: p.coordinates.lng.toDouble(),
);
