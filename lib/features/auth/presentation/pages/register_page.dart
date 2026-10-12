import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/register_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/credential_error_text.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/password_field.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Expects a [RegisterCubit] above it. A successful registration signs the
/// user in; the router's auth gate then leaves this page.
class RegisterPage extends StatelessWidget {
  const RegisterPage({required this.onSignIn, super.key});

  static const nameFieldKey = Key('register.name');
  static const emailFieldKey = Key('register.email');
  static const passwordFieldKey = Key('register.password');
  static const submitKey = Key('register.submit');

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<RegisterCubit>();

    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        return AutofillGroup(
          child: AuthScaffold(
            title: l10n.registerTitle,
            showBackButton: true,
            children: [
              TextField(
                key: nameFieldKey,
                enabled: !state.submitting,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
                onChanged: cubit.displayNameChanged,
                decoration: InputDecoration(
                  labelText: l10n.displayNameLabel,
                  errorText: fieldErrorText(
                    l10n,
                    local: state.displayNameError,
                    server: state.serverFieldError(CredentialField.displayName),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: emailFieldKey,
                enabled: !state.submitting,
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
                helperText: l10n.passwordHint(CredentialRules.passwordMinLength),
                autofillHints: const [AutofillHints.newPassword],
                enabled: !state.submitting,
                onChanged: cubit.passwordChanged,
                onSubmitted: (_) => cubit.submit(),
                errorText: fieldErrorText(
                  l10n,
                  local: state.passwordError,
                  server: state.serverFieldError(CredentialField.password),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.bannerFailure != null) ...[
                FailureBanner(failure: state.bannerFailure),
                const SizedBox(height: AppSpacing.md),
              ],
              SubmitButton(
                key: submitKey,
                label: l10n.registerButton,
                busy: state.submitting,
                onPressed: cubit.submit,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.haveAccountPrompt),
                  TextButton(
                    onPressed: state.submitting ? null : onSignIn,
                    child: Text(l10n.signInLink),
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
