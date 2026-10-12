// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_planner_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyPlannerState {

/// Today in the user's home zone.
 LocalDate get today; LocalDate get selectedDay;/// The loaded range: the selected day, or its Monday–Sunday week.
 LocalDate get rangeStart; LocalDate get rangeEnd; DateTime get now; PlannerLoad get load;/// The selected day's entries in agenda order.
 List<AgendaEntry> get dayEntries; DaySummary get summary;/// Per-day summaries for the loaded range (week strip).
 Map<LocalDate, DaySummary> get rangeSummaries; Failure? get loadFailure;/// The last failed action; [actionFailureCount] changes with each one so
/// the page can show it exactly once.
 Failure? get actionFailure; int get actionFailureCount;/// Occurrences with an action in flight (their controls are disabled).
 Set<String> get busy;
/// Create a copy of DailyPlannerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyPlannerStateCopyWith<DailyPlannerState> get copyWith => _$DailyPlannerStateCopyWithImpl<DailyPlannerState>(this as DailyPlannerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DailyPlannerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyPlannerState&&(identical(other.today, _this.today) || other.today == _this.today)&&(identical(other.selectedDay, _this.selectedDay) || other.selectedDay == _this.selectedDay)&&(identical(other.rangeStart, _this.rangeStart) || other.rangeStart == _this.rangeStart)&&(identical(other.rangeEnd, _this.rangeEnd) || other.rangeEnd == _this.rangeEnd)&&(identical(other.now, _this.now) || other.now == _this.now)&&(identical(other.load, _this.load) || other.load == _this.load)&&const DeepCollectionEquality().equals(other.dayEntries, _this.dayEntries)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&const DeepCollectionEquality().equals(other.rangeSummaries, _this.rangeSummaries)&&(identical(other.loadFailure, _this.loadFailure) || other.loadFailure == _this.loadFailure)&&(identical(other.actionFailure, _this.actionFailure) || other.actionFailure == _this.actionFailure)&&(identical(other.actionFailureCount, _this.actionFailureCount) || other.actionFailureCount == _this.actionFailureCount)&&const DeepCollectionEquality().equals(other.busy, _this.busy));
}


@override
int get hashCode {
  final _this = this as DailyPlannerState;
  return Object.hash(runtimeType,_this.today,_this.selectedDay,_this.rangeStart,_this.rangeEnd,_this.now,_this.load,const DeepCollectionEquality().hash(_this.dayEntries),_this.summary,const DeepCollectionEquality().hash(_this.rangeSummaries),_this.loadFailure,_this.actionFailure,_this.actionFailureCount,const DeepCollectionEquality().hash(_this.busy));
}

@override
String toString() {
  final _this = this as DailyPlannerState;
  return 'DailyPlannerState(today: ${_this.today}, selectedDay: ${_this.selectedDay}, rangeStart: ${_this.rangeStart}, rangeEnd: ${_this.rangeEnd}, now: ${_this.now}, load: ${_this.load}, dayEntries: ${_this.dayEntries}, summary: ${_this.summary}, rangeSummaries: ${_this.rangeSummaries}, loadFailure: ${_this.loadFailure}, actionFailure: ${_this.actionFailure}, actionFailureCount: ${_this.actionFailureCount}, busy: ${_this.busy})';
}


}

