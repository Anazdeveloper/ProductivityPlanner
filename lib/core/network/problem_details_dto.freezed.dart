// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'problem_details_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProblemDetailsDto {

 String? get type; String? get title; int? get status; String? get detail; String? get code; String? get requestId; List<ProblemFieldErrorDto> get errors; String? get feature; String? get limit; int? get allowed;
/// Create a copy of ProblemDetailsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProblemDetailsDtoCopyWith<ProblemDetailsDto> get copyWith => _$ProblemDetailsDtoCopyWithImpl<ProblemDetailsDto>(this as ProblemDetailsDto, _$identity);

  /// Serializes this ProblemDetailsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProblemDetailsDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProblemDetailsDto&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&(identical(other.feature, _this.feature) || other.feature == _this.feature)&&(identical(other.limit, _this.limit) || other.limit == _this.limit)&&(identical(other.allowed, _this.allowed) || other.allowed == _this.allowed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProblemDetailsDto;
  return Object.hash(runtimeType,_this.type,_this.title,_this.status,_this.detail,_this.code,_this.requestId,const DeepCollectionEquality().hash(_this.errors),_this.feature,_this.limit,_this.allowed);
}

@override
String toString() {
  final _this = this as ProblemDetailsDto;
  return 'ProblemDetailsDto(type: ${_this.type}, title: ${_this.title}, status: ${_this.status}, detail: ${_this.detail}, code: ${_this.code}, requestId: ${_this.requestId}, errors: ${_this.errors}, feature: ${_this.feature}, limit: ${_this.limit}, allowed: ${_this.allowed})';
}


}

