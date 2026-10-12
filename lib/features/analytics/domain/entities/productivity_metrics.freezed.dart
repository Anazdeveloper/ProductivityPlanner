// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'productivity_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PeriodMetrics {

/// Occurrences that count: everything except cancelled.
 int get counted; int get completed; int get skipped; int get missed; int get open;/// Expected time of all counted occurrences.
 Duration get planned;/// Measured time: the actual duration of completed occurrences plus the
/// session time of started, unfinished ones.
 Duration get tracked;/// Completed occurrences with a measured duration, and their planned
/// and actual totals (the estimate accuracy inputs).
 int get measured; Duration get measuredPlanned; Duration get measuredActual;/// Started occurrences that had a start time, and how many of those
/// started within the grace period.
 int get timedStarts; int get onTimeStarts;/// Median of actual − scheduled start over [timedStarts]; negative
/// means early.
 Duration? get medianStartDelay;/// Occurrences moved at least once, and the total number of moves.
 int get postponed; int get postponements;
/// Create a copy of PeriodMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<PeriodMetrics> get copyWith => _$PeriodMetricsCopyWithImpl<PeriodMetrics>(this as PeriodMetrics, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PeriodMetrics;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodMetrics&&(identical(other.counted, _this.counted) || other.counted == _this.counted)&&(identical(other.completed, _this.completed) || other.completed == _this.completed)&&(identical(other.skipped, _this.skipped) || other.skipped == _this.skipped)&&(identical(other.missed, _this.missed) || other.missed == _this.missed)&&(identical(other.open, _this.open) || other.open == _this.open)&&(identical(other.planned, _this.planned) || other.planned == _this.planned)&&(identical(other.tracked, _this.tracked) || other.tracked == _this.tracked)&&(identical(other.measured, _this.measured) || other.measured == _this.measured)&&(identical(other.measuredPlanned, _this.measuredPlanned) || other.measuredPlanned == _this.measuredPlanned)&&(identical(other.measuredActual, _this.measuredActual) || other.measuredActual == _this.measuredActual)&&(identical(other.timedStarts, _this.timedStarts) || other.timedStarts == _this.timedStarts)&&(identical(other.onTimeStarts, _this.onTimeStarts) || other.onTimeStarts == _this.onTimeStarts)&&(identical(other.medianStartDelay, _this.medianStartDelay) || other.medianStartDelay == _this.medianStartDelay)&&(identical(other.postponed, _this.postponed) || other.postponed == _this.postponed)&&(identical(other.postponements, _this.postponements) || other.postponements == _this.postponements));
}


@override
int get hashCode {
  final _this = this as PeriodMetrics;
  return Object.hash(runtimeType,_this.counted,_this.completed,_this.skipped,_this.missed,_this.open,_this.planned,_this.tracked,_this.measured,_this.measuredPlanned,_this.measuredActual,_this.timedStarts,_this.onTimeStarts,_this.medianStartDelay,_this.postponed,_this.postponements);
}

@override
String toString() {
  final _this = this as PeriodMetrics;
  return 'PeriodMetrics(counted: ${_this.counted}, completed: ${_this.completed}, skipped: ${_this.skipped}, missed: ${_this.missed}, open: ${_this.open}, planned: ${_this.planned}, tracked: ${_this.tracked}, measured: ${_this.measured}, measuredPlanned: ${_this.measuredPlanned}, measuredActual: ${_this.measuredActual}, timedStarts: ${_this.timedStarts}, onTimeStarts: ${_this.onTimeStarts}, medianStartDelay: ${_this.medianStartDelay}, postponed: ${_this.postponed}, postponements: ${_this.postponements})';
}


}

