import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/queued_action.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';

/// Rider availability, offers, trip actions, and delivery confirmation.
abstract interface class RiderRepository {
  /// Sets whether the rider is online.
  Future<Result<Nothing>> setOnline({required bool isOnline});

  /// Confirms delivery with the customer [otp].
  Future<Result<Nothing>> confirmDelivery({
    required String taskId,
    required String otp,
  });

  /// Replays one queued action.
  Future<Result<Nothing>> replay(QueuedAction action);

  /// Next offer/task, or null when the desk is empty.
  Future<Result<RiderTask?>> peekTask();

  /// Accepts an offered order.
  Future<Result<Nothing>> acceptTask(String taskId);

  /// Rejects an offered order.
  Future<Result<Nothing>> rejectTask(String taskId);

  /// Marks pickup complete.
  Future<Result<Nothing>> pickupTask(String taskId);

  /// Marks enroute to the customer.
  Future<Result<Nothing>> enrouteTask(String taskId);

  /// Publishes GPS for dispatch matching.
  Future<Result<Nothing>> pingPosition({
    required double lat,
    required double lng,
  });
}
