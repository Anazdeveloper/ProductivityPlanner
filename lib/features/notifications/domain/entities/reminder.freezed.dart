// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReminderRequest {

/// Platform notification id (31-bit, stable for the same reminder).
 int get id; String get occurrenceId; ReminderKind get kind;/// When to show it (UTC).
 DateTime get fireAt; String get taskTitle;/// The occurrence's start (UTC), shown as a wall time in `timeZone`.
 DateTime get startAt; String get timeZone;
/// Create a copy of ReminderRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderRequestCopyWith<ReminderRequest> get copyWith => _$ReminderRequestCopyWithImpl<ReminderRequest>(this as ReminderRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReminderRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReminderRequest&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.occurrenceId, _this.occurrenceId) || other.occurrenceId == _this.occurrenceId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.fireAt, _this.fireAt) || other.fireAt == _this.fireAt)&&(identical(other.taskTitle, _this.taskTitle) || other.taskTitle == _this.taskTitle)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.timeZone, _this.timeZone) || other.timeZone == _this.timeZone));
}


@override
int get hashCode {
  final _this = this as ReminderRequest;
  return Object.hash(runtimeType,_this.id,_this.occurrenceId,_this.kind,_this.fireAt,_this.taskTitle,_this.startAt,_this.timeZone);
}

@override
String toString() {
  final _this = this as ReminderRequest;
  return 'ReminderRequest(id: ${_this.id}, occurrenceId: ${_this.occurrenceId}, kind: ${_this.kind}, fireAt: ${_this.fireAt}, taskTitle: ${_this.taskTitle}, startAt: ${_this.startAt}, timeZone: ${_this.timeZone})';
}


}

/// @nodoc
abstract mixin class $ReminderRequestCopyWith<$Res>  {
  factory $ReminderRequestCopyWith(ReminderRequest value, $Res Function(ReminderRequest) _then) = _$ReminderRequestCopyWithImpl;
@useResult
$Res call({
 int id, String occurrenceId, ReminderKind kind, DateTime fireAt, String taskTitle, DateTime startAt, String timeZone
});




}
/// @nodoc
class _$ReminderRequestCopyWithImpl<$Res>
    implements $ReminderRequestCopyWith<$Res> {
  _$ReminderRequestCopyWithImpl(this._self, this._then);

  final ReminderRequest _self;
  final $Res Function(ReminderRequest) _then;

/// Create a copy of ReminderRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? occurrenceId = null,Object? kind = null,Object? fireAt = null,Object? taskTitle = null,Object? startAt = null,Object? timeZone = null,}) {
  return _then(ReminderRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReminderKind,fireAt: null == fireAt ? _self.fireAt : fireAt // ignore: cast_nullable_to_non_nullable
as DateTime,taskTitle: null == taskTitle ? _self.taskTitle : taskTitle // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReminderRequest].
extension ReminderRequestPatterns on ReminderRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReminderRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReminderRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReminderRequest value)  $default,){
final _that = this;
switch (_that) {
case _ReminderRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReminderRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ReminderRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String occurrenceId,  ReminderKind kind,  DateTime fireAt,  String taskTitle,  DateTime startAt,  String timeZone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReminderRequest() when $default != null:
return $default(_that.id,_that.occurrenceId,_that.kind,_that.fireAt,_that.taskTitle,_that.startAt,_that.timeZone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String occurrenceId,  ReminderKind kind,  DateTime fireAt,  String taskTitle,  DateTime startAt,  String timeZone)  $default,) {final _that = this;
switch (_that) {
case _ReminderRequest():
return $default(_that.id,_that.occurrenceId,_that.kind,_that.fireAt,_that.taskTitle,_that.startAt,_that.timeZone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String occurrenceId,  ReminderKind kind,  DateTime fireAt,  String taskTitle,  DateTime startAt,  String timeZone)?  $default,) {final _that = this;
switch (_that) {
case _ReminderRequest() when $default != null:
return $default(_that.id,_that.occurrenceId,_that.kind,_that.fireAt,_that.taskTitle,_that.startAt,_that.timeZone);case _:
  return null;

}
}

}

/// @nodoc


class _ReminderRequest extends ReminderRequest {
  const _ReminderRequest({required this.id, required this.occurrenceId, required this.kind, required this.fireAt, required this.taskTitle, required this.startAt, required this.timeZone}): super._();
  

/// Platform notification id (31-bit, stable for the same reminder).
@override final  int id;
@override final  String occurrenceId;
@override final  ReminderKind kind;
/// When to show it (UTC).
@override final  DateTime fireAt;
@override final  String taskTitle;
/// The occurrence's start (UTC), shown as a wall time in `timeZone`.
@override final  DateTime startAt;
@override final  String timeZone;

/// Create a copy of ReminderRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderRequestCopyWith<_ReminderRequest> get copyWith => __$ReminderRequestCopyWithImpl<_ReminderRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReminderRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.fireAt, fireAt) || other.fireAt == fireAt)&&(identical(other.taskTitle, taskTitle) || other.taskTitle == taskTitle)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,occurrenceId,kind,fireAt,taskTitle,startAt,timeZone);
}

@override
String toString() {
    return 'ReminderRequest(id: $id, occurrenceId: $occurrenceId, kind: $kind, fireAt: $fireAt, taskTitle: $taskTitle, startAt: $startAt, timeZone: $timeZone)';
}


}

