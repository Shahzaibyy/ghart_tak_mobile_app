import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/catalog/domain/order_type_for.dart';
import 'package:attock_xpress/features/catalog/domain/usecases/place_order.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/cart_controller.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_draft.dart';
import 'package:attock_xpress/features/orders/presentation/providers/orders_controller.dart';
import 'package:attock_xpress/features/payments/domain/entities/payment_method.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'checkout_controller.g.dart';

/// Where checkout is.
sealed class CheckoutStep {
  const new();
}

/// The customer is reviewing the basket.
final class EditingCart extends CheckoutStep {
  /// Creates the editing step.
  const new();
}

/// The order is being sent.
final class SubmittingCart extends CheckoutStep {
  /// Creates the submitting step.
  const new();
}

/// Checkout failed.
final class CartFailed extends CheckoutStep {
  /// Creates a failed step.
  const new(this.failure);

  /// Why it failed.
  final Failure failure;
}

/// The order was accepted.
final class CartPlaced extends CheckoutStep {
  /// Creates a placed step.
  const new({required this.orderId, required this.title});

  /// New order id.
  final String orderId;

  /// Merchant or errand name.
  final String title;
}

/// Place-order use case.
@riverpod
PlaceOrder placeOrder(Ref ref) {
  return PlaceOrder(ref.watch(orderRepositoryProvider));
}

/// Payment the customer picked for this checkout.
@riverpod
class PayChoice extends _$PayChoice {
  @override
  PaymentMethod build() => const CashOnDelivery();

  /// Selects [value].
  void choose(PaymentMethod value) {
    if (state == value) return;
    state = value;
  }
}

/// Checkout progress. The basket itself stays on [CartController].
@riverpod
class CheckoutController extends _$CheckoutController {
  String? _clientRequestId;

  @override
  CheckoutStep build() => const EditingCart();

  /// Places the current basket against the live API.
  Future<void> submit() async {
    final cart = ref.read(cartControllerProvider);
    final merchant = cart.merchant;
    if (merchant == null || cart.isEmpty) return;
    final method = ref.read(payChoiceProvider);
    state = const SubmittingCart();

    _clientRequestId ??=
        'req-${DateTime.now().millisecondsSinceEpoch}';
    final draft = OrderDraft(
      title: merchant.name,
      type: orderTypeFor(merchant.category),
      zoneId: DemoConfig.attockZoneId,
      merchantId: merchant.id,
      drop: const GeoPoint(
        lat: DemoConfig.demoDropLat,
        lng: DemoConfig.demoDropLng,
      ),
      dropAddress: DemoConfig.demoDropAddress,
      paymentMethod: paymentMethodWire(method),
      clientRequestId: _clientRequestId!,
      items: [
        for (final line in cart.lines)
          OrderLineDraft(
            catalogItemId: line.item.id,
            quantity: line.quantity,
          ),
      ],
      photoUrl: merchant.photoUrl,
      deliveryFee: cart.deliveryFee,
      paymentLabel: paymentMethodLabel(method),
    );

    final result = await ref.read(placeOrderProvider).call(draft);
    switch (result) {
      case Success(:final value):
        _clientRequestId = null;
        ref.read(cartControllerProvider.notifier).clear();
        ref.invalidate(ordersControllerProvider);
        state = CartPlaced(orderId: value.id, title: value.title);
      case Err(:final failure):
        state = CartFailed(failure);
    }
  }

  /// Returns to the basket after a failure.
  void editAgain() => state = const EditingCart();
}
