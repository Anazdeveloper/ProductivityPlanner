// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'focus_timer_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FocusTimerState {

 FocusLoad get load;/// The followed occurrence; null when there is none (nothing in
/// progress, or the occurrence was deleted).
 AgendaItem? get item;/// Null until the occurrence has been started at least once.
 TimerSnapshot? get timer; bool get busy;/// Set when Done needs confirming; `confirmCount` changes with each
/// request so the page opens the dialog once.
 Duration? get confirmTracked;/// The occurrence the open question is about. The answer completes
/// this one even if the followed item changed meanwhile.
 String? get confirmOccurrenceId; int get confirmCount;/// Title of a task that was paused because this one started;
/// `noticeCount` changes with each.
 String? get autoPausedTitle; int get noticeCount; Failure? get loadFailure; Failure? get failure; int get failureCount;
/// Create a copy of FocusTimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FocusTimerStateCopyWith<FocusTimerState> get copyWith => _$FocusTimerStateCopyWithImpl<FocusTimerState>(this as FocusTimerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FocusTimerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FocusTimerState&&(identical(other.load, _this.load) || other.load == _this.load)&&(identical(other.item, _this.item) || other.item == _this.item)&&(identical(other.timer, _this.timer) || other.timer == _this.timer)&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.confirmTracked, _this.confirmTracked) || other.confirmTracked == _this.confirmTracked)&&(identical(other.confirmOccurrenceId, _this.confirmOccurrenceId) || other.confirmOccurrenceId == _this.confirmOccurrenceId)&&(identical(other.confirmCount, _this.confirmCount) || other.confirmCount == _this.confirmCount)&&(identical(other.autoPausedTitle, _this.autoPausedTitle) || other.autoPausedTitle == _this.autoPausedTitle)&&(identical(other.noticeCount, _this.noticeCount) || other.noticeCount == _this.noticeCount)&&(identical(other.loadFailure, _this.loadFailure) || other.loadFailure == _this.loadFailure)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.failureCount, _this.failureCount) || other.failureCount == _this.failureCount));
}


@override
int get hashCode {
  final _this = this as FocusTimerState;
  return Object.hash(runtimeType,_this.load,_this.item,_this.timer,_this.busy,_this.confirmTracked,_this.confirmOccurrenceId,_this.confirmCount,_this.autoPausedTitle,_this.noticeCount,_this.loadFailure,_this.failure,_this.failureCount);
}

@override
String toString() {
  final _this = this as FocusTimerState;
  return 'FocusTimerState(load: ${_this.load}, item: ${_this.item}, timer: ${_this.timer}, busy: ${_this.busy}, confirmTracked: ${_this.confirmTracked}, confirmOccurrenceId: ${_this.confirmOccurrenceId}, confirmCount: ${_this.confirmCount}, autoPausedTitle: ${_this.autoPausedTitle}, noticeCount: ${_this.noticeCount}, loadFailure: ${_this.loadFailure}, failure: ${_this.failure}, failureCount: ${_this.failureCount})';
}


}

