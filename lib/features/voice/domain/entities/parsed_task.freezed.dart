// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParsedTask {

/// The sentence it was parsed from.
 String get text;/// The date relative words ("tomorrow") were resolved against.
 LocalDate get today; String? get title; LocalDate? get date; LocalTime? get startTime;/// "Any time" was said explicitly ("sometime tomorrow").
 bool get anyTime; Duration? get expectedDuration; RecurrenceRule? get recurrence; Category? get category;
/// Create a copy of ParsedTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedTaskCopyWith<ParsedTask> get copyWith => _$ParsedTaskCopyWithImpl<ParsedTask>(this as ParsedTask, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ParsedTask;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedTask&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.today, _this.today) || other.today == _this.today)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.anyTime, _this.anyTime) || other.anyTime == _this.anyTime)&&(identical(other.expectedDuration, _this.expectedDuration) || other.expectedDuration == _this.expectedDuration)&&(identical(other.recurrence, _this.recurrence) || other.recurrence == _this.recurrence)&&(identical(other.category, _this.category) || other.category == _this.category));
}


@override
int get hashCode {
  final _this = this as ParsedTask;
  return Object.hash(runtimeType,_this.text,_this.today,_this.title,_this.date,_this.startTime,_this.anyTime,_this.expectedDuration,_this.recurrence,_this.category);
}

@override
String toString() {
  final _this = this as ParsedTask;
  return 'ParsedTask(text: ${_this.text}, today: ${_this.today}, title: ${_this.title}, date: ${_this.date}, startTime: ${_this.startTime}, anyTime: ${_this.anyTime}, expectedDuration: ${_this.expectedDuration}, recurrence: ${_this.recurrence}, category: ${_this.category})';
}


}

/// @nodoc
abstract mixin class $ParsedTaskCopyWith<$Res>  {
  factory $ParsedTaskCopyWith(ParsedTask value, $Res Function(ParsedTask) _then) = _$ParsedTaskCopyWithImpl;
@useResult
$Res call({
 String text, LocalDate today, String? title, LocalDate? date, LocalTime? startTime, bool anyTime, Duration? expectedDuration, RecurrenceRule? recurrence, Category? category
});


$RecurrenceRuleCopyWith<$Res>? get recurrence;$CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$ParsedTaskCopyWithImpl<$Res>
    implements $ParsedTaskCopyWith<$Res> {
  _$ParsedTaskCopyWithImpl(this._self, this._then);

  final ParsedTask _self;
  final $Res Function(ParsedTask) _then;

/// Create a copy of ParsedTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? today = null,Object? title = freezed,Object? date = freezed,Object? startTime = freezed,Object? anyTime = null,Object? expectedDuration = freezed,Object? recurrence = freezed,Object? category = freezed,}) {
  return _then(ParsedTask(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as LocalTime?,anyTime: null == anyTime ? _self.anyTime : anyTime // ignore: cast_nullable_to_non_nullable
as bool,expectedDuration: freezed == expectedDuration ? _self.expectedDuration : expectedDuration // ignore: cast_nullable_to_non_nullable
as Duration?,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceRule?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}
/// Create a copy of ParsedTask
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
}/// Create a copy of ParsedTask
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


/// Adds pattern-matching-related methods to [ParsedTask].
extension ParsedTaskPatterns on ParsedTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedTask value)  $default,){
final _that = this;
switch (_that) {
case _ParsedTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedTask value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  LocalDate today,  String? title,  LocalDate? date,  LocalTime? startTime,  bool anyTime,  Duration? expectedDuration,  RecurrenceRule? recurrence,  Category? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedTask() when $default != null:
return $default(_that.text,_that.today,_that.title,_that.date,_that.startTime,_that.anyTime,_that.expectedDuration,_that.recurrence,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  LocalDate today,  String? title,  LocalDate? date,  LocalTime? startTime,  bool anyTime,  Duration? expectedDuration,  RecurrenceRule? recurrence,  Category? category)  $default,) {final _that = this;
switch (_that) {
case _ParsedTask():
return $default(_that.text,_that.today,_that.title,_that.date,_that.startTime,_that.anyTime,_that.expectedDuration,_that.recurrence,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  LocalDate today,  String? title,  LocalDate? date,  LocalTime? startTime,  bool anyTime,  Duration? expectedDuration,  RecurrenceRule? recurrence,  Category? category)?  $default,) {final _that = this;
switch (_that) {
case _ParsedTask() when $default != null:
return $default(_that.text,_that.today,_that.title,_that.date,_that.startTime,_that.anyTime,_that.expectedDuration,_that.recurrence,_that.category);case _:
  return null;

}
}

}

/// @nodoc


class _ParsedTask extends ParsedTask {
  const _ParsedTask({required this.text, required this.today, this.title, this.date, this.startTime, this.anyTime = false, this.expectedDuration, this.recurrence, this.category}): super._();
  

/// The sentence it was parsed from.
@override final  String text;
/// The date relative words ("tomorrow") were resolved against.
@override final  LocalDate today;
@override final  String? title;
@override final  LocalDate? date;
@override final  LocalTime? startTime;
/// "Any time" was said explicitly ("sometime tomorrow").
@override@JsonKey() final  bool anyTime;
@override final  Duration? expectedDuration;
@override final  RecurrenceRule? recurrence;
@override final  Category? category;

/// Create a copy of ParsedTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedTaskCopyWith<_ParsedTask> get copyWith => __$ParsedTaskCopyWithImpl<_ParsedTask>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedTask&&(identical(other.text, text) || other.text == text)&&(identical(other.today, today) || other.today == today)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.anyTime, anyTime) || other.anyTime == anyTime)&&(identical(other.expectedDuration, expectedDuration) || other.expectedDuration == expectedDuration)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,today,title,date,startTime,anyTime,expectedDuration,recurrence,category);
}

@override
String toString() {
    return 'ParsedTask(text: $text, today: $today, title: $title, date: $date, startTime: $startTime, anyTime: $anyTime, expectedDuration: $expectedDuration, recurrence: $recurrence, category: $category)';
}


}

