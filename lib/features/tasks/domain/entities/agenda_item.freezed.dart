// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agenda_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AgendaItem {

 TaskOccurrence get occurrence; Task get task; Category? get category;/// All work sessions of this occurrence, oldest first.
 List<WorkSession> get sessions;
/// Create a copy of AgendaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgendaItemCopyWith<AgendaItem> get copyWith => _$AgendaItemCopyWithImpl<AgendaItem>(this as AgendaItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AgendaItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaItem&&(identical(other.occurrence, _this.occurrence) || other.occurrence == _this.occurrence)&&(identical(other.task, _this.task) || other.task == _this.task)&&(identical(other.category, _this.category) || other.category == _this.category)&&const DeepCollectionEquality().equals(other.sessions, _this.sessions));
}


@override
int get hashCode {
  final _this = this as AgendaItem;
  return Object.hash(runtimeType,_this.occurrence,_this.task,_this.category,const DeepCollectionEquality().hash(_this.sessions));
}

@override
String toString() {
  final _this = this as AgendaItem;
  return 'AgendaItem(occurrence: ${_this.occurrence}, task: ${_this.task}, category: ${_this.category}, sessions: ${_this.sessions})';
}


}

/// @nodoc
abstract mixin class $AgendaItemCopyWith<$Res>  {
  factory $AgendaItemCopyWith(AgendaItem value, $Res Function(AgendaItem) _then) = _$AgendaItemCopyWithImpl;
@useResult
$Res call({
 TaskOccurrence occurrence, Task task, Category? category, List<WorkSession> sessions
});


$TaskOccurrenceCopyWith<$Res> get occurrence;$TaskCopyWith<$Res> get task;$CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$AgendaItemCopyWithImpl<$Res>
    implements $AgendaItemCopyWith<$Res> {
  _$AgendaItemCopyWithImpl(this._self, this._then);

  final AgendaItem _self;
  final $Res Function(AgendaItem) _then;

/// Create a copy of AgendaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? occurrence = null,Object? task = null,Object? category = freezed,Object? sessions = null,}) {
  return _then(AgendaItem(
occurrence: null == occurrence ? _self.occurrence : occurrence // ignore: cast_nullable_to_non_nullable
as TaskOccurrence,task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as Task,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<WorkSession>,
  ));
}
/// Create a copy of AgendaItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskOccurrenceCopyWith<$Res> get occurrence {
  
  return $TaskOccurrenceCopyWith<$Res>(_self.occurrence, (value) {
    return _then(_self.copyWith(occurrence: value));
  });
}/// Create a copy of AgendaItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res> get task {
  
  return $TaskCopyWith<$Res>(_self.task, (value) {
    return _then(_self.copyWith(task: value));
  });
}/// Create a copy of AgendaItem
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


/// Adds pattern-matching-related methods to [AgendaItem].
extension AgendaItemPatterns on AgendaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgendaItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgendaItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgendaItem value)  $default,){
final _that = this;
switch (_that) {
case _AgendaItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgendaItem value)?  $default,){
final _that = this;
switch (_that) {
case _AgendaItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TaskOccurrence occurrence,  Task task,  Category? category,  List<WorkSession> sessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgendaItem() when $default != null:
return $default(_that.occurrence,_that.task,_that.category,_that.sessions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TaskOccurrence occurrence,  Task task,  Category? category,  List<WorkSession> sessions)  $default,) {final _that = this;
switch (_that) {
case _AgendaItem():
return $default(_that.occurrence,_that.task,_that.category,_that.sessions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TaskOccurrence occurrence,  Task task,  Category? category,  List<WorkSession> sessions)?  $default,) {final _that = this;
switch (_that) {
case _AgendaItem() when $default != null:
return $default(_that.occurrence,_that.task,_that.category,_that.sessions);case _:
  return null;

}
}

}

/// @nodoc


class _AgendaItem extends AgendaItem {
  const _AgendaItem({required this.occurrence, required this.task, this.category,  List<WorkSession> sessions = const <WorkSession>[]}): _sessions = sessions,super._();
  

@override final  TaskOccurrence occurrence;
@override final  Task task;
@override final  Category? category;
/// All work sessions of this occurrence, oldest first.
 final  List<WorkSession> _sessions;
/// All work sessions of this occurrence, oldest first.
@override@JsonKey() List<WorkSession> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}


/// Create a copy of AgendaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgendaItemCopyWith<_AgendaItem> get copyWith => __$AgendaItemCopyWithImpl<_AgendaItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgendaItem&&(identical(other.occurrence, occurrence) || other.occurrence == occurrence)&&(identical(other.task, task) || other.task == task)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.sessions, _sessions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,occurrence,task,category,const DeepCollectionEquality().hash(_sessions));
}

@override
String toString() {
    return 'AgendaItem(occurrence: $occurrence, task: $task, category: $category, sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class _$AgendaItemCopyWith<$Res> implements $AgendaItemCopyWith<$Res> {
  factory _$AgendaItemCopyWith(_AgendaItem value, $Res Function(_AgendaItem) _then) = __$AgendaItemCopyWithImpl;
@override @useResult
$Res call({
 TaskOccurrence occurrence, Task task, Category? category, List<WorkSession> sessions
});


@override $TaskOccurrenceCopyWith<$Res> get occurrence;@override $TaskCopyWith<$Res> get task;@override $CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$AgendaItemCopyWithImpl<$Res>
    implements _$AgendaItemCopyWith<$Res> {
  __$AgendaItemCopyWithImpl(this._self, this._then);

  final _AgendaItem _self;
  final $Res Function(_AgendaItem) _then;

/// Create a copy of AgendaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? occurrence = null,Object? task = null,Object? category = freezed,Object? sessions = null,}) {
  return _then(_AgendaItem(
occurrence: null == occurrence ? _self.occurrence : occurrence // ignore: cast_nullable_to_non_nullable
as TaskOccurrence,task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as Task,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<WorkSession>,
  ));
}

/// Create a copy of AgendaItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskOccurrenceCopyWith<$Res> get occurrence {
  
  return $TaskOccurrenceCopyWith<$Res>(_self.occurrence, (value) {
    return _then(_self.copyWith(occurrence: value));
  });
}/// Create a copy of AgendaItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res> get task {
  
  return $TaskCopyWith<$Res>(_self.task, (value) {
    return _then(_self.copyWith(task: value));
  });
}/// Create a copy of AgendaItem
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
