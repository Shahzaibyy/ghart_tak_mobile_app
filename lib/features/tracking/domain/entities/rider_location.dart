/// A throttled rider position for one active order.
class RiderLocation {
  /// Creates a location fix.
  const new({
    required this.orderId,
    required this.lat,
    required this.lng,
  });

  /// Order this fix belongs to.
  final String orderId;

  /// Latitude in degrees.
  final double lat;

  /// Longitude in degrees.
  final double lng;
}
