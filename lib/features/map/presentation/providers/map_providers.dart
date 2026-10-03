import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/network/network_providers.dart';
import 'package:attock_xpress/features/map/data/backend_geo_api.dart';
import 'package:attock_xpress/features/map/data/cached_routing_service.dart';
import 'package:attock_xpress/features/map/data/geo_api.dart';
import 'package:attock_xpress/features/map/data/mapbox_directions_engine.dart';
import 'package:attock_xpress/features/map/data/osrm_routing_engine.dart';
import 'package:attock_xpress/features/map/data/sample_geo_api.dart';
import 'package:attock_xpress/features/map/domain/fallback_routing_engine.dart';
import 'package:attock_xpress/features/map/domain/routing_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Backend geocoding (`/geo/*`) with sample fallback when Mapbox is unavailable
/// on the server, or when [AppConfig.enableMapboxGeo] is off.
final geoApiProvider = Provider<GeoApi>((ref) {
  if (!AppConfig.enableMapboxGeo) {
    return const SampleGeoApi();
  }
  return BackendGeoApi(ref.watch(dioProvider));
});

/// Mapbox Directions first, public OSRM as fallback (swap OSRM host later).
final routingEngineProvider = Provider<RoutingEngine>((ref) {
  return FallbackRoutingEngine([
    MapboxDirectionsEngine(),
    OsrmRoutingEngine(),
  ]);
});

/// Cached per-leg routing with retry / backoff.
final routingServiceProvider = Provider<CachedRoutingService>((ref) {
  return CachedRoutingService(ref.watch(routingEngineProvider));
});
