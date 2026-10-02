import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/features/rider_dashboard/data/datasources/rider_remote_data_source.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/queued_action.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/repositories/rider_repository.dart';
import 'package:dio/dio.dart';

/// Live rider repository over `/riders/*`.
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
  Future<Result<RiderTask?>> peekTask() async {
    try {
      final offers = await _remote.listOffers();
      if (offers.isNotEmpty) return Success(offers.first);
      final tasks = await _remote.listTasks();
      if (tasks.isNotEmpty) return Success(tasks.first);
      return const Success(null);
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Success(null);
    }
  }

  @override
  Future<Result<Nothing>> acceptTask(String taskId) {
    return _guard(() => _remote.acceptTask(taskId));
  }

  @override
  Future<Result<Nothing>> rejectTask(String taskId) {
    return _guard(() => _remote.rejectTask(taskId));
  }

  @override
  Future<Result<Nothing>> pickupTask(String taskId) {
    return _guard(() => _remote.pickupTask(taskId));
  }

  @override
  Future<Result<Nothing>> enrouteTask(String taskId) {
    return _guard(() => _remote.enrouteTask(taskId));
  }

  @override
  Future<Result<Nothing>> pingPosition({
    required double lat,
    required double lng,
  }) {
    return _guard(() => _remote.updatePosition(lat: lat, lng: lng));
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