/// @nodoc
abstract mixin class $DailyPlannerStateCopyWith<$Res>  {
  factory $DailyPlannerStateCopyWith(DailyPlannerState value, $Res Function(DailyPlannerState) _then) = _$DailyPlannerStateCopyWithImpl;
@useResult
$Res call({
 LocalDate today, LocalDate selectedDay, LocalDate rangeStart, LocalDate rangeEnd, DateTime now, PlannerLoad load, List<AgendaEntry> dayEntries, DaySummary summary, Map<LocalDate, DaySummary> rangeSummaries, Failure? loadFailure, Failure? actionFailure, int actionFailureCount, Set<String> busy
});


$FailureCopyWith<$Res>? get loadFailure;$FailureCopyWith<$Res>? get actionFailure;

}
/// @nodoc
class _$DailyPlannerStateCopyWithImpl<$Res>
    implements $DailyPlannerStateCopyWith<$Res> {
  _$DailyPlannerStateCopyWithImpl(this._self, this._then);

  final DailyPlannerState _self;
  final $Res Function(DailyPlannerState) _then;

/// Create a copy of DailyPlannerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? today = null,Object? selectedDay = null,Object? rangeStart = null,Object? rangeEnd = null,Object? now = null,Object? load = null,Object? dayEntries = null,Object? summary = null,Object? rangeSummaries = null,Object? loadFailure = freezed,Object? actionFailure = freezed,Object? actionFailureCount = null,Object? busy = null,}) {
  return _then(DailyPlannerState(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as LocalDate,rangeStart: null == rangeStart ? _self.rangeStart : rangeStart // ignore: cast_nullable_to_non_nullable
as LocalDate,rangeEnd: null == rangeEnd ? _self.rangeEnd : rangeEnd // ignore: cast_nullable_to_non_nullable
as LocalDate,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,load: null == load ? _self.load : load // ignore: cast_nullable_to_non_nullable
as PlannerLoad,dayEntries: null == dayEntries ? _self.dayEntries : dayEntries // ignore: cast_nullable_to_non_nullable
as List<AgendaEntry>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as DaySummary,rangeSummaries: null == rangeSummaries ? _self.rangeSummaries : rangeSummaries // ignore: cast_nullable_to_non_nullable
as Map<LocalDate, DaySummary>,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,actionFailure: freezed == actionFailure ? _self.actionFailure : actionFailure // ignore: cast_nullable_to_non_nullable
as Failure?,actionFailureCount: null == actionFailureCount ? _self.actionFailureCount : actionFailureCount // ignore: cast_nullable_to_non_nullable
as int,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}
/// Create a copy of DailyPlannerState
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
}/// Create a copy of DailyPlannerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get actionFailure {
    if (_self.actionFailure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.actionFailure!, (value) {
    return _then(_self.copyWith(actionFailure: value));
  });
}
}


