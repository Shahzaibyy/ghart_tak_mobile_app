/// How a customer pays for an order.
sealed class PaymentMethod {
  const new();
}

/// JazzCash wallet payment.
final class JazzCash extends PaymentMethod {
  /// Creates the JazzCash method.
  const new();
}

/// Easypaisa wallet payment.
final class EasyPaisa extends PaymentMethod {
  /// Creates the Easypaisa method.
  const new();
}

/// Cash collected by the rider.
final class CashOnDelivery extends PaymentMethod {
  /// Creates the cash method.
  const new();
}

/// In-app wallet balance.
final class WalletPayment extends PaymentMethod {
  /// Creates the wallet method.
  const new();
}

/// Label for [method].
String paymentMethodLabel(PaymentMethod method) {
  return switch (method) {
    JazzCash() => 'JazzCash',
    EasyPaisa() => 'Easypaisa',
    CashOnDelivery() => 'Cash on delivery',
    WalletPayment() => 'Wallet',
  };
}

/// API `payment_method` wire value.
String paymentMethodWire(PaymentMethod method) {
  return switch (method) {
    JazzCash() => 'jazzcash',
    EasyPaisa() => 'easypaisa',
    CashOnDelivery() => 'cod',
    WalletPayment() => 'wallet',
  };
}

/// Methods offered at checkout.
const List<PaymentMethod> availablePaymentMethods = [
  CashOnDelivery(),
  WalletPayment(),
];
