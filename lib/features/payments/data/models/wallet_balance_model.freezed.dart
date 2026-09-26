// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_balance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WalletBalanceModel {

 double get balance;
/// Create a copy of WalletBalanceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletBalanceModelCopyWith<WalletBalanceModel> get copyWith => _$WalletBalanceModelCopyWithImpl<WalletBalanceModel>(this as WalletBalanceModel, _$identity);

  /// Serializes this WalletBalanceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WalletBalanceModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletBalanceModel&&(identical(other.balance, _this.balance) || other.balance == _this.balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WalletBalanceModel;
  return Object.hash(runtimeType,_this.balance);
}

@override
String toString() {
  final _this = this as WalletBalanceModel;
  return 'WalletBalanceModel(balance: ${_this.balance})';
}


}

/// @nodoc
abstract mixin class $WalletBalanceModelCopyWith<$Res>  {
  factory $WalletBalanceModelCopyWith(WalletBalanceModel value, $Res Function(WalletBalanceModel) _then) = _$WalletBalanceModelCopyWithImpl;
@useResult
$Res call({
 double balance
});




}
/// @nodoc
class _$WalletBalanceModelCopyWithImpl<$Res>
    implements $WalletBalanceModelCopyWith<$Res> {
  _$WalletBalanceModelCopyWithImpl(this._self, this._then);

  final WalletBalanceModel _self;
  final $Res Function(WalletBalanceModel) _then;

/// Create a copy of WalletBalanceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? balance = null,}) {
  return _then(WalletBalanceModel(
balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletBalanceModel].
extension WalletBalanceModelPatterns on WalletBalanceModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletBalanceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletBalanceModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletBalanceModel value)  $default,){
final _that = this;
switch (_that) {
case _WalletBalanceModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletBalanceModel value)?  $default,){
final _that = this;
switch (_that) {
case _WalletBalanceModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletBalanceModel() when $default != null:
return $default(_that.balance);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double balance)  $default,) {final _that = this;
switch (_that) {
case _WalletBalanceModel():
return $default(_that.balance);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double balance)?  $default,) {final _that = this;
switch (_that) {
case _WalletBalanceModel() when $default != null:
return $default(_that.balance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletBalanceModel extends WalletBalanceModel {
  const _WalletBalanceModel({required this.balance}): super._();
  factory _WalletBalanceModel.fromJson(Map<String, dynamic> json) => _$WalletBalanceModelFromJson(json);

@override final  double balance;

/// Create a copy of WalletBalanceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletBalanceModelCopyWith<_WalletBalanceModel> get copyWith => __$WalletBalanceModelCopyWithImpl<_WalletBalanceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletBalanceModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletBalanceModel&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,balance);
}

@override
String toString() {
    return 'WalletBalanceModel(balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$WalletBalanceModelCopyWith<$Res> implements $WalletBalanceModelCopyWith<$Res> {
  factory _$WalletBalanceModelCopyWith(_WalletBalanceModel value, $Res Function(_WalletBalanceModel) _then) = __$WalletBalanceModelCopyWithImpl;
@override @useResult
$Res call({
 double balance
});




}
/// @nodoc
class __$WalletBalanceModelCopyWithImpl<$Res>
    implements _$WalletBalanceModelCopyWith<$Res> {
  __$WalletBalanceModelCopyWithImpl(this._self, this._then);

  final _WalletBalanceModel _self;
  final $Res Function(_WalletBalanceModel) _then;

/// Create a copy of WalletBalanceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? balance = null,}) {
  return _then(_WalletBalanceModel(
balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