/// @nodoc
abstract mixin class $PeriodMetricsCopyWith<$Res>  {
  factory $PeriodMetricsCopyWith(PeriodMetrics value, $Res Function(PeriodMetrics) _then) = _$PeriodMetricsCopyWithImpl;
@useResult
$Res call({
 int counted, int completed, int skipped, int missed, int open, Duration planned, Duration tracked, int measured, Duration measuredPlanned, Duration measuredActual, int timedStarts, int onTimeStarts, Duration? medianStartDelay, int postponed, int postponements
});




}
/// @nodoc
class _$PeriodMetricsCopyWithImpl<$Res>
    implements $PeriodMetricsCopyWith<$Res> {
  _$PeriodMetricsCopyWithImpl(this._self, this._then);

  final PeriodMetrics _self;
  final $Res Function(PeriodMetrics) _then;

/// Create a copy of PeriodMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? counted = null,Object? completed = null,Object? skipped = null,Object? missed = null,Object? open = null,Object? planned = null,Object? tracked = null,Object? measured = null,Object? measuredPlanned = null,Object? measuredActual = null,Object? timedStarts = null,Object? onTimeStarts = null,Object? medianStartDelay = freezed,Object? postponed = null,Object? postponements = null,}) {
  return _then(PeriodMetrics(
counted: null == counted ? _self.counted : counted // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as int,missed: null == missed ? _self.missed : missed // ignore: cast_nullable_to_non_nullable
as int,open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as int,planned: null == planned ? _self.planned : planned // ignore: cast_nullable_to_non_nullable
as Duration,tracked: null == tracked ? _self.tracked : tracked // ignore: cast_nullable_to_non_nullable
as Duration,measured: null == measured ? _self.measured : measured // ignore: cast_nullable_to_non_nullable
as int,measuredPlanned: null == measuredPlanned ? _self.measuredPlanned : measuredPlanned // ignore: cast_nullable_to_non_nullable
as Duration,measuredActual: null == measuredActual ? _self.measuredActual : measuredActual // ignore: cast_nullable_to_non_nullable
as Duration,timedStarts: null == timedStarts ? _self.timedStarts : timedStarts // ignore: cast_nullable_to_non_nullable
as int,onTimeStarts: null == onTimeStarts ? _self.onTimeStarts : onTimeStarts // ignore: cast_nullable_to_non_nullable
as int,medianStartDelay: freezed == medianStartDelay ? _self.medianStartDelay : medianStartDelay // ignore: cast_nullable_to_non_nullable
as Duration?,postponed: null == postponed ? _self.postponed : postponed // ignore: cast_nullable_to_non_nullable
as int,postponements: null == postponements ? _self.postponements : postponements // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PeriodMetrics].
extension PeriodMetricsPatterns on PeriodMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodMetrics value)  $default,){
final _that = this;
switch (_that) {
case _PeriodMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int counted,  int completed,  int skipped,  int missed,  int open,  Duration planned,  Duration tracked,  int measured,  Duration measuredPlanned,  Duration measuredActual,  int timedStarts,  int onTimeStarts,  Duration? medianStartDelay,  int postponed,  int postponements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodMetrics() when $default != null:
return $default(_that.counted,_that.completed,_that.skipped,_that.missed,_that.open,_that.planned,_that.tracked,_that.measured,_that.measuredPlanned,_that.measuredActual,_that.timedStarts,_that.onTimeStarts,_that.medianStartDelay,_that.postponed,_that.postponements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int counted,  int completed,  int skipped,  int missed,  int open,  Duration planned,  Duration tracked,  int measured,  Duration measuredPlanned,  Duration measuredActual,  int timedStarts,  int onTimeStarts,  Duration? medianStartDelay,  int postponed,  int postponements)  $default,) {final _that = this;
switch (_that) {
case _PeriodMetrics():
return $default(_that.counted,_that.completed,_that.skipped,_that.missed,_that.open,_that.planned,_that.tracked,_that.measured,_that.measuredPlanned,_that.measuredActual,_that.timedStarts,_that.onTimeStarts,_that.medianStartDelay,_that.postponed,_that.postponements);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int counted,  int completed,  int skipped,  int missed,  int open,  Duration planned,  Duration tracked,  int measured,  Duration measuredPlanned,  Duration measuredActual,  int timedStarts,  int onTimeStarts,  Duration? medianStartDelay,  int postponed,  int postponements)?  $default,) {final _that = this;
switch (_that) {
case _PeriodMetrics() when $default != null:
return $default(_that.counted,_that.completed,_that.skipped,_that.missed,_that.open,_that.planned,_that.tracked,_that.measured,_that.measuredPlanned,_that.measuredActual,_that.timedStarts,_that.onTimeStarts,_that.medianStartDelay,_that.postponed,_that.postponements);case _:
  return null;

}
}

}

/// @nodoc


class _PeriodMetrics extends PeriodMetrics {
  const _PeriodMetrics({this.counted = 0, this.completed = 0, this.skipped = 0, this.missed = 0, this.open = 0, this.planned = Duration.zero, this.tracked = Duration.zero, this.measured = 0, this.measuredPlanned = Duration.zero, this.measuredActual = Duration.zero, this.timedStarts = 0, this.onTimeStarts = 0, this.medianStartDelay, this.postponed = 0, this.postponements = 0}): super._();
  

/// Occurrences that count: everything except cancelled.
@override@JsonKey() final  int counted;
@override@JsonKey() final  int completed;
@override@JsonKey() final  int skipped;
@override@JsonKey() final  int missed;
@override@JsonKey() final  int open;
/// Expected time of all counted occurrences.
@override@JsonKey() final  Duration planned;
/// Measured time: the actual duration of completed occurrences plus the
/// session time of started, unfinished ones.
@override@JsonKey() final  Duration tracked;
/// Completed occurrences with a measured duration, and their planned
/// and actual totals (the estimate accuracy inputs).
@override@JsonKey() final  int measured;
@override@JsonKey() final  Duration measuredPlanned;
@override@JsonKey() final  Duration measuredActual;
/// Started occurrences that had a start time, and how many of those
/// started within the grace period.
@override@JsonKey() final  int timedStarts;
@override@JsonKey() final  int onTimeStarts;
/// Median of actual − scheduled start over [timedStarts]; negative
/// means early.
@override final  Duration? medianStartDelay;
/// Occurrences moved at least once, and the total number of moves.
@override@JsonKey() final  int postponed;
@override@JsonKey() final  int postponements;

/// Create a copy of PeriodMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodMetricsCopyWith<_PeriodMetrics> get copyWith => __$PeriodMetricsCopyWithImpl<_PeriodMetrics>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodMetrics&&(identical(other.counted, counted) || other.counted == counted)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.skipped, skipped) || other.skipped == skipped)&&(identical(other.missed, missed) || other.missed == missed)&&(identical(other.open, open) || other.open == open)&&(identical(other.planned, planned) || other.planned == planned)&&(identical(other.tracked, tracked) || other.tracked == tracked)&&(identical(other.measured, measured) || other.measured == measured)&&(identical(other.measuredPlanned, measuredPlanned) || other.measuredPlanned == measuredPlanned)&&(identical(other.measuredActual, measuredActual) || other.measuredActual == measuredActual)&&(identical(other.timedStarts, timedStarts) || other.timedStarts == timedStarts)&&(identical(other.onTimeStarts, onTimeStarts) || other.onTimeStarts == onTimeStarts)&&(identical(other.medianStartDelay, medianStartDelay) || other.medianStartDelay == medianStartDelay)&&(identical(other.postponed, postponed) || other.postponed == postponed)&&(identical(other.postponements, postponements) || other.postponements == postponements));
}


@override
int get hashCode {
    return Object.hash(runtimeType,counted,completed,skipped,missed,open,planned,tracked,measured,measuredPlanned,measuredActual,timedStarts,onTimeStarts,medianStartDelay,postponed,postponements);
}

@override
String toString() {
    return 'PeriodMetrics(counted: $counted, completed: $completed, skipped: $skipped, missed: $missed, open: $open, planned: $planned, tracked: $tracked, measured: $measured, measuredPlanned: $measuredPlanned, measuredActual: $measuredActual, timedStarts: $timedStarts, onTimeStarts: $onTimeStarts, medianStartDelay: $medianStartDelay, postponed: $postponed, postponements: $postponements)';
}


}

