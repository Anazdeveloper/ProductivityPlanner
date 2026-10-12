// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_status_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncStatusState {

/// Null until the first status arrives.
 SyncStatus? get status; List<SyncIssue> get issues;/// A "Sync now" the person asked for is running.
 bool get manualSync;/// The last failure of an action here; [failureCount] changes with
/// each one.
 Failure? get failure; int get failureCount;/// Changes when a manual sync finished cleanly.
 int get syncedCount;
/// Create a copy of SyncStatusState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncStatusStateCopyWith<SyncStatusState> get copyWith => _$SyncStatusStateCopyWithImpl<SyncStatusState>(this as SyncStatusState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SyncStatusState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncStatusState&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.issues, _this.issues)&&(identical(other.manualSync, _this.manualSync) || other.manualSync == _this.manualSync)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.failureCount, _this.failureCount) || other.failureCount == _this.failureCount)&&(identical(other.syncedCount, _this.syncedCount) || other.syncedCount == _this.syncedCount));
}


@override
int get hashCode {
  final _this = this as SyncStatusState;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.issues),_this.manualSync,_this.failure,_this.failureCount,_this.syncedCount);
}

@override
String toString() {
  final _this = this as SyncStatusState;
  return 'SyncStatusState(status: ${_this.status}, issues: ${_this.issues}, manualSync: ${_this.manualSync}, failure: ${_this.failure}, failureCount: ${_this.failureCount}, syncedCount: ${_this.syncedCount})';
}


}

/// @nodoc
abstract mixin class $SyncStatusStateCopyWith<$Res>  {
  factory $SyncStatusStateCopyWith(SyncStatusState value, $Res Function(SyncStatusState) _then) = _$SyncStatusStateCopyWithImpl;
@useResult
$Res call({
 SyncStatus? status, List<SyncIssue> issues, bool manualSync, Failure? failure, int failureCount, int syncedCount
});


$FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$SyncStatusStateCopyWithImpl<$Res>
    implements $SyncStatusStateCopyWith<$Res> {
  _$SyncStatusStateCopyWithImpl(this._self, this._then);

  final SyncStatusState _self;
  final $Res Function(SyncStatusState) _then;

/// Create a copy of SyncStatusState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? issues = null,Object? manualSync = null,Object? failure = freezed,Object? failureCount = null,Object? syncedCount = null,}) {
  return _then(SyncStatusState(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncStatus?,issues: null == issues ? _self.issues : issues // ignore: cast_nullable_to_non_nullable
as List<SyncIssue>,manualSync: null == manualSync ? _self.manualSync : manualSync // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,syncedCount: null == syncedCount ? _self.syncedCount : syncedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SyncStatusState
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


/// Adds pattern-matching-related methods to [SyncStatusState].
extension SyncStatusStatePatterns on SyncStatusState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncStatusState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncStatusState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncStatusState value)  $default,){
final _that = this;
switch (_that) {
case _SyncStatusState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncStatusState value)?  $default,){
final _that = this;
switch (_that) {
case _SyncStatusState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SyncStatus? status,  List<SyncIssue> issues,  bool manualSync,  Failure? failure,  int failureCount,  int syncedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncStatusState() when $default != null:
return $default(_that.status,_that.issues,_that.manualSync,_that.failure,_that.failureCount,_that.syncedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SyncStatus? status,  List<SyncIssue> issues,  bool manualSync,  Failure? failure,  int failureCount,  int syncedCount)  $default,) {final _that = this;
switch (_that) {
case _SyncStatusState():
return $default(_that.status,_that.issues,_that.manualSync,_that.failure,_that.failureCount,_that.syncedCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SyncStatus? status,  List<SyncIssue> issues,  bool manualSync,  Failure? failure,  int failureCount,  int syncedCount)?  $default,) {final _that = this;
switch (_that) {
case _SyncStatusState() when $default != null:
return $default(_that.status,_that.issues,_that.manualSync,_that.failure,_that.failureCount,_that.syncedCount);case _:
  return null;

}
}

}

/// @nodoc


class _SyncStatusState extends SyncStatusState {
  const _SyncStatusState({this.status,  List<SyncIssue> issues = const <SyncIssue>[], this.manualSync = false, this.failure, this.failureCount = 0, this.syncedCount = 0}): _issues = issues,super._();
  

/// Null until the first status arrives.
@override final  SyncStatus? status;
 final  List<SyncIssue> _issues;
@override@JsonKey() List<SyncIssue> get issues {
  if (_issues is EqualUnmodifiableListView) return _issues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issues);
}

/// A "Sync now" the person asked for is running.
@override@JsonKey() final  bool manualSync;
/// The last failure of an action here; [failureCount] changes with
/// each one.
@override final  Failure? failure;
@override@JsonKey() final  int failureCount;
/// Changes when a manual sync finished cleanly.
@override@JsonKey() final  int syncedCount;

/// Create a copy of SyncStatusState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncStatusStateCopyWith<_SyncStatusState> get copyWith => __$SyncStatusStateCopyWithImpl<_SyncStatusState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncStatusState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.issues, _issues)&&(identical(other.manualSync, manualSync) || other.manualSync == manualSync)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.failureCount, failureCount) || other.failureCount == failureCount)&&(identical(other.syncedCount, syncedCount) || other.syncedCount == syncedCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_issues),manualSync,failure,failureCount,syncedCount);
}

@override
String toString() {
    return 'SyncStatusState(status: $status, issues: $issues, manualSync: $manualSync, failure: $failure, failureCount: $failureCount, syncedCount: $syncedCount)';
}


}

/// @nodoc
abstract mixin class _$SyncStatusStateCopyWith<$Res> implements $SyncStatusStateCopyWith<$Res> {
  factory _$SyncStatusStateCopyWith(_SyncStatusState value, $Res Function(_SyncStatusState) _then) = __$SyncStatusStateCopyWithImpl;
@override @useResult
$Res call({
 SyncStatus? status, List<SyncIssue> issues, bool manualSync, Failure? failure, int failureCount, int syncedCount
});


@override $FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$SyncStatusStateCopyWithImpl<$Res>
    implements _$SyncStatusStateCopyWith<$Res> {
  __$SyncStatusStateCopyWithImpl(this._self, this._then);

  final _SyncStatusState _self;
  final $Res Function(_SyncStatusState) _then;

/// Create a copy of SyncStatusState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? issues = null,Object? manualSync = null,Object? failure = freezed,Object? failureCount = null,Object? syncedCount = null,}) {
  return _then(_SyncStatusState(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncStatus?,issues: null == issues ? _self._issues : issues // ignore: cast_nullable_to_non_nullable
as List<SyncIssue>,manualSync: null == manualSync ? _self.manualSync : manualSync // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,syncedCount: null == syncedCount ? _self.syncedCount : syncedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SyncStatusState
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
