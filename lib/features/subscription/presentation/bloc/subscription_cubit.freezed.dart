// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubscriptionState {

 Entitlement get entitlement; OffersLoad get offersLoad; List<PlanOffer> get offers; String? get selectedOfferId; bool get purchasing; bool get restoring;/// The last failure; [failureCount] changes with each one.
 Failure? get failure; int get failureCount;/// Changes when a purchase or restore made the user Pro.
 int get upgradedCount;/// Changes when a restore found nothing.
 int get nothingRestoredCount;
/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStateCopyWith<SubscriptionState> get copyWith => _$SubscriptionStateCopyWithImpl<SubscriptionState>(this as SubscriptionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SubscriptionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionState&&(identical(other.entitlement, _this.entitlement) || other.entitlement == _this.entitlement)&&(identical(other.offersLoad, _this.offersLoad) || other.offersLoad == _this.offersLoad)&&const DeepCollectionEquality().equals(other.offers, _this.offers)&&(identical(other.selectedOfferId, _this.selectedOfferId) || other.selectedOfferId == _this.selectedOfferId)&&(identical(other.purchasing, _this.purchasing) || other.purchasing == _this.purchasing)&&(identical(other.restoring, _this.restoring) || other.restoring == _this.restoring)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.failureCount, _this.failureCount) || other.failureCount == _this.failureCount)&&(identical(other.upgradedCount, _this.upgradedCount) || other.upgradedCount == _this.upgradedCount)&&(identical(other.nothingRestoredCount, _this.nothingRestoredCount) || other.nothingRestoredCount == _this.nothingRestoredCount));
}


@override
int get hashCode {
  final _this = this as SubscriptionState;
  return Object.hash(runtimeType,_this.entitlement,_this.offersLoad,const DeepCollectionEquality().hash(_this.offers),_this.selectedOfferId,_this.purchasing,_this.restoring,_this.failure,_this.failureCount,_this.upgradedCount,_this.nothingRestoredCount);
}

@override
String toString() {
  final _this = this as SubscriptionState;
  return 'SubscriptionState(entitlement: ${_this.entitlement}, offersLoad: ${_this.offersLoad}, offers: ${_this.offers}, selectedOfferId: ${_this.selectedOfferId}, purchasing: ${_this.purchasing}, restoring: ${_this.restoring}, failure: ${_this.failure}, failureCount: ${_this.failureCount}, upgradedCount: ${_this.upgradedCount}, nothingRestoredCount: ${_this.nothingRestoredCount})';
}


}

/// @nodoc
abstract mixin class $SubscriptionStateCopyWith<$Res>  {
  factory $SubscriptionStateCopyWith(SubscriptionState value, $Res Function(SubscriptionState) _then) = _$SubscriptionStateCopyWithImpl;
@useResult
$Res call({
 Entitlement entitlement, OffersLoad offersLoad, List<PlanOffer> offers, String? selectedOfferId, bool purchasing, bool restoring, Failure? failure, int failureCount, int upgradedCount, int nothingRestoredCount
});


$EntitlementCopyWith<$Res> get entitlement;$FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$SubscriptionStateCopyWithImpl<$Res>
    implements $SubscriptionStateCopyWith<$Res> {
  _$SubscriptionStateCopyWithImpl(this._self, this._then);

  final SubscriptionState _self;
  final $Res Function(SubscriptionState) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entitlement = null,Object? offersLoad = null,Object? offers = null,Object? selectedOfferId = freezed,Object? purchasing = null,Object? restoring = null,Object? failure = freezed,Object? failureCount = null,Object? upgradedCount = null,Object? nothingRestoredCount = null,}) {
  return _then(SubscriptionState(
entitlement: null == entitlement ? _self.entitlement : entitlement // ignore: cast_nullable_to_non_nullable
as Entitlement,offersLoad: null == offersLoad ? _self.offersLoad : offersLoad // ignore: cast_nullable_to_non_nullable
as OffersLoad,offers: null == offers ? _self.offers : offers // ignore: cast_nullable_to_non_nullable
as List<PlanOffer>,selectedOfferId: freezed == selectedOfferId ? _self.selectedOfferId : selectedOfferId // ignore: cast_nullable_to_non_nullable
as String?,purchasing: null == purchasing ? _self.purchasing : purchasing // ignore: cast_nullable_to_non_nullable
as bool,restoring: null == restoring ? _self.restoring : restoring // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,upgradedCount: null == upgradedCount ? _self.upgradedCount : upgradedCount // ignore: cast_nullable_to_non_nullable
as int,nothingRestoredCount: null == nothingRestoredCount ? _self.nothingRestoredCount : nothingRestoredCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntitlementCopyWith<$Res> get entitlement {
  
  return $EntitlementCopyWith<$Res>(_self.entitlement, (value) {
    return _then(_self.copyWith(entitlement: value));
  });
}/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}


/// Adds pattern-matching-related methods to [SubscriptionState].
extension SubscriptionStatePatterns on SubscriptionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionState value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionState value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Entitlement entitlement,  OffersLoad offersLoad,  List<PlanOffer> offers,  String? selectedOfferId,  bool purchasing,  bool restoring,  Failure? failure,  int failureCount,  int upgradedCount,  int nothingRestoredCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
return $default(_that.entitlement,_that.offersLoad,_that.offers,_that.selectedOfferId,_that.purchasing,_that.restoring,_that.failure,_that.failureCount,_that.upgradedCount,_that.nothingRestoredCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Entitlement entitlement,  OffersLoad offersLoad,  List<PlanOffer> offers,  String? selectedOfferId,  bool purchasing,  bool restoring,  Failure? failure,  int failureCount,  int upgradedCount,  int nothingRestoredCount)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionState():
return $default(_that.entitlement,_that.offersLoad,_that.offers,_that.selectedOfferId,_that.purchasing,_that.restoring,_that.failure,_that.failureCount,_that.upgradedCount,_that.nothingRestoredCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Entitlement entitlement,  OffersLoad offersLoad,  List<PlanOffer> offers,  String? selectedOfferId,  bool purchasing,  bool restoring,  Failure? failure,  int failureCount,  int upgradedCount,  int nothingRestoredCount)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionState() when $default != null:
return $default(_that.entitlement,_that.offersLoad,_that.offers,_that.selectedOfferId,_that.purchasing,_that.restoring,_that.failure,_that.failureCount,_that.upgradedCount,_that.nothingRestoredCount);case _:
  return null;

}
}

}

