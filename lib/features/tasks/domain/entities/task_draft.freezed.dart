// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskDetails {

 String get title; Duration get plannedDuration; String? get notes; String? get categoryId; TaskPriority get priority; List<Duration> get reminderOffsets;
/// Create a copy of TaskDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskDetailsCopyWith<TaskDetails> get copyWith => _$TaskDetailsCopyWithImpl<TaskDetails>(this as TaskDetails, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskDetails;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskDetails&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.plannedDuration, _this.plannedDuration) || other.plannedDuration == _this.plannedDuration)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&const DeepCollectionEquality().equals(other.reminderOffsets, _this.reminderOffsets));
}


@override
int get hashCode {
  final _this = this as TaskDetails;
  return Object.hash(runtimeType,_this.title,_this.plannedDuration,_this.notes,_this.categoryId,_this.priority,const DeepCollectionEquality().hash(_this.reminderOffsets));
}

@override
String toString() {
  final _this = this as TaskDetails;
  return 'TaskDetails(title: ${_this.title}, plannedDuration: ${_this.plannedDuration}, notes: ${_this.notes}, categoryId: ${_this.categoryId}, priority: ${_this.priority}, reminderOffsets: ${_this.reminderOffsets})';
}


}

/// @nodoc
abstract mixin class $TaskDetailsCopyWith<$Res>  {
  factory $TaskDetailsCopyWith(TaskDetails value, $Res Function(TaskDetails) _then) = _$TaskDetailsCopyWithImpl;
@useResult
$Res call({
 String title, Duration plannedDuration, String? notes, String? categoryId, TaskPriority priority, List<Duration> reminderOffsets
});




}
/// @nodoc
class _$TaskDetailsCopyWithImpl<$Res>
    implements $TaskDetailsCopyWith<$Res> {
  _$TaskDetailsCopyWithImpl(this._self, this._then);

  final TaskDetails _self;
  final $Res Function(TaskDetails) _then;

/// Create a copy of TaskDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? plannedDuration = null,Object? notes = freezed,Object? categoryId = freezed,Object? priority = null,Object? reminderOffsets = null,}) {
  return _then(TaskDetails(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,plannedDuration: null == plannedDuration ? _self.plannedDuration : plannedDuration // ignore: cast_nullable_to_non_nullable
as Duration,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,reminderOffsets: null == reminderOffsets ? _self.reminderOffsets : reminderOffsets // ignore: cast_nullable_to_non_nullable
as List<Duration>,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskDetails].
extension TaskDetailsPatterns on TaskDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskDetails value)  $default,){
final _that = this;
switch (_that) {
case _TaskDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskDetails value)?  $default,){
final _that = this;
switch (_that) {
case _TaskDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  Duration plannedDuration,  String? notes,  String? categoryId,  TaskPriority priority,  List<Duration> reminderOffsets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskDetails() when $default != null:
return $default(_that.title,_that.plannedDuration,_that.notes,_that.categoryId,_that.priority,_that.reminderOffsets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  Duration plannedDuration,  String? notes,  String? categoryId,  TaskPriority priority,  List<Duration> reminderOffsets)  $default,) {final _that = this;
switch (_that) {
case _TaskDetails():
return $default(_that.title,_that.plannedDuration,_that.notes,_that.categoryId,_that.priority,_that.reminderOffsets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  Duration plannedDuration,  String? notes,  String? categoryId,  TaskPriority priority,  List<Duration> reminderOffsets)?  $default,) {final _that = this;
switch (_that) {
case _TaskDetails() when $default != null:
return $default(_that.title,_that.plannedDuration,_that.notes,_that.categoryId,_that.priority,_that.reminderOffsets);case _:
  return null;

}
}

}

/// @nodoc


class _TaskDetails implements TaskDetails {
  const _TaskDetails({required this.title, required this.plannedDuration, this.notes, this.categoryId, this.priority = TaskPriority.medium,  List<Duration> reminderOffsets = const <Duration>[Duration(minutes: 5)]}): _reminderOffsets = reminderOffsets;
  

@override final  String title;
@override final  Duration plannedDuration;
@override final  String? notes;
@override final  String? categoryId;
@override@JsonKey() final  TaskPriority priority;
 final  List<Duration> _reminderOffsets;
@override@JsonKey() List<Duration> get reminderOffsets {
  if (_reminderOffsets is EqualUnmodifiableListView) return _reminderOffsets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminderOffsets);
}


/// Create a copy of TaskDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskDetailsCopyWith<_TaskDetails> get copyWith => __$TaskDetailsCopyWithImpl<_TaskDetails>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskDetails&&(identical(other.title, title) || other.title == title)&&(identical(other.plannedDuration, plannedDuration) || other.plannedDuration == plannedDuration)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.priority, priority) || other.priority == priority)&&const DeepCollectionEquality().equals(other.reminderOffsets, _reminderOffsets));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,plannedDuration,notes,categoryId,priority,const DeepCollectionEquality().hash(_reminderOffsets));
}

@override
String toString() {
    return 'TaskDetails(title: $title, plannedDuration: $plannedDuration, notes: $notes, categoryId: $categoryId, priority: $priority, reminderOffsets: $reminderOffsets)';
}


}

