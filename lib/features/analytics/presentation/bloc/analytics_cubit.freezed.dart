// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalyticsState {

/// Today in the user's home zone.
 LocalDate get today; AnalyticsPeriod get period; AnalyticsLoad get load;/// Null until the period's records first arrive.
 AnalyticsReport? get report; AnalyticsAccess get access; Failure? get loadFailure;
/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsStateCopyWith<AnalyticsState> get copyWith => _$AnalyticsStateCopyWithImpl<AnalyticsState>(this as AnalyticsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AnalyticsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsState&&(identical(other.today, _this.today) || other.today == _this.today)&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.load, _this.load) || other.load == _this.load)&&(identical(other.report, _this.report) || other.report == _this.report)&&(identical(other.access, _this.access) || other.access == _this.access)&&(identical(other.loadFailure, _this.loadFailure) || other.loadFailure == _this.loadFailure));
}


@override
int get hashCode {
  final _this = this as AnalyticsState;
  return Object.hash(runtimeType,_this.today,_this.period,_this.load,_this.report,_this.access,_this.loadFailure);
}

@override
String toString() {
  final _this = this as AnalyticsState;
  return 'AnalyticsState(today: ${_this.today}, period: ${_this.period}, load: ${_this.load}, report: ${_this.report}, access: ${_this.access}, loadFailure: ${_this.loadFailure})';
}


}

/// @nodoc
abstract mixin class $AnalyticsStateCopyWith<$Res>  {
  factory $AnalyticsStateCopyWith(AnalyticsState value, $Res Function(AnalyticsState) _then) = _$AnalyticsStateCopyWithImpl;
@useResult
$Res call({
 LocalDate today, AnalyticsPeriod period, AnalyticsLoad load, AnalyticsReport? report, AnalyticsAccess access, Failure? loadFailure
});


$AnalyticsReportCopyWith<$Res>? get report;$FailureCopyWith<$Res>? get loadFailure;

}
/// @nodoc
class _$AnalyticsStateCopyWithImpl<$Res>
    implements $AnalyticsStateCopyWith<$Res> {
  _$AnalyticsStateCopyWithImpl(this._self, this._then);

  final AnalyticsState _self;
  final $Res Function(AnalyticsState) _then;

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? today = null,Object? period = null,Object? load = null,Object? report = freezed,Object? access = null,Object? loadFailure = freezed,}) {
  return _then(AnalyticsState(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsPeriod,load: null == load ? _self.load : load // ignore: cast_nullable_to_non_nullable
as AnalyticsLoad,report: freezed == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as AnalyticsReport?,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as AnalyticsAccess,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}
/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsReportCopyWith<$Res>? get report {
    if (_self.report == null) {
    return null;
  }

  return $AnalyticsReportCopyWith<$Res>(_self.report!, (value) {
    return _then(_self.copyWith(report: value));
  });
}/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get loadFailure {
    if (_self.loadFailure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.loadFailure!, (value) {
    return _then(_self.copyWith(loadFailure: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsState].
extension AnalyticsStatePatterns on AnalyticsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsState value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsState value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate today,  AnalyticsPeriod period,  AnalyticsLoad load,  AnalyticsReport? report,  AnalyticsAccess access,  Failure? loadFailure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
return $default(_that.today,_that.period,_that.load,_that.report,_that.access,_that.loadFailure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate today,  AnalyticsPeriod period,  AnalyticsLoad load,  AnalyticsReport? report,  AnalyticsAccess access,  Failure? loadFailure)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsState():
return $default(_that.today,_that.period,_that.load,_that.report,_that.access,_that.loadFailure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate today,  AnalyticsPeriod period,  AnalyticsLoad load,  AnalyticsReport? report,  AnalyticsAccess access,  Failure? loadFailure)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
return $default(_that.today,_that.period,_that.load,_that.report,_that.access,_that.loadFailure);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsState extends AnalyticsState {
  const _AnalyticsState({required this.today, required this.period, this.load = AnalyticsLoad.loading, this.report, this.access = const AnalyticsAccess(suggestionsUnlocked: true), this.loadFailure}): super._();
  

/// Today in the user's home zone.
@override final  LocalDate today;
@override final  AnalyticsPeriod period;
@override@JsonKey() final  AnalyticsLoad load;
/// Null until the period's records first arrive.
@override final  AnalyticsReport? report;
@override@JsonKey() final  AnalyticsAccess access;
@override final  Failure? loadFailure;

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsStateCopyWith<_AnalyticsState> get copyWith => __$AnalyticsStateCopyWithImpl<_AnalyticsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsState&&(identical(other.today, today) || other.today == today)&&(identical(other.period, period) || other.period == period)&&(identical(other.load, load) || other.load == load)&&(identical(other.report, report) || other.report == report)&&(identical(other.access, access) || other.access == access)&&(identical(other.loadFailure, loadFailure) || other.loadFailure == loadFailure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,today,period,load,report,access,loadFailure);
}

@override
String toString() {
    return 'AnalyticsState(today: $today, period: $period, load: $load, report: $report, access: $access, loadFailure: $loadFailure)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsStateCopyWith<$Res> implements $AnalyticsStateCopyWith<$Res> {
  factory _$AnalyticsStateCopyWith(_AnalyticsState value, $Res Function(_AnalyticsState) _then) = __$AnalyticsStateCopyWithImpl;
@override @useResult
$Res call({
 LocalDate today, AnalyticsPeriod period, AnalyticsLoad load, AnalyticsReport? report, AnalyticsAccess access, Failure? loadFailure
});


@override $AnalyticsReportCopyWith<$Res>? get report;@override $FailureCopyWith<$Res>? get loadFailure;

}
/// @nodoc
class __$AnalyticsStateCopyWithImpl<$Res>
    implements _$AnalyticsStateCopyWith<$Res> {
  __$AnalyticsStateCopyWithImpl(this._self, this._then);

  final _AnalyticsState _self;
  final $Res Function(_AnalyticsState) _then;

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? today = null,Object? period = null,Object? load = null,Object? report = freezed,Object? access = null,Object? loadFailure = freezed,}) {
  return _then(_AnalyticsState(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsPeriod,load: null == load ? _self.load : load // ignore: cast_nullable_to_non_nullable
as AnalyticsLoad,report: freezed == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as AnalyticsReport?,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as AnalyticsAccess,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsReportCopyWith<$Res>? get report {
    if (_self.report == null) {
    return null;
  }

  return $AnalyticsReportCopyWith<$Res>(_self.report!, (value) {
    return _then(_self.copyWith(report: value));
  });
}/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get loadFailure {
    if (_self.loadFailure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.loadFailure!, (value) {
    return _then(_self.copyWith(loadFailure: value));
  });
}
}

// dart format on
