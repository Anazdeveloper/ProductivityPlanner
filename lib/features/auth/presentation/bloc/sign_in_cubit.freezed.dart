// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_in_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignInState {

 String get email; String get password;/// Field errors appear only after the first submit, not while typing.
 bool get showValidation; SignInMethod? get inProgress; Failure? get failure; bool get appleAvailable; bool get googleAvailable;/// The previous session was ended by the server, not by the user.
 bool get sessionExpired;
/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInStateCopyWith<SignInState> get copyWith => _$SignInStateCopyWithImpl<SignInState>(this as SignInState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SignInState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInState&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.showValidation, _this.showValidation) || other.showValidation == _this.showValidation)&&(identical(other.inProgress, _this.inProgress) || other.inProgress == _this.inProgress)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.appleAvailable, _this.appleAvailable) || other.appleAvailable == _this.appleAvailable)&&(identical(other.googleAvailable, _this.googleAvailable) || other.googleAvailable == _this.googleAvailable)&&(identical(other.sessionExpired, _this.sessionExpired) || other.sessionExpired == _this.sessionExpired));
}


@override
int get hashCode {
  final _this = this as SignInState;
  return Object.hash(runtimeType,_this.email,_this.password,_this.showValidation,_this.inProgress,_this.failure,_this.appleAvailable,_this.googleAvailable,_this.sessionExpired);
}

@override
String toString() {
  final _this = this as SignInState;
  return 'SignInState(email: ${_this.email}, password: ${_this.password}, showValidation: ${_this.showValidation}, inProgress: ${_this.inProgress}, failure: ${_this.failure}, appleAvailable: ${_this.appleAvailable}, googleAvailable: ${_this.googleAvailable}, sessionExpired: ${_this.sessionExpired})';
}


}

/// @nodoc
abstract mixin class $SignInStateCopyWith<$Res>  {
  factory $SignInStateCopyWith(SignInState value, $Res Function(SignInState) _then) = _$SignInStateCopyWithImpl;
@useResult
$Res call({
 String email, String password, bool showValidation, SignInMethod? inProgress, Failure? failure, bool appleAvailable, bool googleAvailable, bool sessionExpired
});


$FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$SignInStateCopyWithImpl<$Res>
    implements $SignInStateCopyWith<$Res> {
  _$SignInStateCopyWithImpl(this._self, this._then);

  final SignInState _self;
  final $Res Function(SignInState) _then;

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? showValidation = null,Object? inProgress = freezed,Object? failure = freezed,Object? appleAvailable = null,Object? googleAvailable = null,Object? sessionExpired = null,}) {
  return _then(SignInState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,showValidation: null == showValidation ? _self.showValidation : showValidation // ignore: cast_nullable_to_non_nullable
as bool,inProgress: freezed == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as SignInMethod?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,appleAvailable: null == appleAvailable ? _self.appleAvailable : appleAvailable // ignore: cast_nullable_to_non_nullable
as bool,googleAvailable: null == googleAvailable ? _self.googleAvailable : googleAvailable // ignore: cast_nullable_to_non_nullable
as bool,sessionExpired: null == sessionExpired ? _self.sessionExpired : sessionExpired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}


/// Adds pattern-matching-related methods to [SignInState].
extension SignInStatePatterns on SignInState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignInState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignInState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignInState value)  $default,){
final _that = this;
switch (_that) {
case _SignInState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignInState value)?  $default,){
final _that = this;
switch (_that) {
case _SignInState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  bool showValidation,  SignInMethod? inProgress,  Failure? failure,  bool appleAvailable,  bool googleAvailable,  bool sessionExpired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignInState() when $default != null:
return $default(_that.email,_that.password,_that.showValidation,_that.inProgress,_that.failure,_that.appleAvailable,_that.googleAvailable,_that.sessionExpired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  bool showValidation,  SignInMethod? inProgress,  Failure? failure,  bool appleAvailable,  bool googleAvailable,  bool sessionExpired)  $default,) {final _that = this;
switch (_that) {
case _SignInState():
return $default(_that.email,_that.password,_that.showValidation,_that.inProgress,_that.failure,_that.appleAvailable,_that.googleAvailable,_that.sessionExpired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  bool showValidation,  SignInMethod? inProgress,  Failure? failure,  bool appleAvailable,  bool googleAvailable,  bool sessionExpired)?  $default,) {final _that = this;
switch (_that) {
case _SignInState() when $default != null:
return $default(_that.email,_that.password,_that.showValidation,_that.inProgress,_that.failure,_that.appleAvailable,_that.googleAvailable,_that.sessionExpired);case _:
  return null;

}
}

}

/// @nodoc


class _SignInState extends SignInState {
  const _SignInState({this.email = '', this.password = '', this.showValidation = false, this.inProgress, this.failure, this.appleAvailable = false, this.googleAvailable = false, this.sessionExpired = false}): super._();
  

@override@JsonKey() final  String email;
@override@JsonKey() final  String password;
/// Field errors appear only after the first submit, not while typing.
@override@JsonKey() final  bool showValidation;
@override final  SignInMethod? inProgress;
@override final  Failure? failure;
@override@JsonKey() final  bool appleAvailable;
@override@JsonKey() final  bool googleAvailable;
/// The previous session was ended by the server, not by the user.
@override@JsonKey() final  bool sessionExpired;

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignInStateCopyWith<_SignInState> get copyWith => __$SignInStateCopyWithImpl<_SignInState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.showValidation, showValidation) || other.showValidation == showValidation)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.appleAvailable, appleAvailable) || other.appleAvailable == appleAvailable)&&(identical(other.googleAvailable, googleAvailable) || other.googleAvailable == googleAvailable)&&(identical(other.sessionExpired, sessionExpired) || other.sessionExpired == sessionExpired));
}


@override
int get hashCode {
    return Object.hash(runtimeType,email,password,showValidation,inProgress,failure,appleAvailable,googleAvailable,sessionExpired);
}

@override
String toString() {
    return 'SignInState(email: $email, password: $password, showValidation: $showValidation, inProgress: $inProgress, failure: $failure, appleAvailable: $appleAvailable, googleAvailable: $googleAvailable, sessionExpired: $sessionExpired)';
}


}

/// @nodoc
abstract mixin class _$SignInStateCopyWith<$Res> implements $SignInStateCopyWith<$Res> {
  factory _$SignInStateCopyWith(_SignInState value, $Res Function(_SignInState) _then) = __$SignInStateCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, bool showValidation, SignInMethod? inProgress, Failure? failure, bool appleAvailable, bool googleAvailable, bool sessionExpired
});


@override $FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$SignInStateCopyWithImpl<$Res>
    implements _$SignInStateCopyWith<$Res> {
  __$SignInStateCopyWithImpl(this._self, this._then);

  final _SignInState _self;
  final $Res Function(_SignInState) _then;

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? showValidation = null,Object? inProgress = freezed,Object? failure = freezed,Object? appleAvailable = null,Object? googleAvailable = null,Object? sessionExpired = null,}) {
  return _then(_SignInState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,showValidation: null == showValidation ? _self.showValidation : showValidation // ignore: cast_nullable_to_non_nullable
as bool,inProgress: freezed == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as SignInMethod?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,appleAvailable: null == appleAvailable ? _self.appleAvailable : appleAvailable // ignore: cast_nullable_to_non_nullable
as bool,googleAvailable: null == googleAvailable ? _self.googleAvailable : googleAvailable // ignore: cast_nullable_to_non_nullable
as bool,sessionExpired: null == sessionExpired ? _self.sessionExpired : sessionExpired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
