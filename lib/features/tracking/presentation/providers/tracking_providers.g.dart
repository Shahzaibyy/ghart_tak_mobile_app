// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live-location socket.

@ProviderFor(locationSocket)
final locationSocketProvider = LocationSocketProvider._();

/// Live-location socket.

final class LocationSocketProvider
    extends $FunctionalProvider<LocationSocket, LocationSocket, LocationSocket>
    with $Provider<LocationSocket> {
  /// Live-location socket.
  LocationSocketProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationSocketProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationSocketHash();

  @$internal
  @override
  $ProviderElement<LocationSocket> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationSocket create(Ref ref) {
    return locationSocket(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationSocket value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationSocket>(value),
    );
  }
}

String _$locationSocketHash() => r'a1522d22c43a741a90bac76ef661a673d88c5925';

/// Tracking repository.

@ProviderFor(trackingRepository)
final trackingRepositoryProvider = TrackingRepositoryProvider._();

/// Tracking repository.

final class TrackingRepositoryProvider
    extends
        $FunctionalProvider<
          TrackingRepository,
          TrackingRepository,
          TrackingRepository
        >
    with $Provider<TrackingRepository> {
  /// Tracking repository.
  TrackingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrackingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrackingRepository create(Ref ref) {
    return trackingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackingRepository>(value),
    );
  }
}

String _$trackingRepositoryHash() =>
    r'e74b02342bd1ce732703f24b99dcc3a82cf6bff6';

/// Local geocode cache used before any Maps geocode request.

@ProviderFor(geocodeLookup)
final geocodeLookupProvider = GeocodeLookupProvider._();

/// Local geocode cache used before any Maps geocode request.

final class GeocodeLookupProvider
    extends $FunctionalProvider<GeocodeLookup, GeocodeLookup, GeocodeLookup>
    with $Provider<GeocodeLookup> {
  /// Local geocode cache used before any Maps geocode request.
  GeocodeLookupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geocodeLookupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geocodeLookupHash();

  @$internal
  @override
  $ProviderElement<GeocodeLookup> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeocodeLookup create(Ref ref) {
    return geocodeLookup(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeocodeLookup value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeocodeLookup>(value),
    );
  }
}

String _$geocodeLookupHash() => r'0fe1fdcf55d973b9f95b6ea6e7367f38f183509c';

/// Rider position stream for [orderId].

@ProviderFor(riderLocation)
final riderLocationProvider = RiderLocationFamily._();

/// Rider position stream for [orderId].

final class RiderLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<RiderLocation>,
          RiderLocation,
          Stream<RiderLocation>
        >
    with $FutureModifier<RiderLocation>, $StreamProvider<RiderLocation> {
  /// Rider position stream for [orderId].
  RiderLocationProvider._({
    required RiderLocationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'riderLocationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$riderLocationHash();

  @override
  String toString() {
    return r'riderLocationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<RiderLocation> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RiderLocation> create(Ref ref) {
    final argument = this.argument as String;
    return riderLocation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RiderLocationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$riderLocationHash() => r'4dbee76eeb3971a011345874961f939c1eacde0e';

/// Rider position stream for [orderId].

final class RiderLocationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RiderLocation>, String> {
  RiderLocationFamily._()
    : super(
        retry: null,
        name: r'riderLocationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Rider position stream for [orderId].

  RiderLocationProvider call(String orderId) =>
      RiderLocationProvider._(argument: orderId, from: this);

  @override
  String toString() => r'riderLocationProvider';
}
