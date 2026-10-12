// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entitlement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Entitlement {

 SubscriptionPlan get plan; SubscriptionStatus get status; BillingStore get store;/// End of the paid (or trial) period.
 DateTime? get periodEnd; bool get willRenew;/// Usage of counted limits this period (e.g. voice parses).
 Map<LimitKey, int> get usage;/// True when the server confirmed it; false for the moments after a
/// store purchase before the server has heard about it.
 bool get verified;/// Where the person changes or cancels the subscription.
 String? get managementUrl; DateTime? get updatedAt;
/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementCopyWith<Entitlement> get copyWith => _$EntitlementCopyWithImpl<Entitlement>(this as Entitlement, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Entitlement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Entitlement&&(identical(other.plan, _this.plan) || other.plan == _this.plan)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.store, _this.store) || other.store == _this.store)&&(identical(other.periodEnd, _this.periodEnd) || other.periodEnd == _this.periodEnd)&&(identical(other.willRenew, _this.willRenew) || other.willRenew == _this.willRenew)&&const DeepCollectionEquality().equals(other.usage, _this.usage)&&(identical(other.verified, _this.verified) || other.verified == _this.verified)&&(identical(other.managementUrl, _this.managementUrl) || other.managementUrl == _this.managementUrl)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as Entitlement;
  return Object.hash(runtimeType,_this.plan,_this.status,_this.store,_this.periodEnd,_this.willRenew,const DeepCollectionEquality().hash(_this.usage),_this.verified,_this.managementUrl,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Entitlement;
  return 'Entitlement(plan: ${_this.plan}, status: ${_this.status}, store: ${_this.store}, periodEnd: ${_this.periodEnd}, willRenew: ${_this.willRenew}, usage: ${_this.usage}, verified: ${_this.verified}, managementUrl: ${_this.managementUrl}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $EntitlementCopyWith<$Res>  {
  factory $EntitlementCopyWith(Entitlement value, $Res Function(Entitlement) _then) = _$EntitlementCopyWithImpl;
@useResult
$Res call({
 SubscriptionPlan plan, SubscriptionStatus status, BillingStore store, DateTime? periodEnd, bool willRenew, Map<LimitKey, int> usage, bool verified, String? managementUrl, DateTime? updatedAt
});


$SubscriptionPlanCopyWith<$Res> get plan;

}
/// @nodoc
class _$EntitlementCopyWithImpl<$Res>
    implements $EntitlementCopyWith<$Res> {
  _$EntitlementCopyWithImpl(this._self, this._then);

  final Entitlement _self;
  final $Res Function(Entitlement) _then;

/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plan = null,Object? status = null,Object? store = null,Object? periodEnd = freezed,Object? willRenew = null,Object? usage = null,Object? verified = null,Object? managementUrl = freezed,Object? updatedAt = freezed,}) {
  return _then(Entitlement(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlan,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,store: null == store ? _self.store : store // ignore: cast_nullable_to_non_nullable
as BillingStore,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,willRenew: null == willRenew ? _self.willRenew : willRenew // ignore: cast_nullable_to_non_nullable
as bool,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as Map<LimitKey, int>,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,managementUrl: freezed == managementUrl ? _self.managementUrl : managementUrl // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionPlanCopyWith<$Res> get plan {
  
  return $SubscriptionPlanCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}


/// Adds pattern-matching-related methods to [Entitlement].
extension EntitlementPatterns on Entitlement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Entitlement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Entitlement value)  $default,){
final _that = this;
switch (_that) {
case _Entitlement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Entitlement value)?  $default,){
final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SubscriptionPlan plan,  SubscriptionStatus status,  BillingStore store,  DateTime? periodEnd,  bool willRenew,  Map<LimitKey, int> usage,  bool verified,  String? managementUrl,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
return $default(_that.plan,_that.status,_that.store,_that.periodEnd,_that.willRenew,_that.usage,_that.verified,_that.managementUrl,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SubscriptionPlan plan,  SubscriptionStatus status,  BillingStore store,  DateTime? periodEnd,  bool willRenew,  Map<LimitKey, int> usage,  bool verified,  String? managementUrl,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Entitlement():
return $default(_that.plan,_that.status,_that.store,_that.periodEnd,_that.willRenew,_that.usage,_that.verified,_that.managementUrl,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SubscriptionPlan plan,  SubscriptionStatus status,  BillingStore store,  DateTime? periodEnd,  bool willRenew,  Map<LimitKey, int> usage,  bool verified,  String? managementUrl,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
return $default(_that.plan,_that.status,_that.store,_that.periodEnd,_that.willRenew,_that.usage,_that.verified,_that.managementUrl,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Entitlement extends Entitlement {
  const _Entitlement({required this.plan, this.status = SubscriptionStatus.none, this.store = BillingStore.none, this.periodEnd, this.willRenew = false,  Map<LimitKey, int> usage = const <LimitKey, int>{}, this.verified = true, this.managementUrl, this.updatedAt}): _usage = usage,super._();
  

@override final  SubscriptionPlan plan;
@override@JsonKey() final  SubscriptionStatus status;
@override@JsonKey() final  BillingStore store;
/// End of the paid (or trial) period.
@override final  DateTime? periodEnd;
@override@JsonKey() final  bool willRenew;
/// Usage of counted limits this period (e.g. voice parses).
 final  Map<LimitKey, int> _usage;
/// Usage of counted limits this period (e.g. voice parses).
@override@JsonKey() Map<LimitKey, int> get usage {
  if (_usage is EqualUnmodifiableMapView) return _usage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_usage);
}

/// True when the server confirmed it; false for the moments after a
/// store purchase before the server has heard about it.
@override@JsonKey() final  bool verified;
/// Where the person changes or cancels the subscription.
@override final  String? managementUrl;
@override final  DateTime? updatedAt;

/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementCopyWith<_Entitlement> get copyWith => __$EntitlementCopyWithImpl<_Entitlement>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Entitlement&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.status, status) || other.status == status)&&(identical(other.store, store) || other.store == store)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.willRenew, willRenew) || other.willRenew == willRenew)&&const DeepCollectionEquality().equals(other.usage, _usage)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.managementUrl, managementUrl) || other.managementUrl == managementUrl)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,plan,status,store,periodEnd,willRenew,const DeepCollectionEquality().hash(_usage),verified,managementUrl,updatedAt);
}

