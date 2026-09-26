import 'package:attock_xpress/features/tracking/data/datasources/location_socket.dart';
import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/domain/repositories/tracking_repository.dart';

/// [TrackingRepository] backed by [LocationSocket].
class TrackingRepositoryImpl implements TrackingRepository {
  /// Creates the repository.
  const new(this._socket);

  final LocationSocket _socket;

  @override
  Stream<RiderLocation> watch(String orderId) => _socket.watch(orderId);
}
