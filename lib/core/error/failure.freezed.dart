// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Failure()';
}


}

/// @nodoc
class $FailureCopyWith<$Res>  {
$FailureCopyWith(Failure _, $Res Function(Failure) __);
}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkFailure value)?  network,TResult Function( UnauthenticatedFailure value)?  unauthenticated,TResult Function( InvalidCredentialsFailure value)?  invalidCredentials,TResult Function( CancelledFailure value)?  cancelled,TResult Function( ForbiddenFailure value)?  forbidden,TResult Function( ValidationFailure value)?  validation,TResult Function( NotFoundFailure value)?  notFound,TResult Function( ConflictFailure value)?  conflict,TResult Function( ServerFailure value)?  server,TResult Function( DatabaseFailure value)?  database,TResult Function( PermissionDeniedFailure value)?  permissionDenied,TResult Function( EntitlementRequiredFailure value)?  entitlementRequired,TResult Function( LimitReachedFailure value)?  limitReached,TResult Function( UnexpectedFailure value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case UnauthenticatedFailure() when unauthenticated != null:
return unauthenticated(_that);case InvalidCredentialsFailure() when invalidCredentials != null:
return invalidCredentials(_that);case CancelledFailure() when cancelled != null:
return cancelled(_that);case ForbiddenFailure() when forbidden != null:
return forbidden(_that);case ValidationFailure() when validation != null:
return validation(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case ConflictFailure() when conflict != null:
return conflict(_that);case ServerFailure() when server != null:
return server(_that);case DatabaseFailure() when database != null:
return database(_that);case PermissionDeniedFailure() when permissionDenied != null:
return permissionDenied(_that);case EntitlementRequiredFailure() when entitlementRequired != null:
return entitlementRequired(_that);case LimitReachedFailure() when limitReached != null:
return limitReached(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkFailure value)  network,required TResult Function( UnauthenticatedFailure value)  unauthenticated,required TResult Function( InvalidCredentialsFailure value)  invalidCredentials,required TResult Function( CancelledFailure value)  cancelled,required TResult Function( ForbiddenFailure value)  forbidden,required TResult Function( ValidationFailure value)  validation,required TResult Function( NotFoundFailure value)  notFound,required TResult Function( ConflictFailure value)  conflict,required TResult Function( ServerFailure value)  server,required TResult Function( DatabaseFailure value)  database,required TResult Function( PermissionDeniedFailure value)  permissionDenied,required TResult Function( EntitlementRequiredFailure value)  entitlementRequired,required TResult Function( LimitReachedFailure value)  limitReached,required TResult Function( UnexpectedFailure value)  unexpected,}){
final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that);case UnauthenticatedFailure():
return unauthenticated(_that);case InvalidCredentialsFailure():
return invalidCredentials(_that);case CancelledFailure():
return cancelled(_that);case ForbiddenFailure():
return forbidden(_that);case ValidationFailure():
return validation(_that);case NotFoundFailure():
return notFound(_that);case ConflictFailure():
return conflict(_that);case ServerFailure():
return server(_that);case DatabaseFailure():
return database(_that);case PermissionDeniedFailure():
return permissionDenied(_that);case EntitlementRequiredFailure():
return entitlementRequired(_that);case LimitReachedFailure():
return limitReached(_that);case UnexpectedFailure():
return unexpected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkFailure value)?  network,TResult? Function( UnauthenticatedFailure value)?  unauthenticated,TResult? Function( InvalidCredentialsFailure value)?  invalidCredentials,TResult? Function( CancelledFailure value)?  cancelled,TResult? Function( ForbiddenFailure value)?  forbidden,TResult? Function( ValidationFailure value)?  validation,TResult? Function( NotFoundFailure value)?  notFound,TResult? Function( ConflictFailure value)?  conflict,TResult? Function( ServerFailure value)?  server,TResult? Function( DatabaseFailure value)?  database,TResult? Function( PermissionDeniedFailure value)?  permissionDenied,TResult? Function( EntitlementRequiredFailure value)?  entitlementRequired,TResult? Function( LimitReachedFailure value)?  limitReached,TResult? Function( UnexpectedFailure value)?  unexpected,}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case UnauthenticatedFailure() when unauthenticated != null:
return unauthenticated(_that);case InvalidCredentialsFailure() when invalidCredentials != null:
return invalidCredentials(_that);case CancelledFailure() when cancelled != null:
return cancelled(_that);case ForbiddenFailure() when forbidden != null:
return forbidden(_that);case ValidationFailure() when validation != null:
return validation(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case ConflictFailure() when conflict != null:
return conflict(_that);case ServerFailure() when server != null:
return server(_that);case DatabaseFailure() when database != null:
return database(_that);case PermissionDeniedFailure() when permissionDenied != null:
return permissionDenied(_that);case EntitlementRequiredFailure() when entitlementRequired != null:
return entitlementRequired(_that);case LimitReachedFailure() when limitReached != null:
return limitReached(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  network,TResult Function()?  unauthenticated,TResult Function()?  invalidCredentials,TResult Function()?  cancelled,TResult Function()?  forbidden,TResult Function( Map<String, String> fieldErrors,  String? message)?  validation,TResult Function( String? entity)?  notFound,TResult Function( String code,  String? message)?  conflict,TResult Function( int? statusCode,  String? code,  String? requestId)?  server,TResult Function( String? message)?  database,TResult Function( AppPermission permission,  bool permanently)?  permissionDenied,TResult Function( Feature feature)?  entitlementRequired,TResult Function( LimitKey limit,  int? allowed)?  limitReached,TResult Function( Object? cause,  StackTrace? stackTrace)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network();case UnauthenticatedFailure() when unauthenticated != null:
return unauthenticated();case InvalidCredentialsFailure() when invalidCredentials != null:
return invalidCredentials();case CancelledFailure() when cancelled != null:
return cancelled();case ForbiddenFailure() when forbidden != null:
return forbidden();case ValidationFailure() when validation != null:
return validation(_that.fieldErrors,_that.message);case NotFoundFailure() when notFound != null:
return notFound(_that.entity);case ConflictFailure() when conflict != null:
return conflict(_that.code,_that.message);case ServerFailure() when server != null:
return server(_that.statusCode,_that.code,_that.requestId);case DatabaseFailure() when database != null:
return database(_that.message);case PermissionDeniedFailure() when permissionDenied != null:
return permissionDenied(_that.permission,_that.permanently);case EntitlementRequiredFailure() when entitlementRequired != null:
return entitlementRequired(_that.feature);case LimitReachedFailure() when limitReached != null:
return limitReached(_that.limit,_that.allowed);case UnexpectedFailure() when unexpected != null:
return unexpected(_that.cause,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  network,required TResult Function()  unauthenticated,required TResult Function()  invalidCredentials,required TResult Function()  cancelled,required TResult Function()  forbidden,required TResult Function( Map<String, String> fieldErrors,  String? message)  validation,required TResult Function( String? entity)  notFound,required TResult Function( String code,  String? message)  conflict,required TResult Function( int? statusCode,  String? code,  String? requestId)  server,required TResult Function( String? message)  database,required TResult Function( AppPermission permission,  bool permanently)  permissionDenied,required TResult Function( Feature feature)  entitlementRequired,required TResult Function( LimitKey limit,  int? allowed)  limitReached,required TResult Function( Object? cause,  StackTrace? stackTrace)  unexpected,}) {final _that = this;
switch (_that) {
case NetworkFailure():
return network();case UnauthenticatedFailure():
return unauthenticated();case InvalidCredentialsFailure():
return invalidCredentials();case CancelledFailure():
return cancelled();case ForbiddenFailure():
return forbidden();case ValidationFailure():
return validation(_that.fieldErrors,_that.message);case NotFoundFailure():
return notFound(_that.entity);case ConflictFailure():
return conflict(_that.code,_that.message);case ServerFailure():
return server(_that.statusCode,_that.code,_that.requestId);case DatabaseFailure():
return database(_that.message);case PermissionDeniedFailure():
return permissionDenied(_that.permission,_that.permanently);case EntitlementRequiredFailure():
return entitlementRequired(_that.feature);case LimitReachedFailure():
return limitReached(_that.limit,_that.allowed);case UnexpectedFailure():
return unexpected(_that.cause,_that.stackTrace);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  network,TResult? Function()?  unauthenticated,TResult? Function()?  invalidCredentials,TResult? Function()?  cancelled,TResult? Function()?  forbidden,TResult? Function( Map<String, String> fieldErrors,  String? message)?  validation,TResult? Function( String? entity)?  notFound,TResult? Function( String code,  String? message)?  conflict,TResult? Function( int? statusCode,  String? code,  String? requestId)?  server,TResult? Function( String? message)?  database,TResult? Function( AppPermission permission,  bool permanently)?  permissionDenied,TResult? Function( Feature feature)?  entitlementRequired,TResult? Function( LimitKey limit,  int? allowed)?  limitReached,TResult? Function( Object? cause,  StackTrace? stackTrace)?  unexpected,}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network();case UnauthenticatedFailure() when unauthenticated != null:
return unauthenticated();case InvalidCredentialsFailure() when invalidCredentials != null:
return invalidCredentials();case CancelledFailure() when cancelled != null:
return cancelled();case ForbiddenFailure() when forbidden != null:
return forbidden();case ValidationFailure() when validation != null:
return validation(_that.fieldErrors,_that.message);case NotFoundFailure() when notFound != null:
return notFound(_that.entity);case ConflictFailure() when conflict != null:
return conflict(_that.code,_that.message);case ServerFailure() when server != null:
return server(_that.statusCode,_that.code,_that.requestId);case DatabaseFailure() when database != null:
return database(_that.message);case PermissionDeniedFailure() when permissionDenied != null:
return permissionDenied(_that.permission,_that.permanently);case EntitlementRequiredFailure() when entitlementRequired != null:
return entitlementRequired(_that.feature);case LimitReachedFailure() when limitReached != null:
return limitReached(_that.limit,_that.allowed);case UnexpectedFailure() when unexpected != null:
return unexpected(_that.cause,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class NetworkFailure implements Failure {
  const NetworkFailure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Failure.network()';
}


}




/// @nodoc


class UnauthenticatedFailure implements Failure {
  const UnauthenticatedFailure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnauthenticatedFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Failure.unauthenticated()';
}


}




/// @nodoc


class InvalidCredentialsFailure implements Failure {
  const InvalidCredentialsFailure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidCredentialsFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Failure.invalidCredentials()';
}


}




