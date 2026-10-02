// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auth repository wired to Dio and secure storage.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Auth repository wired to Dio and secure storage.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Auth repository wired to Dio and secure storage.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'f9855ed394d4a78ff2531bca86d85898ad7666e0';

/// OTP request use case.

@ProviderFor(requestOtp)
final requestOtpProvider = RequestOtpProvider._();

/// OTP request use case.

final class RequestOtpProvider
    extends $FunctionalProvider<RequestOtp, RequestOtp, RequestOtp>
    with $Provider<RequestOtp> {
  /// OTP request use case.
  RequestOtpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestOtpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestOtpHash();

  @$internal
  @override
  $ProviderElement<RequestOtp> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RequestOtp create(Ref ref) {
    return requestOtp(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestOtp value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestOtp>(value),
    );
  }
}

String _$requestOtpHash() => r'31ad6af3015dfa9e0af412294b17336e57673951';

/// OTP verification use case.

@ProviderFor(verifyOtp)
final verifyOtpProvider = VerifyOtpProvider._();

/// OTP verification use case.

final class VerifyOtpProvider
    extends $FunctionalProvider<VerifyOtp, VerifyOtp, VerifyOtp>
    with $Provider<VerifyOtp> {
  /// OTP verification use case.
  VerifyOtpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyOtpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyOtpHash();

  @$internal
  @override
  $ProviderElement<VerifyOtp> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VerifyOtp create(Ref ref) {
    return verifyOtp(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyOtp value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyOtp>(value),
    );
  }
}

String _$verifyOtpHash() => r'9dac5c57ab7eabdc2445b692177bc1f47d4f0ad6';

/// Logout use case.

@ProviderFor(logout)
final logoutProvider = LogoutProvider._();

/// Logout use case.

final class LogoutProvider extends $FunctionalProvider<Logout, Logout, Logout>
    with $Provider<Logout> {
  /// Logout use case.
  LogoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoutHash();

  @$internal
  @override
  $ProviderElement<Logout> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Logout create(Ref ref) {
    return logout(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Logout value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Logout>(value),
    );
  }
}

String _$logoutHash() => r'6e0d1f84f5c65cb0e2a5f37a5c5920d4baa2cddf';

/// Local preview use case.

@ProviderFor(enterPreview)
final enterPreviewProvider = EnterPreviewProvider._();

/// Local preview use case.

final class EnterPreviewProvider
    extends $FunctionalProvider<EnterPreview, EnterPreview, EnterPreview>
    with $Provider<EnterPreview> {
  /// Local preview use case.
  EnterPreviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enterPreviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enterPreviewHash();

  @$internal
  @override
  $ProviderElement<EnterPreview> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EnterPreview create(Ref ref) {
    return enterPreview(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnterPreview value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnterPreview>(value),
    );
  }
}

String _$enterPreviewHash() => r'39ad98bbc4e8234965f28e16d1650192faba2b08';
