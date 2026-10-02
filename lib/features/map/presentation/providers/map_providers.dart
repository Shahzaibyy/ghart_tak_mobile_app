import 'package:attock_xpress/core/network/network_providers.dart';
import 'package:attock_xpress/features/map/data/backend_geo_api.dart';
import 'package:attock_xpress/features/map/data/geo_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Backend geocoding (`/geo/*`) with sample fallback when Mapbox is unavailable.
final geoApiProvider = Provider<GeoApi>((ref) {
  return BackendGeoApi(ref.watch(dioProvider));
});
