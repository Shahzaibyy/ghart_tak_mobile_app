// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Payment repository.

@ProviderFor(paymentRepository)
final paymentRepositoryProvider = PaymentRepositoryProvider._();

/// Payment repository.

final class PaymentRepositoryProvider
    extends
        $FunctionalProvider<
          PaymentRepository,
          PaymentRepository,
          PaymentRepository
        >
    with $Provider<PaymentRepository> {
  /// Payment repository.
  PaymentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentRepositoryHash();

  @$internal
  @override
  $ProviderElement<PaymentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentRepository create(Ref ref) {
    return paymentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentRepository>(value),
    );
  }
}

String _$paymentRepositoryHash() => r'86510d5d3eb3904a603fe0c7ad14b8d19c1d2b9e';

/// Wallet use case.

@ProviderFor(readWallet)
final readWalletProvider = ReadWalletProvider._();

/// Wallet use case.

final class ReadWalletProvider
    extends $FunctionalProvider<ReadWallet, ReadWallet, ReadWallet>
    with $Provider<ReadWallet> {
  /// Wallet use case.
  ReadWalletProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readWalletProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readWalletHash();

  @$internal
  @override
  $ProviderElement<ReadWallet> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReadWallet create(Ref ref) {
    return readWallet(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadWallet value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadWallet>(value),
    );
  }
}

String _$readWalletHash() => r'6621fcc6c1ce2952c270036995d5e9be8c7bc5ba';

/// Signed-in wallet balance.

@ProviderFor(WalletController)
final walletControllerProvider = WalletControllerProvider._();

/// Signed-in wallet balance.
final class WalletControllerProvider
    extends $AsyncNotifierProvider<WalletController, WalletBalance> {
  /// Signed-in wallet balance.
  WalletControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletControllerHash();

  @$internal
  @override
  WalletController create() => WalletController();
}

String _$walletControllerHash() => r'63fa71cc8742cc859064d9c61d90362ff0b70bd8';

/// Signed-in wallet balance.

abstract class _$WalletController extends $AsyncNotifier<WalletBalance> {
  FutureOr<WalletBalance> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WalletBalance>, WalletBalance>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WalletBalance>, WalletBalance>,
              AsyncValue<WalletBalance>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