/// @nodoc
abstract mixin class _$PeriodMetricsCopyWith<$Res> implements $PeriodMetricsCopyWith<$Res> {
  factory _$PeriodMetricsCopyWith(_PeriodMetrics value, $Res Function(_PeriodMetrics) _then) = __$PeriodMetricsCopyWithImpl;
@override @useResult
$Res call({
 int counted, int completed, int skipped, int missed, int open, Duration planned, Duration tracked, int measured, Duration measuredPlanned, Duration measuredActual, int timedStarts, int onTimeStarts, Duration? medianStartDelay, int postponed, int postponements
});




}
/// @nodoc
class __$PeriodMetricsCopyWithImpl<$Res>
    implements _$PeriodMetricsCopyWith<$Res> {
  __$PeriodMetricsCopyWithImpl(this._self, this._then);

  final _PeriodMetrics _self;
  final $Res Function(_PeriodMetrics) _then;

/// Create a copy of PeriodMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? counted = null,Object? completed = null,Object? skipped = null,Object? missed = null,Object? open = null,Object? planned = null,Object? tracked = null,Object? measured = null,Object? measuredPlanned = null,Object? measuredActual = null,Object? timedStarts = null,Object? onTimeStarts = null,Object? medianStartDelay = freezed,Object? postponed = null,Object? postponements = null,}) {
  return _then(_PeriodMetrics(
counted: null == counted ? _self.counted : counted // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as int,missed: null == missed ? _self.missed : missed // ignore: cast_nullable_to_non_nullable
as int,open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as int,planned: null == planned ? _self.planned : planned // ignore: cast_nullable_to_non_nullable
as Duration,tracked: null == tracked ? _self.tracked : tracked // ignore: cast_nullable_to_non_nullable
as Duration,measured: null == measured ? _self.measured : measured // ignore: cast_nullable_to_non_nullable
as int,measuredPlanned: null == measuredPlanned ? _self.measuredPlanned : measuredPlanned // ignore: cast_nullable_to_non_nullable
as Duration,measuredActual: null == measuredActual ? _self.measuredActual : measuredActual // ignore: cast_nullable_to_non_nullable
as Duration,timedStarts: null == timedStarts ? _self.timedStarts : timedStarts // ignore: cast_nullable_to_non_nullable
as int,onTimeStarts: null == onTimeStarts ? _self.onTimeStarts : onTimeStarts // ignore: cast_nullable_to_non_nullable
as int,medianStartDelay: freezed == medianStartDelay ? _self.medianStartDelay : medianStartDelay // ignore: cast_nullable_to_non_nullable
as Duration?,postponed: null == postponed ? _self.postponed : postponed // ignore: cast_nullable_to_non_nullable
as int,postponements: null == postponements ? _self.postponements : postponements // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DayMetrics {

 LocalDate get date; PeriodMetrics get metrics;
/// Create a copy of DayMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayMetricsCopyWith<DayMetrics> get copyWith => _$DayMetricsCopyWithImpl<DayMetrics>(this as DayMetrics, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DayMetrics;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayMetrics&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.metrics, _this.metrics) || other.metrics == _this.metrics));
}


@override
int get hashCode {
  final _this = this as DayMetrics;
  return Object.hash(runtimeType,_this.date,_this.metrics);
}

@override
String toString() {
  final _this = this as DayMetrics;
  return 'DayMetrics(date: ${_this.date}, metrics: ${_this.metrics})';
}


}

/// @nodoc
abstract mixin class $DayMetricsCopyWith<$Res>  {
  factory $DayMetricsCopyWith(DayMetrics value, $Res Function(DayMetrics) _then) = _$DayMetricsCopyWithImpl;
@useResult
$Res call({
 LocalDate date, PeriodMetrics metrics
});


$PeriodMetricsCopyWith<$Res> get metrics;

}
/// @nodoc
class _$DayMetricsCopyWithImpl<$Res>
    implements $DayMetricsCopyWith<$Res> {
  _$DayMetricsCopyWithImpl(this._self, this._then);

  final DayMetrics _self;
  final $Res Function(DayMetrics) _then;

/// Create a copy of DayMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? metrics = null,}) {
  return _then(DayMetrics(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as PeriodMetrics,
  ));
}
/// Create a copy of DayMetrics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<$Res> get metrics {
  
  return $PeriodMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}
}


/// Adds pattern-matching-related methods to [DayMetrics].
extension DayMetricsPatterns on DayMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayMetrics value)  $default,){
final _that = this;
switch (_that) {
case _DayMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _DayMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate date,  PeriodMetrics metrics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayMetrics() when $default != null:
return $default(_that.date,_that.metrics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate date,  PeriodMetrics metrics)  $default,) {final _that = this;
switch (_that) {
case _DayMetrics():
return $default(_that.date,_that.metrics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate date,  PeriodMetrics metrics)?  $default,) {final _that = this;
switch (_that) {
case _DayMetrics() when $default != null:
return $default(_that.date,_that.metrics);case _:
  return null;

}
}

}

/// @nodoc


class _DayMetrics implements DayMetrics {
  const _DayMetrics({required this.date, required this.metrics});
  

@override final  LocalDate date;
@override final  PeriodMetrics metrics;

/// Create a copy of DayMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayMetricsCopyWith<_DayMetrics> get copyWith => __$DayMetricsCopyWithImpl<_DayMetrics>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayMetrics&&(identical(other.date, date) || other.date == date)&&(identical(other.metrics, metrics) || other.metrics == metrics));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,metrics);
}

@override
String toString() {
    return 'DayMetrics(date: $date, metrics: $metrics)';
}


}

/// @nodoc
abstract mixin class _$DayMetricsCopyWith<$Res> implements $DayMetricsCopyWith<$Res> {
  factory _$DayMetricsCopyWith(_DayMetrics value, $Res Function(_DayMetrics) _then) = __$DayMetricsCopyWithImpl;
@override @useResult
$Res call({
 LocalDate date, PeriodMetrics metrics
});


@override $PeriodMetricsCopyWith<$Res> get metrics;

}
/// @nodoc
class __$DayMetricsCopyWithImpl<$Res>
    implements _$DayMetricsCopyWith<$Res> {
  __$DayMetricsCopyWithImpl(this._self, this._then);

  final _DayMetrics _self;
  final $Res Function(_DayMetrics) _then;

/// Create a copy of DayMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? metrics = null,}) {
  return _then(_DayMetrics(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as PeriodMetrics,
  ));
}

/// Create a copy of DayMetrics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<$Res> get metrics {
  
  return $PeriodMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}
}

/// @nodoc
mixin _$ExecutionSummary {

 ExecutionRecord get record; ExecutionOutcome get outcome;/// The actual duration if completed and measured, else session time so
/// far; null when nothing was measured.
 Duration? get measured;
/// Create a copy of ExecutionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExecutionSummaryCopyWith<ExecutionSummary> get copyWith => _$ExecutionSummaryCopyWithImpl<ExecutionSummary>(this as ExecutionSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExecutionSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExecutionSummary&&(identical(other.record, _this.record) || other.record == _this.record)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.measured, _this.measured) || other.measured == _this.measured));
}


@override
int get hashCode {
  final _this = this as ExecutionSummary;
  return Object.hash(runtimeType,_this.record,_this.outcome,_this.measured);
}

@override
String toString() {
  final _this = this as ExecutionSummary;
  return 'ExecutionSummary(record: ${_this.record}, outcome: ${_this.outcome}, measured: ${_this.measured})';
}


}

