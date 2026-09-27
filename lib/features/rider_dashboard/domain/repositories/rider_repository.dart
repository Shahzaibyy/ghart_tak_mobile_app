import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/queued_action.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';

/// Rider availability and delivery confirmation.
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

  /// Next task, or null when the desk is empty.
  Future<Result<RiderTask?>> peekTask();
}
