// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_occurrence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskOccurrence {

 String get id; String get seriesId;/// The date the recurrence produced. Never changes.
 LocalDate get originalDate;/// The date it is currently planned for; differs after a postpone.
 LocalDate get scheduledDate;/// Copied from the series when created, so editing the series later
/// does not rewrite history.
 Duration get plannedDuration; DateTime get createdAt; DateTime get updatedAt;/// UTC start; null for an any-time task.
 DateTime? get scheduledStart;/// UTC start the rule produced; kept across postpones.
 DateTime? get originalStart; OccurrenceStatus get status; int get postponeCount;/// When work first started.
 DateTime? get actualStart;/// Time actually spent. Null means not measured (completed without a
/// timer and without an entered duration), which is not the same as 0.
 Duration? get actualDuration;/// When it became completed, skipped or cancelled.
 DateTime? get resolvedAt; SkipReason? get skipReason; String? get note;/// Server row version; 0 until the server knows the occurrence.
 int get version;
/// Create a copy of TaskOccurrence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskOccurrenceCopyWith<TaskOccurrence> get copyWith => _$TaskOccurrenceCopyWithImpl<TaskOccurrence>(this as TaskOccurrence, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskOccurrence;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskOccurrence&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.seriesId, _this.seriesId) || other.seriesId == _this.seriesId)&&(identical(other.originalDate, _this.originalDate) || other.originalDate == _this.originalDate)&&(identical(other.scheduledDate, _this.scheduledDate) || other.scheduledDate == _this.scheduledDate)&&(identical(other.plannedDuration, _this.plannedDuration) || other.plannedDuration == _this.plannedDuration)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.scheduledStart, _this.scheduledStart) || other.scheduledStart == _this.scheduledStart)&&(identical(other.originalStart, _this.originalStart) || other.originalStart == _this.originalStart)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.postponeCount, _this.postponeCount) || other.postponeCount == _this.postponeCount)&&(identical(other.actualStart, _this.actualStart) || other.actualStart == _this.actualStart)&&(identical(other.actualDuration, _this.actualDuration) || other.actualDuration == _this.actualDuration)&&(identical(other.resolvedAt, _this.resolvedAt) || other.resolvedAt == _this.resolvedAt)&&(identical(other.skipReason, _this.skipReason) || other.skipReason == _this.skipReason)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.version, _this.version) || other.version == _this.version));
}


@override
int get hashCode {
  final _this = this as TaskOccurrence;
  return Object.hash(runtimeType,_this.id,_this.seriesId,_this.originalDate,_this.scheduledDate,_this.plannedDuration,_this.createdAt,_this.updatedAt,_this.scheduledStart,_this.originalStart,_this.status,_this.postponeCount,_this.actualStart,_this.actualDuration,_this.resolvedAt,_this.skipReason,_this.note,_this.version);
}

