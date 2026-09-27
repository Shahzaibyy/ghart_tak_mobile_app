import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';

/// Online flag, queue depth, and the current task phase.
class RiderDashboardState {
  /// Creates dashboard state.
  const new({
    required this.isOnline,
    required this.pendingSyncCount,
    this.phase = const Waiting(),
  });

  /// Whether the rider is accepting tasks.
  final bool isOnline;

  /// Actions stored on the device.
  final int pendingSyncCount;

  /// Waiting, being offered a task, or on a trip.
  final RiderPhase phase;

  /// Returns a copy with the provided fields replaced.
  RiderDashboardState copyWith({
    bool? isOnline,
    int? pendingSyncCount,
    RiderPhase? phase,
  }) {
    return RiderDashboardState(
      isOnline: isOnline ?? this.isOnline,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      phase: phase ?? this.phase,
    );
  }
}
