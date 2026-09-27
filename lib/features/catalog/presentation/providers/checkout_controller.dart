import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
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
  @override
  CheckoutStep build() => const EditingCart();

  /// Places the current basket.
  Future<void> submit() async {
    final cart = ref.read(cartControllerProvider);
    final merchant = cart.merchant;
    if (merchant == null || cart.isEmpty) return;
    final method = ref.read(payChoiceProvider);
    state = const SubmittingCart();
    final result = await ref.read(placeOrderProvider).call(
      OrderDraft(
        title: merchant.name,
        type: orderTypeFor(merchant.category),
        deliveryFee: cart.deliveryFee,
        photoUrl: merchant.photoUrl,
        paymentLabel: paymentMethodLabel(method),
      ),
    );
    switch (result) {
      case Success(:final value):
        ref.read(cartControllerProvider.notifier).clear();
        state = CartPlaced(orderId: value.id, title: value.title);
      case Err(:final failure):
        state = CartFailed(failure);
    }
  }

  /// Returns to the basket after a failure.
  void editAgain() => state = const EditingCart();
}