/// @nodoc
abstract mixin class _$ParsedTaskCopyWith<$Res> implements $ParsedTaskCopyWith<$Res> {
  factory _$ParsedTaskCopyWith(_ParsedTask value, $Res Function(_ParsedTask) _then) = __$ParsedTaskCopyWithImpl;
@override @useResult
$Res call({
 String text, LocalDate today, String? title, LocalDate? date, LocalTime? startTime, bool anyTime, Duration? expectedDuration, RecurrenceRule? recurrence, Category? category
});


@override $RecurrenceRuleCopyWith<$Res>? get recurrence;@override $CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$ParsedTaskCopyWithImpl<$Res>
    implements _$ParsedTaskCopyWith<$Res> {
  __$ParsedTaskCopyWithImpl(this._self, this._then);

  final _ParsedTask _self;
  final $Res Function(_ParsedTask) _then;

/// Create a copy of ParsedTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? today = null,Object? title = freezed,Object? date = freezed,Object? startTime = freezed,Object? anyTime = null,Object? expectedDuration = freezed,Object? recurrence = freezed,Object? category = freezed,}) {
  return _then(_ParsedTask(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as LocalTime?,anyTime: null == anyTime ? _self.anyTime : anyTime // ignore: cast_nullable_to_non_nullable
as bool,expectedDuration: freezed == expectedDuration ? _self.expectedDuration : expectedDuration // ignore: cast_nullable_to_non_nullable
as Duration?,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceRule?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}

/// Create a copy of ParsedTask
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
}/// Create a copy of ParsedTask
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
mixin _$ParseContext {

/// Today and the current time in the user's home zone.
 LocalDate get today; LocalTime get now;/// The user's categories, matched by name.
 List<Category> get categories;/// BCP 47 tag of the language spoken (the parser may not support it).
 String get language;
/// Create a copy of ParseContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParseContextCopyWith<ParseContext> get copyWith => _$ParseContextCopyWithImpl<ParseContext>(this as ParseContext, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ParseContext;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParseContext&&(identical(other.today, _this.today) || other.today == _this.today)&&(identical(other.now, _this.now) || other.now == _this.now)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&(identical(other.language, _this.language) || other.language == _this.language));
}


@override
int get hashCode {
  final _this = this as ParseContext;
  return Object.hash(runtimeType,_this.today,_this.now,const DeepCollectionEquality().hash(_this.categories),_this.language);
}

@override
String toString() {
  final _this = this as ParseContext;
  return 'ParseContext(today: ${_this.today}, now: ${_this.now}, categories: ${_this.categories}, language: ${_this.language})';
}


}

/// @nodoc
abstract mixin class $ParseContextCopyWith<$Res>  {
  factory $ParseContextCopyWith(ParseContext value, $Res Function(ParseContext) _then) = _$ParseContextCopyWithImpl;
@useResult
$Res call({
 LocalDate today, LocalTime now, List<Category> categories, String language
});




}
/// @nodoc
class _$ParseContextCopyWithImpl<$Res>
    implements $ParseContextCopyWith<$Res> {
  _$ParseContextCopyWithImpl(this._self, this._then);

  final ParseContext _self;
  final $Res Function(ParseContext) _then;

/// Create a copy of ParseContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? today = null,Object? now = null,Object? categories = null,Object? language = null,}) {
  return _then(ParseContext(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as LocalTime,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ParseContext].
extension ParseContextPatterns on ParseContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParseContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParseContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParseContext value)  $default,){
final _that = this;
switch (_that) {
case _ParseContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParseContext value)?  $default,){
final _that = this;
switch (_that) {
case _ParseContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate today,  LocalTime now,  List<Category> categories,  String language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParseContext() when $default != null:
return $default(_that.today,_that.now,_that.categories,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate today,  LocalTime now,  List<Category> categories,  String language)  $default,) {final _that = this;
switch (_that) {
case _ParseContext():
return $default(_that.today,_that.now,_that.categories,_that.language);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate today,  LocalTime now,  List<Category> categories,  String language)?  $default,) {final _that = this;
switch (_that) {
case _ParseContext() when $default != null:
return $default(_that.today,_that.now,_that.categories,_that.language);case _:
  return null;

}
}

}

/// @nodoc


class _ParseContext implements ParseContext {
  const _ParseContext({required this.today, required this.now,  List<Category> categories = const <Category>[], this.language = 'en'}): _categories = categories;
  

/// Today and the current time in the user's home zone.
@override final  LocalDate today;
@override final  LocalTime now;
/// The user's categories, matched by name.
 final  List<Category> _categories;
/// The user's categories, matched by name.
@override@JsonKey() List<Category> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// BCP 47 tag of the language spoken (the parser may not support it).
@override@JsonKey() final  String language;

/// Create a copy of ParseContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParseContextCopyWith<_ParseContext> get copyWith => __$ParseContextCopyWithImpl<_ParseContext>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParseContext&&(identical(other.today, today) || other.today == today)&&(identical(other.now, now) || other.now == now)&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode {
    return Object.hash(runtimeType,today,now,const DeepCollectionEquality().hash(_categories),language);
}

@override
String toString() {
    return 'ParseContext(today: $today, now: $now, categories: $categories, language: $language)';
}


}

/// @nodoc
abstract mixin class _$ParseContextCopyWith<$Res> implements $ParseContextCopyWith<$Res> {
  factory _$ParseContextCopyWith(_ParseContext value, $Res Function(_ParseContext) _then) = __$ParseContextCopyWithImpl;
@override @useResult
$Res call({
 LocalDate today, LocalTime now, List<Category> categories, String language
});




}
/// @nodoc
class __$ParseContextCopyWithImpl<$Res>
    implements _$ParseContextCopyWith<$Res> {
  __$ParseContextCopyWithImpl(this._self, this._then);

  final _ParseContext _self;
  final $Res Function(_ParseContext) _then;

/// Create a copy of ParseContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? today = null,Object? now = null,Object? categories = null,Object? language = null,}) {
  return _then(_ParseContext(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as LocalTime,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