/// @nodoc
abstract mixin class $ExecutionSummaryCopyWith<$Res>  {
  factory $ExecutionSummaryCopyWith(ExecutionSummary value, $Res Function(ExecutionSummary) _then) = _$ExecutionSummaryCopyWithImpl;
@useResult
$Res call({
 ExecutionRecord record, ExecutionOutcome outcome, Duration? measured
});


$ExecutionRecordCopyWith<$Res> get record;

}
/// @nodoc
class _$ExecutionSummaryCopyWithImpl<$Res>
    implements $ExecutionSummaryCopyWith<$Res> {
  _$ExecutionSummaryCopyWithImpl(this._self, this._then);

  final ExecutionSummary _self;
  final $Res Function(ExecutionSummary) _then;

/// Create a copy of ExecutionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? record = null,Object? outcome = null,Object? measured = freezed,}) {
  return _then(ExecutionSummary(
record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as ExecutionRecord,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as ExecutionOutcome,measured: freezed == measured ? _self.measured : measured // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}
/// Create a copy of ExecutionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExecutionRecordCopyWith<$Res> get record {
  
  return $ExecutionRecordCopyWith<$Res>(_self.record, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExecutionSummary].
extension ExecutionSummaryPatterns on ExecutionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExecutionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExecutionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExecutionSummary value)  $default,){
final _that = this;
switch (_that) {
case _ExecutionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExecutionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ExecutionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExecutionRecord record,  ExecutionOutcome outcome,  Duration? measured)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExecutionSummary() when $default != null:
return $default(_that.record,_that.outcome,_that.measured);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExecutionRecord record,  ExecutionOutcome outcome,  Duration? measured)  $default,) {final _that = this;
switch (_that) {
case _ExecutionSummary():
return $default(_that.record,_that.outcome,_that.measured);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExecutionRecord record,  ExecutionOutcome outcome,  Duration? measured)?  $default,) {final _that = this;
switch (_that) {
case _ExecutionSummary() when $default != null:
return $default(_that.record,_that.outcome,_that.measured);case _:
  return null;

}
}

}

/// @nodoc


class _ExecutionSummary implements ExecutionSummary {
  const _ExecutionSummary({required this.record, required this.outcome, this.measured});
  

@override final  ExecutionRecord record;
@override final  ExecutionOutcome outcome;
/// The actual duration if completed and measured, else session time so
/// far; null when nothing was measured.
@override final  Duration? measured;

/// Create a copy of ExecutionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExecutionSummaryCopyWith<_ExecutionSummary> get copyWith => __$ExecutionSummaryCopyWithImpl<_ExecutionSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExecutionSummary&&(identical(other.record, record) || other.record == record)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.measured, measured) || other.measured == measured));
}


@override
int get hashCode {
    return Object.hash(runtimeType,record,outcome,measured);
}

@override
String toString() {
    return 'ExecutionSummary(record: $record, outcome: $outcome, measured: $measured)';
}


}

