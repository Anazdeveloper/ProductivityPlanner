// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_access.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationAccess {

 NotificationPermission get permission;/// Android 12+: whether reminders can fire at the exact minute. False
/// means they may arrive a few minutes late. Null where it does not
/// apply (iOS, older Android).
 bool? get exactAlarmsAllowed;/// The in-app "Task reminders" switch.
 bool get remindersEnabled;
/// Create a copy of NotificationAccess
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationAccessCopyWith<NotificationAccess> get copyWith => _$NotificationAccessCopyWithImpl<NotificationAccess>(this as NotificationAccess, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NotificationAccess;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationAccess&&(identical(other.permission, _this.permission) || other.permission == _this.permission)&&(identical(other.exactAlarmsAllowed, _this.exactAlarmsAllowed) || other.exactAlarmsAllowed == _this.exactAlarmsAllowed)&&(identical(other.remindersEnabled, _this.remindersEnabled) || other.remindersEnabled == _this.remindersEnabled));
}


@override
int get hashCode {
  final _this = this as NotificationAccess;
  return Object.hash(runtimeType,_this.permission,_this.exactAlarmsAllowed,_this.remindersEnabled);
}

@override
String toString() {
  final _this = this as NotificationAccess;
  return 'NotificationAccess(permission: ${_this.permission}, exactAlarmsAllowed: ${_this.exactAlarmsAllowed}, remindersEnabled: ${_this.remindersEnabled})';
}


}

/// @nodoc
abstract mixin class $NotificationAccessCopyWith<$Res>  {
  factory $NotificationAccessCopyWith(NotificationAccess value, $Res Function(NotificationAccess) _then) = _$NotificationAccessCopyWithImpl;
@useResult
$Res call({
 NotificationPermission permission, bool? exactAlarmsAllowed, bool remindersEnabled
});




}
/// @nodoc
class _$NotificationAccessCopyWithImpl<$Res>
    implements $NotificationAccessCopyWith<$Res> {
  _$NotificationAccessCopyWithImpl(this._self, this._then);

  final NotificationAccess _self;
  final $Res Function(NotificationAccess) _then;

/// Create a copy of NotificationAccess
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? permission = null,Object? exactAlarmsAllowed = freezed,Object? remindersEnabled = null,}) {
  return _then(NotificationAccess(
permission: null == permission ? _self.permission : permission // ignore: cast_nullable_to_non_nullable
as NotificationPermission,exactAlarmsAllowed: freezed == exactAlarmsAllowed ? _self.exactAlarmsAllowed : exactAlarmsAllowed // ignore: cast_nullable_to_non_nullable
as bool?,remindersEnabled: null == remindersEnabled ? _self.remindersEnabled : remindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationAccess].
extension NotificationAccessPatterns on NotificationAccess {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationAccess value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationAccess() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationAccess value)  $default,){
final _that = this;
switch (_that) {
case _NotificationAccess():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationAccess value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationAccess() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NotificationPermission permission,  bool? exactAlarmsAllowed,  bool remindersEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationAccess() when $default != null:
return $default(_that.permission,_that.exactAlarmsAllowed,_that.remindersEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NotificationPermission permission,  bool? exactAlarmsAllowed,  bool remindersEnabled)  $default,) {final _that = this;
switch (_that) {
case _NotificationAccess():
return $default(_that.permission,_that.exactAlarmsAllowed,_that.remindersEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NotificationPermission permission,  bool? exactAlarmsAllowed,  bool remindersEnabled)?  $default,) {final _that = this;
switch (_that) {
case _NotificationAccess() when $default != null:
return $default(_that.permission,_that.exactAlarmsAllowed,_that.remindersEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationAccess extends NotificationAccess {
  const _NotificationAccess({required this.permission, this.exactAlarmsAllowed, this.remindersEnabled = true}): super._();
  

@override final  NotificationPermission permission;
/// Android 12+: whether reminders can fire at the exact minute. False
/// means they may arrive a few minutes late. Null where it does not
/// apply (iOS, older Android).
@override final  bool? exactAlarmsAllowed;
/// The in-app "Task reminders" switch.
@override@JsonKey() final  bool remindersEnabled;

/// Create a copy of NotificationAccess
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationAccessCopyWith<_NotificationAccess> get copyWith => __$NotificationAccessCopyWithImpl<_NotificationAccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationAccess&&(identical(other.permission, permission) || other.permission == permission)&&(identical(other.exactAlarmsAllowed, exactAlarmsAllowed) || other.exactAlarmsAllowed == exactAlarmsAllowed)&&(identical(other.remindersEnabled, remindersEnabled) || other.remindersEnabled == remindersEnabled));
}


@override
int get hashCode {
    return Object.hash(runtimeType,permission,exactAlarmsAllowed,remindersEnabled);
}

@override
String toString() {
    return 'NotificationAccess(permission: $permission, exactAlarmsAllowed: $exactAlarmsAllowed, remindersEnabled: $remindersEnabled)';
}


}

/// @nodoc
abstract mixin class _$NotificationAccessCopyWith<$Res> implements $NotificationAccessCopyWith<$Res> {
  factory _$NotificationAccessCopyWith(_NotificationAccess value, $Res Function(_NotificationAccess) _then) = __$NotificationAccessCopyWithImpl;
@override @useResult
$Res call({
 NotificationPermission permission, bool? exactAlarmsAllowed, bool remindersEnabled
});




}
/// @nodoc
class __$NotificationAccessCopyWithImpl<$Res>
    implements _$NotificationAccessCopyWith<$Res> {
  __$NotificationAccessCopyWithImpl(this._self, this._then);

  final _NotificationAccess _self;
  final $Res Function(_NotificationAccess) _then;

/// Create a copy of NotificationAccess
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? permission = null,Object? exactAlarmsAllowed = freezed,Object? remindersEnabled = null,}) {
  return _then(_NotificationAccess(
permission: null == permission ? _self.permission : permission // ignore: cast_nullable_to_non_nullable
as NotificationPermission,exactAlarmsAllowed: freezed == exactAlarmsAllowed ? _self.exactAlarmsAllowed : exactAlarmsAllowed // ignore: cast_nullable_to_non_nullable
as bool?,remindersEnabled: null == remindersEnabled ? _self.remindersEnabled : remindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
