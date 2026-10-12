// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'execution_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExecutionRecord {

 String get occurrenceId;/// Follows one activity across "change from this date" splits.
 String get lineageId;/// The series this occurrence belongs to.
 String get taskId; String get title;/// The series' zone: "today" and "missed" are judged in it.
 String get timeZone;/// The date it is (or was last) planned for. A postponed occurrence
/// counts on its new date.
 LocalDate get date;/// Expected duration, copied onto the occurrence when it was created.
 Duration get planned;/// The series' expected duration now (may have changed since).
 Duration get seriesPlanned; OccurrenceStatus get status;/// Time in finished work sessions.
 Duration get closedSessionTime;/// Start of the running work session, if one is running.
 DateTime? get openSessionStart; Category? get category;/// UTC; null for an any-time task.
 DateTime? get scheduledStart;/// When work first started.
 DateTime? get actualStart;/// Null means not measured (done without a timer), which is not zero.
 Duration? get actualDuration;/// When it became completed, skipped or cancelled.
 DateTime? get resolvedAt; int get postponeCount;
/// Create a copy of ExecutionRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExecutionRecordCopyWith<ExecutionRecord> get copyWith => _$ExecutionRecordCopyWithImpl<ExecutionRecord>(this as ExecutionRecord, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExecutionRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExecutionRecord&&(identical(other.occurrenceId, _this.occurrenceId) || other.occurrenceId == _this.occurrenceId)&&(identical(other.lineageId, _this.lineageId) || other.lineageId == _this.lineageId)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.timeZone, _this.timeZone) || other.timeZone == _this.timeZone)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.planned, _this.planned) || other.planned == _this.planned)&&(identical(other.seriesPlanned, _this.seriesPlanned) || other.seriesPlanned == _this.seriesPlanned)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.closedSessionTime, _this.closedSessionTime) || other.closedSessionTime == _this.closedSessionTime)&&(identical(other.openSessionStart, _this.openSessionStart) || other.openSessionStart == _this.openSessionStart)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.scheduledStart, _this.scheduledStart) || other.scheduledStart == _this.scheduledStart)&&(identical(other.actualStart, _this.actualStart) || other.actualStart == _this.actualStart)&&(identical(other.actualDuration, _this.actualDuration) || other.actualDuration == _this.actualDuration)&&(identical(other.resolvedAt, _this.resolvedAt) || other.resolvedAt == _this.resolvedAt)&&(identical(other.postponeCount, _this.postponeCount) || other.postponeCount == _this.postponeCount));
}


@override
int get hashCode {
  final _this = this as ExecutionRecord;
  return Object.hash(runtimeType,_this.occurrenceId,_this.lineageId,_this.taskId,_this.title,_this.timeZone,_this.date,_this.planned,_this.seriesPlanned,_this.status,_this.closedSessionTime,_this.openSessionStart,_this.category,_this.scheduledStart,_this.actualStart,_this.actualDuration,_this.resolvedAt,_this.postponeCount);
}

@override
String toString() {
  final _this = this as ExecutionRecord;
  return 'ExecutionRecord(occurrenceId: ${_this.occurrenceId}, lineageId: ${_this.lineageId}, taskId: ${_this.taskId}, title: ${_this.title}, timeZone: ${_this.timeZone}, date: ${_this.date}, planned: ${_this.planned}, seriesPlanned: ${_this.seriesPlanned}, status: ${_this.status}, closedSessionTime: ${_this.closedSessionTime}, openSessionStart: ${_this.openSessionStart}, category: ${_this.category}, scheduledStart: ${_this.scheduledStart}, actualStart: ${_this.actualStart}, actualDuration: ${_this.actualDuration}, resolvedAt: ${_this.resolvedAt}, postponeCount: ${_this.postponeCount})';
}


}

