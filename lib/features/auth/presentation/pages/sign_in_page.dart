import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/sign_in_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/credential_error_text.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/password_field.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/social_sign_in_buttons.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Expects a [SignInCubit] above it (provided by the route).
class SignInPage extends StatelessWidget {
  const SignInPage({
    required this.onCreateAccount,
    required this.onForgotPassword,
    super.key,
  });

  static const emailFieldKey = Key('signIn.email');
  static const passwordFieldKey = Key('signIn.password');
  static const submitKey = Key('signIn.submit');

  final VoidCallback onCreateAccount;
  final ValueChanged<String> onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SignInCubit>();

    return BlocBuilder<SignInCubit, SignInState>(
      builder: (context, state) {
        return AutofillGroup(
          child: AuthScaffold(
            title: l10n.signInTitle,
            subtitle: l10n.signInSubtitle,
            children: [
              if (state.sessionExpired) ...[
                NoticeBanner(
                  text: l10n.sessionExpiredNotice,
                  icon: Icons.lock_clock_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              TextField(
                key: emailFieldKey,
                enabled: !state.isBusy,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                onChanged: cubit.emailChanged,
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  errorText: fieldErrorText(
                    l10n,
                    local: state.emailError,
                    server: state.serverFieldError(CredentialField.email),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                fieldKey: passwordFieldKey,
                label: l10n.passwordLabel,
                enabled: !state.isBusy,
                onChanged: cubit.passwordChanged,
                onSubmitted: (_) => cubit.submitEmail(),
                errorText: fieldErrorText(
                  l10n,
                  local: state.passwordError,
                  server: state.serverFieldError(CredentialField.password),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: state.isBusy
                      ? null
                      : () => onForgotPassword(state.email),
                  child: Text(l10n.forgotPasswordLink),
                ),
              ),
              if (state.bannerFailure != null) ...[
                FailureBanner(failure: state.bannerFailure),
                const SizedBox(height: AppSpacing.md),
              ],
              SubmitButton(
                key: submitKey,
                label: l10n.signInButton,
                busy: state.inProgress == SignInMethod.email,
                onPressed: state.isBusy ? null : cubit.submitEmail,
              ),
              const SizedBox(height: AppSpacing.lg),
              SocialSignInButtons(
                showApple: state.appleAvailable,
                showGoogle: state.googleAvailable,
                enabled: !state.isBusy,
                appleBusy: state.inProgress == SignInMethod.apple,
                googleBusy: state.inProgress == SignInMethod.google,
                onApple: cubit.signInWithApple,
                onGoogle: cubit.signInWithGoogle,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.noAccountPrompt),
                  TextButton(
                    onPressed: state.isBusy ? null : onCreateAccount,
                    child: Text(l10n.createAccountLink),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