/// @nodoc
abstract mixin class _$ExecutionSummaryCopyWith<$Res> implements $ExecutionSummaryCopyWith<$Res> {
  factory _$ExecutionSummaryCopyWith(_ExecutionSummary value, $Res Function(_ExecutionSummary) _then) = __$ExecutionSummaryCopyWithImpl;
@override @useResult
$Res call({
 ExecutionRecord record, ExecutionOutcome outcome, Duration? measured
});


@override $ExecutionRecordCopyWith<$Res> get record;

}
/// @nodoc
class __$ExecutionSummaryCopyWithImpl<$Res>
    implements _$ExecutionSummaryCopyWith<$Res> {
  __$ExecutionSummaryCopyWithImpl(this._self, this._then);

  final _ExecutionSummary _self;
  final $Res Function(_ExecutionSummary) _then;

/// Create a copy of ExecutionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? record = null,Object? outcome = null,Object? measured = freezed,}) {
  return _then(_ExecutionSummary(
record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as ExecutionRecord,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as ExecutionOutcome,measured: freezed == measured ? _self.measured : measured // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

/// Create a copy of ExecutionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExecutionRecordCopyWith<$Res> get record {
  
  return $ExecutionRecordCopyWith<$Res>(_self.record, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}

/// @nodoc
mixin _$ActivityBreakdown {

 String get lineageId;/// The most recent title (an activity can be renamed).
 String get title; PeriodMetrics get metrics; Category? get category;
/// Create a copy of ActivityBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityBreakdownCopyWith<ActivityBreakdown> get copyWith => _$ActivityBreakdownCopyWithImpl<ActivityBreakdown>(this as ActivityBreakdown, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ActivityBreakdown;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityBreakdown&&(identical(other.lineageId, _this.lineageId) || other.lineageId == _this.lineageId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.metrics, _this.metrics) || other.metrics == _this.metrics)&&(identical(other.category, _this.category) || other.category == _this.category));
}


@override
int get hashCode {
  final _this = this as ActivityBreakdown;
  return Object.hash(runtimeType,_this.lineageId,_this.title,_this.metrics,_this.category);
}

@override
String toString() {
  final _this = this as ActivityBreakdown;
  return 'ActivityBreakdown(lineageId: ${_this.lineageId}, title: ${_this.title}, metrics: ${_this.metrics}, category: ${_this.category})';
}


}

/// @nodoc
abstract mixin class $ActivityBreakdownCopyWith<$Res>  {
  factory $ActivityBreakdownCopyWith(ActivityBreakdown value, $Res Function(ActivityBreakdown) _then) = _$ActivityBreakdownCopyWithImpl;
@useResult
$Res call({
 String lineageId, String title, PeriodMetrics metrics, Category? category
});


$PeriodMetricsCopyWith<$Res> get metrics;$CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$ActivityBreakdownCopyWithImpl<$Res>
    implements $ActivityBreakdownCopyWith<$Res> {
  _$ActivityBreakdownCopyWithImpl(this._self, this._then);

  final ActivityBreakdown _self;
  final $Res Function(ActivityBreakdown) _then;

/// Create a copy of ActivityBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineageId = null,Object? title = null,Object? metrics = null,Object? category = freezed,}) {
  return _then(ActivityBreakdown(
lineageId: null == lineageId ? _self.lineageId : lineageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as PeriodMetrics,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}
/// Create a copy of ActivityBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<$Res> get metrics {
  
  return $PeriodMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}/// Create a copy of ActivityBreakdown
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


/// Adds pattern-matching-related methods to [ActivityBreakdown].
extension ActivityBreakdownPatterns on ActivityBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _ActivityBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lineageId,  String title,  PeriodMetrics metrics,  Category? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityBreakdown() when $default != null:
return $default(_that.lineageId,_that.title,_that.metrics,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lineageId,  String title,  PeriodMetrics metrics,  Category? category)  $default,) {final _that = this;
switch (_that) {
case _ActivityBreakdown():
return $default(_that.lineageId,_that.title,_that.metrics,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lineageId,  String title,  PeriodMetrics metrics,  Category? category)?  $default,) {final _that = this;
switch (_that) {
case _ActivityBreakdown() when $default != null:
return $default(_that.lineageId,_that.title,_that.metrics,_that.category);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityBreakdown implements ActivityBreakdown {
  const _ActivityBreakdown({required this.lineageId, required this.title, required this.metrics, this.category});
  

@override final  String lineageId;
/// The most recent title (an activity can be renamed).
@override final  String title;
@override final  PeriodMetrics metrics;
@override final  Category? category;

/// Create a copy of ActivityBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityBreakdownCopyWith<_ActivityBreakdown> get copyWith => __$ActivityBreakdownCopyWithImpl<_ActivityBreakdown>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityBreakdown&&(identical(other.lineageId, lineageId) || other.lineageId == lineageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.metrics, metrics) || other.metrics == metrics)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lineageId,title,metrics,category);
}

@override
String toString() {
    return 'ActivityBreakdown(lineageId: $lineageId, title: $title, metrics: $metrics, category: $category)';
}


}

/// @nodoc
abstract mixin class _$ActivityBreakdownCopyWith<$Res> implements $ActivityBreakdownCopyWith<$Res> {
  factory _$ActivityBreakdownCopyWith(_ActivityBreakdown value, $Res Function(_ActivityBreakdown) _then) = __$ActivityBreakdownCopyWithImpl;
@override @useResult
$Res call({
 String lineageId, String title, PeriodMetrics metrics, Category? category
});


@override $PeriodMetricsCopyWith<$Res> get metrics;@override $CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$ActivityBreakdownCopyWithImpl<$Res>
    implements _$ActivityBreakdownCopyWith<$Res> {
  __$ActivityBreakdownCopyWithImpl(this._self, this._then);

  final _ActivityBreakdown _self;
  final $Res Function(_ActivityBreakdown) _then;

/// Create a copy of ActivityBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineageId = null,Object? title = null,Object? metrics = null,Object? category = freezed,}) {
  return _then(_ActivityBreakdown(
lineageId: null == lineageId ? _self.lineageId : lineageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as PeriodMetrics,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}

/// Create a copy of ActivityBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<$Res> get metrics {
  
  return $PeriodMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}/// Create a copy of ActivityBreakdown
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

/// @nodoc
mixin _$AnalyticsReport {

 AnalyticsPeriod get period; PeriodMetrics get metrics;/// The period before, for "vs last week".
 PeriodMetrics get previous;/// One entry per day of the period, in order.
 List<DayMetrics> get days;/// Activities with counted occurrences, most tracked time first.
 List<ActivityBreakdown> get activities;/// The period's occurrences in date and start order (the Day view's
/// plan-vs-actual list).
 List<ExecutionSummary> get executions;
/// Create a copy of AnalyticsReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsReportCopyWith<AnalyticsReport> get copyWith => _$AnalyticsReportCopyWithImpl<AnalyticsReport>(this as AnalyticsReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AnalyticsReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsReport&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.metrics, _this.metrics) || other.metrics == _this.metrics)&&(identical(other.previous, _this.previous) || other.previous == _this.previous)&&const DeepCollectionEquality().equals(other.days, _this.days)&&const DeepCollectionEquality().equals(other.activities, _this.activities)&&const DeepCollectionEquality().equals(other.executions, _this.executions));
}


@override
int get hashCode {
  final _this = this as AnalyticsReport;
  return Object.hash(runtimeType,_this.period,_this.metrics,_this.previous,const DeepCollectionEquality().hash(_this.days),const DeepCollectionEquality().hash(_this.activities),const DeepCollectionEquality().hash(_this.executions));
}

@override
String toString() {
  final _this = this as AnalyticsReport;
  return 'AnalyticsReport(period: ${_this.period}, metrics: ${_this.metrics}, previous: ${_this.previous}, days: ${_this.days}, activities: ${_this.activities}, executions: ${_this.executions})';
}


}

/// @nodoc
abstract mixin class $AnalyticsReportCopyWith<$Res>  {
  factory $AnalyticsReportCopyWith(AnalyticsReport value, $Res Function(AnalyticsReport) _then) = _$AnalyticsReportCopyWithImpl;
@useResult
$Res call({
 AnalyticsPeriod period, PeriodMetrics metrics, PeriodMetrics previous, List<DayMetrics> days, List<ActivityBreakdown> activities, List<ExecutionSummary> executions
});


$PeriodMetricsCopyWith<$Res> get metrics;$PeriodMetricsCopyWith<$Res> get previous;

}
/// @nodoc
class _$AnalyticsReportCopyWithImpl<$Res>
    implements $AnalyticsReportCopyWith<$Res> {
  _$AnalyticsReportCopyWithImpl(this._self, this._then);

  final AnalyticsReport _self;
  final $Res Function(AnalyticsReport) _then;

/// Create a copy of AnalyticsReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? metrics = null,Object? previous = null,Object? days = null,Object? activities = null,Object? executions = null,}) {
  return _then(AnalyticsReport(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsPeriod,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as PeriodMetrics,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as PeriodMetrics,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<DayMetrics>,activities: null == activities ? _self.activities : activities // ignore: cast_nullable_to_non_nullable
as List<ActivityBreakdown>,executions: null == executions ? _self.executions : executions // ignore: cast_nullable_to_non_nullable
as List<ExecutionSummary>,
  ));
}
/// Create a copy of AnalyticsReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<$Res> get metrics {
  
  return $PeriodMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}/// Create a copy of AnalyticsReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<$Res> get previous {
  
  return $PeriodMetricsCopyWith<$Res>(_self.previous, (value) {
    return _then(_self.copyWith(previous: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsReport].
extension AnalyticsReportPatterns on AnalyticsReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsReport value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsReport value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsPeriod period,  PeriodMetrics metrics,  PeriodMetrics previous,  List<DayMetrics> days,  List<ActivityBreakdown> activities,  List<ExecutionSummary> executions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsReport() when $default != null:
return $default(_that.period,_that.metrics,_that.previous,_that.days,_that.activities,_that.executions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsPeriod period,  PeriodMetrics metrics,  PeriodMetrics previous,  List<DayMetrics> days,  List<ActivityBreakdown> activities,  List<ExecutionSummary> executions)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsReport():
return $default(_that.period,_that.metrics,_that.previous,_that.days,_that.activities,_that.executions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsPeriod period,  PeriodMetrics metrics,  PeriodMetrics previous,  List<DayMetrics> days,  List<ActivityBreakdown> activities,  List<ExecutionSummary> executions)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsReport() when $default != null:
return $default(_that.period,_that.metrics,_that.previous,_that.days,_that.activities,_that.executions);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsReport implements AnalyticsReport {
  const _AnalyticsReport({required this.period, required this.metrics, required this.previous, required  List<DayMetrics> days, required  List<ActivityBreakdown> activities, required  List<ExecutionSummary> executions}): _days = days,_activities = activities,_executions = executions;
  

@override final  AnalyticsPeriod period;
@override final  PeriodMetrics metrics;
/// The period before, for "vs last week".
@override final  PeriodMetrics previous;
/// One entry per day of the period, in order.
 final  List<DayMetrics> _days;
/// One entry per day of the period, in order.
@override List<DayMetrics> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

/// Activities with counted occurrences, most tracked time first.
 final  List<ActivityBreakdown> _activities;
/// Activities with counted occurrences, most tracked time first.
@override List<ActivityBreakdown> get activities {
  if (_activities is EqualUnmodifiableListView) return _activities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activities);
}

/// The period's occurrences in date and start order (the Day view's
/// plan-vs-actual list).
 final  List<ExecutionSummary> _executions;
/// The period's occurrences in date and start order (the Day view's
/// plan-vs-actual list).
@override List<ExecutionSummary> get executions {
  if (_executions is EqualUnmodifiableListView) return _executions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_executions);
}


/// Create a copy of AnalyticsReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsReportCopyWith<_AnalyticsReport> get copyWith => __$AnalyticsReportCopyWithImpl<_AnalyticsReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsReport&&(identical(other.period, period) || other.period == period)&&(identical(other.metrics, metrics) || other.metrics == metrics)&&(identical(other.previous, previous) || other.previous == previous)&&const DeepCollectionEquality().equals(other.days, _days)&&const DeepCollectionEquality().equals(other.activities, _activities)&&const DeepCollectionEquality().equals(other.executions, _executions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,period,metrics,previous,const DeepCollectionEquality().hash(_days),const DeepCollectionEquality().hash(_activities),const DeepCollectionEquality().hash(_executions));
}

@override
String toString() {
    return 'AnalyticsReport(period: $period, metrics: $metrics, previous: $previous, days: $days, activities: $activities, executions: $executions)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsReportCopyWith<$Res> implements $AnalyticsReportCopyWith<$Res> {
  factory _$AnalyticsReportCopyWith(_AnalyticsReport value, $Res Function(_AnalyticsReport) _then) = __$AnalyticsReportCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsPeriod period, PeriodMetrics metrics, PeriodMetrics previous, List<DayMetrics> days, List<ActivityBreakdown> activities, List<ExecutionSummary> executions
});


@override $PeriodMetricsCopyWith<$Res> get metrics;@override $PeriodMetricsCopyWith<$Res> get previous;

}
/// @nodoc
class __$AnalyticsReportCopyWithImpl<$Res>
    implements _$AnalyticsReportCopyWith<$Res> {
  __$AnalyticsReportCopyWithImpl(this._self, this._then);

  final _AnalyticsReport _self;
  final $Res Function(_AnalyticsReport) _then;

/// Create a copy of AnalyticsReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? metrics = null,Object? previous = null,Object? days = null,Object? activities = null,Object? executions = null,}) {
  return _then(_AnalyticsReport(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsPeriod,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as PeriodMetrics,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as PeriodMetrics,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<DayMetrics>,activities: null == activities ? _self._activities : activities // ignore: cast_nullable_to_non_nullable
as List<ActivityBreakdown>,executions: null == executions ? _self._executions : executions // ignore: cast_nullable_to_non_nullable
as List<ExecutionSummary>,
  ));
}

/// Create a copy of AnalyticsReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<$Res> get metrics {
  
  return $PeriodMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}/// Create a copy of AnalyticsReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<$Res> get previous {
  
  return $PeriodMetricsCopyWith<$Res>(_self.previous, (value) {
    return _then(_self.copyWith(previous: value));
  });
}
}

/// @nodoc
mixin _$DurationSuggestion {

 Duration get current; Duration get suggested;/// How many measured completions it is based on.
 int get basedOn;
/// Create a copy of DurationSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DurationSuggestionCopyWith<DurationSuggestion> get copyWith => _$DurationSuggestionCopyWithImpl<DurationSuggestion>(this as DurationSuggestion, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DurationSuggestion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DurationSuggestion&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.suggested, _this.suggested) || other.suggested == _this.suggested)&&(identical(other.basedOn, _this.basedOn) || other.basedOn == _this.basedOn));
}


@override
int get hashCode {
  final _this = this as DurationSuggestion;
  return Object.hash(runtimeType,_this.current,_this.suggested,_this.basedOn);
}

@override
String toString() {
  final _this = this as DurationSuggestion;
  return 'DurationSuggestion(current: ${_this.current}, suggested: ${_this.suggested}, basedOn: ${_this.basedOn})';
}


}

