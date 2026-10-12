// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_analytics_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivityAnalyticsState {

 ActivityLoad get load; ActivityStats? get stats;/// The first date the stats cover.
 LocalDate? get from; AnalyticsAccess get access; bool get applying;/// Changes each time a suggestion was applied (for a confirmation).
 int get appliedCount; Failure? get loadFailure; Failure? get failure; int get failureCount;
/// Create a copy of ActivityAnalyticsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityAnalyticsStateCopyWith<ActivityAnalyticsState> get copyWith => _$ActivityAnalyticsStateCopyWithImpl<ActivityAnalyticsState>(this as ActivityAnalyticsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ActivityAnalyticsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityAnalyticsState&&(identical(other.load, _this.load) || other.load == _this.load)&&(identical(other.stats, _this.stats) || other.stats == _this.stats)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.access, _this.access) || other.access == _this.access)&&(identical(other.applying, _this.applying) || other.applying == _this.applying)&&(identical(other.appliedCount, _this.appliedCount) || other.appliedCount == _this.appliedCount)&&(identical(other.loadFailure, _this.loadFailure) || other.loadFailure == _this.loadFailure)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.failureCount, _this.failureCount) || other.failureCount == _this.failureCount));
}


@override
int get hashCode {
  final _this = this as ActivityAnalyticsState;
  return Object.hash(runtimeType,_this.load,_this.stats,_this.from,_this.access,_this.applying,_this.appliedCount,_this.loadFailure,_this.failure,_this.failureCount);
}

@override
String toString() {
  final _this = this as ActivityAnalyticsState;
  return 'ActivityAnalyticsState(load: ${_this.load}, stats: ${_this.stats}, from: ${_this.from}, access: ${_this.access}, applying: ${_this.applying}, appliedCount: ${_this.appliedCount}, loadFailure: ${_this.loadFailure}, failure: ${_this.failure}, failureCount: ${_this.failureCount})';
}


}

