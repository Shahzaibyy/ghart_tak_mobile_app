import 'dart:async';

import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/network_providers.dart';
import 'package:attock_xpress/core/storage/hive_boxes.dart';
import 'package:attock_xpress/features/rider_dashboard/data/datasources/rider_remote_data_source.dart';
import 'package:attock_xpress/features/rider_dashboard/data/offline_action_queue.dart';
import 'package:attock_xpress/features/rider_dashboard/data/repositories/rider_repository_impl.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/queued_action.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_dashboard_state.dart';
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
  return RiderRepositoryImpl(RiderRemoteDataSource(ref.watch(dioProvider)));
}

/// Availability use case.
@riverpod
SetAvailability setAvailability(Ref ref) {
  return SetAvailability(ref.watch(riderRepositoryProvider));
}

/// Rider home: availability plus the offline queue.
@riverpod
class RiderDashboardController extends _$RiderDashboardController {
  @override
  Future<RiderDashboardState> build() async {
    ref.listen(connectivityResultsProvider, (previous, next) {
      final results = next.value;
      if (results == null) return;
      if (!_isOnline(results)) return;
      unawaited(_flush());
    });
    final pending = await ref.watch(offlineActionQueueProvider).pendingCount();
    return RiderDashboardState(isOnline: false, pendingSyncCount: pending);
  }

  /// Optimistically toggles availability and queues the write when offline.
  Future<void> setOnline({required bool isOnline}) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isOnline: isOnline));
    final result = await ref.read(setAvailabilityProvider).call(
      isOnline: isOnline,
    );
    await _afterWrite(
      result,
      current,
      ToggleOnlineAction(isOnline: isOnline),
    );
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