/// @nodoc
abstract mixin class $FocusTimerStateCopyWith<$Res>  {
  factory $FocusTimerStateCopyWith(FocusTimerState value, $Res Function(FocusTimerState) _then) = _$FocusTimerStateCopyWithImpl;
@useResult
$Res call({
 FocusLoad load, AgendaItem? item, TimerSnapshot? timer, bool busy, Duration? confirmTracked, String? confirmOccurrenceId, int confirmCount, String? autoPausedTitle, int noticeCount, Failure? loadFailure, Failure? failure, int failureCount
});


$AgendaItemCopyWith<$Res>? get item;$TimerSnapshotCopyWith<$Res>? get timer;$FailureCopyWith<$Res>? get loadFailure;$FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$FocusTimerStateCopyWithImpl<$Res>
    implements $FocusTimerStateCopyWith<$Res> {
  _$FocusTimerStateCopyWithImpl(this._self, this._then);

  final FocusTimerState _self;
  final $Res Function(FocusTimerState) _then;

/// Create a copy of FocusTimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? load = null,Object? item = freezed,Object? timer = freezed,Object? busy = null,Object? confirmTracked = freezed,Object? confirmOccurrenceId = freezed,Object? confirmCount = null,Object? autoPausedTitle = freezed,Object? noticeCount = null,Object? loadFailure = freezed,Object? failure = freezed,Object? failureCount = null,}) {
  return _then(FocusTimerState(
load: null == load ? _self.load : load // ignore: cast_nullable_to_non_nullable
as FocusLoad,item: freezed == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as AgendaItem?,timer: freezed == timer ? _self.timer : timer // ignore: cast_nullable_to_non_nullable
as TimerSnapshot?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,confirmTracked: freezed == confirmTracked ? _self.confirmTracked : confirmTracked // ignore: cast_nullable_to_non_nullable
as Duration?,confirmOccurrenceId: freezed == confirmOccurrenceId ? _self.confirmOccurrenceId : confirmOccurrenceId // ignore: cast_nullable_to_non_nullable
as String?,confirmCount: null == confirmCount ? _self.confirmCount : confirmCount // ignore: cast_nullable_to_non_nullable
as int,autoPausedTitle: freezed == autoPausedTitle ? _self.autoPausedTitle : autoPausedTitle // ignore: cast_nullable_to_non_nullable
as String?,noticeCount: null == noticeCount ? _self.noticeCount : noticeCount // ignore: cast_nullable_to_non_nullable
as int,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of FocusTimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgendaItemCopyWith<$Res>? get item {
    if (_self.item == null) {
    return null;
  }

  return $AgendaItemCopyWith<$Res>(_self.item!, (value) {
    return _then(_self.copyWith(item: value));
  });
}/// Create a copy of FocusTimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimerSnapshotCopyWith<$Res>? get timer {
    if (_self.timer == null) {
    return null;
  }

  return $TimerSnapshotCopyWith<$Res>(_self.timer!, (value) {
    return _then(_self.copyWith(timer: value));
  });
}/// Create a copy of FocusTimerState
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
}/// Create a copy of FocusTimerState
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


/// Adds pattern-matching-related methods to [FocusTimerState].
extension FocusTimerStatePatterns on FocusTimerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FocusTimerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FocusTimerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FocusTimerState value)  $default,){
final _that = this;
switch (_that) {
case _FocusTimerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FocusTimerState value)?  $default,){
final _that = this;
switch (_that) {
case _FocusTimerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FocusLoad load,  AgendaItem? item,  TimerSnapshot? timer,  bool busy,  Duration? confirmTracked,  String? confirmOccurrenceId,  int confirmCount,  String? autoPausedTitle,  int noticeCount,  Failure? loadFailure,  Failure? failure,  int failureCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FocusTimerState() when $default != null:
return $default(_that.load,_that.item,_that.timer,_that.busy,_that.confirmTracked,_that.confirmOccurrenceId,_that.confirmCount,_that.autoPausedTitle,_that.noticeCount,_that.loadFailure,_that.failure,_that.failureCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FocusLoad load,  AgendaItem? item,  TimerSnapshot? timer,  bool busy,  Duration? confirmTracked,  String? confirmOccurrenceId,  int confirmCount,  String? autoPausedTitle,  int noticeCount,  Failure? loadFailure,  Failure? failure,  int failureCount)  $default,) {final _that = this;
switch (_that) {
case _FocusTimerState():
return $default(_that.load,_that.item,_that.timer,_that.busy,_that.confirmTracked,_that.confirmOccurrenceId,_that.confirmCount,_that.autoPausedTitle,_that.noticeCount,_that.loadFailure,_that.failure,_that.failureCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FocusLoad load,  AgendaItem? item,  TimerSnapshot? timer,  bool busy,  Duration? confirmTracked,  String? confirmOccurrenceId,  int confirmCount,  String? autoPausedTitle,  int noticeCount,  Failure? loadFailure,  Failure? failure,  int failureCount)?  $default,) {final _that = this;
switch (_that) {
case _FocusTimerState() when $default != null:
return $default(_that.load,_that.item,_that.timer,_that.busy,_that.confirmTracked,_that.confirmOccurrenceId,_that.confirmCount,_that.autoPausedTitle,_that.noticeCount,_that.loadFailure,_that.failure,_that.failureCount);case _:
  return null;

}
}

}

/// @nodoc


class _FocusTimerState extends FocusTimerState {
  const _FocusTimerState({this.load = FocusLoad.loading, this.item, this.timer, this.busy = false, this.confirmTracked, this.confirmOccurrenceId, this.confirmCount = 0, this.autoPausedTitle, this.noticeCount = 0, this.loadFailure, this.failure, this.failureCount = 0}): super._();
  

@override@JsonKey() final  FocusLoad load;
/// The followed occurrence; null when there is none (nothing in
/// progress, or the occurrence was deleted).
@override final  AgendaItem? item;
/// Null until the occurrence has been started at least once.
@override final  TimerSnapshot? timer;
@override@JsonKey() final  bool busy;
/// Set when Done needs confirming; `confirmCount` changes with each
/// request so the page opens the dialog once.
@override final  Duration? confirmTracked;
/// The occurrence the open question is about. The answer completes
/// this one even if the followed item changed meanwhile.
@override final  String? confirmOccurrenceId;
@override@JsonKey() final  int confirmCount;
/// Title of a task that was paused because this one started;
/// `noticeCount` changes with each.
@override final  String? autoPausedTitle;
@override@JsonKey() final  int noticeCount;
@override final  Failure? loadFailure;
@override final  Failure? failure;
@override@JsonKey() final  int failureCount;

/// Create a copy of FocusTimerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FocusTimerStateCopyWith<_FocusTimerState> get copyWith => __$FocusTimerStateCopyWithImpl<_FocusTimerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FocusTimerState&&(identical(other.load, load) || other.load == load)&&(identical(other.item, item) || other.item == item)&&(identical(other.timer, timer) || other.timer == timer)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.confirmTracked, confirmTracked) || other.confirmTracked == confirmTracked)&&(identical(other.confirmOccurrenceId, confirmOccurrenceId) || other.confirmOccurrenceId == confirmOccurrenceId)&&(identical(other.confirmCount, confirmCount) || other.confirmCount == confirmCount)&&(identical(other.autoPausedTitle, autoPausedTitle) || other.autoPausedTitle == autoPausedTitle)&&(identical(other.noticeCount, noticeCount) || other.noticeCount == noticeCount)&&(identical(other.loadFailure, loadFailure) || other.loadFailure == loadFailure)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.failureCount, failureCount) || other.failureCount == failureCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,load,item,timer,busy,confirmTracked,confirmOccurrenceId,confirmCount,autoPausedTitle,noticeCount,loadFailure,failure,failureCount);
}

@override
String toString() {
    return 'FocusTimerState(load: $load, item: $item, timer: $timer, busy: $busy, confirmTracked: $confirmTracked, confirmOccurrenceId: $confirmOccurrenceId, confirmCount: $confirmCount, autoPausedTitle: $autoPausedTitle, noticeCount: $noticeCount, loadFailure: $loadFailure, failure: $failure, failureCount: $failureCount)';
}


}