/// @nodoc
abstract mixin class $ActivityAnalyticsStateCopyWith<$Res>  {
  factory $ActivityAnalyticsStateCopyWith(ActivityAnalyticsState value, $Res Function(ActivityAnalyticsState) _then) = _$ActivityAnalyticsStateCopyWithImpl;
@useResult
$Res call({
 ActivityLoad load, ActivityStats? stats, LocalDate? from, AnalyticsAccess access, bool applying, int appliedCount, Failure? loadFailure, Failure? failure, int failureCount
});


$ActivityStatsCopyWith<$Res>? get stats;$FailureCopyWith<$Res>? get loadFailure;$FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$ActivityAnalyticsStateCopyWithImpl<$Res>
    implements $ActivityAnalyticsStateCopyWith<$Res> {
  _$ActivityAnalyticsStateCopyWithImpl(this._self, this._then);

  final ActivityAnalyticsState _self;
  final $Res Function(ActivityAnalyticsState) _then;

/// Create a copy of ActivityAnalyticsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? load = null,Object? stats = freezed,Object? from = freezed,Object? access = null,Object? applying = null,Object? appliedCount = null,Object? loadFailure = freezed,Object? failure = freezed,Object? failureCount = null,}) {
  return _then(ActivityAnalyticsState(
load: null == load ? _self.load : load // ignore: cast_nullable_to_non_nullable
as ActivityLoad,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ActivityStats?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as LocalDate?,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as AnalyticsAccess,applying: null == applying ? _self.applying : applying // ignore: cast_nullable_to_non_nullable
as bool,appliedCount: null == appliedCount ? _self.appliedCount : appliedCount // ignore: cast_nullable_to_non_nullable
as int,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ActivityAnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivityStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
    return null;
  }

  return $ActivityStatsCopyWith<$Res>(_self.stats!, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of ActivityAnalyticsState
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
}/// Create a copy of ActivityAnalyticsState
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


/// Adds pattern-matching-related methods to [ActivityAnalyticsState].
extension ActivityAnalyticsStatePatterns on ActivityAnalyticsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityAnalyticsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityAnalyticsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityAnalyticsState value)  $default,){
final _that = this;
switch (_that) {
case _ActivityAnalyticsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityAnalyticsState value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityAnalyticsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ActivityLoad load,  ActivityStats? stats,  LocalDate? from,  AnalyticsAccess access,  bool applying,  int appliedCount,  Failure? loadFailure,  Failure? failure,  int failureCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityAnalyticsState() when $default != null:
return $default(_that.load,_that.stats,_that.from,_that.access,_that.applying,_that.appliedCount,_that.loadFailure,_that.failure,_that.failureCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ActivityLoad load,  ActivityStats? stats,  LocalDate? from,  AnalyticsAccess access,  bool applying,  int appliedCount,  Failure? loadFailure,  Failure? failure,  int failureCount)  $default,) {final _that = this;
switch (_that) {
case _ActivityAnalyticsState():
return $default(_that.load,_that.stats,_that.from,_that.access,_that.applying,_that.appliedCount,_that.loadFailure,_that.failure,_that.failureCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ActivityLoad load,  ActivityStats? stats,  LocalDate? from,  AnalyticsAccess access,  bool applying,  int appliedCount,  Failure? loadFailure,  Failure? failure,  int failureCount)?  $default,) {final _that = this;
switch (_that) {
case _ActivityAnalyticsState() when $default != null:
return $default(_that.load,_that.stats,_that.from,_that.access,_that.applying,_that.appliedCount,_that.loadFailure,_that.failure,_that.failureCount);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityAnalyticsState extends ActivityAnalyticsState {
  const _ActivityAnalyticsState({this.load = ActivityLoad.loading, this.stats, this.from, this.access = const AnalyticsAccess(suggestionsUnlocked: true), this.applying = false, this.appliedCount = 0, this.loadFailure, this.failure, this.failureCount = 0}): super._();
  

@override@JsonKey() final  ActivityLoad load;
@override final  ActivityStats? stats;
/// The first date the stats cover.
@override final  LocalDate? from;
@override@JsonKey() final  AnalyticsAccess access;
@override@JsonKey() final  bool applying;
/// Changes each time a suggestion was applied (for a confirmation).
@override@JsonKey() final  int appliedCount;
@override final  Failure? loadFailure;
@override final  Failure? failure;
@override@JsonKey() final  int failureCount;

/// Create a copy of ActivityAnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityAnalyticsStateCopyWith<_ActivityAnalyticsState> get copyWith => __$ActivityAnalyticsStateCopyWithImpl<_ActivityAnalyticsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityAnalyticsState&&(identical(other.load, load) || other.load == load)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.from, from) || other.from == from)&&(identical(other.access, access) || other.access == access)&&(identical(other.applying, applying) || other.applying == applying)&&(identical(other.appliedCount, appliedCount) || other.appliedCount == appliedCount)&&(identical(other.loadFailure, loadFailure) || other.loadFailure == loadFailure)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.failureCount, failureCount) || other.failureCount == failureCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,load,stats,from,access,applying,appliedCount,loadFailure,failure,failureCount);
}

@override
String toString() {
    return 'ActivityAnalyticsState(load: $load, stats: $stats, from: $from, access: $access, applying: $applying, appliedCount: $appliedCount, loadFailure: $loadFailure, failure: $failure, failureCount: $failureCount)';
}


}

/// @nodoc
abstract mixin class _$ActivityAnalyticsStateCopyWith<$Res> implements $ActivityAnalyticsStateCopyWith<$Res> {
  factory _$ActivityAnalyticsStateCopyWith(_ActivityAnalyticsState value, $Res Function(_ActivityAnalyticsState) _then) = __$ActivityAnalyticsStateCopyWithImpl;
@override @useResult
$Res call({
 ActivityLoad load, ActivityStats? stats, LocalDate? from, AnalyticsAccess access, bool applying, int appliedCount, Failure? loadFailure, Failure? failure, int failureCount
});


@override $ActivityStatsCopyWith<$Res>? get stats;@override $FailureCopyWith<$Res>? get loadFailure;@override $FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$ActivityAnalyticsStateCopyWithImpl<$Res>
    implements _$ActivityAnalyticsStateCopyWith<$Res> {
  __$ActivityAnalyticsStateCopyWithImpl(this._self, this._then);

  final _ActivityAnalyticsState _self;
  final $Res Function(_ActivityAnalyticsState) _then;

/// Create a copy of ActivityAnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? load = null,Object? stats = freezed,Object? from = freezed,Object? access = null,Object? applying = null,Object? appliedCount = null,Object? loadFailure = freezed,Object? failure = freezed,Object? failureCount = null,}) {
  return _then(_ActivityAnalyticsState(
load: null == load ? _self.load : load // ignore: cast_nullable_to_non_nullable
as ActivityLoad,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ActivityStats?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as LocalDate?,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as AnalyticsAccess,applying: null == applying ? _self.applying : applying // ignore: cast_nullable_to_non_nullable
as bool,appliedCount: null == appliedCount ? _self.appliedCount : appliedCount // ignore: cast_nullable_to_non_nullable
as int,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ActivityAnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivityStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
    return null;
  }

  return $ActivityStatsCopyWith<$Res>(_self.stats!, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of ActivityAnalyticsState
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
}/// Create a copy of ActivityAnalyticsState
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