/// @nodoc


class _SubscriptionState extends SubscriptionState {
  const _SubscriptionState({this.entitlement = Entitlement.free, this.offersLoad = OffersLoad.loading,  List<PlanOffer> offers = const <PlanOffer>[], this.selectedOfferId, this.purchasing = false, this.restoring = false, this.failure, this.failureCount = 0, this.upgradedCount = 0, this.nothingRestoredCount = 0}): _offers = offers,super._();
  

@override@JsonKey() final  Entitlement entitlement;
@override@JsonKey() final  OffersLoad offersLoad;
 final  List<PlanOffer> _offers;
@override@JsonKey() List<PlanOffer> get offers {
  if (_offers is EqualUnmodifiableListView) return _offers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_offers);
}

@override final  String? selectedOfferId;
@override@JsonKey() final  bool purchasing;
@override@JsonKey() final  bool restoring;
/// The last failure; [failureCount] changes with each one.
@override final  Failure? failure;
@override@JsonKey() final  int failureCount;
/// Changes when a purchase or restore made the user Pro.
@override@JsonKey() final  int upgradedCount;
/// Changes when a restore found nothing.
@override@JsonKey() final  int nothingRestoredCount;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionStateCopyWith<_SubscriptionState> get copyWith => __$SubscriptionStateCopyWithImpl<_SubscriptionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionState&&(identical(other.entitlement, entitlement) || other.entitlement == entitlement)&&(identical(other.offersLoad, offersLoad) || other.offersLoad == offersLoad)&&const DeepCollectionEquality().equals(other.offers, _offers)&&(identical(other.selectedOfferId, selectedOfferId) || other.selectedOfferId == selectedOfferId)&&(identical(other.purchasing, purchasing) || other.purchasing == purchasing)&&(identical(other.restoring, restoring) || other.restoring == restoring)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.failureCount, failureCount) || other.failureCount == failureCount)&&(identical(other.upgradedCount, upgradedCount) || other.upgradedCount == upgradedCount)&&(identical(other.nothingRestoredCount, nothingRestoredCount) || other.nothingRestoredCount == nothingRestoredCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entitlement,offersLoad,const DeepCollectionEquality().hash(_offers),selectedOfferId,purchasing,restoring,failure,failureCount,upgradedCount,nothingRestoredCount);
}

@override
String toString() {
    return 'SubscriptionState(entitlement: $entitlement, offersLoad: $offersLoad, offers: $offers, selectedOfferId: $selectedOfferId, purchasing: $purchasing, restoring: $restoring, failure: $failure, failureCount: $failureCount, upgradedCount: $upgradedCount, nothingRestoredCount: $nothingRestoredCount)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionStateCopyWith<$Res> implements $SubscriptionStateCopyWith<$Res> {
  factory _$SubscriptionStateCopyWith(_SubscriptionState value, $Res Function(_SubscriptionState) _then) = __$SubscriptionStateCopyWithImpl;
@override @useResult
$Res call({
 Entitlement entitlement, OffersLoad offersLoad, List<PlanOffer> offers, String? selectedOfferId, bool purchasing, bool restoring, Failure? failure, int failureCount, int upgradedCount, int nothingRestoredCount
});


@override $EntitlementCopyWith<$Res> get entitlement;@override $FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$SubscriptionStateCopyWithImpl<$Res>
    implements _$SubscriptionStateCopyWith<$Res> {
  __$SubscriptionStateCopyWithImpl(this._self, this._then);

  final _SubscriptionState _self;
  final $Res Function(_SubscriptionState) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entitlement = null,Object? offersLoad = null,Object? offers = null,Object? selectedOfferId = freezed,Object? purchasing = null,Object? restoring = null,Object? failure = freezed,Object? failureCount = null,Object? upgradedCount = null,Object? nothingRestoredCount = null,}) {
  return _then(_SubscriptionState(
entitlement: null == entitlement ? _self.entitlement : entitlement // ignore: cast_nullable_to_non_nullable
as Entitlement,offersLoad: null == offersLoad ? _self.offersLoad : offersLoad // ignore: cast_nullable_to_non_nullable
as OffersLoad,offers: null == offers ? _self._offers : offers // ignore: cast_nullable_to_non_nullable
as List<PlanOffer>,selectedOfferId: freezed == selectedOfferId ? _self.selectedOfferId : selectedOfferId // ignore: cast_nullable_to_non_nullable
as String?,purchasing: null == purchasing ? _self.purchasing : purchasing // ignore: cast_nullable_to_non_nullable
as bool,restoring: null == restoring ? _self.restoring : restoring // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,upgradedCount: null == upgradedCount ? _self.upgradedCount : upgradedCount // ignore: cast_nullable_to_non_nullable
as int,nothingRestoredCount: null == nothingRestoredCount ? _self.nothingRestoredCount : nothingRestoredCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntitlementCopyWith<$Res> get entitlement {
  
  return $EntitlementCopyWith<$Res>(_self.entitlement, (value) {
    return _then(_self.copyWith(entitlement: value));
  });
}/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
