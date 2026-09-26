import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';

/// Live location for an accepted order.
abstract interface class TrackingRepository {
  /// Emits rider positions for [orderId] until the socket closes.
  Stream<RiderLocation> watch(String orderId);
}