/// @nodoc
abstract mixin class _$FocusTimerStateCopyWith<$Res> implements $FocusTimerStateCopyWith<$Res> {
  factory _$FocusTimerStateCopyWith(_FocusTimerState value, $Res Function(_FocusTimerState) _then) = __$FocusTimerStateCopyWithImpl;
@override @useResult
$Res call({
 FocusLoad load, AgendaItem? item, TimerSnapshot? timer, bool busy, Duration? confirmTracked, String? confirmOccurrenceId, int confirmCount, String? autoPausedTitle, int noticeCount, Failure? loadFailure, Failure? failure, int failureCount
});


@override $AgendaItemCopyWith<$Res>? get item;@override $TimerSnapshotCopyWith<$Res>? get timer;@override $FailureCopyWith<$Res>? get loadFailure;@override $FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$FocusTimerStateCopyWithImpl<$Res>
    implements _$FocusTimerStateCopyWith<$Res> {
  __$FocusTimerStateCopyWithImpl(this._self, this._then);

  final _FocusTimerState _self;
  final $Res Function(_FocusTimerState) _then;

/// Create a copy of FocusTimerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? load = null,Object? item = freezed,Object? timer = freezed,Object? busy = null,Object? confirmTracked = freezed,Object? confirmOccurrenceId = freezed,Object? confirmCount = null,Object? autoPausedTitle = freezed,Object? noticeCount = null,Object? loadFailure = freezed,Object? failure = freezed,Object? failureCount = null,}) {
  return _then(_FocusTimerState(
load: null == load ? _self.load : load // ignore: cast_nullable_to_non_nullable
as FocusLoad,item: freezed == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as AgendaItem?,timer: freezed == timer ? _self.timer : timer // ignore: cast_nullable_to_non_nullable
as TimerSnapshot?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,confirmTracked: freezed == confirmTracked ? _self.confirmTracked : confirmTracked // ignore: cast_nullable_to_non_nullable
as Duration?,confirmOccurrenceId: freezed == confirmOccurrenceId ? _self.confirmOccurrenceId : confirmOccurrenceId // ignore: cast_nullable_to_non_nullable
as String?,confirmCount: null == confirmCount ? _self.confirmCount : confirmCount // ignore: cast_nullable_to_non_nullable
as int,autoPausedTitle: freezed == autoPausedTitle ? _self.autoPausedTitle : autoPausedTitle // ignore: cast_nullable_to_non_nullable
as String?,noticeCount: null == noticeCount ? _self.noticeCount : noticeCount // ignore: cast_nullable_to_non_nullable
as int,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,failureCount: null == failureCount ? _self.failureCount : failureCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of FocusTimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgendaItemCopyWith<$Res>? get item {
    if (_self.item == null) {
    return null;
  }

  return $AgendaItemCopyWith<$Res>(_self.item!, (value) {
    return _then(_self.copyWith(item: value));
  });
}/// Create a copy of FocusTimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimerSnapshotCopyWith<$Res>? get timer {
    if (_self.timer == null) {
    return null;
  }

  return $TimerSnapshotCopyWith<$Res>(_self.timer!, (value) {
    return _then(_self.copyWith(timer: value));
  });
}/// Create a copy of FocusTimerState
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
}/// Create a copy of FocusTimerState
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
