import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/domain/entities/road_route.dart';
import 'package:attock_xpress/features/map/domain/routing_engine.dart';

/// Caches road routes per leg and retries with exponential backoff.
///
/// On persistent failure returns `null` — callers must show "Route unavailable"
/// and draw **no** line (never a straight A→B fallback).
class CachedRoutingService {
  /// Creates the service over [engine].
  new(this._engine, {this.maxAttempts = 3});

  final RoutingEngine _engine;
  final int maxAttempts;
  final _cache = <String, RoadRoute>{};

  /// Fetches (or returns cached) driving route for a leg.
  Future<RoadRoute?> fetchLeg({
    required String legKey,
    required GeoPoint origin,
    required GeoPoint destination,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final hit = _cache[legKey];
      if (hit != null) return hit;
    }
    var delay = const Duration(milliseconds: 400);
    Object? lastError;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final route = await _engine.route(
          origin: origin,
          destination: destination,
        );
        _cache[legKey] = route;
        return route;
      } on Object catch (error) {
        lastError = error;
        if (attempt == maxAttempts - 1) break;
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }
    assert(() {
      // ignore: avoid_print
      print('CachedRoutingService failed for $legKey: $lastError');
      return true;
    }());
    return null;
  }

  /// Drops a cached leg (call when the rider goes off-route).
  void invalidate(String legKey) => _cache.remove(legKey);

  /// Clears all cached legs.
  void clear() => _cache.clear();
}
