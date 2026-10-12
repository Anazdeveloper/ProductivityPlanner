// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Task {

 String get id;/// Same across "change from this date" splits.
 String get lineageId; String get title; Duration get plannedDuration; TaskSchedule get schedule; DateTime get createdAt; DateTime get updatedAt; String? get notes; String? get categoryId; TaskPriority get priority;/// How long before the start to remind. Empty for no reminder; ignored
/// for any-time tasks.
 List<Duration> get reminderOffsets;/// Set when the user ended the series: no occurrences after this date.
 LocalDate? get endedOn;/// Occurrences exist through this date (materialization watermark).
 LocalDate? get materializedThrough;/// Server row version; 0 until the server has acknowledged the series.
 int get version;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Task;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lineageId, _this.lineageId) || other.lineageId == _this.lineageId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.plannedDuration, _this.plannedDuration) || other.plannedDuration == _this.plannedDuration)&&(identical(other.schedule, _this.schedule) || other.schedule == _this.schedule)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&const DeepCollectionEquality().equals(other.reminderOffsets, _this.reminderOffsets)&&(identical(other.endedOn, _this.endedOn) || other.endedOn == _this.endedOn)&&(identical(other.materializedThrough, _this.materializedThrough) || other.materializedThrough == _this.materializedThrough)&&(identical(other.version, _this.version) || other.version == _this.version));
}


@override
int get hashCode {
  final _this = this as Task;
  return Object.hash(runtimeType,_this.id,_this.lineageId,_this.title,_this.plannedDuration,_this.schedule,_this.createdAt,_this.updatedAt,_this.notes,_this.categoryId,_this.priority,const DeepCollectionEquality().hash(_this.reminderOffsets),_this.endedOn,_this.materializedThrough,_this.version);
}

@override
String toString() {
  final _this = this as Task;
  return 'Task(id: ${_this.id}, lineageId: ${_this.lineageId}, title: ${_this.title}, plannedDuration: ${_this.plannedDuration}, schedule: ${_this.schedule}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, notes: ${_this.notes}, categoryId: ${_this.categoryId}, priority: ${_this.priority}, reminderOffsets: ${_this.reminderOffsets}, endedOn: ${_this.endedOn}, materializedThrough: ${_this.materializedThrough}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 String id, String lineageId, String title, Duration plannedDuration, TaskSchedule schedule, DateTime createdAt, DateTime updatedAt, String? notes, String? categoryId, TaskPriority priority, List<Duration> reminderOffsets, LocalDate? endedOn, LocalDate? materializedThrough, int version
});


$TaskScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lineageId = null,Object? title = null,Object? plannedDuration = null,Object? schedule = null,Object? createdAt = null,Object? updatedAt = null,Object? notes = freezed,Object? categoryId = freezed,Object? priority = null,Object? reminderOffsets = null,Object? endedOn = freezed,Object? materializedThrough = freezed,Object? version = null,}) {
  return _then(Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lineageId: null == lineageId ? _self.lineageId : lineageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,plannedDuration: null == plannedDuration ? _self.plannedDuration : plannedDuration // ignore: cast_nullable_to_non_nullable
as Duration,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as TaskSchedule,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,reminderOffsets: null == reminderOffsets ? _self.reminderOffsets : reminderOffsets // ignore: cast_nullable_to_non_nullable
as List<Duration>,endedOn: freezed == endedOn ? _self.endedOn : endedOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,materializedThrough: freezed == materializedThrough ? _self.materializedThrough : materializedThrough // ignore: cast_nullable_to_non_nullable
as LocalDate?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskScheduleCopyWith<$Res> get schedule {
  
  return $TaskScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String lineageId,  String title,  Duration plannedDuration,  TaskSchedule schedule,  DateTime createdAt,  DateTime updatedAt,  String? notes,  String? categoryId,  TaskPriority priority,  List<Duration> reminderOffsets,  LocalDate? endedOn,  LocalDate? materializedThrough,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.lineageId,_that.title,_that.plannedDuration,_that.schedule,_that.createdAt,_that.updatedAt,_that.notes,_that.categoryId,_that.priority,_that.reminderOffsets,_that.endedOn,_that.materializedThrough,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String lineageId,  String title,  Duration plannedDuration,  TaskSchedule schedule,  DateTime createdAt,  DateTime updatedAt,  String? notes,  String? categoryId,  TaskPriority priority,  List<Duration> reminderOffsets,  LocalDate? endedOn,  LocalDate? materializedThrough,  int version)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.lineageId,_that.title,_that.plannedDuration,_that.schedule,_that.createdAt,_that.updatedAt,_that.notes,_that.categoryId,_that.priority,_that.reminderOffsets,_that.endedOn,_that.materializedThrough,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String lineageId,  String title,  Duration plannedDuration,  TaskSchedule schedule,  DateTime createdAt,  DateTime updatedAt,  String? notes,  String? categoryId,  TaskPriority priority,  List<Duration> reminderOffsets,  LocalDate? endedOn,  LocalDate? materializedThrough,  int version)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.lineageId,_that.title,_that.plannedDuration,_that.schedule,_that.createdAt,_that.updatedAt,_that.notes,_that.categoryId,_that.priority,_that.reminderOffsets,_that.endedOn,_that.materializedThrough,_that.version);case _:
  return null;

}
}

}

