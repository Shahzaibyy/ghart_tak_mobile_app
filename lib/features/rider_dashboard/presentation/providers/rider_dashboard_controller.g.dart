// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rider_dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Device connectivity changes.

@ProviderFor(connectivityResults)
final connectivityResultsProvider = ConnectivityResultsProvider._();

/// Device connectivity changes.

final class ConnectivityResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConnectivityResult>>,
          List<ConnectivityResult>,
          Stream<List<ConnectivityResult>>
        >
    with
        $FutureModifier<List<ConnectivityResult>>,
        $StreamProvider<List<ConnectivityResult>> {
  /// Device connectivity changes.
  ConnectivityResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityResultsHash();

  @$internal
  @override
  $StreamProviderElement<List<ConnectivityResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConnectivityResult>> create(Ref ref) {
    return connectivityResults(ref);
  }
}

String _$connectivityResultsHash() =>
    r'73c84b50dc1924965ac805d591527a92a3f7ea99';

/// Local queue of rider actions.

@ProviderFor(offlineActionQueue)
final offlineActionQueueProvider = OfflineActionQueueProvider._();

/// Local queue of rider actions.

final class OfflineActionQueueProvider
    extends
        $FunctionalProvider<
          OfflineActionQueue,
          OfflineActionQueue,
          OfflineActionQueue
        >
    with $Provider<OfflineActionQueue> {
  /// Local queue of rider actions.
  OfflineActionQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineActionQueueProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineActionQueueHash();

  @$internal
  @override
  $ProviderElement<OfflineActionQueue> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OfflineActionQueue create(Ref ref) {
    return offlineActionQueue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfflineActionQueue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfflineActionQueue>(value),
    );
  }
}

String _$offlineActionQueueHash() =>
    r'5bcacd972f5ab4e1c56897114da6224f6b6ea073';

/// Rider repository.

@ProviderFor(riderRepository)
final riderRepositoryProvider = RiderRepositoryProvider._();

/// Rider repository.

final class RiderRepositoryProvider
    extends
        $FunctionalProvider<RiderRepository, RiderRepository, RiderRepository>
    with $Provider<RiderRepository> {
  /// Rider repository.
  RiderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'riderRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$riderRepositoryHash();

  @$internal
  @override
  $ProviderElement<RiderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RiderRepository create(Ref ref) {
    return riderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RiderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RiderRepository>(value),
    );
  }
}

String _$riderRepositoryHash() => r'e7cda1fc823a143e86292fbd66804e1d8977f39c';

/// Availability use case.

@ProviderFor(setAvailability)
final setAvailabilityProvider = SetAvailabilityProvider._();

/// Availability use case.

final class SetAvailabilityProvider
    extends
        $FunctionalProvider<SetAvailability, SetAvailability, SetAvailability>
    with $Provider<SetAvailability> {
  /// Availability use case.
  SetAvailabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setAvailabilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setAvailabilityHash();

  @$internal
  @override
  $ProviderElement<SetAvailability> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SetAvailability create(Ref ref) {
    return setAvailability(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetAvailability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetAvailability>(value),
    );
  }
}

String _$setAvailabilityHash() => r'8e033752826b472c0a28587a948fe82bb73703fb';

/// Rider home: availability plus the offline queue.

@ProviderFor(RiderDashboardController)
final riderDashboardControllerProvider = RiderDashboardControllerProvider._();

/// Rider home: availability plus the offline queue.
final class RiderDashboardControllerProvider
    extends
        $AsyncNotifierProvider<RiderDashboardController, RiderDashboardState> {
  /// Rider home: availability plus the offline queue.
  RiderDashboardControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'riderDashboardControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$riderDashboardControllerHash();

  @$internal
  @override
  RiderDashboardController create() => RiderDashboardController();
}

String _$riderDashboardControllerHash() =>
    r'dabc8e874f66003760d5847726f2ec5c07f6de5e';

/// Rider home: availability plus the offline queue.

abstract class _$RiderDashboardController
    extends $AsyncNotifier<RiderDashboardState> {
  FutureOr<RiderDashboardState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<RiderDashboardState>, RiderDashboardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RiderDashboardState>, RiderDashboardState>,
              AsyncValue<RiderDashboardState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
