import 'package:dio/dio.dart';

/// HTTP calls for rider availability and delivery.
class RiderRemoteDataSource {
  /// Creates a data source over the HTTP client.
  const new(this._dio);

  final Dio _dio;

  /// Updates availability. The body is not logged.
  Future<void> setOnline({required bool isOnline}) {
    return _dio.post<void>(
      '/riders/availability',
      data: <String, bool>{'is_online': isOnline},
    );
  }

  /// Confirms delivery. [otp] is sent to the API and not logged.
  Future<void> confirmDelivery({
    required String taskId,
    required String otp,
  }) {
    return _dio.post<void>(
      '/riders/tasks/$taskId/deliver',
      data: <String, String>{'otp': otp},
    );
  }
}