/// @nodoc


class _Task extends Task {
  const _Task({required this.id, required this.lineageId, required this.title, required this.plannedDuration, required this.schedule, required this.createdAt, required this.updatedAt, this.notes, this.categoryId, this.priority = TaskPriority.medium,  List<Duration> reminderOffsets = const <Duration>[], this.endedOn, this.materializedThrough, this.version = 0}): _reminderOffsets = reminderOffsets,super._();
  

@override final  String id;
/// Same across "change from this date" splits.
@override final  String lineageId;
@override final  String title;
@override final  Duration plannedDuration;
@override final  TaskSchedule schedule;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? notes;
@override final  String? categoryId;
@override@JsonKey() final  TaskPriority priority;
/// How long before the start to remind. Empty for no reminder; ignored
/// for any-time tasks.
 final  List<Duration> _reminderOffsets;
/// How long before the start to remind. Empty for no reminder; ignored
/// for any-time tasks.
@override@JsonKey() List<Duration> get reminderOffsets {
  if (_reminderOffsets is EqualUnmodifiableListView) return _reminderOffsets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminderOffsets);
}

/// Set when the user ended the series: no occurrences after this date.
@override final  LocalDate? endedOn;
/// Occurrences exist through this date (materialization watermark).
@override final  LocalDate? materializedThrough;
/// Server row version; 0 until the server has acknowledged the series.
@override@JsonKey() final  int version;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.lineageId, lineageId) || other.lineageId == lineageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.plannedDuration, plannedDuration) || other.plannedDuration == plannedDuration)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.priority, priority) || other.priority == priority)&&const DeepCollectionEquality().equals(other.reminderOffsets, _reminderOffsets)&&(identical(other.endedOn, endedOn) || other.endedOn == endedOn)&&(identical(other.materializedThrough, materializedThrough) || other.materializedThrough == materializedThrough)&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,lineageId,title,plannedDuration,schedule,createdAt,updatedAt,notes,categoryId,priority,const DeepCollectionEquality().hash(_reminderOffsets),endedOn,materializedThrough,version);
}

@override
String toString() {
    return 'Task(id: $id, lineageId: $lineageId, title: $title, plannedDuration: $plannedDuration, schedule: $schedule, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, categoryId: $categoryId, priority: $priority, reminderOffsets: $reminderOffsets, endedOn: $endedOn, materializedThrough: $materializedThrough, version: $version)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String lineageId, String title, Duration plannedDuration, TaskSchedule schedule, DateTime createdAt, DateTime updatedAt, String? notes, String? categoryId, TaskPriority priority, List<Duration> reminderOffsets, LocalDate? endedOn, LocalDate? materializedThrough, int version
});


@override $TaskScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lineageId = null,Object? title = null,Object? plannedDuration = null,Object? schedule = null,Object? createdAt = null,Object? updatedAt = null,Object? notes = freezed,Object? categoryId = freezed,Object? priority = null,Object? reminderOffsets = null,Object? endedOn = freezed,Object? materializedThrough = freezed,Object? version = null,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lineageId: null == lineageId ? _self.lineageId : lineageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,plannedDuration: null == plannedDuration ? _self.plannedDuration : plannedDuration // ignore: cast_nullable_to_non_nullable
as Duration,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as TaskSchedule,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,reminderOffsets: null == reminderOffsets ? _self._reminderOffsets : reminderOffsets // ignore: cast_nullable_to_non_nullable
as List<Duration>,endedOn: freezed == endedOn ? _self.endedOn : endedOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,materializedThrough: freezed == materializedThrough ? _self.materializedThrough : materializedThrough // ignore: cast_nullable_to_non_nullable
as LocalDate?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskScheduleCopyWith<$Res> get schedule {
  
  return $TaskScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}

// dart format on
