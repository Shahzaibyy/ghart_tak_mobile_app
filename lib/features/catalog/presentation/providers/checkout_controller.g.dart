// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Place-order use case.

@ProviderFor(placeOrder)
final placeOrderProvider = PlaceOrderProvider._();

/// Place-order use case.

final class PlaceOrderProvider
    extends $FunctionalProvider<PlaceOrder, PlaceOrder, PlaceOrder>
    with $Provider<PlaceOrder> {
  /// Place-order use case.
  PlaceOrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placeOrderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placeOrderHash();

  @$internal
  @override
  $ProviderElement<PlaceOrder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlaceOrder create(Ref ref) {
    return placeOrder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaceOrder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaceOrder>(value),
    );
  }
}

String _$placeOrderHash() => r'e26bc86bea2eedf00c7c2889419ec88d531aac77';

/// Payment the customer picked for this checkout.

@ProviderFor(PayChoice)
final payChoiceProvider = PayChoiceProvider._();

/// Payment the customer picked for this checkout.
final class PayChoiceProvider
    extends $NotifierProvider<PayChoice, PaymentMethod> {
  /// Payment the customer picked for this checkout.
  PayChoiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'payChoiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$payChoiceHash();

  @$internal
  @override
  PayChoice create() => PayChoice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentMethod value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentMethod>(value),
    );
  }
}

String _$payChoiceHash() => r'66d862bd97c4c61347a5414c8274fb119f89ff97';

/// Payment the customer picked for this checkout.

abstract class _$PayChoice extends $Notifier<PaymentMethod> {
  PaymentMethod build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PaymentMethod, PaymentMethod>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaymentMethod, PaymentMethod>,
              PaymentMethod,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Checkout progress. The basket itself stays on [CartController].

@ProviderFor(CheckoutController)
final checkoutControllerProvider = CheckoutControllerProvider._();

/// Checkout progress. The basket itself stays on [CartController].
final class CheckoutControllerProvider
    extends $NotifierProvider<CheckoutController, CheckoutStep> {
  /// Checkout progress. The basket itself stays on [CartController].
  CheckoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutControllerHash();

  @$internal
  @override
  CheckoutController create() => CheckoutController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutStep value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutStep>(value),
    );
  }
}

String _$checkoutControllerHash() =>
    r'c89f3d571062e99319b851afd97e73aad12de128';

/// Checkout progress. The basket itself stays on [CartController].

abstract class _$CheckoutController extends $Notifier<CheckoutStep> {
  CheckoutStep build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CheckoutStep, CheckoutStep>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckoutStep, CheckoutStep>,
              CheckoutStep,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
