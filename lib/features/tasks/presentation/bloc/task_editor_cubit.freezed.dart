// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_editor_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskEditorState {

 bool get isEdit; LocalDate get today; LocalDate get date; EditorStatus get status; String get title; String get notes;/// Null = any time that day.
 LocalTime? get time; Duration get duration; TaskPriority get priority; String? get categoryId; RecurrenceFrequency get frequency; int get interval; List<int> get weekdays; RepeatEnd get repeatEnd; LocalDate? get until; int get count;/// Null = no reminder.
 Duration? get reminder; String get timeZone; List<Category> get categories;/// `TaskFields` key → `TaskRuleCodes` value.
 Map<String, String> get fieldErrors; Failure? get failure;/// Edit mode: the task being edited and where schedule changes start.
 Task? get original; LocalDate? get editFrom;/// What a prefill was made from (e.g. the spoken sentence).
 String? get originText;
/// Create a copy of TaskEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskEditorStateCopyWith<TaskEditorState> get copyWith => _$TaskEditorStateCopyWithImpl<TaskEditorState>(this as TaskEditorState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskEditorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskEditorState&&(identical(other.isEdit, _this.isEdit) || other.isEdit == _this.isEdit)&&(identical(other.today, _this.today) || other.today == _this.today)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.frequency, _this.frequency) || other.frequency == _this.frequency)&&(identical(other.interval, _this.interval) || other.interval == _this.interval)&&const DeepCollectionEquality().equals(other.weekdays, _this.weekdays)&&(identical(other.repeatEnd, _this.repeatEnd) || other.repeatEnd == _this.repeatEnd)&&(identical(other.until, _this.until) || other.until == _this.until)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.reminder, _this.reminder) || other.reminder == _this.reminder)&&(identical(other.timeZone, _this.timeZone) || other.timeZone == _this.timeZone)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.original, _this.original) || other.original == _this.original)&&(identical(other.editFrom, _this.editFrom) || other.editFrom == _this.editFrom)&&(identical(other.originText, _this.originText) || other.originText == _this.originText));
}


@override
int get hashCode {
  final _this = this as TaskEditorState;
  return Object.hashAll([runtimeType,_this.isEdit,_this.today,_this.date,_this.status,_this.title,_this.notes,_this.time,_this.duration,_this.priority,_this.categoryId,_this.frequency,_this.interval,const DeepCollectionEquality().hash(_this.weekdays),_this.repeatEnd,_this.until,_this.count,_this.reminder,_this.timeZone,const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.fieldErrors),_this.failure,_this.original,_this.editFrom,_this.originText]);
}

@override
String toString() {
  final _this = this as TaskEditorState;
  return 'TaskEditorState(isEdit: ${_this.isEdit}, today: ${_this.today}, date: ${_this.date}, status: ${_this.status}, title: ${_this.title}, notes: ${_this.notes}, time: ${_this.time}, duration: ${_this.duration}, priority: ${_this.priority}, categoryId: ${_this.categoryId}, frequency: ${_this.frequency}, interval: ${_this.interval}, weekdays: ${_this.weekdays}, repeatEnd: ${_this.repeatEnd}, until: ${_this.until}, count: ${_this.count}, reminder: ${_this.reminder}, timeZone: ${_this.timeZone}, categories: ${_this.categories}, fieldErrors: ${_this.fieldErrors}, failure: ${_this.failure}, original: ${_this.original}, editFrom: ${_this.editFrom}, originText: ${_this.originText})';
}


}