/// @nodoc


class CancelledFailure implements Failure {
  const CancelledFailure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelledFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Failure.cancelled()';
}


}




/// @nodoc


class ForbiddenFailure implements Failure {
  const ForbiddenFailure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ForbiddenFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Failure.forbidden()';
}


}




/// @nodoc


class ValidationFailure implements Failure {
  const ValidationFailure({ Map<String, String> fieldErrors = const <String, String>{}, this.message}): _fieldErrors = fieldErrors;
  

 final  Map<String, String> _fieldErrors;
@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}

 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationFailureCopyWith<ValidationFailure> get copyWith => _$ValidationFailureCopyWithImpl<ValidationFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationFailure&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_fieldErrors),message);
}

@override
String toString() {
    return 'Failure.validation(fieldErrors: $fieldErrors, message: $message)';
}


}

/// @nodoc
abstract mixin class $ValidationFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ValidationFailureCopyWith(ValidationFailure value, $Res Function(ValidationFailure) _then) = _$ValidationFailureCopyWithImpl;
@useResult
$Res call({
 Map<String, String> fieldErrors, String? message
});




}
/// @nodoc
class _$ValidationFailureCopyWithImpl<$Res>
    implements $ValidationFailureCopyWith<$Res> {
  _$ValidationFailureCopyWithImpl(this._self, this._then);

  final ValidationFailure _self;
  final $Res Function(ValidationFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fieldErrors = null,Object? message = freezed,}) {
  return _then(ValidationFailure(
fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class NotFoundFailure implements Failure {
  const NotFoundFailure({this.entity});
  

 final  String? entity;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundFailureCopyWith<NotFoundFailure> get copyWith => _$NotFoundFailureCopyWithImpl<NotFoundFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundFailure&&(identical(other.entity, entity) || other.entity == entity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entity);
}

@override
String toString() {
    return 'Failure.notFound(entity: $entity)';
}


}

/// @nodoc
abstract mixin class $NotFoundFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NotFoundFailureCopyWith(NotFoundFailure value, $Res Function(NotFoundFailure) _then) = _$NotFoundFailureCopyWithImpl;
@useResult
$Res call({
 String? entity
});




}
/// @nodoc
class _$NotFoundFailureCopyWithImpl<$Res>
    implements $NotFoundFailureCopyWith<$Res> {
  _$NotFoundFailureCopyWithImpl(this._self, this._then);

  final NotFoundFailure _self;
  final $Res Function(NotFoundFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entity = freezed,}) {
  return _then(NotFoundFailure(
entity: freezed == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ConflictFailure implements Failure {
  const ConflictFailure({required this.code, this.message});
  

 final  String code;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictFailureCopyWith<ConflictFailure> get copyWith => _$ConflictFailureCopyWithImpl<ConflictFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConflictFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,message);
}

@override
String toString() {
    return 'Failure.conflict(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $ConflictFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ConflictFailureCopyWith(ConflictFailure value, $Res Function(ConflictFailure) _then) = _$ConflictFailureCopyWithImpl;
@useResult
$Res call({
 String code, String? message
});




}
/// @nodoc
class _$ConflictFailureCopyWithImpl<$Res>
    implements $ConflictFailureCopyWith<$Res> {
  _$ConflictFailureCopyWithImpl(this._self, this._then);

  final ConflictFailure _self;
  final $Res Function(ConflictFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = freezed,}) {
  return _then(ConflictFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ServerFailure implements Failure {
  const ServerFailure({this.statusCode, this.code, this.requestId});
  

 final  int? statusCode;
 final  String? code;
 final  String? requestId;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerFailureCopyWith<ServerFailure> get copyWith => _$ServerFailureCopyWithImpl<ServerFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFailure&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.code, code) || other.code == code)&&(identical(other.requestId, requestId) || other.requestId == requestId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,statusCode,code,requestId);
}

@override
String toString() {
    return 'Failure.server(statusCode: $statusCode, code: $code, requestId: $requestId)';
}


}

/// @nodoc
abstract mixin class $ServerFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ServerFailureCopyWith(ServerFailure value, $Res Function(ServerFailure) _then) = _$ServerFailureCopyWithImpl;
@useResult
$Res call({
 int? statusCode, String? code, String? requestId
});




}
/// @nodoc
class _$ServerFailureCopyWithImpl<$Res>
    implements $ServerFailureCopyWith<$Res> {
  _$ServerFailureCopyWithImpl(this._self, this._then);

  final ServerFailure _self;
  final $Res Function(ServerFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statusCode = freezed,Object? code = freezed,Object? requestId = freezed,}) {
  return _then(ServerFailure(
statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class DatabaseFailure implements Failure {
  const DatabaseFailure({this.message});
  

 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DatabaseFailureCopyWith<DatabaseFailure> get copyWith => _$DatabaseFailureCopyWithImpl<DatabaseFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DatabaseFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'Failure.database(message: $message)';
}


}

/// @nodoc
abstract mixin class $DatabaseFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $DatabaseFailureCopyWith(DatabaseFailure value, $Res Function(DatabaseFailure) _then) = _$DatabaseFailureCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$DatabaseFailureCopyWithImpl<$Res>
    implements $DatabaseFailureCopyWith<$Res> {
  _$DatabaseFailureCopyWithImpl(this._self, this._then);

  final DatabaseFailure _self;
  final $Res Function(DatabaseFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(DatabaseFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class PermissionDeniedFailure implements Failure {
  const PermissionDeniedFailure({required this.permission, this.permanently = false});
  

 final  AppPermission permission;
@JsonKey() final  bool permanently;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermissionDeniedFailureCopyWith<PermissionDeniedFailure> get copyWith => _$PermissionDeniedFailureCopyWithImpl<PermissionDeniedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionDeniedFailure&&(identical(other.permission, permission) || other.permission == permission)&&(identical(other.permanently, permanently) || other.permanently == permanently));
}


@override
int get hashCode {
    return Object.hash(runtimeType,permission,permanently);
}

@override
String toString() {
    return 'Failure.permissionDenied(permission: $permission, permanently: $permanently)';
}


}

/// @nodoc
abstract mixin class $PermissionDeniedFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $PermissionDeniedFailureCopyWith(PermissionDeniedFailure value, $Res Function(PermissionDeniedFailure) _then) = _$PermissionDeniedFailureCopyWithImpl;
@useResult
$Res call({
 AppPermission permission, bool permanently
});




}
/// @nodoc
class _$PermissionDeniedFailureCopyWithImpl<$Res>
    implements $PermissionDeniedFailureCopyWith<$Res> {
  _$PermissionDeniedFailureCopyWithImpl(this._self, this._then);

  final PermissionDeniedFailure _self;
  final $Res Function(PermissionDeniedFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? permission = null,Object? permanently = null,}) {
  return _then(PermissionDeniedFailure(
permission: null == permission ? _self.permission : permission // ignore: cast_nullable_to_non_nullable
as AppPermission,permanently: null == permanently ? _self.permanently : permanently // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class EntitlementRequiredFailure implements Failure {
  const EntitlementRequiredFailure({required this.feature});
  

 final  Feature feature;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementRequiredFailureCopyWith<EntitlementRequiredFailure> get copyWith => _$EntitlementRequiredFailureCopyWithImpl<EntitlementRequiredFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntitlementRequiredFailure&&(identical(other.feature, feature) || other.feature == feature));
}


@override
int get hashCode {
    return Object.hash(runtimeType,feature);
}

@override
String toString() {
    return 'Failure.entitlementRequired(feature: $feature)';
}


}

/// @nodoc
abstract mixin class $EntitlementRequiredFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $EntitlementRequiredFailureCopyWith(EntitlementRequiredFailure value, $Res Function(EntitlementRequiredFailure) _then) = _$EntitlementRequiredFailureCopyWithImpl;
@useResult
$Res call({
 Feature feature
});




}
/// @nodoc
class _$EntitlementRequiredFailureCopyWithImpl<$Res>
    implements $EntitlementRequiredFailureCopyWith<$Res> {
  _$EntitlementRequiredFailureCopyWithImpl(this._self, this._then);

  final EntitlementRequiredFailure _self;
  final $Res Function(EntitlementRequiredFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? feature = null,}) {
  return _then(EntitlementRequiredFailure(
feature: null == feature ? _self.feature : feature // ignore: cast_nullable_to_non_nullable
as Feature,
  ));
}


}

/// @nodoc


class LimitReachedFailure implements Failure {
  const LimitReachedFailure({required this.limit, this.allowed});
  

 final  LimitKey limit;
 final  int? allowed;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LimitReachedFailureCopyWith<LimitReachedFailure> get copyWith => _$LimitReachedFailureCopyWithImpl<LimitReachedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LimitReachedFailure&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.allowed, allowed) || other.allowed == allowed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,limit,allowed);
}

