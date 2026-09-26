// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => _OrderModel(
  id: json['id'] as String,
  type: json['type'] as String,
  status: json['status'] as String,
  deliveryFee: (json['delivery_fee'] as num).toDouble(),
  photoUrl: json['photo_url'] as String?,
);

Map<String, dynamic> _$OrderModelToJson(_OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'delivery_fee': instance.deliveryFee,
      'photo_url': instance.photoUrl,
    };