/// @nodoc
abstract mixin class $TaskEditorStateCopyWith<$Res>  {
  factory $TaskEditorStateCopyWith(TaskEditorState value, $Res Function(TaskEditorState) _then) = _$TaskEditorStateCopyWithImpl;
@useResult
$Res call({
 bool isEdit, LocalDate today, LocalDate date, EditorStatus status, String title, String notes, LocalTime? time, Duration duration, TaskPriority priority, String? categoryId, RecurrenceFrequency frequency, int interval, List<int> weekdays, RepeatEnd repeatEnd, LocalDate? until, int count, Duration? reminder, String timeZone, List<Category> categories, Map<String, String> fieldErrors, Failure? failure, Task? original, LocalDate? editFrom, String? originText
});


$FailureCopyWith<$Res>? get failure;$TaskCopyWith<$Res>? get original;

}
/// @nodoc
class _$TaskEditorStateCopyWithImpl<$Res>
    implements $TaskEditorStateCopyWith<$Res> {
  _$TaskEditorStateCopyWithImpl(this._self, this._then);

  final TaskEditorState _self;
  final $Res Function(TaskEditorState) _then;

/// Create a copy of TaskEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isEdit = null,Object? today = null,Object? date = null,Object? status = null,Object? title = null,Object? notes = null,Object? time = freezed,Object? duration = null,Object? priority = null,Object? categoryId = freezed,Object? frequency = null,Object? interval = null,Object? weekdays = null,Object? repeatEnd = null,Object? until = freezed,Object? count = null,Object? reminder = freezed,Object? timeZone = null,Object? categories = null,Object? fieldErrors = null,Object? failure = freezed,Object? original = freezed,Object? editFrom = freezed,Object? originText = freezed,}) {
  return _then(TaskEditorState(
isEdit: null == isEdit ? _self.isEdit : isEdit // ignore: cast_nullable_to_non_nullable
as bool,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EditorStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as LocalTime?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as RecurrenceFrequency,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,weekdays: null == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as List<int>,repeatEnd: null == repeatEnd ? _self.repeatEnd : repeatEnd // ignore: cast_nullable_to_non_nullable
as RepeatEnd,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as LocalDate?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,reminder: freezed == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as Duration?,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Task?,editFrom: freezed == editFrom ? _self.editFrom : editFrom // ignore: cast_nullable_to_non_nullable
as LocalDate?,originText: freezed == originText ? _self.originText : originText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TaskEditorState
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
}/// Create a copy of TaskEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $TaskCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskEditorState].
extension TaskEditorStatePatterns on TaskEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskEditorState value)  $default,){
final _that = this;
switch (_that) {
case _TaskEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _TaskEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isEdit,  LocalDate today,  LocalDate date,  EditorStatus status,  String title,  String notes,  LocalTime? time,  Duration duration,  TaskPriority priority,  String? categoryId,  RecurrenceFrequency frequency,  int interval,  List<int> weekdays,  RepeatEnd repeatEnd,  LocalDate? until,  int count,  Duration? reminder,  String timeZone,  List<Category> categories,  Map<String, String> fieldErrors,  Failure? failure,  Task? original,  LocalDate? editFrom,  String? originText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskEditorState() when $default != null:
return $default(_that.isEdit,_that.today,_that.date,_that.status,_that.title,_that.notes,_that.time,_that.duration,_that.priority,_that.categoryId,_that.frequency,_that.interval,_that.weekdays,_that.repeatEnd,_that.until,_that.count,_that.reminder,_that.timeZone,_that.categories,_that.fieldErrors,_that.failure,_that.original,_that.editFrom,_that.originText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isEdit,  LocalDate today,  LocalDate date,  EditorStatus status,  String title,  String notes,  LocalTime? time,  Duration duration,  TaskPriority priority,  String? categoryId,  RecurrenceFrequency frequency,  int interval,  List<int> weekdays,  RepeatEnd repeatEnd,  LocalDate? until,  int count,  Duration? reminder,  String timeZone,  List<Category> categories,  Map<String, String> fieldErrors,  Failure? failure,  Task? original,  LocalDate? editFrom,  String? originText)  $default,) {final _that = this;
switch (_that) {
case _TaskEditorState():
return $default(_that.isEdit,_that.today,_that.date,_that.status,_that.title,_that.notes,_that.time,_that.duration,_that.priority,_that.categoryId,_that.frequency,_that.interval,_that.weekdays,_that.repeatEnd,_that.until,_that.count,_that.reminder,_that.timeZone,_that.categories,_that.fieldErrors,_that.failure,_that.original,_that.editFrom,_that.originText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isEdit,  LocalDate today,  LocalDate date,  EditorStatus status,  String title,  String notes,  LocalTime? time,  Duration duration,  TaskPriority priority,  String? categoryId,  RecurrenceFrequency frequency,  int interval,  List<int> weekdays,  RepeatEnd repeatEnd,  LocalDate? until,  int count,  Duration? reminder,  String timeZone,  List<Category> categories,  Map<String, String> fieldErrors,  Failure? failure,  Task? original,  LocalDate? editFrom,  String? originText)?  $default,) {final _that = this;
switch (_that) {
case _TaskEditorState() when $default != null:
return $default(_that.isEdit,_that.today,_that.date,_that.status,_that.title,_that.notes,_that.time,_that.duration,_that.priority,_that.categoryId,_that.frequency,_that.interval,_that.weekdays,_that.repeatEnd,_that.until,_that.count,_that.reminder,_that.timeZone,_that.categories,_that.fieldErrors,_that.failure,_that.original,_that.editFrom,_that.originText);case _:
  return null;

}
}

}

/// @nodoc


class _TaskEditorState extends TaskEditorState {
  const _TaskEditorState({required this.isEdit, required this.today, required this.date, this.status = EditorStatus.loading, this.title = '', this.notes = '', this.time, this.duration = const Duration(minutes: 30), this.priority = TaskPriority.medium, this.categoryId, this.frequency = RecurrenceFrequency.none, this.interval = 1,  List<int> weekdays = const <int>[], this.repeatEnd = RepeatEnd.never, this.until, this.count = 10, this.reminder = const Duration(minutes: 5), this.timeZone = 'UTC',  List<Category> categories = const <Category>[],  Map<String, String> fieldErrors = const <String, String>{}, this.failure, this.original, this.editFrom, this.originText}): _weekdays = weekdays,_categories = categories,_fieldErrors = fieldErrors,super._();
  

@override final  bool isEdit;
@override final  LocalDate today;
@override final  LocalDate date;
@override@JsonKey() final  EditorStatus status;
@override@JsonKey() final  String title;
@override@JsonKey() final  String notes;
/// Null = any time that day.
@override final  LocalTime? time;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  TaskPriority priority;
@override final  String? categoryId;
@override@JsonKey() final  RecurrenceFrequency frequency;
@override@JsonKey() final  int interval;
 final  List<int> _weekdays;
@override@JsonKey() List<int> get weekdays {
  if (_weekdays is EqualUnmodifiableListView) return _weekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weekdays);
}

@override@JsonKey() final  RepeatEnd repeatEnd;
@override final  LocalDate? until;
@override@JsonKey() final  int count;
/// Null = no reminder.
@override@JsonKey() final  Duration? reminder;
@override@JsonKey() final  String timeZone;
 final  List<Category> _categories;
@override@JsonKey() List<Category> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// `TaskFields` key → `TaskRuleCodes` value.
 final  Map<String, String> _fieldErrors;
/// `TaskFields` key → `TaskRuleCodes` value.
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}