@override
String toString() {
    return 'Failure.limitReached(limit: $limit, allowed: $allowed)';
}


}

/// @nodoc
abstract mixin class $LimitReachedFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $LimitReachedFailureCopyWith(LimitReachedFailure value, $Res Function(LimitReachedFailure) _then) = _$LimitReachedFailureCopyWithImpl;
@useResult
$Res call({
 LimitKey limit, int? allowed
});




}
/// @nodoc
class _$LimitReachedFailureCopyWithImpl<$Res>
    implements $LimitReachedFailureCopyWith<$Res> {
  _$LimitReachedFailureCopyWithImpl(this._self, this._then);

  final LimitReachedFailure _self;
  final $Res Function(LimitReachedFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? limit = null,Object? allowed = freezed,}) {
  return _then(LimitReachedFailure(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as LimitKey,allowed: freezed == allowed ? _self.allowed : allowed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class UnexpectedFailure implements Failure {
  const UnexpectedFailure({this.cause, this.stackTrace});
  

 final  Object? cause;
 final  StackTrace? stackTrace;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedFailureCopyWith<UnexpectedFailure> get copyWith => _$UnexpectedFailureCopyWithImpl<UnexpectedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedFailure&&const DeepCollectionEquality().equals(other.cause, cause)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(cause),stackTrace);
}

@override
String toString() {
    return 'Failure.unexpected(cause: $cause, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $UnexpectedFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $UnexpectedFailureCopyWith(UnexpectedFailure value, $Res Function(UnexpectedFailure) _then) = _$UnexpectedFailureCopyWithImpl;
@useResult
$Res call({
 Object? cause, StackTrace? stackTrace
});




}
/// @nodoc
class _$UnexpectedFailureCopyWithImpl<$Res>
    implements $UnexpectedFailureCopyWith<$Res> {
  _$UnexpectedFailureCopyWithImpl(this._self, this._then);

  final UnexpectedFailure _self;
  final $Res Function(UnexpectedFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cause = freezed,Object? stackTrace = freezed,}) {
  return _then(UnexpectedFailure(
cause: freezed == cause ? _self.cause : cause ,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
