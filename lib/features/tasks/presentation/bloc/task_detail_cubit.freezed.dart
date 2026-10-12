// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_detail_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskDetailState {

 DateTime get now; DetailStatus get status; AgendaEntry? get entry;/// Today in the task's zone (for "Today"/"Tomorrow" labels and pickers).
 LocalDate? get today;/// Whether "later today" is still possible for this occurrence.
 bool get canPostponeLaterToday; bool get busy; Failure? get loadFailure;/// The last failed action; [actionFailureCount] changes with each one.
 Failure? get actionFailure; int get actionFailureCount;/// Set once the series was deleted from this screen (the page closes).
 bool get deleted;
/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskDetailStateCopyWith<TaskDetailState> get copyWith => _$TaskDetailStateCopyWithImpl<TaskDetailState>(this as TaskDetailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskDetailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskDetailState&&(identical(other.now, _this.now) || other.now == _this.now)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.entry, _this.entry) || other.entry == _this.entry)&&(identical(other.today, _this.today) || other.today == _this.today)&&(identical(other.canPostponeLaterToday, _this.canPostponeLaterToday) || other.canPostponeLaterToday == _this.canPostponeLaterToday)&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.loadFailure, _this.loadFailure) || other.loadFailure == _this.loadFailure)&&(identical(other.actionFailure, _this.actionFailure) || other.actionFailure == _this.actionFailure)&&(identical(other.actionFailureCount, _this.actionFailureCount) || other.actionFailureCount == _this.actionFailureCount)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted));
}


@override
int get hashCode {
  final _this = this as TaskDetailState;
  return Object.hash(runtimeType,_this.now,_this.status,_this.entry,_this.today,_this.canPostponeLaterToday,_this.busy,_this.loadFailure,_this.actionFailure,_this.actionFailureCount,_this.deleted);
}

@override
String toString() {
  final _this = this as TaskDetailState;
  return 'TaskDetailState(now: ${_this.now}, status: ${_this.status}, entry: ${_this.entry}, today: ${_this.today}, canPostponeLaterToday: ${_this.canPostponeLaterToday}, busy: ${_this.busy}, loadFailure: ${_this.loadFailure}, actionFailure: ${_this.actionFailure}, actionFailureCount: ${_this.actionFailureCount}, deleted: ${_this.deleted})';
}


}