/// Adds pattern-matching-related methods to [DailyPlannerState].
extension DailyPlannerStatePatterns on DailyPlannerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyPlannerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyPlannerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyPlannerState value)  $default,){
final _that = this;
switch (_that) {
case _DailyPlannerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyPlannerState value)?  $default,){
final _that = this;
switch (_that) {
case _DailyPlannerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate today,  LocalDate selectedDay,  LocalDate rangeStart,  LocalDate rangeEnd,  DateTime now,  PlannerLoad load,  List<AgendaEntry> dayEntries,  DaySummary summary,  Map<LocalDate, DaySummary> rangeSummaries,  Failure? loadFailure,  Failure? actionFailure,  int actionFailureCount,  Set<String> busy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyPlannerState() when $default != null:
return $default(_that.today,_that.selectedDay,_that.rangeStart,_that.rangeEnd,_that.now,_that.load,_that.dayEntries,_that.summary,_that.rangeSummaries,_that.loadFailure,_that.actionFailure,_that.actionFailureCount,_that.busy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate today,  LocalDate selectedDay,  LocalDate rangeStart,  LocalDate rangeEnd,  DateTime now,  PlannerLoad load,  List<AgendaEntry> dayEntries,  DaySummary summary,  Map<LocalDate, DaySummary> rangeSummaries,  Failure? loadFailure,  Failure? actionFailure,  int actionFailureCount,  Set<String> busy)  $default,) {final _that = this;
switch (_that) {
case _DailyPlannerState():
return $default(_that.today,_that.selectedDay,_that.rangeStart,_that.rangeEnd,_that.now,_that.load,_that.dayEntries,_that.summary,_that.rangeSummaries,_that.loadFailure,_that.actionFailure,_that.actionFailureCount,_that.busy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate today,  LocalDate selectedDay,  LocalDate rangeStart,  LocalDate rangeEnd,  DateTime now,  PlannerLoad load,  List<AgendaEntry> dayEntries,  DaySummary summary,  Map<LocalDate, DaySummary> rangeSummaries,  Failure? loadFailure,  Failure? actionFailure,  int actionFailureCount,  Set<String> busy)?  $default,) {final _that = this;
switch (_that) {
case _DailyPlannerState() when $default != null:
return $default(_that.today,_that.selectedDay,_that.rangeStart,_that.rangeEnd,_that.now,_that.load,_that.dayEntries,_that.summary,_that.rangeSummaries,_that.loadFailure,_that.actionFailure,_that.actionFailureCount,_that.busy);case _:
  return null;

}
}

}

/// @nodoc


class _DailyPlannerState extends DailyPlannerState {
  const _DailyPlannerState({required this.today, required this.selectedDay, required this.rangeStart, required this.rangeEnd, required this.now, this.load = PlannerLoad.loading,  List<AgendaEntry> dayEntries = const <AgendaEntry>[], this.summary = DaySummary.empty,  Map<LocalDate, DaySummary> rangeSummaries = const <LocalDate, DaySummary>{}, this.loadFailure, this.actionFailure, this.actionFailureCount = 0,  Set<String> busy = const <String>{}}): _dayEntries = dayEntries,_rangeSummaries = rangeSummaries,_busy = busy,super._();
  

/// Today in the user's home zone.
@override final  LocalDate today;
@override final  LocalDate selectedDay;
/// The loaded range: the selected day, or its Monday–Sunday week.
@override final  LocalDate rangeStart;
@override final  LocalDate rangeEnd;
@override final  DateTime now;
@override@JsonKey() final  PlannerLoad load;
/// The selected day's entries in agenda order.
 final  List<AgendaEntry> _dayEntries;
/// The selected day's entries in agenda order.
@override@JsonKey() List<AgendaEntry> get dayEntries {
  if (_dayEntries is EqualUnmodifiableListView) return _dayEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dayEntries);
}

@override@JsonKey() final  DaySummary summary;
/// Per-day summaries for the loaded range (week strip).
 final  Map<LocalDate, DaySummary> _rangeSummaries;
/// Per-day summaries for the loaded range (week strip).
@override@JsonKey() Map<LocalDate, DaySummary> get rangeSummaries {
  if (_rangeSummaries is EqualUnmodifiableMapView) return _rangeSummaries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rangeSummaries);
}

@override final  Failure? loadFailure;
/// The last failed action; [actionFailureCount] changes with each one so
/// the page can show it exactly once.
@override final  Failure? actionFailure;
@override@JsonKey() final  int actionFailureCount;
/// Occurrences with an action in flight (their controls are disabled).
 final  Set<String> _busy;
/// Occurrences with an action in flight (their controls are disabled).
@override@JsonKey() Set<String> get busy {
  if (_busy is EqualUnmodifiableSetView) return _busy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_busy);
}


/// Create a copy of DailyPlannerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyPlannerStateCopyWith<_DailyPlannerState> get copyWith => __$DailyPlannerStateCopyWithImpl<_DailyPlannerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyPlannerState&&(identical(other.today, today) || other.today == today)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&(identical(other.rangeStart, rangeStart) || other.rangeStart == rangeStart)&&(identical(other.rangeEnd, rangeEnd) || other.rangeEnd == rangeEnd)&&(identical(other.now, now) || other.now == now)&&(identical(other.load, load) || other.load == load)&&const DeepCollectionEquality().equals(other.dayEntries, _dayEntries)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.rangeSummaries, _rangeSummaries)&&(identical(other.loadFailure, loadFailure) || other.loadFailure == loadFailure)&&(identical(other.actionFailure, actionFailure) || other.actionFailure == actionFailure)&&(identical(other.actionFailureCount, actionFailureCount) || other.actionFailureCount == actionFailureCount)&&const DeepCollectionEquality().equals(other.busy, _busy));
}


