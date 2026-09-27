// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The customer's basket. Local until checkout.

@ProviderFor(CartController)
final cartControllerProvider = CartControllerProvider._();

/// The customer's basket. Local until checkout.
final class CartControllerProvider
    extends $NotifierProvider<CartController, Cart> {
  /// The customer's basket. Local until checkout.
  CartControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartControllerHash();

  @$internal
  @override
  CartController create() => CartController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Cart value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Cart>(value),
    );
  }
}

String _$cartControllerHash() => r'0a5680b7487c83dafa1f45966fe0d621031cc742';

/// The customer's basket. Local until checkout.

abstract class _$CartController extends $Notifier<Cart> {
  Cart build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Cart, Cart>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Cart, Cart>,
              Cart,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
