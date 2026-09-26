/// Hive box names opened during bootstrap.
abstract final class HiveBoxes {
  /// FIFO queue of rider actions waiting for a connection.
  static const pendingActions = 'pending_rider_actions';

  /// Address to lat/lng cache.
  static const geocode = 'geocode_cache';
}
