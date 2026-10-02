import 'package:attock_xpress/features/map/data/sample_route.dart';
import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/domain/repositories/tracking_repository.dart';

/// Walks a sample Attock route so the tracking map can be reviewed offline.
class SampleTrackingRepository implements TrackingRepository {
  /// Creates the sample stream.
  const new();

  @override
  Stream<RiderLocation> watch(String orderId) async* {
    for (final point in SampleRoute.path) {
      yield RiderLocation(
        orderId: orderId,
        lat: point.lat,
        lng: point.lng,
      );
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }
}