@override
String toString() {
  final _this = this as TaskOccurrence;
  return 'TaskOccurrence(id: ${_this.id}, seriesId: ${_this.seriesId}, originalDate: ${_this.originalDate}, scheduledDate: ${_this.scheduledDate}, plannedDuration: ${_this.plannedDuration}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, scheduledStart: ${_this.scheduledStart}, originalStart: ${_this.originalStart}, status: ${_this.status}, postponeCount: ${_this.postponeCount}, actualStart: ${_this.actualStart}, actualDuration: ${_this.actualDuration}, resolvedAt: ${_this.resolvedAt}, skipReason: ${_this.skipReason}, note: ${_this.note}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $TaskOccurrenceCopyWith<$Res>  {
  factory $TaskOccurrenceCopyWith(TaskOccurrence value, $Res Function(TaskOccurrence) _then) = _$TaskOccurrenceCopyWithImpl;
@useResult
$Res call({
 String id, String seriesId, LocalDate originalDate, LocalDate scheduledDate, Duration plannedDuration, DateTime createdAt, DateTime updatedAt, DateTime? scheduledStart, DateTime? originalStart, OccurrenceStatus status, int postponeCount, DateTime? actualStart, Duration? actualDuration, DateTime? resolvedAt, SkipReason? skipReason, String? note, int version
});




}
/// @nodoc
class _$TaskOccurrenceCopyWithImpl<$Res>
    implements $TaskOccurrenceCopyWith<$Res> {
  _$TaskOccurrenceCopyWithImpl(this._self, this._then);

  final TaskOccurrence _self;
  final $Res Function(TaskOccurrence) _then;

/// Create a copy of TaskOccurrence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? seriesId = null,Object? originalDate = null,Object? scheduledDate = null,Object? plannedDuration = null,Object? createdAt = null,Object? updatedAt = null,Object? scheduledStart = freezed,Object? originalStart = freezed,Object? status = null,Object? postponeCount = null,Object? actualStart = freezed,Object? actualDuration = freezed,Object? resolvedAt = freezed,Object? skipReason = freezed,Object? note = freezed,Object? version = null,}) {
  return _then(TaskOccurrence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,seriesId: null == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as String,originalDate: null == originalDate ? _self.originalDate : originalDate // ignore: cast_nullable_to_non_nullable
as LocalDate,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as LocalDate,plannedDuration: null == plannedDuration ? _self.plannedDuration : plannedDuration // ignore: cast_nullable_to_non_nullable
as Duration,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledStart: freezed == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime?,originalStart: freezed == originalStart ? _self.originalStart : originalStart // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OccurrenceStatus,postponeCount: null == postponeCount ? _self.postponeCount : postponeCount // ignore: cast_nullable_to_non_nullable
as int,actualStart: freezed == actualStart ? _self.actualStart : actualStart // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDuration: freezed == actualDuration ? _self.actualDuration : actualDuration // ignore: cast_nullable_to_non_nullable
as Duration?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,skipReason: freezed == skipReason ? _self.skipReason : skipReason // ignore: cast_nullable_to_non_nullable
as SkipReason?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskOccurrence].
extension TaskOccurrencePatterns on TaskOccurrence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskOccurrence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskOccurrence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskOccurrence value)  $default,){
final _that = this;
switch (_that) {
case _TaskOccurrence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskOccurrence value)?  $default,){
final _that = this;
switch (_that) {
case _TaskOccurrence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String seriesId,  LocalDate originalDate,  LocalDate scheduledDate,  Duration plannedDuration,  DateTime createdAt,  DateTime updatedAt,  DateTime? scheduledStart,  DateTime? originalStart,  OccurrenceStatus status,  int postponeCount,  DateTime? actualStart,  Duration? actualDuration,  DateTime? resolvedAt,  SkipReason? skipReason,  String? note,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskOccurrence() when $default != null:
return $default(_that.id,_that.seriesId,_that.originalDate,_that.scheduledDate,_that.plannedDuration,_that.createdAt,_that.updatedAt,_that.scheduledStart,_that.originalStart,_that.status,_that.postponeCount,_that.actualStart,_that.actualDuration,_that.resolvedAt,_that.skipReason,_that.note,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String seriesId,  LocalDate originalDate,  LocalDate scheduledDate,  Duration plannedDuration,  DateTime createdAt,  DateTime updatedAt,  DateTime? scheduledStart,  DateTime? originalStart,  OccurrenceStatus status,  int postponeCount,  DateTime? actualStart,  Duration? actualDuration,  DateTime? resolvedAt,  SkipReason? skipReason,  String? note,  int version)  $default,) {final _that = this;
switch (_that) {
case _TaskOccurrence():
return $default(_that.id,_that.seriesId,_that.originalDate,_that.scheduledDate,_that.plannedDuration,_that.createdAt,_that.updatedAt,_that.scheduledStart,_that.originalStart,_that.status,_that.postponeCount,_that.actualStart,_that.actualDuration,_that.resolvedAt,_that.skipReason,_that.note,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String seriesId,  LocalDate originalDate,  LocalDate scheduledDate,  Duration plannedDuration,  DateTime createdAt,  DateTime updatedAt,  DateTime? scheduledStart,  DateTime? originalStart,  OccurrenceStatus status,  int postponeCount,  DateTime? actualStart,  Duration? actualDuration,  DateTime? resolvedAt,  SkipReason? skipReason,  String? note,  int version)?  $default,) {final _that = this;
switch (_that) {
case _TaskOccurrence() when $default != null:
return $default(_that.id,_that.seriesId,_that.originalDate,_that.scheduledDate,_that.plannedDuration,_that.createdAt,_that.updatedAt,_that.scheduledStart,_that.originalStart,_that.status,_that.postponeCount,_that.actualStart,_that.actualDuration,_that.resolvedAt,_that.skipReason,_that.note,_that.version);case _:
  return null;

}
}

}

/// @nodoc


class _TaskOccurrence extends TaskOccurrence {
  const _TaskOccurrence({required this.id, required this.seriesId, required this.originalDate, required this.scheduledDate, required this.plannedDuration, required this.createdAt, required this.updatedAt, this.scheduledStart, this.originalStart, this.status = OccurrenceStatus.scheduled, this.postponeCount = 0, this.actualStart, this.actualDuration, this.resolvedAt, this.skipReason, this.note, this.version = 0}): super._();
  

@override final  String id;
@override final  String seriesId;
/// The date the recurrence produced. Never changes.
@override final  LocalDate originalDate;
/// The date it is currently planned for; differs after a postpone.
@override final  LocalDate scheduledDate;
/// Copied from the series when created, so editing the series later
/// does not rewrite history.
@override final  Duration plannedDuration;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
/// UTC start; null for an any-time task.
@override final  DateTime? scheduledStart;
/// UTC start the rule produced; kept across postpones.
@override final  DateTime? originalStart;
@override@JsonKey() final  OccurrenceStatus status;
@override@JsonKey() final  int postponeCount;
/// When work first started.
@override final  DateTime? actualStart;
/// Time actually spent. Null means not measured (completed without a
/// timer and without an entered duration), which is not the same as 0.
@override final  Duration? actualDuration;
/// When it became completed, skipped or cancelled.
@override final  DateTime? resolvedAt;
@override final  SkipReason? skipReason;
@override final  String? note;
/// Server row version; 0 until the server knows the occurrence.
@override@JsonKey() final  int version;

/// Create a copy of TaskOccurrence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskOccurrenceCopyWith<_TaskOccurrence> get copyWith => __$TaskOccurrenceCopyWithImpl<_TaskOccurrence>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskOccurrence&&(identical(other.id, id) || other.id == id)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.originalDate, originalDate) || other.originalDate == originalDate)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.plannedDuration, plannedDuration) || other.plannedDuration == plannedDuration)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.originalStart, originalStart) || other.originalStart == originalStart)&&(identical(other.status, status) || other.status == status)&&(identical(other.postponeCount, postponeCount) || other.postponeCount == postponeCount)&&(identical(other.actualStart, actualStart) || other.actualStart == actualStart)&&(identical(other.actualDuration, actualDuration) || other.actualDuration == actualDuration)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.skipReason, skipReason) || other.skipReason == skipReason)&&(identical(other.note, note) || other.note == note)&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,seriesId,originalDate,scheduledDate,plannedDuration,createdAt,updatedAt,scheduledStart,originalStart,status,postponeCount,actualStart,actualDuration,resolvedAt,skipReason,note,version);
}

@override
String toString() {
    return 'TaskOccurrence(id: $id, seriesId: $seriesId, originalDate: $originalDate, scheduledDate: $scheduledDate, plannedDuration: $plannedDuration, createdAt: $createdAt, updatedAt: $updatedAt, scheduledStart: $scheduledStart, originalStart: $originalStart, status: $status, postponeCount: $postponeCount, actualStart: $actualStart, actualDuration: $actualDuration, resolvedAt: $resolvedAt, skipReason: $skipReason, note: $note, version: $version)';
}


}