@override final  Failure? failure;
/// Edit mode: the task being edited and where schedule changes start.
@override final  Task? original;
@override final  LocalDate? editFrom;
/// What a prefill was made from (e.g. the spoken sentence).
@override final  String? originText;

/// Create a copy of TaskEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskEditorStateCopyWith<_TaskEditorState> get copyWith => __$TaskEditorStateCopyWithImpl<_TaskEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskEditorState&&(identical(other.isEdit, isEdit) || other.isEdit == isEdit)&&(identical(other.today, today) || other.today == today)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.time, time) || other.time == time)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&const DeepCollectionEquality().equals(other.weekdays, _weekdays)&&(identical(other.repeatEnd, repeatEnd) || other.repeatEnd == repeatEnd)&&(identical(other.until, until) || other.until == until)&&(identical(other.count, count) || other.count == count)&&(identical(other.reminder, reminder) || other.reminder == reminder)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.original, original) || other.original == original)&&(identical(other.editFrom, editFrom) || other.editFrom == editFrom)&&(identical(other.originText, originText) || other.originText == originText));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,isEdit,today,date,status,title,notes,time,duration,priority,categoryId,frequency,interval,const DeepCollectionEquality().hash(_weekdays),repeatEnd,until,count,reminder,timeZone,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_fieldErrors),failure,original,editFrom,originText]);
}

