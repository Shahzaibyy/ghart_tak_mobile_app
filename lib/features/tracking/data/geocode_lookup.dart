import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/core/utils/geocode_cache.dart';

/// Reads and writes the local geocode cache before any network geocode.
class GeocodeLookup {
  /// Creates a lookup over the geocode cache.
  const new(this._cache);

  final GeocodeCache _cache;

  /// Returns a cached point for [address], if one exists.
  GeoPoint? cached(String address) => _cache.read(address);

  /// Remembers [point] for [address].
  Future<void> remember(String address, GeoPoint point) {
    return _cache.write(address, point);
  }
}
