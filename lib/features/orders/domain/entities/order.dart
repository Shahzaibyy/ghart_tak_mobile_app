import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_type.dart';

/// A customer order or rider task.
class Order {
  /// Creates an order.
  const new({
    required this.id,
    required this.type,
    required this.status,
    required this.deliveryFee,
    this.title = 'Order',
    this.photoUrl,
    this.deliveryOtp,
  });

  /// Order id.
  final String id;

  /// Merchant or task name.
  final String title;

  /// Food, mart, courier, or errand.
  final OrderType type;

  /// Current lifecycle status.
  final OrderStatus status;

  /// Customer-paid delivery fee.
  final double deliveryFee;

  /// Merchant photo, when the order has one.
  final String? photoUrl;

  /// 4-digit door code returned on place / get (customer only).
  final String? deliveryOtp;
}
