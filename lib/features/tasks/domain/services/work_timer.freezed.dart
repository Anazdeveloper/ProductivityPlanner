// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_timer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimerSnapshot {

 String get occurrenceId;/// A work session is open right now.
 bool get running;/// Time across all sessions, the open one counted up to now.
 Duration get tracked;/// Length of the open session so far (zero when paused).
 Duration get currentSession; Duration get planned;
/// Create a copy of TimerSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerSnapshotCopyWith<TimerSnapshot> get copyWith => _$TimerSnapshotCopyWithImpl<TimerSnapshot>(this as TimerSnapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TimerSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerSnapshot&&(identical(other.occurrenceId, _this.occurrenceId) || other.occurrenceId == _this.occurrenceId)&&(identical(other.running, _this.running) || other.running == _this.running)&&(identical(other.tracked, _this.tracked) || other.tracked == _this.tracked)&&(identical(other.currentSession, _this.currentSession) || other.currentSession == _this.currentSession)&&(identical(other.planned, _this.planned) || other.planned == _this.planned));
}


@override
int get hashCode {
  final _this = this as TimerSnapshot;
  return Object.hash(runtimeType,_this.occurrenceId,_this.running,_this.tracked,_this.currentSession,_this.planned);
}

@override
String toString() {
  final _this = this as TimerSnapshot;
  return 'TimerSnapshot(occurrenceId: ${_this.occurrenceId}, running: ${_this.running}, tracked: ${_this.tracked}, currentSession: ${_this.currentSession}, planned: ${_this.planned})';
}


}

/// @nodoc
abstract mixin class $TimerSnapshotCopyWith<$Res>  {
  factory $TimerSnapshotCopyWith(TimerSnapshot value, $Res Function(TimerSnapshot) _then) = _$TimerSnapshotCopyWithImpl;
@useResult
$Res call({
 String occurrenceId, bool running, Duration tracked, Duration currentSession, Duration planned
});




}
/// @nodoc
class _$TimerSnapshotCopyWithImpl<$Res>
    implements $TimerSnapshotCopyWith<$Res> {
  _$TimerSnapshotCopyWithImpl(this._self, this._then);

  final TimerSnapshot _self;
  final $Res Function(TimerSnapshot) _then;

/// Create a copy of TimerSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? occurrenceId = null,Object? running = null,Object? tracked = null,Object? currentSession = null,Object? planned = null,}) {
  return _then(TimerSnapshot(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,tracked: null == tracked ? _self.tracked : tracked // ignore: cast_nullable_to_non_nullable
as Duration,currentSession: null == currentSession ? _self.currentSession : currentSession // ignore: cast_nullable_to_non_nullable
as Duration,planned: null == planned ? _self.planned : planned // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [TimerSnapshot].
extension TimerSnapshotPatterns on TimerSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _TimerSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _TimerSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String occurrenceId,  bool running,  Duration tracked,  Duration currentSession,  Duration planned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerSnapshot() when $default != null:
return $default(_that.occurrenceId,_that.running,_that.tracked,_that.currentSession,_that.planned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String occurrenceId,  bool running,  Duration tracked,  Duration currentSession,  Duration planned)  $default,) {final _that = this;
switch (_that) {
case _TimerSnapshot():
return $default(_that.occurrenceId,_that.running,_that.tracked,_that.currentSession,_that.planned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String occurrenceId,  bool running,  Duration tracked,  Duration currentSession,  Duration planned)?  $default,) {final _that = this;
switch (_that) {
case _TimerSnapshot() when $default != null:
return $default(_that.occurrenceId,_that.running,_that.tracked,_that.currentSession,_that.planned);case _:
  return null;

}
}

}

/// @nodoc


class _TimerSnapshot extends TimerSnapshot {
  const _TimerSnapshot({required this.occurrenceId, required this.running, required this.tracked, required this.currentSession, required this.planned}): super._();
  

@override final  String occurrenceId;
/// A work session is open right now.
@override final  bool running;
/// Time across all sessions, the open one counted up to now.
@override final  Duration tracked;
/// Length of the open session so far (zero when paused).
@override final  Duration currentSession;
@override final  Duration planned;

/// Create a copy of TimerSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerSnapshotCopyWith<_TimerSnapshot> get copyWith => __$TimerSnapshotCopyWithImpl<_TimerSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerSnapshot&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.running, running) || other.running == running)&&(identical(other.tracked, tracked) || other.tracked == tracked)&&(identical(other.currentSession, currentSession) || other.currentSession == currentSession)&&(identical(other.planned, planned) || other.planned == planned));
}


@override
int get hashCode {
    return Object.hash(runtimeType,occurrenceId,running,tracked,currentSession,planned);
}

@override
String toString() {
    return 'TimerSnapshot(occurrenceId: $occurrenceId, running: $running, tracked: $tracked, currentSession: $currentSession, planned: $planned)';
}


}

/// @nodoc
abstract mixin class _$TimerSnapshotCopyWith<$Res> implements $TimerSnapshotCopyWith<$Res> {
  factory _$TimerSnapshotCopyWith(_TimerSnapshot value, $Res Function(_TimerSnapshot) _then) = __$TimerSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String occurrenceId, bool running, Duration tracked, Duration currentSession, Duration planned
});




}
/// @nodoc
class __$TimerSnapshotCopyWithImpl<$Res>
    implements _$TimerSnapshotCopyWith<$Res> {
  __$TimerSnapshotCopyWithImpl(this._self, this._then);

  final _TimerSnapshot _self;
  final $Res Function(_TimerSnapshot) _then;

/// Create a copy of TimerSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? occurrenceId = null,Object? running = null,Object? tracked = null,Object? currentSession = null,Object? planned = null,}) {
  return _then(_TimerSnapshot(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,tracked: null == tracked ? _self.tracked : tracked // ignore: cast_nullable_to_non_nullable
as Duration,currentSession: null == currentSession ? _self.currentSession : currentSession // ignore: cast_nullable_to_non_nullable
as Duration,planned: null == planned ? _self.planned : planned // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