/// @nodoc
abstract mixin class _$ReminderRequestCopyWith<$Res> implements $ReminderRequestCopyWith<$Res> {
  factory _$ReminderRequestCopyWith(_ReminderRequest value, $Res Function(_ReminderRequest) _then) = __$ReminderRequestCopyWithImpl;
@override @useResult
$Res call({
 int id, String occurrenceId, ReminderKind kind, DateTime fireAt, String taskTitle, DateTime startAt, String timeZone
});




}
/// @nodoc
class __$ReminderRequestCopyWithImpl<$Res>
    implements _$ReminderRequestCopyWith<$Res> {
  __$ReminderRequestCopyWithImpl(this._self, this._then);

  final _ReminderRequest _self;
  final $Res Function(_ReminderRequest) _then;

/// Create a copy of ReminderRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? occurrenceId = null,Object? kind = null,Object? fireAt = null,Object? taskTitle = null,Object? startAt = null,Object? timeZone = null,}) {
  return _then(_ReminderRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReminderKind,fireAt: null == fireAt ? _self.fireAt : fireAt // ignore: cast_nullable_to_non_nullable
as DateTime,taskTitle: null == taskTitle ? _self.taskTitle : taskTitle // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ScheduledReminder {

 int get id; String get occurrenceId; ReminderKind get kind; String get fingerprint;
/// Create a copy of ScheduledReminder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduledReminderCopyWith<ScheduledReminder> get copyWith => _$ScheduledReminderCopyWithImpl<ScheduledReminder>(this as ScheduledReminder, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ScheduledReminder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduledReminder&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.occurrenceId, _this.occurrenceId) || other.occurrenceId == _this.occurrenceId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.fingerprint, _this.fingerprint) || other.fingerprint == _this.fingerprint));
}


@override
int get hashCode {
  final _this = this as ScheduledReminder;
  return Object.hash(runtimeType,_this.id,_this.occurrenceId,_this.kind,_this.fingerprint);
}

@override
String toString() {
  final _this = this as ScheduledReminder;
  return 'ScheduledReminder(id: ${_this.id}, occurrenceId: ${_this.occurrenceId}, kind: ${_this.kind}, fingerprint: ${_this.fingerprint})';
}


}

/// @nodoc
abstract mixin class $ScheduledReminderCopyWith<$Res>  {
  factory $ScheduledReminderCopyWith(ScheduledReminder value, $Res Function(ScheduledReminder) _then) = _$ScheduledReminderCopyWithImpl;
@useResult
$Res call({
 int id, String occurrenceId, ReminderKind kind, String fingerprint
});




}
/// @nodoc
class _$ScheduledReminderCopyWithImpl<$Res>
    implements $ScheduledReminderCopyWith<$Res> {
  _$ScheduledReminderCopyWithImpl(this._self, this._then);

  final ScheduledReminder _self;
  final $Res Function(ScheduledReminder) _then;

/// Create a copy of ScheduledReminder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? occurrenceId = null,Object? kind = null,Object? fingerprint = null,}) {
  return _then(ScheduledReminder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReminderKind,fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduledReminder].
extension ScheduledReminderPatterns on ScheduledReminder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduledReminder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduledReminder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduledReminder value)  $default,){
final _that = this;
switch (_that) {
case _ScheduledReminder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduledReminder value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduledReminder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String occurrenceId,  ReminderKind kind,  String fingerprint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduledReminder() when $default != null:
return $default(_that.id,_that.occurrenceId,_that.kind,_that.fingerprint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String occurrenceId,  ReminderKind kind,  String fingerprint)  $default,) {final _that = this;
switch (_that) {
case _ScheduledReminder():
return $default(_that.id,_that.occurrenceId,_that.kind,_that.fingerprint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String occurrenceId,  ReminderKind kind,  String fingerprint)?  $default,) {final _that = this;
switch (_that) {
case _ScheduledReminder() when $default != null:
return $default(_that.id,_that.occurrenceId,_that.kind,_that.fingerprint);case _:
  return null;

}
}

}

/// @nodoc


class _ScheduledReminder implements ScheduledReminder {
  const _ScheduledReminder({required this.id, required this.occurrenceId, required this.kind, required this.fingerprint});
  

@override final  int id;
@override final  String occurrenceId;
@override final  ReminderKind kind;
@override final  String fingerprint;

/// Create a copy of ScheduledReminder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduledReminderCopyWith<_ScheduledReminder> get copyWith => __$ScheduledReminderCopyWithImpl<_ScheduledReminder>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduledReminder&&(identical(other.id, id) || other.id == id)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.fingerprint, fingerprint) || other.fingerprint == fingerprint));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,occurrenceId,kind,fingerprint);
}

@override
String toString() {
    return 'ScheduledReminder(id: $id, occurrenceId: $occurrenceId, kind: $kind, fingerprint: $fingerprint)';
}


}

/// @nodoc
abstract mixin class _$ScheduledReminderCopyWith<$Res> implements $ScheduledReminderCopyWith<$Res> {
  factory _$ScheduledReminderCopyWith(_ScheduledReminder value, $Res Function(_ScheduledReminder) _then) = __$ScheduledReminderCopyWithImpl;
@override @useResult
$Res call({
 int id, String occurrenceId, ReminderKind kind, String fingerprint
});




}
/// @nodoc
class __$ScheduledReminderCopyWithImpl<$Res>
    implements _$ScheduledReminderCopyWith<$Res> {
  __$ScheduledReminderCopyWithImpl(this._self, this._then);

  final _ScheduledReminder _self;
  final $Res Function(_ScheduledReminder) _then;

/// Create a copy of ScheduledReminder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? occurrenceId = null,Object? kind = null,Object? fingerprint = null,}) {
  return _then(_ScheduledReminder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReminderKind,fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
