import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/domain/repositories/tracking_repository.dart';

/// A single Attock fix so tracking can be reviewed without a socket.
class SampleTrackingRepository implements TrackingRepository {
  /// Creates the sample stream.
  const new();

  @override
  Stream<RiderLocation> watch(String orderId) async* {
    yield RiderLocation(orderId: orderId, lat: 33.766, lng: 72.361);
  }
}
