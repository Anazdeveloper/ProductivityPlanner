// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlanOffer {

/// The provider's package id; passed back to purchase it.
 String get id; OfferPeriod get period;/// Store-formatted price, e.g. "₹299.00".
 String get price;/// For annual offers: the price per month, store-formatted.
 String? get pricePerMonth;/// A free trial, if the person is eligible ("1 week").
 Duration? get freeTrial;
/// Create a copy of PlanOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanOfferCopyWith<PlanOffer> get copyWith => _$PlanOfferCopyWithImpl<PlanOffer>(this as PlanOffer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlanOffer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanOffer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.pricePerMonth, _this.pricePerMonth) || other.pricePerMonth == _this.pricePerMonth)&&(identical(other.freeTrial, _this.freeTrial) || other.freeTrial == _this.freeTrial));
}


@override
int get hashCode {
  final _this = this as PlanOffer;
  return Object.hash(runtimeType,_this.id,_this.period,_this.price,_this.pricePerMonth,_this.freeTrial);
}

@override
String toString() {
  final _this = this as PlanOffer;
  return 'PlanOffer(id: ${_this.id}, period: ${_this.period}, price: ${_this.price}, pricePerMonth: ${_this.pricePerMonth}, freeTrial: ${_this.freeTrial})';
}


}

/// @nodoc
abstract mixin class $PlanOfferCopyWith<$Res>  {
  factory $PlanOfferCopyWith(PlanOffer value, $Res Function(PlanOffer) _then) = _$PlanOfferCopyWithImpl;
@useResult
$Res call({
 String id, OfferPeriod period, String price, String? pricePerMonth, Duration? freeTrial
});




}
/// @nodoc
class _$PlanOfferCopyWithImpl<$Res>
    implements $PlanOfferCopyWith<$Res> {
  _$PlanOfferCopyWithImpl(this._self, this._then);

  final PlanOffer _self;
  final $Res Function(PlanOffer) _then;

/// Create a copy of PlanOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? period = null,Object? price = null,Object? pricePerMonth = freezed,Object? freeTrial = freezed,}) {
  return _then(PlanOffer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as OfferPeriod,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,pricePerMonth: freezed == pricePerMonth ? _self.pricePerMonth : pricePerMonth // ignore: cast_nullable_to_non_nullable
as String?,freeTrial: freezed == freeTrial ? _self.freeTrial : freeTrial // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanOffer].
extension PlanOfferPatterns on PlanOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanOffer value)  $default,){
final _that = this;
switch (_that) {
case _PlanOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanOffer value)?  $default,){
final _that = this;
switch (_that) {
case _PlanOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  OfferPeriod period,  String price,  String? pricePerMonth,  Duration? freeTrial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanOffer() when $default != null:
return $default(_that.id,_that.period,_that.price,_that.pricePerMonth,_that.freeTrial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  OfferPeriod period,  String price,  String? pricePerMonth,  Duration? freeTrial)  $default,) {final _that = this;
switch (_that) {
case _PlanOffer():
return $default(_that.id,_that.period,_that.price,_that.pricePerMonth,_that.freeTrial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  OfferPeriod period,  String price,  String? pricePerMonth,  Duration? freeTrial)?  $default,) {final _that = this;
switch (_that) {
case _PlanOffer() when $default != null:
return $default(_that.id,_that.period,_that.price,_that.pricePerMonth,_that.freeTrial);case _:
  return null;

}
}

}

/// @nodoc


class _PlanOffer implements PlanOffer {
  const _PlanOffer({required this.id, required this.period, required this.price, this.pricePerMonth, this.freeTrial});
  

/// The provider's package id; passed back to purchase it.
@override final  String id;
@override final  OfferPeriod period;
/// Store-formatted price, e.g. "₹299.00".
@override final  String price;
/// For annual offers: the price per month, store-formatted.
@override final  String? pricePerMonth;
/// A free trial, if the person is eligible ("1 week").
@override final  Duration? freeTrial;

/// Create a copy of PlanOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanOfferCopyWith<_PlanOffer> get copyWith => __$PlanOfferCopyWithImpl<_PlanOffer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanOffer&&(identical(other.id, id) || other.id == id)&&(identical(other.period, period) || other.period == period)&&(identical(other.price, price) || other.price == price)&&(identical(other.pricePerMonth, pricePerMonth) || other.pricePerMonth == pricePerMonth)&&(identical(other.freeTrial, freeTrial) || other.freeTrial == freeTrial));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,period,price,pricePerMonth,freeTrial);
}

@override
String toString() {
    return 'PlanOffer(id: $id, period: $period, price: $price, pricePerMonth: $pricePerMonth, freeTrial: $freeTrial)';
}


}

/// @nodoc
abstract mixin class _$PlanOfferCopyWith<$Res> implements $PlanOfferCopyWith<$Res> {
  factory _$PlanOfferCopyWith(_PlanOffer value, $Res Function(_PlanOffer) _then) = __$PlanOfferCopyWithImpl;
@override @useResult
$Res call({
 String id, OfferPeriod period, String price, String? pricePerMonth, Duration? freeTrial
});




}
/// @nodoc
class __$PlanOfferCopyWithImpl<$Res>
    implements _$PlanOfferCopyWith<$Res> {
  __$PlanOfferCopyWithImpl(this._self, this._then);

  final _PlanOffer _self;
  final $Res Function(_PlanOffer) _then;

/// Create a copy of PlanOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? period = null,Object? price = null,Object? pricePerMonth = freezed,Object? freeTrial = freezed,}) {
  return _then(_PlanOffer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as OfferPeriod,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,pricePerMonth: freezed == pricePerMonth ? _self.pricePerMonth : pricePerMonth // ignore: cast_nullable_to_non_nullable
as String?,freeTrial: freezed == freeTrial ? _self.freeTrial : freeTrial // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

// dart format on