@override
int get hashCode {
    return Object.hash(runtimeType,today,selectedDay,rangeStart,rangeEnd,now,load,const DeepCollectionEquality().hash(_dayEntries),summary,const DeepCollectionEquality().hash(_rangeSummaries),loadFailure,actionFailure,actionFailureCount,const DeepCollectionEquality().hash(_busy));
}

@override
String toString() {
    return 'DailyPlannerState(today: $today, selectedDay: $selectedDay, rangeStart: $rangeStart, rangeEnd: $rangeEnd, now: $now, load: $load, dayEntries: $dayEntries, summary: $summary, rangeSummaries: $rangeSummaries, loadFailure: $loadFailure, actionFailure: $actionFailure, actionFailureCount: $actionFailureCount, busy: $busy)';
}


}

/// @nodoc
abstract mixin class _$DailyPlannerStateCopyWith<$Res> implements $DailyPlannerStateCopyWith<$Res> {
  factory _$DailyPlannerStateCopyWith(_DailyPlannerState value, $Res Function(_DailyPlannerState) _then) = __$DailyPlannerStateCopyWithImpl;
@override @useResult
$Res call({
 LocalDate today, LocalDate selectedDay, LocalDate rangeStart, LocalDate rangeEnd, DateTime now, PlannerLoad load, List<AgendaEntry> dayEntries, DaySummary summary, Map<LocalDate, DaySummary> rangeSummaries, Failure? loadFailure, Failure? actionFailure, int actionFailureCount, Set<String> busy
});


@override $FailureCopyWith<$Res>? get loadFailure;@override $FailureCopyWith<$Res>? get actionFailure;

}
/// @nodoc
class __$DailyPlannerStateCopyWithImpl<$Res>
    implements _$DailyPlannerStateCopyWith<$Res> {
  __$DailyPlannerStateCopyWithImpl(this._self, this._then);

  final _DailyPlannerState _self;
  final $Res Function(_DailyPlannerState) _then;

/// Create a copy of DailyPlannerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? today = null,Object? selectedDay = null,Object? rangeStart = null,Object? rangeEnd = null,Object? now = null,Object? load = null,Object? dayEntries = null,Object? summary = null,Object? rangeSummaries = null,Object? loadFailure = freezed,Object? actionFailure = freezed,Object? actionFailureCount = null,Object? busy = null,}) {
  return _then(_DailyPlannerState(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as LocalDate,rangeStart: null == rangeStart ? _self.rangeStart : rangeStart // ignore: cast_nullable_to_non_nullable
as LocalDate,rangeEnd: null == rangeEnd ? _self.rangeEnd : rangeEnd // ignore: cast_nullable_to_non_nullable
as LocalDate,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,load: null == load ? _self.load : load // ignore: cast_nullable_to_non_nullable
as PlannerLoad,dayEntries: null == dayEntries ? _self._dayEntries : dayEntries // ignore: cast_nullable_to_non_nullable
as List<AgendaEntry>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as DaySummary,rangeSummaries: null == rangeSummaries ? _self._rangeSummaries : rangeSummaries // ignore: cast_nullable_to_non_nullable
as Map<LocalDate, DaySummary>,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,actionFailure: freezed == actionFailure ? _self.actionFailure : actionFailure // ignore: cast_nullable_to_non_nullable
as Failure?,actionFailureCount: null == actionFailureCount ? _self.actionFailureCount : actionFailureCount // ignore: cast_nullable_to_non_nullable
as int,busy: null == busy ? _self._busy : busy // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

/// Create a copy of DailyPlannerState
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
}/// Create a copy of DailyPlannerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get actionFailure {
    if (_self.actionFailure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.actionFailure!, (value) {
    return _then(_self.copyWith(actionFailure: value));
  });
}
}

// dart format on
