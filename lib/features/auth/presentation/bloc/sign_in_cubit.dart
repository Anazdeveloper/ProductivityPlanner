import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';
import 'package:productivity_planner/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:productivity_planner/features/auth/domain/usecases/social_sign_in.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';

part 'sign_in_cubit.freezed.dart';

enum SignInMethod { email, apple, google }

@freezed
abstract class SignInState with _$SignInState {
  const factory SignInState({
    @Default('') String email,
    @Default('') String password,

    /// Field errors appear only after the first submit, not while typing.
    @Default(false) bool showValidation,
    SignInMethod? inProgress,
    Failure? failure,
    @Default(false) bool appleAvailable,
    @Default(false) bool googleAvailable,

    /// The previous session was ended by the server, not by the user.
    @Default(false) bool sessionExpired,
  }) = _SignInState;

  const SignInState._();

  bool get isBusy => inProgress != null;

  CredentialError? get emailError =>
      showValidation ? CredentialRules.email(email) : null;

  CredentialError? get passwordError =>
      showValidation ? CredentialRules.existingPassword(password) : null;

  /// Field messages returned by the server (`errors[]`), if any.
  String? serverFieldError(String field) => switch (failure) {
    ValidationFailure(:final fieldErrors) => fieldErrors[field],
    _ => null,
  };

  /// A failure worth a banner (field errors are shown inline instead).
  Failure? get bannerFailure => switch (failure) {
    null || CancelledFailure() => null,
    ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty => null,
    final other => other,
  };
}

/// Sign-in screen. Success needs no navigation here: the session stream
/// moves the app to its destination via the router's auth gate.
final class SignInCubit extends Cubit<SignInState> {
  SignInCubit({
    required SignInWithEmail signInWithEmail,
    required SignInWithApple signInWithApple,
    required SignInWithGoogle signInWithGoogle,
    required GetSocialSignInOptions getSocialSignInOptions,
    required WatchAuthState watchAuthState,
  }) : _signInWithEmail = signInWithEmail,
       _signInWithApple = signInWithApple,
       _signInWithGoogle = signInWithGoogle,
       _getSocialSignInOptions = getSocialSignInOptions,
       super(
         SignInState(
           sessionExpired: switch (watchAuthState.current) {
             Unauthenticated(reason: SignOutReason.sessionExpired) => true,
             _ => false,
           },
         ),
       );

  final SignInWithEmail _signInWithEmail;
  final SignInWithApple _signInWithApple;
  final SignInWithGoogle _signInWithGoogle;
  final GetSocialSignInOptions _getSocialSignInOptions;

  Future<void> loadOptions() async {
    final options = await _getSocialSignInOptions();
    if (isClosed) return;
    emit(
      state.copyWith(
        appleAvailable: options.apple,
        googleAvailable: options.google,
      ),
    );
  }

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, failure: null));

  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, failure: null));

  void dismissFailure() => emit(state.copyWith(failure: null));

  Future<void> submitEmail() async {
    if (state.isBusy) return;
    emit(state.copyWith(showValidation: true, failure: null));
    if (state.emailError != null || state.passwordError != null) return;
    await _run(
      SignInMethod.email,
      () => _signInWithEmail(
        EmailCredentials(email: state.email, password: state.password),
      ),
    );
  }

  Future<void> signInWithApple() =>
      _run(SignInMethod.apple, () => _signInWithApple(const NoParams()));

  Future<void> signInWithGoogle() =>
      _run(SignInMethod.google, () => _signInWithGoogle(const NoParams()));

  Future<void> _run(
    SignInMethod method,
    Future<Result<User>> Function() action,
  ) async {
    if (state.isBusy) return;
    emit(state.copyWith(inProgress: method, failure: null, sessionExpired: false));
    final result = await action();
    if (isClosed) return;
    emit(state.copyWith(inProgress: null, failure: result.failureOrNull));
  }
}