@override
String toString() {
    return 'Entitlement(plan: $plan, status: $status, store: $store, periodEnd: $periodEnd, willRenew: $willRenew, usage: $usage, verified: $verified, managementUrl: $managementUrl, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EntitlementCopyWith<$Res> implements $EntitlementCopyWith<$Res> {
  factory _$EntitlementCopyWith(_Entitlement value, $Res Function(_Entitlement) _then) = __$EntitlementCopyWithImpl;
@override @useResult
$Res call({
 SubscriptionPlan plan, SubscriptionStatus status, BillingStore store, DateTime? periodEnd, bool willRenew, Map<LimitKey, int> usage, bool verified, String? managementUrl, DateTime? updatedAt
});


@override $SubscriptionPlanCopyWith<$Res> get plan;

}
/// @nodoc
class __$EntitlementCopyWithImpl<$Res>
    implements _$EntitlementCopyWith<$Res> {
  __$EntitlementCopyWithImpl(this._self, this._then);

  final _Entitlement _self;
  final $Res Function(_Entitlement) _then;

/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? status = null,Object? store = null,Object? periodEnd = freezed,Object? willRenew = null,Object? usage = null,Object? verified = null,Object? managementUrl = freezed,Object? updatedAt = freezed,}) {
  return _then(_Entitlement(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlan,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,store: null == store ? _self.store : store // ignore: cast_nullable_to_non_nullable
as BillingStore,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,willRenew: null == willRenew ? _self.willRenew : willRenew // ignore: cast_nullable_to_non_nullable
as bool,usage: null == usage ? _self._usage : usage // ignore: cast_nullable_to_non_nullable
as Map<LimitKey, int>,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,managementUrl: freezed == managementUrl ? _self.managementUrl : managementUrl // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionPlanCopyWith<$Res> get plan {
  
  return $SubscriptionPlanCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}

// dart format on
