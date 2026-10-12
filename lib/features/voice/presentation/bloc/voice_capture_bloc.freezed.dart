// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_capture_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoiceCaptureState {

 VoicePhase get phase;/// What was heard so far (live while listening).
 String get transcript; ParsedTask? get draft; SpeechAvailability? get availability; SpeechErrorKind? get error; Failure? get failure;
/// Create a copy of VoiceCaptureState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceCaptureStateCopyWith<VoiceCaptureState> get copyWith => _$VoiceCaptureStateCopyWithImpl<VoiceCaptureState>(this as VoiceCaptureState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VoiceCaptureState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceCaptureState&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.transcript, _this.transcript) || other.transcript == _this.transcript)&&(identical(other.draft, _this.draft) || other.draft == _this.draft)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as VoiceCaptureState;
  return Object.hash(runtimeType,_this.phase,_this.transcript,_this.draft,_this.availability,_this.error,_this.failure);
}

@override
String toString() {
  final _this = this as VoiceCaptureState;
  return 'VoiceCaptureState(phase: ${_this.phase}, transcript: ${_this.transcript}, draft: ${_this.draft}, availability: ${_this.availability}, error: ${_this.error}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $VoiceCaptureStateCopyWith<$Res>  {
  factory $VoiceCaptureStateCopyWith(VoiceCaptureState value, $Res Function(VoiceCaptureState) _then) = _$VoiceCaptureStateCopyWithImpl;
@useResult
$Res call({
 VoicePhase phase, String transcript, ParsedTask? draft, SpeechAvailability? availability, SpeechErrorKind? error, Failure? failure
});


$ParsedTaskCopyWith<$Res>? get draft;$FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$VoiceCaptureStateCopyWithImpl<$Res>
    implements $VoiceCaptureStateCopyWith<$Res> {
  _$VoiceCaptureStateCopyWithImpl(this._self, this._then);

  final VoiceCaptureState _self;
  final $Res Function(VoiceCaptureState) _then;

/// Create a copy of VoiceCaptureState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? transcript = null,Object? draft = freezed,Object? availability = freezed,Object? error = freezed,Object? failure = freezed,}) {
  return _then(VoiceCaptureState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as VoicePhase,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as ParsedTask?,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as SpeechAvailability?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as SpeechErrorKind?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}
/// Create a copy of VoiceCaptureState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParsedTaskCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $ParsedTaskCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of VoiceCaptureState
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


/// Adds pattern-matching-related methods to [VoiceCaptureState].
extension VoiceCaptureStatePatterns on VoiceCaptureState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceCaptureState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceCaptureState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceCaptureState value)  $default,){
final _that = this;
switch (_that) {
case _VoiceCaptureState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceCaptureState value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceCaptureState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VoicePhase phase,  String transcript,  ParsedTask? draft,  SpeechAvailability? availability,  SpeechErrorKind? error,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceCaptureState() when $default != null:
return $default(_that.phase,_that.transcript,_that.draft,_that.availability,_that.error,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VoicePhase phase,  String transcript,  ParsedTask? draft,  SpeechAvailability? availability,  SpeechErrorKind? error,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _VoiceCaptureState():
return $default(_that.phase,_that.transcript,_that.draft,_that.availability,_that.error,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VoicePhase phase,  String transcript,  ParsedTask? draft,  SpeechAvailability? availability,  SpeechErrorKind? error,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _VoiceCaptureState() when $default != null:
return $default(_that.phase,_that.transcript,_that.draft,_that.availability,_that.error,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _VoiceCaptureState implements VoiceCaptureState {
  const _VoiceCaptureState({this.phase = VoicePhase.preparing, this.transcript = '', this.draft, this.availability, this.error, this.failure});
  

@override@JsonKey() final  VoicePhase phase;
/// What was heard so far (live while listening).
@override@JsonKey() final  String transcript;
@override final  ParsedTask? draft;
@override final  SpeechAvailability? availability;
@override final  SpeechErrorKind? error;
@override final  Failure? failure;

/// Create a copy of VoiceCaptureState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceCaptureStateCopyWith<_VoiceCaptureState> get copyWith => __$VoiceCaptureStateCopyWithImpl<_VoiceCaptureState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceCaptureState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.error, error) || other.error == error)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase,transcript,draft,availability,error,failure);
}

@override
String toString() {
    return 'VoiceCaptureState(phase: $phase, transcript: $transcript, draft: $draft, availability: $availability, error: $error, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$VoiceCaptureStateCopyWith<$Res> implements $VoiceCaptureStateCopyWith<$Res> {
  factory _$VoiceCaptureStateCopyWith(_VoiceCaptureState value, $Res Function(_VoiceCaptureState) _then) = __$VoiceCaptureStateCopyWithImpl;
@override @useResult
$Res call({
 VoicePhase phase, String transcript, ParsedTask? draft, SpeechAvailability? availability, SpeechErrorKind? error, Failure? failure
});


@override $ParsedTaskCopyWith<$Res>? get draft;@override $FailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$VoiceCaptureStateCopyWithImpl<$Res>
    implements _$VoiceCaptureStateCopyWith<$Res> {
  __$VoiceCaptureStateCopyWithImpl(this._self, this._then);

  final _VoiceCaptureState _self;
  final $Res Function(_VoiceCaptureState) _then;

/// Create a copy of VoiceCaptureState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? transcript = null,Object? draft = freezed,Object? availability = freezed,Object? error = freezed,Object? failure = freezed,}) {
  return _then(_VoiceCaptureState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as VoicePhase,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as ParsedTask?,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as SpeechAvailability?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as SpeechErrorKind?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

/// Create a copy of VoiceCaptureState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParsedTaskCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $ParsedTaskCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of VoiceCaptureState
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
