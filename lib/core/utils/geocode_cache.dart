import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:hive/hive.dart';

/// Local address to coordinate cache.
///
/// The same saved address is never geocoded twice.
class GeocodeCache {
  /// Creates a cache backed by a Hive box.
  new(this._box);

  final Box<String> _box;

  /// Returns a cached point, or null when [address] has not been seen.
  GeoPoint? read(String address) {
    final raw = _box.get(_key(address));
    if (raw == null) return null;
    final parts = raw.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) return null;
    return GeoPoint(lat: lat, lng: lng);
  }

  /// Stores [point] for [address].
  Future<void> write(String address, GeoPoint point) {
    return _box.put(_key(address), '${point.lat},${point.lng}');
  }

  String _key(String address) => address.trim().toLowerCase();
}
