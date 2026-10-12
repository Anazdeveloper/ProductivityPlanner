// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecurrenceRule {

 RecurrenceFrequency get frequency; int get interval; List<int> get weekdays; int? get monthDay; LocalDate? get until; int? get count;
/// Create a copy of RecurrenceRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurrenceRuleCopyWith<RecurrenceRule> get copyWith => _$RecurrenceRuleCopyWithImpl<RecurrenceRule>(this as RecurrenceRule, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecurrenceRule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurrenceRule&&(identical(other.frequency, _this.frequency) || other.frequency == _this.frequency)&&(identical(other.interval, _this.interval) || other.interval == _this.interval)&&const DeepCollectionEquality().equals(other.weekdays, _this.weekdays)&&(identical(other.monthDay, _this.monthDay) || other.monthDay == _this.monthDay)&&(identical(other.until, _this.until) || other.until == _this.until)&&(identical(other.count, _this.count) || other.count == _this.count));
}


@override
int get hashCode {
  final _this = this as RecurrenceRule;
  return Object.hash(runtimeType,_this.frequency,_this.interval,const DeepCollectionEquality().hash(_this.weekdays),_this.monthDay,_this.until,_this.count);
}

@override
String toString() {
  final _this = this as RecurrenceRule;
  return 'RecurrenceRule(frequency: ${_this.frequency}, interval: ${_this.interval}, weekdays: ${_this.weekdays}, monthDay: ${_this.monthDay}, until: ${_this.until}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $RecurrenceRuleCopyWith<$Res>  {
  factory $RecurrenceRuleCopyWith(RecurrenceRule value, $Res Function(RecurrenceRule) _then) = _$RecurrenceRuleCopyWithImpl;
@useResult
$Res call({
 RecurrenceFrequency frequency, int interval, List<int> weekdays, int? monthDay, LocalDate? until, int? count
});




}
/// @nodoc
class _$RecurrenceRuleCopyWithImpl<$Res>
    implements $RecurrenceRuleCopyWith<$Res> {
  _$RecurrenceRuleCopyWithImpl(this._self, this._then);

  final RecurrenceRule _self;
  final $Res Function(RecurrenceRule) _then;

/// Create a copy of RecurrenceRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? frequency = null,Object? interval = null,Object? weekdays = null,Object? monthDay = freezed,Object? until = freezed,Object? count = freezed,}) {
  return _then(RecurrenceRule(
frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as RecurrenceFrequency,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,weekdays: null == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as List<int>,monthDay: freezed == monthDay ? _self.monthDay : monthDay // ignore: cast_nullable_to_non_nullable
as int?,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as LocalDate?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurrenceRule].
extension RecurrenceRulePatterns on RecurrenceRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurrenceRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurrenceRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurrenceRule value)  $default,){
final _that = this;
switch (_that) {
case _RecurrenceRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurrenceRule value)?  $default,){
final _that = this;
switch (_that) {
case _RecurrenceRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecurrenceFrequency frequency,  int interval,  List<int> weekdays,  int? monthDay,  LocalDate? until,  int? count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurrenceRule() when $default != null:
return $default(_that.frequency,_that.interval,_that.weekdays,_that.monthDay,_that.until,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecurrenceFrequency frequency,  int interval,  List<int> weekdays,  int? monthDay,  LocalDate? until,  int? count)  $default,) {final _that = this;
switch (_that) {
case _RecurrenceRule():
return $default(_that.frequency,_that.interval,_that.weekdays,_that.monthDay,_that.until,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecurrenceFrequency frequency,  int interval,  List<int> weekdays,  int? monthDay,  LocalDate? until,  int? count)?  $default,) {final _that = this;
switch (_that) {
case _RecurrenceRule() when $default != null:
return $default(_that.frequency,_that.interval,_that.weekdays,_that.monthDay,_that.until,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _RecurrenceRule extends RecurrenceRule {
  const _RecurrenceRule({required this.frequency, this.interval = 1,  List<int> weekdays = const <int>[], this.monthDay, this.until, this.count}): _weekdays = weekdays,super._();
  

@override final  RecurrenceFrequency frequency;
@override@JsonKey() final  int interval;
 final  List<int> _weekdays;
@override@JsonKey() List<int> get weekdays {
  if (_weekdays is EqualUnmodifiableListView) return _weekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weekdays);
}

@override final  int? monthDay;
@override final  LocalDate? until;
@override final  int? count;

/// Create a copy of RecurrenceRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurrenceRuleCopyWith<_RecurrenceRule> get copyWith => __$RecurrenceRuleCopyWithImpl<_RecurrenceRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurrenceRule&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&const DeepCollectionEquality().equals(other.weekdays, _weekdays)&&(identical(other.monthDay, monthDay) || other.monthDay == monthDay)&&(identical(other.until, until) || other.until == until)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,frequency,interval,const DeepCollectionEquality().hash(_weekdays),monthDay,until,count);
}

@override
String toString() {
    return 'RecurrenceRule(frequency: $frequency, interval: $interval, weekdays: $weekdays, monthDay: $monthDay, until: $until, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RecurrenceRuleCopyWith<$Res> implements $RecurrenceRuleCopyWith<$Res> {
  factory _$RecurrenceRuleCopyWith(_RecurrenceRule value, $Res Function(_RecurrenceRule) _then) = __$RecurrenceRuleCopyWithImpl;
@override @useResult
$Res call({
 RecurrenceFrequency frequency, int interval, List<int> weekdays, int? monthDay, LocalDate? until, int? count
});




}
/// @nodoc
class __$RecurrenceRuleCopyWithImpl<$Res>
    implements _$RecurrenceRuleCopyWith<$Res> {
  __$RecurrenceRuleCopyWithImpl(this._self, this._then);

  final _RecurrenceRule _self;
  final $Res Function(_RecurrenceRule) _then;

/// Create a copy of RecurrenceRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? frequency = null,Object? interval = null,Object? weekdays = null,Object? monthDay = freezed,Object? until = freezed,Object? count = freezed,}) {
  return _then(_RecurrenceRule(
frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as RecurrenceFrequency,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,weekdays: null == weekdays ? _self._weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as List<int>,monthDay: freezed == monthDay ? _self.monthDay : monthDay // ignore: cast_nullable_to_non_nullable
as int?,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as LocalDate?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$TaskSchedule {

/// First date of the series (in [timeZone]).
 LocalDate get startDate;/// IANA zone the dates and times are expressed in. Usually the user's
/// home zone; kept per series so travel does not move a 7:00 run.
 String get timeZone;/// Null means "any time that day": no start instant, no reminder.
 LocalTime? get startTime; RecurrenceRule get rule;
/// Create a copy of TaskSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskScheduleCopyWith<TaskSchedule> get copyWith => _$TaskScheduleCopyWithImpl<TaskSchedule>(this as TaskSchedule, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskSchedule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskSchedule&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.timeZone, _this.timeZone) || other.timeZone == _this.timeZone)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.rule, _this.rule) || other.rule == _this.rule));
}


@override
int get hashCode {
  final _this = this as TaskSchedule;
  return Object.hash(runtimeType,_this.startDate,_this.timeZone,_this.startTime,_this.rule);
}

@override
String toString() {
  final _this = this as TaskSchedule;
  return 'TaskSchedule(startDate: ${_this.startDate}, timeZone: ${_this.timeZone}, startTime: ${_this.startTime}, rule: ${_this.rule})';
}


}

/// @nodoc
abstract mixin class $TaskScheduleCopyWith<$Res>  {
  factory $TaskScheduleCopyWith(TaskSchedule value, $Res Function(TaskSchedule) _then) = _$TaskScheduleCopyWithImpl;
@useResult
$Res call({
 LocalDate startDate, String timeZone, LocalTime? startTime, RecurrenceRule rule
});


$RecurrenceRuleCopyWith<$Res> get rule;

}
/// @nodoc
class _$TaskScheduleCopyWithImpl<$Res>
    implements $TaskScheduleCopyWith<$Res> {
  _$TaskScheduleCopyWithImpl(this._self, this._then);

  final TaskSchedule _self;
  final $Res Function(TaskSchedule) _then;

/// Create a copy of TaskSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = null,Object? timeZone = null,Object? startTime = freezed,Object? rule = null,}) {
  return _then(TaskSchedule(
startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as LocalDate,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as LocalTime?,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as RecurrenceRule,
  ));
}
/// Create a copy of TaskSchedule
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrenceRuleCopyWith<$Res> get rule {
  
  return $RecurrenceRuleCopyWith<$Res>(_self.rule, (value) {
    return _then(_self.copyWith(rule: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskSchedule].
extension TaskSchedulePatterns on TaskSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskSchedule value)  $default,){
final _that = this;
switch (_that) {
case _TaskSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _TaskSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate startDate,  String timeZone,  LocalTime? startTime,  RecurrenceRule rule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskSchedule() when $default != null:
return $default(_that.startDate,_that.timeZone,_that.startTime,_that.rule);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate startDate,  String timeZone,  LocalTime? startTime,  RecurrenceRule rule)  $default,) {final _that = this;
switch (_that) {
case _TaskSchedule():
return $default(_that.startDate,_that.timeZone,_that.startTime,_that.rule);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate startDate,  String timeZone,  LocalTime? startTime,  RecurrenceRule rule)?  $default,) {final _that = this;
switch (_that) {
case _TaskSchedule() when $default != null:
return $default(_that.startDate,_that.timeZone,_that.startTime,_that.rule);case _:
  return null;

}
}

}

/// @nodoc


class _TaskSchedule implements TaskSchedule {
  const _TaskSchedule({required this.startDate, required this.timeZone, this.startTime, this.rule = RecurrenceRule.once});
  

/// First date of the series (in [timeZone]).
@override final  LocalDate startDate;
/// IANA zone the dates and times are expressed in. Usually the user's
/// home zone; kept per series so travel does not move a 7:00 run.
@override final  String timeZone;
/// Null means "any time that day": no start instant, no reminder.
@override final  LocalTime? startTime;
@override@JsonKey() final  RecurrenceRule rule;

/// Create a copy of TaskSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskScheduleCopyWith<_TaskSchedule> get copyWith => __$TaskScheduleCopyWithImpl<_TaskSchedule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskSchedule&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.rule, rule) || other.rule == rule));
}


@override
int get hashCode {
    return Object.hash(runtimeType,startDate,timeZone,startTime,rule);
}

@override
String toString() {
    return 'TaskSchedule(startDate: $startDate, timeZone: $timeZone, startTime: $startTime, rule: $rule)';
}


}

/// @nodoc
abstract mixin class _$TaskScheduleCopyWith<$Res> implements $TaskScheduleCopyWith<$Res> {
  factory _$TaskScheduleCopyWith(_TaskSchedule value, $Res Function(_TaskSchedule) _then) = __$TaskScheduleCopyWithImpl;
@override @useResult
$Res call({
 LocalDate startDate, String timeZone, LocalTime? startTime, RecurrenceRule rule
});


@override $RecurrenceRuleCopyWith<$Res> get rule;

}
/// @nodoc
class __$TaskScheduleCopyWithImpl<$Res>
    implements _$TaskScheduleCopyWith<$Res> {
  __$TaskScheduleCopyWithImpl(this._self, this._then);

  final _TaskSchedule _self;
  final $Res Function(_TaskSchedule) _then;

/// Create a copy of TaskSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = null,Object? timeZone = null,Object? startTime = freezed,Object? rule = null,}) {
  return _then(_TaskSchedule(
startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as LocalDate,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as LocalTime?,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as RecurrenceRule,
  ));
}

/// Create a copy of TaskSchedule
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrenceRuleCopyWith<$Res> get rule {
  
  return $RecurrenceRuleCopyWith<$Res>(_self.rule, (value) {
    return _then(_self.copyWith(rule: value));
  });
}
}

// dart format on