/// @nodoc
abstract mixin class $DurationSuggestionCopyWith<$Res>  {
  factory $DurationSuggestionCopyWith(DurationSuggestion value, $Res Function(DurationSuggestion) _then) = _$DurationSuggestionCopyWithImpl;
@useResult
$Res call({
 Duration current, Duration suggested, int basedOn
});




}
/// @nodoc
class _$DurationSuggestionCopyWithImpl<$Res>
    implements $DurationSuggestionCopyWith<$Res> {
  _$DurationSuggestionCopyWithImpl(this._self, this._then);

  final DurationSuggestion _self;
  final $Res Function(DurationSuggestion) _then;

/// Create a copy of DurationSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? suggested = null,Object? basedOn = null,}) {
  return _then(DurationSuggestion(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as Duration,suggested: null == suggested ? _self.suggested : suggested // ignore: cast_nullable_to_non_nullable
as Duration,basedOn: null == basedOn ? _self.basedOn : basedOn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DurationSuggestion].
extension DurationSuggestionPatterns on DurationSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DurationSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DurationSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DurationSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _DurationSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DurationSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _DurationSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration current,  Duration suggested,  int basedOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DurationSuggestion() when $default != null:
return $default(_that.current,_that.suggested,_that.basedOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration current,  Duration suggested,  int basedOn)  $default,) {final _that = this;
switch (_that) {
case _DurationSuggestion():
return $default(_that.current,_that.suggested,_that.basedOn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration current,  Duration suggested,  int basedOn)?  $default,) {final _that = this;
switch (_that) {
case _DurationSuggestion() when $default != null:
return $default(_that.current,_that.suggested,_that.basedOn);case _:
  return null;

}
}

}

/// @nodoc


class _DurationSuggestion implements DurationSuggestion {
  const _DurationSuggestion({required this.current, required this.suggested, required this.basedOn});
  

@override final  Duration current;
@override final  Duration suggested;
/// How many measured completions it is based on.
@override final  int basedOn;

/// Create a copy of DurationSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DurationSuggestionCopyWith<_DurationSuggestion> get copyWith => __$DurationSuggestionCopyWithImpl<_DurationSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DurationSuggestion&&(identical(other.current, current) || other.current == current)&&(identical(other.suggested, suggested) || other.suggested == suggested)&&(identical(other.basedOn, basedOn) || other.basedOn == basedOn));
}


@override
int get hashCode {
    return Object.hash(runtimeType,current,suggested,basedOn);
}

@override
String toString() {
    return 'DurationSuggestion(current: $current, suggested: $suggested, basedOn: $basedOn)';
}


}

