import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_type.dart';

/// One line sent to quote / place.
class OrderLineDraft {
  /// Creates a line.
  const new({
    required this.catalogItemId,
    required this.quantity,
  });

  /// Catalog UUID from `GET /merchants/{id}/catalog`.
  final String catalogItemId;

  /// Quantity.
  final int quantity;

  Map<String, Object> toJson() => {
    'catalog_item_id': catalogItemId,
    'quantity': quantity,
  };
}

/// What the customer confirms at checkout (maps to PlaceOrder / QuoteRequest).
class OrderDraft {
  /// Creates a draft.
  const new({
    required this.title,
    required this.type,
    required this.zoneId,
    required this.drop,
    required this.dropAddress,
    required this.paymentMethod,
    required this.clientRequestId,
    required this.items,
    this.merchantId,
    this.photoUrl,
    this.deliveryFee = 0,
    this.paymentLabel = 'Cash on delivery',
  });

  /// Merchant or errand title (UI only).
  final String title;

  /// Food, mart, courier, or errand.
  final OrderType type;

  /// Zone UUID.
  final String zoneId;

  /// Merchant UUID for food/mart.
  final String? merchantId;

  /// Drop pin.
  final GeoPoint drop;

  /// Editable drop address text.
  final String dropAddress;

  /// `cod` | `wallet` | …
  final String paymentMethod;

  /// Idempotency key (8–64 chars).
  final String clientRequestId;

  /// Cart lines.
  final List<OrderLineDraft> items;

  /// Cover photo for local UI.
  final String? photoUrl;

  /// Last known delivery fee for optimistic UI.
  final int deliveryFee;

  /// How the customer is paying (display).
  final String paymentLabel;

  /// Wire type for the API.
  String get typeWire => switch (type) {
    FoodOrder() => 'food',
    MartOrder() => 'mart',
    CourierOrder() => 'courier',
    ErrandOrder() => 'errand',
  };

  Map<String, Object?> toQuoteJson() => {
    'type': typeWire,
    'zone_id': zoneId,
    if (merchantId != null) 'merchant_id': merchantId,
    'drop_lat': drop.lat,
    'drop_lng': drop.lng,
    'drop_address': dropAddress,
    'items': items.map((i) => i.toJson()).toList(),
    'payment_method': paymentMethod,
  };

  Map<String, Object?> toPlaceJson() => {
    ...toQuoteJson(),
    'client_request_id': clientRequestId,
  };
}
