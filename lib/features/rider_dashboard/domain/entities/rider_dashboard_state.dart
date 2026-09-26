/// Online flag and how many actions are waiting to sync.
class RiderDashboardState {
  /// Creates dashboard state.
  const new({
    required this.isOnline,
    required this.pendingSyncCount,
  });

  /// Whether the rider is accepting tasks.
  final bool isOnline;

  /// Actions stored on the device.
  final int pendingSyncCount;

  /// Returns a copy with the provided fields replaced.
  RiderDashboardState copyWith({bool? isOnline, int? pendingSyncCount}) {
    return RiderDashboardState(
      isOnline: isOnline ?? this.isOnline,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }
}
