import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/features/auth/domain/usecases/password_reset.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';

part 'password_reset_cubit.freezed.dart';

enum PasswordResetStep {
  /// Enter email, receive a code.
  request,

  /// Enter the 6-digit code and a new password.
  confirm,

  /// Password changed; all sessions were revoked by the server.
  done,
}

@freezed
abstract class PasswordResetState with _$PasswordResetState {
  const factory PasswordResetState({
    @Default(PasswordResetStep.request) PasswordResetStep step,
    @Default('') String email,
    @Default('') String code,
    @Default('') String newPassword,
    @Default(false) bool showValidation,
    @Default(false) bool submitting,
    Failure? failure,
  }) = _PasswordResetState;

  const PasswordResetState._();

  CredentialError? get emailError =>
      showValidation ? CredentialRules.email(email) : null;

  CredentialError? get codeError =>
      showValidation ? CredentialRules.resetCode(code) : null;

  CredentialError? get newPasswordError =>
      showValidation ? CredentialRules.newPassword(newPassword) : null;

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

final class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit({
    required RequestPasswordReset requestPasswordReset,
    required ResetPassword resetPassword,
    String initialEmail = '',
  }) : _requestPasswordReset = requestPasswordReset,
       _resetPassword = resetPassword,
       super(PasswordResetState(email: initialEmail));

  final RequestPasswordReset _requestPasswordReset;
  final ResetPassword _resetPassword;

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, failure: null));

  void codeChanged(String value) =>
      emit(state.copyWith(code: value, failure: null));

  void newPasswordChanged(String value) =>
      emit(state.copyWith(newPassword: value, failure: null));

  Future<void> requestCode() async {
    if (state.submitting) return;
    emit(state.copyWith(showValidation: true, failure: null));
    if (CredentialRules.email(state.email) != null) return;
    emit(state.copyWith(submitting: true));
    final result = await _requestPasswordReset(state.email);
    if (isClosed) return;
    emit(
      state.copyWith(
        submitting: false,
        failure: result.failureOrNull,
        step: result.isOk ? PasswordResetStep.confirm : state.step,
        // The next step's fields start without errors shown.
        showValidation: !result.isOk,
      ),
    );
  }

  Future<void> confirm() async {
    if (state.submitting) return;
    emit(state.copyWith(showValidation: true, failure: null));
    if (CredentialRules.resetCode(state.code) != null ||
        CredentialRules.newPassword(state.newPassword) != null) {
      return;
    }
    emit(state.copyWith(submitting: true));
    final result = await _resetPassword(
      PasswordResetConfirmation(
        email: state.email,
        code: state.code,
        newPassword: state.newPassword,
      ),
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        submitting: false,
        failure: result.failureOrNull,
        step: result.isOk ? PasswordResetStep.done : state.step,
      ),
    );
  }

  /// Back from the code step, e.g. to fix a mistyped email.
  void changeEmail() => emit(
    state.copyWith(
      step: PasswordResetStep.request,
      code: '',
      showValidation: false,
      failure: null,
    ),
  );
}