/// @nodoc
abstract mixin class _$DurationSuggestionCopyWith<$Res> implements $DurationSuggestionCopyWith<$Res> {
  factory _$DurationSuggestionCopyWith(_DurationSuggestion value, $Res Function(_DurationSuggestion) _then) = __$DurationSuggestionCopyWithImpl;
@override @useResult
$Res call({
 Duration current, Duration suggested, int basedOn
});




}
/// @nodoc
class __$DurationSuggestionCopyWithImpl<$Res>
    implements _$DurationSuggestionCopyWith<$Res> {
  __$DurationSuggestionCopyWithImpl(this._self, this._then);

  final _DurationSuggestion _self;
  final $Res Function(_DurationSuggestion) _then;

/// Create a copy of DurationSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? suggested = null,Object? basedOn = null,}) {
  return _then(_DurationSuggestion(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as Duration,suggested: null == suggested ? _self.suggested : suggested // ignore: cast_nullable_to_non_nullable
as Duration,basedOn: null == basedOn ? _self.basedOn : basedOn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ActivityStats {

 String get lineageId; String get title;/// The series carrying the current schedule (where a suggestion
/// applies).
 String get currentTaskId;/// Its expected duration.
 Duration get currentPlanned; PeriodMetrics get metrics;/// Completed occurrences in a row, up to the latest decided one. A
/// skip or a miss ends a streak; open ones are ignored.
 int get currentStreak; int get bestStreak;/// The most recent occurrences up to today, oldest first.
 List<ExecutionSummary> get history; Category? get category; DurationSuggestion? get suggestion;
/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityStatsCopyWith<ActivityStats> get copyWith => _$ActivityStatsCopyWithImpl<ActivityStats>(this as ActivityStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ActivityStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityStats&&(identical(other.lineageId, _this.lineageId) || other.lineageId == _this.lineageId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.currentTaskId, _this.currentTaskId) || other.currentTaskId == _this.currentTaskId)&&(identical(other.currentPlanned, _this.currentPlanned) || other.currentPlanned == _this.currentPlanned)&&(identical(other.metrics, _this.metrics) || other.metrics == _this.metrics)&&(identical(other.currentStreak, _this.currentStreak) || other.currentStreak == _this.currentStreak)&&(identical(other.bestStreak, _this.bestStreak) || other.bestStreak == _this.bestStreak)&&const DeepCollectionEquality().equals(other.history, _this.history)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.suggestion, _this.suggestion) || other.suggestion == _this.suggestion));
}


@override
int get hashCode {
  final _this = this as ActivityStats;
  return Object.hash(runtimeType,_this.lineageId,_this.title,_this.currentTaskId,_this.currentPlanned,_this.metrics,_this.currentStreak,_this.bestStreak,const DeepCollectionEquality().hash(_this.history),_this.category,_this.suggestion);
}

@override
String toString() {
  final _this = this as ActivityStats;
  return 'ActivityStats(lineageId: ${_this.lineageId}, title: ${_this.title}, currentTaskId: ${_this.currentTaskId}, currentPlanned: ${_this.currentPlanned}, metrics: ${_this.metrics}, currentStreak: ${_this.currentStreak}, bestStreak: ${_this.bestStreak}, history: ${_this.history}, category: ${_this.category}, suggestion: ${_this.suggestion})';
}


}

/// @nodoc
abstract mixin class $ActivityStatsCopyWith<$Res>  {
  factory $ActivityStatsCopyWith(ActivityStats value, $Res Function(ActivityStats) _then) = _$ActivityStatsCopyWithImpl;
@useResult
$Res call({
 String lineageId, String title, String currentTaskId, Duration currentPlanned, PeriodMetrics metrics, int currentStreak, int bestStreak, List<ExecutionSummary> history, Category? category, DurationSuggestion? suggestion
});


$PeriodMetricsCopyWith<$Res> get metrics;$CategoryCopyWith<$Res>? get category;$DurationSuggestionCopyWith<$Res>? get suggestion;

}
/// @nodoc
class _$ActivityStatsCopyWithImpl<$Res>
    implements $ActivityStatsCopyWith<$Res> {
  _$ActivityStatsCopyWithImpl(this._self, this._then);

  final ActivityStats _self;
  final $Res Function(ActivityStats) _then;

/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineageId = null,Object? title = null,Object? currentTaskId = null,Object? currentPlanned = null,Object? metrics = null,Object? currentStreak = null,Object? bestStreak = null,Object? history = null,Object? category = freezed,Object? suggestion = freezed,}) {
  return _then(ActivityStats(
lineageId: null == lineageId ? _self.lineageId : lineageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,currentTaskId: null == currentTaskId ? _self.currentTaskId : currentTaskId // ignore: cast_nullable_to_non_nullable
as String,currentPlanned: null == currentPlanned ? _self.currentPlanned : currentPlanned // ignore: cast_nullable_to_non_nullable
as Duration,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as PeriodMetrics,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,bestStreak: null == bestStreak ? _self.bestStreak : bestStreak // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<ExecutionSummary>,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,suggestion: freezed == suggestion ? _self.suggestion : suggestion // ignore: cast_nullable_to_non_nullable
as DurationSuggestion?,
  ));
}
/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<$Res> get metrics {
  
  return $PeriodMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}/// Create a copy of ActivityStats
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
}/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DurationSuggestionCopyWith<$Res>? get suggestion {
    if (_self.suggestion == null) {
    return null;
  }

  return $DurationSuggestionCopyWith<$Res>(_self.suggestion!, (value) {
    return _then(_self.copyWith(suggestion: value));
  });
}
}