/// @nodoc
abstract mixin class _$TaskOccurrenceCopyWith<$Res> implements $TaskOccurrenceCopyWith<$Res> {
  factory _$TaskOccurrenceCopyWith(_TaskOccurrence value, $Res Function(_TaskOccurrence) _then) = __$TaskOccurrenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String seriesId, LocalDate originalDate, LocalDate scheduledDate, Duration plannedDuration, DateTime createdAt, DateTime updatedAt, DateTime? scheduledStart, DateTime? originalStart, OccurrenceStatus status, int postponeCount, DateTime? actualStart, Duration? actualDuration, DateTime? resolvedAt, SkipReason? skipReason, String? note, int version
});




}
/// @nodoc
class __$TaskOccurrenceCopyWithImpl<$Res>
    implements _$TaskOccurrenceCopyWith<$Res> {
  __$TaskOccurrenceCopyWithImpl(this._self, this._then);

  final _TaskOccurrence _self;
  final $Res Function(_TaskOccurrence) _then;

/// Create a copy of TaskOccurrence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? seriesId = null,Object? originalDate = null,Object? scheduledDate = null,Object? plannedDuration = null,Object? createdAt = null,Object? updatedAt = null,Object? scheduledStart = freezed,Object? originalStart = freezed,Object? status = null,Object? postponeCount = null,Object? actualStart = freezed,Object? actualDuration = freezed,Object? resolvedAt = freezed,Object? skipReason = freezed,Object? note = freezed,Object? version = null,}) {
  return _then(_TaskOccurrence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,seriesId: null == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as String,originalDate: null == originalDate ? _self.originalDate : originalDate // ignore: cast_nullable_to_non_nullable
as LocalDate,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as LocalDate,plannedDuration: null == plannedDuration ? _self.plannedDuration : plannedDuration // ignore: cast_nullable_to_non_nullable
as Duration,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledStart: freezed == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime?,originalStart: freezed == originalStart ? _self.originalStart : originalStart // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OccurrenceStatus,postponeCount: null == postponeCount ? _self.postponeCount : postponeCount // ignore: cast_nullable_to_non_nullable
as int,actualStart: freezed == actualStart ? _self.actualStart : actualStart // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDuration: freezed == actualDuration ? _self.actualDuration : actualDuration // ignore: cast_nullable_to_non_nullable
as Duration?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,skipReason: freezed == skipReason ? _self.skipReason : skipReason // ignore: cast_nullable_to_non_nullable
as SkipReason?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
