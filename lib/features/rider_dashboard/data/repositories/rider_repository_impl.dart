import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/features/rider_dashboard/data/datasources/rider_remote_data_source.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/queued_action.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/repositories/rider_repository.dart';
import 'package:dio/dio.dart';

/// [RiderRepository] that maps transport errors once.
class RiderRepositoryImpl implements RiderRepository {
  /// Creates the repository.
  const new(this._remote);

  final RiderRemoteDataSource _remote;

  @override
  Future<Result<Nothing>> setOnline({required bool isOnline}) {
    return _guard(() => _remote.setOnline(isOnline: isOnline));
  }

  @override
  Future<Result<Nothing>> confirmDelivery({
    required String taskId,
    required String otp,
  }) {
    return _guard(() => _remote.confirmDelivery(taskId: taskId, otp: otp));
  }

  @override
  Future<Result<Nothing>> replay(QueuedAction action) {
    return switch (action) {
      ToggleOnlineAction(:final isOnline) => setOnline(isOnline: isOnline),
      DeliveryConfirmationAction(:final taskId, :final otp) => confirmDelivery(
        taskId: taskId,
        otp: otp,
      ),
    };
  }

  Future<Result<Nothing>> _guard(Future<void> Function() send) async {
    try {
      await send();
      return const Success(nothing);
    } on DioException catch (error) {
      return Err(mapDioException(error));
    }
  }
}
