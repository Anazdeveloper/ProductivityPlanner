// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'occurrence_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OccurrenceEvent {

 String get id; String get occurrenceId; OccurrenceTransition get type; DateTime get occurredAt;/// Type-specific details with string/number values, e.g.
/// `{'from_date': '2026-10-06', 'to_date': '2026-10-07'}`.
 Map<String, Object?> get data;
/// Create a copy of OccurrenceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OccurrenceEventCopyWith<OccurrenceEvent> get copyWith => _$OccurrenceEventCopyWithImpl<OccurrenceEvent>(this as OccurrenceEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OccurrenceEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OccurrenceEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.occurrenceId, _this.occurrenceId) || other.occurrenceId == _this.occurrenceId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&const DeepCollectionEquality().equals(other.data, _this.data));
}


@override
int get hashCode {
  final _this = this as OccurrenceEvent;
  return Object.hash(runtimeType,_this.id,_this.occurrenceId,_this.type,_this.occurredAt,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as OccurrenceEvent;
  return 'OccurrenceEvent(id: ${_this.id}, occurrenceId: ${_this.occurrenceId}, type: ${_this.type}, occurredAt: ${_this.occurredAt}, data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $OccurrenceEventCopyWith<$Res>  {
  factory $OccurrenceEventCopyWith(OccurrenceEvent value, $Res Function(OccurrenceEvent) _then) = _$OccurrenceEventCopyWithImpl;
@useResult
$Res call({
 String id, String occurrenceId, OccurrenceTransition type, DateTime occurredAt, Map<String, Object?> data
});




}
/// @nodoc
class _$OccurrenceEventCopyWithImpl<$Res>
    implements $OccurrenceEventCopyWith<$Res> {
  _$OccurrenceEventCopyWithImpl(this._self, this._then);

  final OccurrenceEvent _self;
  final $Res Function(OccurrenceEvent) _then;

/// Create a copy of OccurrenceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? occurrenceId = null,Object? type = null,Object? occurredAt = null,Object? data = null,}) {
  return _then(OccurrenceEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OccurrenceTransition,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [OccurrenceEvent].
extension OccurrenceEventPatterns on OccurrenceEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OccurrenceEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OccurrenceEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OccurrenceEvent value)  $default,){
final _that = this;
switch (_that) {
case _OccurrenceEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OccurrenceEvent value)?  $default,){
final _that = this;
switch (_that) {
case _OccurrenceEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String occurrenceId,  OccurrenceTransition type,  DateTime occurredAt,  Map<String, Object?> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OccurrenceEvent() when $default != null:
return $default(_that.id,_that.occurrenceId,_that.type,_that.occurredAt,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String occurrenceId,  OccurrenceTransition type,  DateTime occurredAt,  Map<String, Object?> data)  $default,) {final _that = this;
switch (_that) {
case _OccurrenceEvent():
return $default(_that.id,_that.occurrenceId,_that.type,_that.occurredAt,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String occurrenceId,  OccurrenceTransition type,  DateTime occurredAt,  Map<String, Object?> data)?  $default,) {final _that = this;
switch (_that) {
case _OccurrenceEvent() when $default != null:
return $default(_that.id,_that.occurrenceId,_that.type,_that.occurredAt,_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _OccurrenceEvent implements OccurrenceEvent {
  const _OccurrenceEvent({required this.id, required this.occurrenceId, required this.type, required this.occurredAt,  Map<String, Object?> data = const <String, Object?>{}}): _data = data;
  

@override final  String id;
@override final  String occurrenceId;
@override final  OccurrenceTransition type;
@override final  DateTime occurredAt;
/// Type-specific details with string/number values, e.g.
/// `{'from_date': '2026-10-06', 'to_date': '2026-10-07'}`.
 final  Map<String, Object?> _data;
/// Type-specific details with string/number values, e.g.
/// `{'from_date': '2026-10-06', 'to_date': '2026-10-07'}`.
@override@JsonKey() Map<String, Object?> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


/// Create a copy of OccurrenceEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OccurrenceEventCopyWith<_OccurrenceEvent> get copyWith => __$OccurrenceEventCopyWithImpl<_OccurrenceEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OccurrenceEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.type, type) || other.type == type)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&const DeepCollectionEquality().equals(other.data, _data));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,occurrenceId,type,occurredAt,const DeepCollectionEquality().hash(_data));
}

@override
String toString() {
    return 'OccurrenceEvent(id: $id, occurrenceId: $occurrenceId, type: $type, occurredAt: $occurredAt, data: $data)';
}


}

/// @nodoc
abstract mixin class _$OccurrenceEventCopyWith<$Res> implements $OccurrenceEventCopyWith<$Res> {
  factory _$OccurrenceEventCopyWith(_OccurrenceEvent value, $Res Function(_OccurrenceEvent) _then) = __$OccurrenceEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String occurrenceId, OccurrenceTransition type, DateTime occurredAt, Map<String, Object?> data
});




}
/// @nodoc
class __$OccurrenceEventCopyWithImpl<$Res>
    implements _$OccurrenceEventCopyWith<$Res> {
  __$OccurrenceEventCopyWithImpl(this._self, this._then);

  final _OccurrenceEvent _self;
  final $Res Function(_OccurrenceEvent) _then;

/// Create a copy of OccurrenceEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? occurrenceId = null,Object? type = null,Object? occurredAt = null,Object? data = null,}) {
  return _then(_OccurrenceEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OccurrenceTransition,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

// dart format on
