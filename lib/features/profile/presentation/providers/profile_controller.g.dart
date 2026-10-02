// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live profile repository (`GET /users/me`).

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

/// Live profile repository (`GET /users/me`).

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  /// Live profile repository (`GET /users/me`).
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'4e27c7f0559bc685ae35c00edd6b4e4b71b21323';

/// Profile use case.

@ProviderFor(readProfile)
final readProfileProvider = ReadProfileProvider._();

/// Profile use case.

final class ReadProfileProvider
    extends $FunctionalProvider<ReadProfile, ReadProfile, ReadProfile>
    with $Provider<ReadProfile> {
  /// Profile use case.
  ReadProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readProfileHash();

  @$internal
  @override
  $ProviderElement<ReadProfile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReadProfile create(Ref ref) {
    return readProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadProfile>(value),
    );
  }
}

String _$readProfileHash() => r'126a0882384d08273b057a551d44fb3d5ccdc8b8';

/// Signed-in profile from the API.

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerProvider._();

/// Signed-in profile from the API.
final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, UserProfile> {
  /// Signed-in profile from the API.
  ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();
}

String _$profileControllerHash() => r'51840eb246061c902faefd9c315aa97fd92dc7c5';

/// Signed-in profile from the API.

abstract class _$ProfileController extends $AsyncNotifier<UserProfile> {
  FutureOr<UserProfile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserProfile>, UserProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile>, UserProfile>,
              AsyncValue<UserProfile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
