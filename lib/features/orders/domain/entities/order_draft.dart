import 'package:attock_xpress/features/orders/domain/entities/order_type.dart';

/// What the customer confirms at checkout.
class OrderDraft {
  /// Creates a draft.
  const new({
    required this.title,
    required this.type,
    required this.deliveryFee,
    required this.photoUrl,
    required this.paymentLabel,
  });

  /// Merchant or errand title.
  final String title;

  /// Food, mart, courier, or errand.
  final OrderType type;

  /// Delivery fee in rupees.
  final int deliveryFee;

  /// Cover photo.
  final String? photoUrl;

  /// How the customer is paying.
  final String paymentLabel;
}
