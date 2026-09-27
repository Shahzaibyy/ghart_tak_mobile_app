import 'dart:async';

import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/storage/hive_boxes.dart';
import 'package:attock_xpress/features/rider_dashboard/data/offline_action_queue.dart';
import 'package:attock_xpress/features/rider_dashboard/data/sample_rider.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/queued_action.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_dashboard_state.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/repositories/rider_repository.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/usecases/set_availability.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rider_dashboard_controller.g.dart';

/// Device connectivity changes.
@riverpod
Stream<List<ConnectivityResult>> connectivityResults(Ref ref) {
  return Connectivity().onConnectivityChanged;
}

/// Local queue of rider actions.
@Riverpod(keepAlive: true)
OfflineActionQueue offlineActionQueue(Ref ref) {
  return OfflineActionQueue(box: Hive.box<String>(HiveBoxes.pendingActions));
}

/// Rider repository.
@Riverpod(keepAlive: true)
RiderRepository riderRepository(Ref ref) {
  return const SampleRiderRepository();
}

/// Availability use case.
@riverpod
SetAvailability setAvailability(Ref ref) {
  return SetAvailability(ref.watch(riderRepositoryProvider));
}

/// Rider home: availability plus the offline queue.
@riverpod
class RiderDashboardController extends _$RiderDashboardController {
  Timer? _timer;

  @override
  Future<RiderDashboardState> build() async {
    ref.onDispose(() => _timer?.cancel());
    ref.listen(connectivityResultsProvider, (previous, next) {
      final results = next.value;
      if (results == null) return;
      if (!_isOnline(results)) return;
      unawaited(_flush());
    });
    final pending = await ref.watch(offlineActionQueueProvider).pendingCount();
    return RiderDashboardState(isOnline: true, pendingSyncCount: pending);
  }

  /// Optimistically toggles availability and queues the write when offline.
  Future<void> setOnline({required bool isOnline}) async {
    final current = state.value;
    if (current == null) return;
    if (!isOnline) _timer?.cancel();
    state = AsyncData(
      current.copyWith(
        isOnline: isOnline,
        phase: isOnline ? current.phase : const Waiting(),
      ),
    );
    final result = await ref.read(setAvailabilityProvider).call(
      isOnline: isOnline,
    );
    await _afterWrite(
      result,
      current,
      ToggleOnlineAction(isOnline: isOnline),
    );
  }

  /// Starts the countdown for the next nearby request.
  Future<void> presentOffer() async {
    final current = state.value;
    if (current == null || !current.isOnline) return;
    if (current.phase is! Waiting) return;
    await _offer();
  }

  /// Moves the trip from pickup to the customer.
  void markPickedUp() {
    final current = state.value;
    final phase = current?.phase;
    if (current == null || phase is! Riding) return;
    if (phase.leg is! ToPickup) return;
    state = AsyncData(
      current.copyWith(phase: Riding(phase.task, leg: const ToDropoff())),
    );
  }

  /// Accepts the offer on screen.
  void accept() {
    final current = state.value;
    final phase = current?.phase;
    if (current == null || phase is! Offering) return;
    _timer?.cancel();
    state = AsyncData(current.copyWith(phase: Riding(phase.task)));
  }

  /// Declines the offer and stays online.
  void decline() {
    _timer?.cancel();
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(phase: const Waiting()));
  }

  /// Confirms the trip with the customer's code.
  Future<void> confirm(String otp) async {
    final current = state.value;
    final phase = current?.phase;
    if (current == null || phase is! Riding) return;
    if (phase.leg is! ToDropoff) return;
    if (otp.trim().length != 6) {
      _rejectCode(current);
      return;
    }
    await _finish(current, phase.task, otp.trim());
  }

  Future<void> _offer() async {
    final result = await ref.read(riderRepositoryProvider).peekTask();
    final task = switch (result) {
      Success(:final value) => value,
      Err() => null,
    };
    if (task == null) return;
    _countDown(task, 30);
  }

  void _countDown(RiderTask task, int seconds) {
    _timer?.cancel();
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        phase: Offering(task: task, secondsLeft: seconds),
      ),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    final latest = state.value;
    final phase = latest?.phase;
    if (latest == null || phase is! Offering) {
      timer.cancel();
      return;
    }
    _advance(latest, phase, timer);
  }

  void _advance(RiderDashboardState latest, Offering phase, Timer timer) {
    if (phase.secondsLeft <= 1) {
      timer.cancel();
      state = AsyncData(latest.copyWith(phase: OfferExpired(phase.task)));
      return;
    }
    state = AsyncData(
      latest.copyWith(
        phase: Offering(
          task: phase.task,
          secondsLeft: phase.secondsLeft - 1,
        ),
      ),
    );
  }

  void _rejectCode(RiderDashboardState current) {
    state = AsyncError(
      const ValidationFailure('Enter the 6-digit code'),
      StackTrace.current,
    );
    state = AsyncData(current);
  }

  Future<void> _finish(
    RiderDashboardState current,
    RiderTask task,
    String otp,
  ) async {
    final result = await ref.read(riderRepositoryProvider).confirmDelivery(
      taskId: task.id,
      otp: otp,
    );
    switch (result) {
      case Success():
        state = AsyncData(current.copyWith(phase: const Waiting()));
      case Err(failure: NetworkFailure()):
        await _keepLocally(
          current,
          DeliveryConfirmationAction(taskId: task.id, otp: otp),
        );
      case Err(:final failure):
        state = AsyncError(failure, StackTrace.current);
        state = AsyncData(current);
    }
  }

  Future<void> _afterWrite(
    Result<Nothing> result,
    RiderDashboardState previous,
    QueuedAction action,
  ) async {
    switch (result) {
      case Success():
        return;
      case Err(failure: NetworkFailure()):
        await _keepLocally(previous, action);
      case Err(:final failure):
        state = AsyncError(failure, StackTrace.current);
        state = AsyncData(previous);
    }
  }

  Future<void> _keepLocally(
    RiderDashboardState previous,
    QueuedAction action,
  ) async {
    final queue = ref.read(offlineActionQueueProvider);
    await queue.enqueue(action);
    final pending = await queue.pendingCount();
    state = AsyncData(
      previous.copyWith(
        isOnline: _onlineAfter(action, previous),
        pendingSyncCount: pending,
      ),
    );
  }

  Future<void> _flush() async {
    final queue = ref.read(offlineActionQueueProvider);
    await queue.flush(ref.read(riderRepositoryProvider).replay);
    final current = state.value;
    if (current == null) return;
    final pending = await queue.pendingCount();
    state = AsyncData(current.copyWith(pendingSyncCount: pending));
  }
}

bool _isOnline(List<ConnectivityResult> results) {
  return results.any((item) => item != ConnectivityResult.none);
}

bool _onlineAfter(QueuedAction action, RiderDashboardState previous) {
  return switch (action) {
    ToggleOnlineAction(:final isOnline) => isOnline,
    DeliveryConfirmationAction() => previous.isOnline,
  };
}
