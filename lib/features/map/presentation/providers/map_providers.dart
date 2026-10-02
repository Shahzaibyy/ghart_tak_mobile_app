import 'package:attock_xpress/features/map/data/cached_routing_service.dart';
import 'package:attock_xpress/features/map/data/mapbox_directions_engine.dart';
import 'package:attock_xpress/features/map/domain/routing_engine.dart';
import 'package:attock_xpress/core/network/network_providers.dart';
import 'package:attock_xpress/features/map/data/backend_geo_api.dart';
import 'package:attock_xpress/features/map/data/geo_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Backend geocoding (`/geo/*`) with sample fallback when Mapbox is unavailable.
final geoApiProvider = Provider<GeoApi>((ref) {
  return BackendGeoApi(ref.watch(dioProvider));
});

/// Pluggable road-routing engine (Mapbox Directions today; OSRM later).
final routingEngineProvider = Provider<RoutingEngine>((ref) {
  return MapboxDirectionsEngine();
});

/// Cached per-leg routing with retry / backoff.
final routingServiceProvider = Provider<CachedRoutingService>((ref) {
  return CachedRoutingService(ref.watch(routingEngineProvider));
});
