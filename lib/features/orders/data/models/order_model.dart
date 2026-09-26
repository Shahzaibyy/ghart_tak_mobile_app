import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

/// Order payload from `GET /orders`.
@freezed
abstract class OrderModel with _$OrderModel {

  /// Creates an order model.
  const factory({
    required String id,
    required String type,
    required String status,
    @JsonKey(name: 'delivery_fee') required double deliveryFee,
    @JsonKey(name: 'photo_url') String? photoUrl,
  }) = _OrderModel;
  const new _();

  /// Parses [json].
  factory fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  /// Maps this model onto the domain order.
  Order toEntity() {
    return Order(
      id: id,
      type: parseOrderType(type),
      status: parseOrderStatus(status),
      deliveryFee: deliveryFee,
      photoUrl: photoUrl,
    );
  }
}