/// @nodoc
abstract mixin class $ExecutionRecordCopyWith<$Res>  {
  factory $ExecutionRecordCopyWith(ExecutionRecord value, $Res Function(ExecutionRecord) _then) = _$ExecutionRecordCopyWithImpl;
@useResult
$Res call({
 String occurrenceId, String lineageId, String taskId, String title, String timeZone, LocalDate date, Duration planned, Duration seriesPlanned, OccurrenceStatus status, Duration closedSessionTime, DateTime? openSessionStart, Category? category, DateTime? scheduledStart, DateTime? actualStart, Duration? actualDuration, DateTime? resolvedAt, int postponeCount
});


$CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$ExecutionRecordCopyWithImpl<$Res>
    implements $ExecutionRecordCopyWith<$Res> {
  _$ExecutionRecordCopyWithImpl(this._self, this._then);

  final ExecutionRecord _self;
  final $Res Function(ExecutionRecord) _then;

/// Create a copy of ExecutionRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? occurrenceId = null,Object? lineageId = null,Object? taskId = null,Object? title = null,Object? timeZone = null,Object? date = null,Object? planned = null,Object? seriesPlanned = null,Object? status = null,Object? closedSessionTime = null,Object? openSessionStart = freezed,Object? category = freezed,Object? scheduledStart = freezed,Object? actualStart = freezed,Object? actualDuration = freezed,Object? resolvedAt = freezed,Object? postponeCount = null,}) {
  return _then(ExecutionRecord(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,lineageId: null == lineageId ? _self.lineageId : lineageId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,planned: null == planned ? _self.planned : planned // ignore: cast_nullable_to_non_nullable
as Duration,seriesPlanned: null == seriesPlanned ? _self.seriesPlanned : seriesPlanned // ignore: cast_nullable_to_non_nullable
as Duration,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OccurrenceStatus,closedSessionTime: null == closedSessionTime ? _self.closedSessionTime : closedSessionTime // ignore: cast_nullable_to_non_nullable
as Duration,openSessionStart: freezed == openSessionStart ? _self.openSessionStart : openSessionStart // ignore: cast_nullable_to_non_nullable
as DateTime?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,scheduledStart: freezed == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime?,actualStart: freezed == actualStart ? _self.actualStart : actualStart // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDuration: freezed == actualDuration ? _self.actualDuration : actualDuration // ignore: cast_nullable_to_non_nullable
as Duration?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,postponeCount: null == postponeCount ? _self.postponeCount : postponeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ExecutionRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExecutionRecord].
extension ExecutionRecordPatterns on ExecutionRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExecutionRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExecutionRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExecutionRecord value)  $default,){
final _that = this;
switch (_that) {
case _ExecutionRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExecutionRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ExecutionRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String occurrenceId,  String lineageId,  String taskId,  String title,  String timeZone,  LocalDate date,  Duration planned,  Duration seriesPlanned,  OccurrenceStatus status,  Duration closedSessionTime,  DateTime? openSessionStart,  Category? category,  DateTime? scheduledStart,  DateTime? actualStart,  Duration? actualDuration,  DateTime? resolvedAt,  int postponeCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExecutionRecord() when $default != null:
return $default(_that.occurrenceId,_that.lineageId,_that.taskId,_that.title,_that.timeZone,_that.date,_that.planned,_that.seriesPlanned,_that.status,_that.closedSessionTime,_that.openSessionStart,_that.category,_that.scheduledStart,_that.actualStart,_that.actualDuration,_that.resolvedAt,_that.postponeCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String occurrenceId,  String lineageId,  String taskId,  String title,  String timeZone,  LocalDate date,  Duration planned,  Duration seriesPlanned,  OccurrenceStatus status,  Duration closedSessionTime,  DateTime? openSessionStart,  Category? category,  DateTime? scheduledStart,  DateTime? actualStart,  Duration? actualDuration,  DateTime? resolvedAt,  int postponeCount)  $default,) {final _that = this;
switch (_that) {
case _ExecutionRecord():
return $default(_that.occurrenceId,_that.lineageId,_that.taskId,_that.title,_that.timeZone,_that.date,_that.planned,_that.seriesPlanned,_that.status,_that.closedSessionTime,_that.openSessionStart,_that.category,_that.scheduledStart,_that.actualStart,_that.actualDuration,_that.resolvedAt,_that.postponeCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String occurrenceId,  String lineageId,  String taskId,  String title,  String timeZone,  LocalDate date,  Duration planned,  Duration seriesPlanned,  OccurrenceStatus status,  Duration closedSessionTime,  DateTime? openSessionStart,  Category? category,  DateTime? scheduledStart,  DateTime? actualStart,  Duration? actualDuration,  DateTime? resolvedAt,  int postponeCount)?  $default,) {final _that = this;
switch (_that) {
case _ExecutionRecord() when $default != null:
return $default(_that.occurrenceId,_that.lineageId,_that.taskId,_that.title,_that.timeZone,_that.date,_that.planned,_that.seriesPlanned,_that.status,_that.closedSessionTime,_that.openSessionStart,_that.category,_that.scheduledStart,_that.actualStart,_that.actualDuration,_that.resolvedAt,_that.postponeCount);case _:
  return null;

}
}

}

/// @nodoc


class _ExecutionRecord extends ExecutionRecord {
  const _ExecutionRecord({required this.occurrenceId, required this.lineageId, required this.taskId, required this.title, required this.timeZone, required this.date, required this.planned, required this.seriesPlanned, required this.status, this.closedSessionTime = Duration.zero, this.openSessionStart, this.category, this.scheduledStart, this.actualStart, this.actualDuration, this.resolvedAt, this.postponeCount = 0}): super._();
  

@override final  String occurrenceId;
/// Follows one activity across "change from this date" splits.
@override final  String lineageId;
/// The series this occurrence belongs to.
@override final  String taskId;
@override final  String title;
/// The series' zone: "today" and "missed" are judged in it.
@override final  String timeZone;
/// The date it is (or was last) planned for. A postponed occurrence
/// counts on its new date.
@override final  LocalDate date;
/// Expected duration, copied onto the occurrence when it was created.
@override final  Duration planned;
/// The series' expected duration now (may have changed since).
@override final  Duration seriesPlanned;
@override final  OccurrenceStatus status;
/// Time in finished work sessions.
@override@JsonKey() final  Duration closedSessionTime;
/// Start of the running work session, if one is running.
@override final  DateTime? openSessionStart;
@override final  Category? category;
/// UTC; null for an any-time task.
@override final  DateTime? scheduledStart;
/// When work first started.
@override final  DateTime? actualStart;
/// Null means not measured (done without a timer), which is not zero.
@override final  Duration? actualDuration;
/// When it became completed, skipped or cancelled.
@override final  DateTime? resolvedAt;
@override@JsonKey() final  int postponeCount;

/// Create a copy of ExecutionRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExecutionRecordCopyWith<_ExecutionRecord> get copyWith => __$ExecutionRecordCopyWithImpl<_ExecutionRecord>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExecutionRecord&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.lineageId, lineageId) || other.lineageId == lineageId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.date, date) || other.date == date)&&(identical(other.planned, planned) || other.planned == planned)&&(identical(other.seriesPlanned, seriesPlanned) || other.seriesPlanned == seriesPlanned)&&(identical(other.status, status) || other.status == status)&&(identical(other.closedSessionTime, closedSessionTime) || other.closedSessionTime == closedSessionTime)&&(identical(other.openSessionStart, openSessionStart) || other.openSessionStart == openSessionStart)&&(identical(other.category, category) || other.category == category)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.actualStart, actualStart) || other.actualStart == actualStart)&&(identical(other.actualDuration, actualDuration) || other.actualDuration == actualDuration)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.postponeCount, postponeCount) || other.postponeCount == postponeCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,occurrenceId,lineageId,taskId,title,timeZone,date,planned,seriesPlanned,status,closedSessionTime,openSessionStart,category,scheduledStart,actualStart,actualDuration,resolvedAt,postponeCount);
}

@override
String toString() {
    return 'ExecutionRecord(occurrenceId: $occurrenceId, lineageId: $lineageId, taskId: $taskId, title: $title, timeZone: $timeZone, date: $date, planned: $planned, seriesPlanned: $seriesPlanned, status: $status, closedSessionTime: $closedSessionTime, openSessionStart: $openSessionStart, category: $category, scheduledStart: $scheduledStart, actualStart: $actualStart, actualDuration: $actualDuration, resolvedAt: $resolvedAt, postponeCount: $postponeCount)';
}


}

/// @nodoc
abstract mixin class _$ExecutionRecordCopyWith<$Res> implements $ExecutionRecordCopyWith<$Res> {
  factory _$ExecutionRecordCopyWith(_ExecutionRecord value, $Res Function(_ExecutionRecord) _then) = __$ExecutionRecordCopyWithImpl;
@override @useResult
$Res call({
 String occurrenceId, String lineageId, String taskId, String title, String timeZone, LocalDate date, Duration planned, Duration seriesPlanned, OccurrenceStatus status, Duration closedSessionTime, DateTime? openSessionStart, Category? category, DateTime? scheduledStart, DateTime? actualStart, Duration? actualDuration, DateTime? resolvedAt, int postponeCount
});


@override $CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$ExecutionRecordCopyWithImpl<$Res>
    implements _$ExecutionRecordCopyWith<$Res> {
  __$ExecutionRecordCopyWithImpl(this._self, this._then);

  final _ExecutionRecord _self;
  final $Res Function(_ExecutionRecord) _then;

/// Create a copy of ExecutionRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? occurrenceId = null,Object? lineageId = null,Object? taskId = null,Object? title = null,Object? timeZone = null,Object? date = null,Object? planned = null,Object? seriesPlanned = null,Object? status = null,Object? closedSessionTime = null,Object? openSessionStart = freezed,Object? category = freezed,Object? scheduledStart = freezed,Object? actualStart = freezed,Object? actualDuration = freezed,Object? resolvedAt = freezed,Object? postponeCount = null,}) {
  return _then(_ExecutionRecord(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,lineageId: null == lineageId ? _self.lineageId : lineageId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,planned: null == planned ? _self.planned : planned // ignore: cast_nullable_to_non_nullable
as Duration,seriesPlanned: null == seriesPlanned ? _self.seriesPlanned : seriesPlanned // ignore: cast_nullable_to_non_nullable
as Duration,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OccurrenceStatus,closedSessionTime: null == closedSessionTime ? _self.closedSessionTime : closedSessionTime // ignore: cast_nullable_to_non_nullable
as Duration,openSessionStart: freezed == openSessionStart ? _self.openSessionStart : openSessionStart // ignore: cast_nullable_to_non_nullable
as DateTime?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,scheduledStart: freezed == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime?,actualStart: freezed == actualStart ? _self.actualStart : actualStart // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDuration: freezed == actualDuration ? _self.actualDuration : actualDuration // ignore: cast_nullable_to_non_nullable
as Duration?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,postponeCount: null == postponeCount ? _self.postponeCount : postponeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ExecutionRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

// dart format on