/// @nodoc
abstract mixin class $ProblemDetailsDtoCopyWith<$Res>  {
  factory $ProblemDetailsDtoCopyWith(ProblemDetailsDto value, $Res Function(ProblemDetailsDto) _then) = _$ProblemDetailsDtoCopyWithImpl;
@useResult
$Res call({
 String? type, String? title, int? status, String? detail, String? code, String? requestId, List<ProblemFieldErrorDto> errors, String? feature, String? limit, int? allowed
});




}
/// @nodoc
class _$ProblemDetailsDtoCopyWithImpl<$Res>
    implements $ProblemDetailsDtoCopyWith<$Res> {
  _$ProblemDetailsDtoCopyWithImpl(this._self, this._then);

  final ProblemDetailsDto _self;
  final $Res Function(ProblemDetailsDto) _then;

/// Create a copy of ProblemDetailsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? title = freezed,Object? status = freezed,Object? detail = freezed,Object? code = freezed,Object? requestId = freezed,Object? errors = null,Object? feature = freezed,Object? limit = freezed,Object? allowed = freezed,}) {
  return _then(ProblemDetailsDto(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<ProblemFieldErrorDto>,feature: freezed == feature ? _self.feature : feature // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as String?,allowed: freezed == allowed ? _self.allowed : allowed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProblemDetailsDto].
extension ProblemDetailsDtoPatterns on ProblemDetailsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProblemDetailsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProblemDetailsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProblemDetailsDto value)  $default,){
final _that = this;
switch (_that) {
case _ProblemDetailsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProblemDetailsDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProblemDetailsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  String? title,  int? status,  String? detail,  String? code,  String? requestId,  List<ProblemFieldErrorDto> errors,  String? feature,  String? limit,  int? allowed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProblemDetailsDto() when $default != null:
return $default(_that.type,_that.title,_that.status,_that.detail,_that.code,_that.requestId,_that.errors,_that.feature,_that.limit,_that.allowed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  String? title,  int? status,  String? detail,  String? code,  String? requestId,  List<ProblemFieldErrorDto> errors,  String? feature,  String? limit,  int? allowed)  $default,) {final _that = this;
switch (_that) {
case _ProblemDetailsDto():
return $default(_that.type,_that.title,_that.status,_that.detail,_that.code,_that.requestId,_that.errors,_that.feature,_that.limit,_that.allowed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  String? title,  int? status,  String? detail,  String? code,  String? requestId,  List<ProblemFieldErrorDto> errors,  String? feature,  String? limit,  int? allowed)?  $default,) {final _that = this;
switch (_that) {
case _ProblemDetailsDto() when $default != null:
return $default(_that.type,_that.title,_that.status,_that.detail,_that.code,_that.requestId,_that.errors,_that.feature,_that.limit,_that.allowed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProblemDetailsDto implements ProblemDetailsDto {
  const _ProblemDetailsDto({this.type, this.title, this.status, this.detail, this.code, this.requestId,  List<ProblemFieldErrorDto> errors = const <ProblemFieldErrorDto>[], this.feature, this.limit, this.allowed}): _errors = errors;
  factory _ProblemDetailsDto.fromJson(Map<String, dynamic> json) => _$ProblemDetailsDtoFromJson(json);

@override final  String? type;
@override final  String? title;
@override final  int? status;
@override final  String? detail;
@override final  String? code;
@override final  String? requestId;
 final  List<ProblemFieldErrorDto> _errors;
@override@JsonKey() List<ProblemFieldErrorDto> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}

@override final  String? feature;
@override final  String? limit;
@override final  int? allowed;

/// Create a copy of ProblemDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProblemDetailsDtoCopyWith<_ProblemDetailsDto> get copyWith => __$ProblemDetailsDtoCopyWithImpl<_ProblemDetailsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProblemDetailsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProblemDetailsDto&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.code, code) || other.code == code)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&const DeepCollectionEquality().equals(other.errors, _errors)&&(identical(other.feature, feature) || other.feature == feature)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.allowed, allowed) || other.allowed == allowed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,title,status,detail,code,requestId,const DeepCollectionEquality().hash(_errors),feature,limit,allowed);
}

@override
String toString() {
    return 'ProblemDetailsDto(type: $type, title: $title, status: $status, detail: $detail, code: $code, requestId: $requestId, errors: $errors, feature: $feature, limit: $limit, allowed: $allowed)';
}


}

/// @nodoc
abstract mixin class _$ProblemDetailsDtoCopyWith<$Res> implements $ProblemDetailsDtoCopyWith<$Res> {
  factory _$ProblemDetailsDtoCopyWith(_ProblemDetailsDto value, $Res Function(_ProblemDetailsDto) _then) = __$ProblemDetailsDtoCopyWithImpl;
@override @useResult
$Res call({
 String? type, String? title, int? status, String? detail, String? code, String? requestId, List<ProblemFieldErrorDto> errors, String? feature, String? limit, int? allowed
});




}
/// @nodoc
class __$ProblemDetailsDtoCopyWithImpl<$Res>
    implements _$ProblemDetailsDtoCopyWith<$Res> {
  __$ProblemDetailsDtoCopyWithImpl(this._self, this._then);

  final _ProblemDetailsDto _self;
  final $Res Function(_ProblemDetailsDto) _then;

/// Create a copy of ProblemDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? title = freezed,Object? status = freezed,Object? detail = freezed,Object? code = freezed,Object? requestId = freezed,Object? errors = null,Object? feature = freezed,Object? limit = freezed,Object? allowed = freezed,}) {
  return _then(_ProblemDetailsDto(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<ProblemFieldErrorDto>,feature: freezed == feature ? _self.feature : feature // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as String?,allowed: freezed == allowed ? _self.allowed : allowed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ProblemFieldErrorDto {

 String get field; String get message;
/// Create a copy of ProblemFieldErrorDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProblemFieldErrorDtoCopyWith<ProblemFieldErrorDto> get copyWith => _$ProblemFieldErrorDtoCopyWithImpl<ProblemFieldErrorDto>(this as ProblemFieldErrorDto, _$identity);

  /// Serializes this ProblemFieldErrorDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProblemFieldErrorDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProblemFieldErrorDto&&(identical(other.field, _this.field) || other.field == _this.field)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProblemFieldErrorDto;
  return Object.hash(runtimeType,_this.field,_this.message);
}

@override
String toString() {
  final _this = this as ProblemFieldErrorDto;
  return 'ProblemFieldErrorDto(field: ${_this.field}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ProblemFieldErrorDtoCopyWith<$Res>  {
  factory $ProblemFieldErrorDtoCopyWith(ProblemFieldErrorDto value, $Res Function(ProblemFieldErrorDto) _then) = _$ProblemFieldErrorDtoCopyWithImpl;
@useResult
$Res call({
 String field, String message
});




}
/// @nodoc
class _$ProblemFieldErrorDtoCopyWithImpl<$Res>
    implements $ProblemFieldErrorDtoCopyWith<$Res> {
  _$ProblemFieldErrorDtoCopyWithImpl(this._self, this._then);

  final ProblemFieldErrorDto _self;
  final $Res Function(ProblemFieldErrorDto) _then;

/// Create a copy of ProblemFieldErrorDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field = null,Object? message = null,}) {
  return _then(ProblemFieldErrorDto(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProblemFieldErrorDto].
extension ProblemFieldErrorDtoPatterns on ProblemFieldErrorDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProblemFieldErrorDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProblemFieldErrorDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProblemFieldErrorDto value)  $default,){
final _that = this;
switch (_that) {
case _ProblemFieldErrorDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProblemFieldErrorDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProblemFieldErrorDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String field,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProblemFieldErrorDto() when $default != null:
return $default(_that.field,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String field,  String message)  $default,) {final _that = this;
switch (_that) {
case _ProblemFieldErrorDto():
return $default(_that.field,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String field,  String message)?  $default,) {final _that = this;
switch (_that) {
case _ProblemFieldErrorDto() when $default != null:
return $default(_that.field,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProblemFieldErrorDto implements ProblemFieldErrorDto {
  const _ProblemFieldErrorDto({required this.field, required this.message});
  factory _ProblemFieldErrorDto.fromJson(Map<String, dynamic> json) => _$ProblemFieldErrorDtoFromJson(json);

@override final  String field;
@override final  String message;

/// Create a copy of ProblemFieldErrorDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProblemFieldErrorDtoCopyWith<_ProblemFieldErrorDto> get copyWith => __$ProblemFieldErrorDtoCopyWithImpl<_ProblemFieldErrorDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProblemFieldErrorDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProblemFieldErrorDto&&(identical(other.field, field) || other.field == field)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,field,message);
}

@override
String toString() {
    return 'ProblemFieldErrorDto(field: $field, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ProblemFieldErrorDtoCopyWith<$Res> implements $ProblemFieldErrorDtoCopyWith<$Res> {
  factory _$ProblemFieldErrorDtoCopyWith(_ProblemFieldErrorDto value, $Res Function(_ProblemFieldErrorDto) _then) = __$ProblemFieldErrorDtoCopyWithImpl;
@override @useResult
$Res call({
 String field, String message
});




}
/// @nodoc
class __$ProblemFieldErrorDtoCopyWithImpl<$Res>
    implements _$ProblemFieldErrorDtoCopyWith<$Res> {
  __$ProblemFieldErrorDtoCopyWithImpl(this._self, this._then);

  final _ProblemFieldErrorDto _self;
  final $Res Function(_ProblemFieldErrorDto) _then;

/// Create a copy of ProblemFieldErrorDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? message = null,}) {
  return _then(_ProblemFieldErrorDto(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
