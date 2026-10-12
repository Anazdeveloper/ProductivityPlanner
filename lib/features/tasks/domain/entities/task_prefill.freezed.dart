// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_prefill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskPrefill {

 String? get title; LocalDate? get date;/// Null with [anyTime] false: not said, the editor picks its default.
 LocalTime? get time;/// Explicitly "any time that day".
 bool get anyTime; Duration? get duration; RecurrenceRule? get recurrence; String? get categoryId;/// What the values were made from (the spoken sentence), shown so the
/// person can check them.
 String? get originText;
/// Create a copy of TaskPrefill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskPrefillCopyWith<TaskPrefill> get copyWith => _$TaskPrefillCopyWithImpl<TaskPrefill>(this as TaskPrefill, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskPrefill;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskPrefill&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.anyTime, _this.anyTime) || other.anyTime == _this.anyTime)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.recurrence, _this.recurrence) || other.recurrence == _this.recurrence)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.originText, _this.originText) || other.originText == _this.originText));
}


@override
int get hashCode {
  final _this = this as TaskPrefill;
  return Object.hash(runtimeType,_this.title,_this.date,_this.time,_this.anyTime,_this.duration,_this.recurrence,_this.categoryId,_this.originText);
}

@override
String toString() {
  final _this = this as TaskPrefill;
  return 'TaskPrefill(title: ${_this.title}, date: ${_this.date}, time: ${_this.time}, anyTime: ${_this.anyTime}, duration: ${_this.duration}, recurrence: ${_this.recurrence}, categoryId: ${_this.categoryId}, originText: ${_this.originText})';
}


}

/// @nodoc
abstract mixin class $TaskPrefillCopyWith<$Res>  {
  factory $TaskPrefillCopyWith(TaskPrefill value, $Res Function(TaskPrefill) _then) = _$TaskPrefillCopyWithImpl;
@useResult
$Res call({
 String? title, LocalDate? date, LocalTime? time, bool anyTime, Duration? duration, RecurrenceRule? recurrence, String? categoryId, String? originText
});


$RecurrenceRuleCopyWith<$Res>? get recurrence;

}
/// @nodoc
class _$TaskPrefillCopyWithImpl<$Res>
    implements $TaskPrefillCopyWith<$Res> {
  _$TaskPrefillCopyWithImpl(this._self, this._then);

  final TaskPrefill _self;
  final $Res Function(TaskPrefill) _then;

/// Create a copy of TaskPrefill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? date = freezed,Object? time = freezed,Object? anyTime = null,Object? duration = freezed,Object? recurrence = freezed,Object? categoryId = freezed,Object? originText = freezed,}) {
  return _then(TaskPrefill(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as LocalTime?,anyTime: null == anyTime ? _self.anyTime : anyTime // ignore: cast_nullable_to_non_nullable
as bool,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceRule?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,originText: freezed == originText ? _self.originText : originText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TaskPrefill
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrenceRuleCopyWith<$Res>? get recurrence {
    if (_self.recurrence == null) {
    return null;
  }

  return $RecurrenceRuleCopyWith<$Res>(_self.recurrence!, (value) {
    return _then(_self.copyWith(recurrence: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskPrefill].
extension TaskPrefillPatterns on TaskPrefill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskPrefill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskPrefill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskPrefill value)  $default,){
final _that = this;
switch (_that) {
case _TaskPrefill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskPrefill value)?  $default,){
final _that = this;
switch (_that) {
case _TaskPrefill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  LocalDate? date,  LocalTime? time,  bool anyTime,  Duration? duration,  RecurrenceRule? recurrence,  String? categoryId,  String? originText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskPrefill() when $default != null:
return $default(_that.title,_that.date,_that.time,_that.anyTime,_that.duration,_that.recurrence,_that.categoryId,_that.originText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  LocalDate? date,  LocalTime? time,  bool anyTime,  Duration? duration,  RecurrenceRule? recurrence,  String? categoryId,  String? originText)  $default,) {final _that = this;
switch (_that) {
case _TaskPrefill():
return $default(_that.title,_that.date,_that.time,_that.anyTime,_that.duration,_that.recurrence,_that.categoryId,_that.originText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  LocalDate? date,  LocalTime? time,  bool anyTime,  Duration? duration,  RecurrenceRule? recurrence,  String? categoryId,  String? originText)?  $default,) {final _that = this;
switch (_that) {
case _TaskPrefill() when $default != null:
return $default(_that.title,_that.date,_that.time,_that.anyTime,_that.duration,_that.recurrence,_that.categoryId,_that.originText);case _:
  return null;

}
}

}

/// @nodoc


class _TaskPrefill implements TaskPrefill {
  const _TaskPrefill({this.title, this.date, this.time, this.anyTime = false, this.duration, this.recurrence, this.categoryId, this.originText});
  

@override final  String? title;
@override final  LocalDate? date;
/// Null with [anyTime] false: not said, the editor picks its default.
@override final  LocalTime? time;
/// Explicitly "any time that day".
@override@JsonKey() final  bool anyTime;
@override final  Duration? duration;
@override final  RecurrenceRule? recurrence;
@override final  String? categoryId;
/// What the values were made from (the spoken sentence), shown so the
/// person can check them.
@override final  String? originText;

/// Create a copy of TaskPrefill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskPrefillCopyWith<_TaskPrefill> get copyWith => __$TaskPrefillCopyWithImpl<_TaskPrefill>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskPrefill&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.anyTime, anyTime) || other.anyTime == anyTime)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.originText, originText) || other.originText == originText));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,date,time,anyTime,duration,recurrence,categoryId,originText);
}

@override
String toString() {
    return 'TaskPrefill(title: $title, date: $date, time: $time, anyTime: $anyTime, duration: $duration, recurrence: $recurrence, categoryId: $categoryId, originText: $originText)';
}


}

/// @nodoc
abstract mixin class _$TaskPrefillCopyWith<$Res> implements $TaskPrefillCopyWith<$Res> {
  factory _$TaskPrefillCopyWith(_TaskPrefill value, $Res Function(_TaskPrefill) _then) = __$TaskPrefillCopyWithImpl;
@override @useResult
$Res call({
 String? title, LocalDate? date, LocalTime? time, bool anyTime, Duration? duration, RecurrenceRule? recurrence, String? categoryId, String? originText
});


@override $RecurrenceRuleCopyWith<$Res>? get recurrence;

}
/// @nodoc
class __$TaskPrefillCopyWithImpl<$Res>
    implements _$TaskPrefillCopyWith<$Res> {
  __$TaskPrefillCopyWithImpl(this._self, this._then);

  final _TaskPrefill _self;
  final $Res Function(_TaskPrefill) _then;

/// Create a copy of TaskPrefill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? date = freezed,Object? time = freezed,Object? anyTime = null,Object? duration = freezed,Object? recurrence = freezed,Object? categoryId = freezed,Object? originText = freezed,}) {
  return _then(_TaskPrefill(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as LocalTime?,anyTime: null == anyTime ? _self.anyTime : anyTime // ignore: cast_nullable_to_non_nullable
as bool,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceRule?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,originText: freezed == originText ? _self.originText : originText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TaskPrefill
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrenceRuleCopyWith<$Res>? get recurrence {
    if (_self.recurrence == null) {
    return null;
  }

  return $RecurrenceRuleCopyWith<$Res>(_self.recurrence!, (value) {
    return _then(_self.copyWith(recurrence: value));
  });
}
}

// dart format on