/// @nodoc
abstract mixin class _$TaskDetailsCopyWith<$Res> implements $TaskDetailsCopyWith<$Res> {
  factory _$TaskDetailsCopyWith(_TaskDetails value, $Res Function(_TaskDetails) _then) = __$TaskDetailsCopyWithImpl;
@override @useResult
$Res call({
 String title, Duration plannedDuration, String? notes, String? categoryId, TaskPriority priority, List<Duration> reminderOffsets
});




}
/// @nodoc
class __$TaskDetailsCopyWithImpl<$Res>
    implements _$TaskDetailsCopyWith<$Res> {
  __$TaskDetailsCopyWithImpl(this._self, this._then);

  final _TaskDetails _self;
  final $Res Function(_TaskDetails) _then;

/// Create a copy of TaskDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? plannedDuration = null,Object? notes = freezed,Object? categoryId = freezed,Object? priority = null,Object? reminderOffsets = null,}) {
  return _then(_TaskDetails(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,plannedDuration: null == plannedDuration ? _self.plannedDuration : plannedDuration // ignore: cast_nullable_to_non_nullable
as Duration,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,reminderOffsets: null == reminderOffsets ? _self._reminderOffsets : reminderOffsets // ignore: cast_nullable_to_non_nullable
as List<Duration>,
  ));
}


}

/// @nodoc
mixin _$TaskDraft {

 TaskDetails get details; TaskSchedule get schedule;
/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskDraftCopyWith<TaskDraft> get copyWith => _$TaskDraftCopyWithImpl<TaskDraft>(this as TaskDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskDraft&&(identical(other.details, _this.details) || other.details == _this.details)&&(identical(other.schedule, _this.schedule) || other.schedule == _this.schedule));
}


@override
int get hashCode {
  final _this = this as TaskDraft;
  return Object.hash(runtimeType,_this.details,_this.schedule);
}

@override
String toString() {
  final _this = this as TaskDraft;
  return 'TaskDraft(details: ${_this.details}, schedule: ${_this.schedule})';
}


}

/// @nodoc
abstract mixin class $TaskDraftCopyWith<$Res>  {
  factory $TaskDraftCopyWith(TaskDraft value, $Res Function(TaskDraft) _then) = _$TaskDraftCopyWithImpl;
@useResult
$Res call({
 TaskDetails details, TaskSchedule schedule
});


$TaskDetailsCopyWith<$Res> get details;$TaskScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class _$TaskDraftCopyWithImpl<$Res>
    implements $TaskDraftCopyWith<$Res> {
  _$TaskDraftCopyWithImpl(this._self, this._then);

  final TaskDraft _self;
  final $Res Function(TaskDraft) _then;

/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? details = null,Object? schedule = null,}) {
  return _then(TaskDraft(
details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as TaskDetails,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as TaskSchedule,
  ));
}
/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskDetailsCopyWith<$Res> get details {
  
  return $TaskDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskScheduleCopyWith<$Res> get schedule {
  
  return $TaskScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskDraft].
extension TaskDraftPatterns on TaskDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskDraft value)  $default,){
final _that = this;
switch (_that) {
case _TaskDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskDraft value)?  $default,){
final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TaskDetails details,  TaskSchedule schedule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
return $default(_that.details,_that.schedule);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TaskDetails details,  TaskSchedule schedule)  $default,) {final _that = this;
switch (_that) {
case _TaskDraft():
return $default(_that.details,_that.schedule);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TaskDetails details,  TaskSchedule schedule)?  $default,) {final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
return $default(_that.details,_that.schedule);case _:
  return null;

}
}

}

/// @nodoc


class _TaskDraft implements TaskDraft {
  const _TaskDraft({required this.details, required this.schedule});
  

@override final  TaskDetails details;
@override final  TaskSchedule schedule;

/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskDraftCopyWith<_TaskDraft> get copyWith => __$TaskDraftCopyWithImpl<_TaskDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskDraft&&(identical(other.details, details) || other.details == details)&&(identical(other.schedule, schedule) || other.schedule == schedule));
}


@override
int get hashCode {
    return Object.hash(runtimeType,details,schedule);
}

@override
String toString() {
    return 'TaskDraft(details: $details, schedule: $schedule)';
}


}

/// @nodoc
abstract mixin class _$TaskDraftCopyWith<$Res> implements $TaskDraftCopyWith<$Res> {
  factory _$TaskDraftCopyWith(_TaskDraft value, $Res Function(_TaskDraft) _then) = __$TaskDraftCopyWithImpl;
@override @useResult
$Res call({
 TaskDetails details, TaskSchedule schedule
});


@override $TaskDetailsCopyWith<$Res> get details;@override $TaskScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class __$TaskDraftCopyWithImpl<$Res>
    implements _$TaskDraftCopyWith<$Res> {
  __$TaskDraftCopyWithImpl(this._self, this._then);

  final _TaskDraft _self;
  final $Res Function(_TaskDraft) _then;

/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? details = null,Object? schedule = null,}) {
  return _then(_TaskDraft(
details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as TaskDetails,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as TaskSchedule,
  ));
}

/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskDetailsCopyWith<$Res> get details {
  
  return $TaskDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}/// Create a copy of TaskDraft
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