/// @nodoc
abstract mixin class $TaskDetailStateCopyWith<$Res>  {
  factory $TaskDetailStateCopyWith(TaskDetailState value, $Res Function(TaskDetailState) _then) = _$TaskDetailStateCopyWithImpl;
@useResult
$Res call({
 DateTime now, DetailStatus status, AgendaEntry? entry, LocalDate? today, bool canPostponeLaterToday, bool busy, Failure? loadFailure, Failure? actionFailure, int actionFailureCount, bool deleted
});


$FailureCopyWith<$Res>? get loadFailure;$FailureCopyWith<$Res>? get actionFailure;

}
/// @nodoc
class _$TaskDetailStateCopyWithImpl<$Res>
    implements $TaskDetailStateCopyWith<$Res> {
  _$TaskDetailStateCopyWithImpl(this._self, this._then);

  final TaskDetailState _self;
  final $Res Function(TaskDetailState) _then;

/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? now = null,Object? status = null,Object? entry = freezed,Object? today = freezed,Object? canPostponeLaterToday = null,Object? busy = null,Object? loadFailure = freezed,Object? actionFailure = freezed,Object? actionFailureCount = null,Object? deleted = null,}) {
  return _then(TaskDetailState(
now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DetailStatus,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as AgendaEntry?,today: freezed == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate?,canPostponeLaterToday: null == canPostponeLaterToday ? _self.canPostponeLaterToday : canPostponeLaterToday // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,actionFailure: freezed == actionFailure ? _self.actionFailure : actionFailure // ignore: cast_nullable_to_non_nullable
as Failure?,actionFailureCount: null == actionFailureCount ? _self.actionFailureCount : actionFailureCount // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TaskDetailState
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
}/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get actionFailure {
    if (_self.actionFailure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.actionFailure!, (value) {
    return _then(_self.copyWith(actionFailure: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskDetailState].
extension TaskDetailStatePatterns on TaskDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskDetailState value)  $default,){
final _that = this;
switch (_that) {
case _TaskDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _TaskDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime now,  DetailStatus status,  AgendaEntry? entry,  LocalDate? today,  bool canPostponeLaterToday,  bool busy,  Failure? loadFailure,  Failure? actionFailure,  int actionFailureCount,  bool deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskDetailState() when $default != null:
return $default(_that.now,_that.status,_that.entry,_that.today,_that.canPostponeLaterToday,_that.busy,_that.loadFailure,_that.actionFailure,_that.actionFailureCount,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime now,  DetailStatus status,  AgendaEntry? entry,  LocalDate? today,  bool canPostponeLaterToday,  bool busy,  Failure? loadFailure,  Failure? actionFailure,  int actionFailureCount,  bool deleted)  $default,) {final _that = this;
switch (_that) {
case _TaskDetailState():
return $default(_that.now,_that.status,_that.entry,_that.today,_that.canPostponeLaterToday,_that.busy,_that.loadFailure,_that.actionFailure,_that.actionFailureCount,_that.deleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime now,  DetailStatus status,  AgendaEntry? entry,  LocalDate? today,  bool canPostponeLaterToday,  bool busy,  Failure? loadFailure,  Failure? actionFailure,  int actionFailureCount,  bool deleted)?  $default,) {final _that = this;
switch (_that) {
case _TaskDetailState() when $default != null:
return $default(_that.now,_that.status,_that.entry,_that.today,_that.canPostponeLaterToday,_that.busy,_that.loadFailure,_that.actionFailure,_that.actionFailureCount,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc


class _TaskDetailState implements TaskDetailState {
  const _TaskDetailState({required this.now, this.status = DetailStatus.loading, this.entry, this.today, this.canPostponeLaterToday = false, this.busy = false, this.loadFailure, this.actionFailure, this.actionFailureCount = 0, this.deleted = false});
  

@override final  DateTime now;
@override@JsonKey() final  DetailStatus status;
@override final  AgendaEntry? entry;
/// Today in the task's zone (for "Today"/"Tomorrow" labels and pickers).
@override final  LocalDate? today;
/// Whether "later today" is still possible for this occurrence.
@override@JsonKey() final  bool canPostponeLaterToday;
@override@JsonKey() final  bool busy;
@override final  Failure? loadFailure;
/// The last failed action; [actionFailureCount] changes with each one.
@override final  Failure? actionFailure;
@override@JsonKey() final  int actionFailureCount;
/// Set once the series was deleted from this screen (the page closes).
@override@JsonKey() final  bool deleted;

/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskDetailStateCopyWith<_TaskDetailState> get copyWith => __$TaskDetailStateCopyWithImpl<_TaskDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskDetailState&&(identical(other.now, now) || other.now == now)&&(identical(other.status, status) || other.status == status)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.today, today) || other.today == today)&&(identical(other.canPostponeLaterToday, canPostponeLaterToday) || other.canPostponeLaterToday == canPostponeLaterToday)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.loadFailure, loadFailure) || other.loadFailure == loadFailure)&&(identical(other.actionFailure, actionFailure) || other.actionFailure == actionFailure)&&(identical(other.actionFailureCount, actionFailureCount) || other.actionFailureCount == actionFailureCount)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode {
    return Object.hash(runtimeType,now,status,entry,today,canPostponeLaterToday,busy,loadFailure,actionFailure,actionFailureCount,deleted);
}

@override
String toString() {
    return 'TaskDetailState(now: $now, status: $status, entry: $entry, today: $today, canPostponeLaterToday: $canPostponeLaterToday, busy: $busy, loadFailure: $loadFailure, actionFailure: $actionFailure, actionFailureCount: $actionFailureCount, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$TaskDetailStateCopyWith<$Res> implements $TaskDetailStateCopyWith<$Res> {
  factory _$TaskDetailStateCopyWith(_TaskDetailState value, $Res Function(_TaskDetailState) _then) = __$TaskDetailStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime now, DetailStatus status, AgendaEntry? entry, LocalDate? today, bool canPostponeLaterToday, bool busy, Failure? loadFailure, Failure? actionFailure, int actionFailureCount, bool deleted
});


@override $FailureCopyWith<$Res>? get loadFailure;@override $FailureCopyWith<$Res>? get actionFailure;

}
/// @nodoc
class __$TaskDetailStateCopyWithImpl<$Res>
    implements _$TaskDetailStateCopyWith<$Res> {
  __$TaskDetailStateCopyWithImpl(this._self, this._then);

  final _TaskDetailState _self;
  final $Res Function(_TaskDetailState) _then;

/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? now = null,Object? status = null,Object? entry = freezed,Object? today = freezed,Object? canPostponeLaterToday = null,Object? busy = null,Object? loadFailure = freezed,Object? actionFailure = freezed,Object? actionFailureCount = null,Object? deleted = null,}) {
  return _then(_TaskDetailState(
now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DetailStatus,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as AgendaEntry?,today: freezed == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate?,canPostponeLaterToday: null == canPostponeLaterToday ? _self.canPostponeLaterToday : canPostponeLaterToday // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,actionFailure: freezed == actionFailure ? _self.actionFailure : actionFailure // ignore: cast_nullable_to_non_nullable
as Failure?,actionFailureCount: null == actionFailureCount ? _self.actionFailureCount : actionFailureCount // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TaskDetailState
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
}/// Create a copy of TaskDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get actionFailure {
    if (_self.actionFailure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.actionFailure!, (value) {
    return _then(_self.copyWith(actionFailure: value));
  });
}
}

// dart format on