@override
String toString() {
    return 'TaskEditorState(isEdit: $isEdit, today: $today, date: $date, status: $status, title: $title, notes: $notes, time: $time, duration: $duration, priority: $priority, categoryId: $categoryId, frequency: $frequency, interval: $interval, weekdays: $weekdays, repeatEnd: $repeatEnd, until: $until, count: $count, reminder: $reminder, timeZone: $timeZone, categories: $categories, fieldErrors: $fieldErrors, failure: $failure, original: $original, editFrom: $editFrom, originText: $originText)';
}


}

/// @nodoc
abstract mixin class _$TaskEditorStateCopyWith<$Res> implements $TaskEditorStateCopyWith<$Res> {
  factory _$TaskEditorStateCopyWith(_TaskEditorState value, $Res Function(_TaskEditorState) _then) = __$TaskEditorStateCopyWithImpl;
@override @useResult
$Res call({
 bool isEdit, LocalDate today, LocalDate date, EditorStatus status, String title, String notes, LocalTime? time, Duration duration, TaskPriority priority, String? categoryId, RecurrenceFrequency frequency, int interval, List<int> weekdays, RepeatEnd repeatEnd, LocalDate? until, int count, Duration? reminder, String timeZone, List<Category> categories, Map<String, String> fieldErrors, Failure? failure, Task? original, LocalDate? editFrom, String? originText
});


@override $FailureCopyWith<$Res>? get failure;@override $TaskCopyWith<$Res>? get original;

}
/// @nodoc
class __$TaskEditorStateCopyWithImpl<$Res>
    implements _$TaskEditorStateCopyWith<$Res> {
  __$TaskEditorStateCopyWithImpl(this._self, this._then);

  final _TaskEditorState _self;
  final $Res Function(_TaskEditorState) _then;

/// Create a copy of TaskEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isEdit = null,Object? today = null,Object? date = null,Object? status = null,Object? title = null,Object? notes = null,Object? time = freezed,Object? duration = null,Object? priority = null,Object? categoryId = freezed,Object? frequency = null,Object? interval = null,Object? weekdays = null,Object? repeatEnd = null,Object? until = freezed,Object? count = null,Object? reminder = freezed,Object? timeZone = null,Object? categories = null,Object? fieldErrors = null,Object? failure = freezed,Object? original = freezed,Object? editFrom = freezed,Object? originText = freezed,}) {
  return _then(_TaskEditorState(
isEdit: null == isEdit ? _self.isEdit : isEdit // ignore: cast_nullable_to_non_nullable
as bool,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EditorStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as LocalTime?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as RecurrenceFrequency,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,weekdays: null == weekdays ? _self._weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as List<int>,repeatEnd: null == repeatEnd ? _self.repeatEnd : repeatEnd // ignore: cast_nullable_to_non_nullable
as RepeatEnd,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as LocalDate?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,reminder: freezed == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as Duration?,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Task?,editFrom: freezed == editFrom ? _self.editFrom : editFrom // ignore: cast_nullable_to_non_nullable
as LocalDate?,originText: freezed == originText ? _self.originText : originText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TaskEditorState
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
}/// Create a copy of TaskEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $TaskCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