/// Adds pattern-matching-related methods to [ActivityStats].
extension ActivityStatsPatterns on ActivityStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityStats value)  $default,){
final _that = this;
switch (_that) {
case _ActivityStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityStats value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lineageId,  String title,  String currentTaskId,  Duration currentPlanned,  PeriodMetrics metrics,  int currentStreak,  int bestStreak,  List<ExecutionSummary> history,  Category? category,  DurationSuggestion? suggestion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityStats() when $default != null:
return $default(_that.lineageId,_that.title,_that.currentTaskId,_that.currentPlanned,_that.metrics,_that.currentStreak,_that.bestStreak,_that.history,_that.category,_that.suggestion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lineageId,  String title,  String currentTaskId,  Duration currentPlanned,  PeriodMetrics metrics,  int currentStreak,  int bestStreak,  List<ExecutionSummary> history,  Category? category,  DurationSuggestion? suggestion)  $default,) {final _that = this;
switch (_that) {
case _ActivityStats():
return $default(_that.lineageId,_that.title,_that.currentTaskId,_that.currentPlanned,_that.metrics,_that.currentStreak,_that.bestStreak,_that.history,_that.category,_that.suggestion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lineageId,  String title,  String currentTaskId,  Duration currentPlanned,  PeriodMetrics metrics,  int currentStreak,  int bestStreak,  List<ExecutionSummary> history,  Category? category,  DurationSuggestion? suggestion)?  $default,) {final _that = this;
switch (_that) {
case _ActivityStats() when $default != null:
return $default(_that.lineageId,_that.title,_that.currentTaskId,_that.currentPlanned,_that.metrics,_that.currentStreak,_that.bestStreak,_that.history,_that.category,_that.suggestion);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityStats implements ActivityStats {
  const _ActivityStats({required this.lineageId, required this.title, required this.currentTaskId, required this.currentPlanned, required this.metrics, required this.currentStreak, required this.bestStreak, required  List<ExecutionSummary> history, this.category, this.suggestion}): _history = history;
  

@override final  String lineageId;
@override final  String title;
/// The series carrying the current schedule (where a suggestion
/// applies).
@override final  String currentTaskId;
/// Its expected duration.
@override final  Duration currentPlanned;
@override final  PeriodMetrics metrics;
/// Completed occurrences in a row, up to the latest decided one. A
/// skip or a miss ends a streak; open ones are ignored.
@override final  int currentStreak;
@override final  int bestStreak;
/// The most recent occurrences up to today, oldest first.
 final  List<ExecutionSummary> _history;
/// The most recent occurrences up to today, oldest first.
@override List<ExecutionSummary> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override final  Category? category;
@override final  DurationSuggestion? suggestion;

/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityStatsCopyWith<_ActivityStats> get copyWith => __$ActivityStatsCopyWithImpl<_ActivityStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityStats&&(identical(other.lineageId, lineageId) || other.lineageId == lineageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.currentTaskId, currentTaskId) || other.currentTaskId == currentTaskId)&&(identical(other.currentPlanned, currentPlanned) || other.currentPlanned == currentPlanned)&&(identical(other.metrics, metrics) || other.metrics == metrics)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.bestStreak, bestStreak) || other.bestStreak == bestStreak)&&const DeepCollectionEquality().equals(other.history, _history)&&(identical(other.category, category) || other.category == category)&&(identical(other.suggestion, suggestion) || other.suggestion == suggestion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lineageId,title,currentTaskId,currentPlanned,metrics,currentStreak,bestStreak,const DeepCollectionEquality().hash(_history),category,suggestion);
}

@override
String toString() {
    return 'ActivityStats(lineageId: $lineageId, title: $title, currentTaskId: $currentTaskId, currentPlanned: $currentPlanned, metrics: $metrics, currentStreak: $currentStreak, bestStreak: $bestStreak, history: $history, category: $category, suggestion: $suggestion)';
}


}

/// @nodoc
abstract mixin class _$ActivityStatsCopyWith<$Res> implements $ActivityStatsCopyWith<$Res> {
  factory _$ActivityStatsCopyWith(_ActivityStats value, $Res Function(_ActivityStats) _then) = __$ActivityStatsCopyWithImpl;
@override @useResult
$Res call({
 String lineageId, String title, String currentTaskId, Duration currentPlanned, PeriodMetrics metrics, int currentStreak, int bestStreak, List<ExecutionSummary> history, Category? category, DurationSuggestion? suggestion
});


@override $PeriodMetricsCopyWith<$Res> get metrics;@override $CategoryCopyWith<$Res>? get category;@override $DurationSuggestionCopyWith<$Res>? get suggestion;

}
/// @nodoc
class __$ActivityStatsCopyWithImpl<$Res>
    implements _$ActivityStatsCopyWith<$Res> {
  __$ActivityStatsCopyWithImpl(this._self, this._then);

  final _ActivityStats _self;
  final $Res Function(_ActivityStats) _then;

/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineageId = null,Object? title = null,Object? currentTaskId = null,Object? currentPlanned = null,Object? metrics = null,Object? currentStreak = null,Object? bestStreak = null,Object? history = null,Object? category = freezed,Object? suggestion = freezed,}) {
  return _then(_ActivityStats(
lineageId: null == lineageId ? _self.lineageId : lineageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,currentTaskId: null == currentTaskId ? _self.currentTaskId : currentTaskId // ignore: cast_nullable_to_non_nullable
as String,currentPlanned: null == currentPlanned ? _self.currentPlanned : currentPlanned // ignore: cast_nullable_to_non_nullable
as Duration,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as PeriodMetrics,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,bestStreak: null == bestStreak ? _self.bestStreak : bestStreak // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<ExecutionSummary>,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,suggestion: freezed == suggestion ? _self.suggestion : suggestion // ignore: cast_nullable_to_non_nullable
as DurationSuggestion?,
  ));
}

/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodMetricsCopyWith<$Res> get metrics {
  
  return $PeriodMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}/// Create a copy of ActivityStats
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
}/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DurationSuggestionCopyWith<$Res>? get suggestion {
    if (_self.suggestion == null) {
    return null;
  }

  return $DurationSuggestionCopyWith<$Res>(_self.suggestion!, (value) {
    return _then(_self.copyWith(suggestion: value));
  });
}
}

// dart format on
