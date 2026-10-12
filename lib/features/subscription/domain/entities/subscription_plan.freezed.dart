// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubscriptionPlan {

 PlanTier get tier; Set<Feature> get features;/// Limit values; a key that is absent or null is unlimited.
 Map<LimitKey, int?> get limits;
/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionPlanCopyWith<SubscriptionPlan> get copyWith => _$SubscriptionPlanCopyWithImpl<SubscriptionPlan>(this as SubscriptionPlan, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SubscriptionPlan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionPlan&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&const DeepCollectionEquality().equals(other.features, _this.features)&&const DeepCollectionEquality().equals(other.limits, _this.limits));
}


@override
int get hashCode {
  final _this = this as SubscriptionPlan;
  return Object.hash(runtimeType,_this.tier,const DeepCollectionEquality().hash(_this.features),const DeepCollectionEquality().hash(_this.limits));
}

@override
String toString() {
  final _this = this as SubscriptionPlan;
  return 'SubscriptionPlan(tier: ${_this.tier}, features: ${_this.features}, limits: ${_this.limits})';
}


}

/// @nodoc
abstract mixin class $SubscriptionPlanCopyWith<$Res>  {
  factory $SubscriptionPlanCopyWith(SubscriptionPlan value, $Res Function(SubscriptionPlan) _then) = _$SubscriptionPlanCopyWithImpl;
@useResult
$Res call({
 PlanTier tier, Set<Feature> features, Map<LimitKey, int?> limits
});




}
/// @nodoc
class _$SubscriptionPlanCopyWithImpl<$Res>
    implements $SubscriptionPlanCopyWith<$Res> {
  _$SubscriptionPlanCopyWithImpl(this._self, this._then);

  final SubscriptionPlan _self;
  final $Res Function(SubscriptionPlan) _then;

/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = null,Object? features = null,Object? limits = null,}) {
  return _then(SubscriptionPlan(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as PlanTier,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as Set<Feature>,limits: null == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as Map<LimitKey, int?>,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionPlan].
extension SubscriptionPlanPatterns on SubscriptionPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionPlan value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionPlan value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlanTier tier,  Set<Feature> features,  Map<LimitKey, int?> limits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
return $default(_that.tier,_that.features,_that.limits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlanTier tier,  Set<Feature> features,  Map<LimitKey, int?> limits)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPlan():
return $default(_that.tier,_that.features,_that.limits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlanTier tier,  Set<Feature> features,  Map<LimitKey, int?> limits)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
return $default(_that.tier,_that.features,_that.limits);case _:
  return null;

}
}

}

/// @nodoc


class _SubscriptionPlan extends SubscriptionPlan {
  const _SubscriptionPlan({required this.tier,  Set<Feature> features = const <Feature>{},  Map<LimitKey, int?> limits = const <LimitKey, int?>{}}): _features = features,_limits = limits,super._();
  

@override final  PlanTier tier;
 final  Set<Feature> _features;
@override@JsonKey() Set<Feature> get features {
  if (_features is EqualUnmodifiableSetView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_features);
}

/// Limit values; a key that is absent or null is unlimited.
 final  Map<LimitKey, int?> _limits;
/// Limit values; a key that is absent or null is unlimited.
@override@JsonKey() Map<LimitKey, int?> get limits {
  if (_limits is EqualUnmodifiableMapView) return _limits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_limits);
}


/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionPlanCopyWith<_SubscriptionPlan> get copyWith => __$SubscriptionPlanCopyWithImpl<_SubscriptionPlan>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionPlan&&(identical(other.tier, tier) || other.tier == tier)&&const DeepCollectionEquality().equals(other.features, _features)&&const DeepCollectionEquality().equals(other.limits, _limits));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tier,const DeepCollectionEquality().hash(_features),const DeepCollectionEquality().hash(_limits));
}

@override
String toString() {
    return 'SubscriptionPlan(tier: $tier, features: $features, limits: $limits)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionPlanCopyWith<$Res> implements $SubscriptionPlanCopyWith<$Res> {
  factory _$SubscriptionPlanCopyWith(_SubscriptionPlan value, $Res Function(_SubscriptionPlan) _then) = __$SubscriptionPlanCopyWithImpl;
@override @useResult
$Res call({
 PlanTier tier, Set<Feature> features, Map<LimitKey, int?> limits
});




}
/// @nodoc
class __$SubscriptionPlanCopyWithImpl<$Res>
    implements _$SubscriptionPlanCopyWith<$Res> {
  __$SubscriptionPlanCopyWithImpl(this._self, this._then);

  final _SubscriptionPlan _self;
  final $Res Function(_SubscriptionPlan) _then;

/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? features = null,Object? limits = null,}) {
  return _then(_SubscriptionPlan(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as PlanTier,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as Set<Feature>,limits: null == limits ? _self._limits : limits // ignore: cast_nullable_to_non_nullable
as Map<LimitKey, int?>,
  ));
}


}

// dart format on
