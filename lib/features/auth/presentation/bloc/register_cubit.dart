import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/features/auth/domain/usecases/register_with_email.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';

part 'register_cubit.freezed.dart';

@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default('') String displayName,
    @Default('') String email,
    @Default('') String password,
    @Default(false) bool showValidation,
    @Default(false) bool submitting,
    Failure? failure,
  }) = _RegisterState;

  const RegisterState._();

  CredentialError? get displayNameError =>
      showValidation ? CredentialRules.displayName(displayName) : null;

  CredentialError? get emailError =>
      showValidation ? CredentialRules.email(email) : null;

  CredentialError? get passwordError =>
      showValidation ? CredentialRules.newPassword(password) : null;

  bool get hasLocalErrors =>
      CredentialRules.displayName(displayName) != null ||
      CredentialRules.email(email) != null ||
      CredentialRules.newPassword(password) != null;

  String? serverFieldError(String field) => switch (failure) {
    ValidationFailure(:final fieldErrors) => fieldErrors[field],
    _ => null,
  };

  Failure? get bannerFailure => switch (failure) {
    null || CancelledFailure() => null,
    ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty => null,
    final other => other,
  };
}

final class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required RegisterWithEmail registerWithEmail})
    : _registerWithEmail = registerWithEmail,
      super(const RegisterState());

  final RegisterWithEmail _registerWithEmail;

  void displayNameChanged(String value) =>
      emit(state.copyWith(displayName: value, failure: null));

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, failure: null));

  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, failure: null));

  Future<void> submit() async {
    if (state.submitting) return;
    emit(state.copyWith(showValidation: true, failure: null));
    if (state.hasLocalErrors) return;
    emit(state.copyWith(submitting: true));
    final result = await _registerWithEmail(
      Registration(
        displayName: state.displayName,
        email: state.email,
        password: state.password,
      ),
    );
    if (isClosed) return;
    emit(state.copyWith(submitting: false, failure: result.failureOrNull));
  }
}
