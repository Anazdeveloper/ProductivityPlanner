import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/password_reset_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/credential_error_text.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/password_field.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Two-step reset: request a code by email, then set a new password.
/// Expects a [PasswordResetCubit] above it.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({required this.onBackToSignIn, super.key});

  static const emailFieldKey = Key('reset.email');
  static const codeFieldKey = Key('reset.code');
  static const passwordFieldKey = Key('reset.password');
  static const submitKey = Key('reset.submit');

  final VoidCallback onBackToSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<PasswordResetCubit, PasswordResetState>(
      builder: (context, state) => AuthScaffold(
        title: l10n.forgotPasswordTitle,
        showBackButton: true,
        children: switch (state.step) {
          PasswordResetStep.request => _requestStep(context, state, l10n),
          PasswordResetStep.confirm => _confirmStep(context, state, l10n),
          PasswordResetStep.done => _doneStep(l10n),
        },
      ),
    );
  }

  List<Widget> _requestStep(
    BuildContext context,
    PasswordResetState state,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<PasswordResetCubit>();
    return [
      Text(l10n.forgotPasswordIntro),
      const SizedBox(height: AppSpacing.lg),
      TextFormField(
        key: emailFieldKey,
        initialValue: state.email,
        enabled: !state.submitting,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        autofillHints: const [AutofillHints.email],
        onChanged: cubit.emailChanged,
        onFieldSubmitted: (_) => cubit.requestCode(),
        decoration: InputDecoration(
          labelText: l10n.emailLabel,
          errorText: fieldErrorText(
            l10n,
            local: state.emailError,
            server: state.serverFieldError(CredentialField.email),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      if (state.bannerFailure != null) ...[
        FailureBanner(failure: state.bannerFailure),
        const SizedBox(height: AppSpacing.md),
      ],
      SubmitButton(
        key: submitKey,
        label: l10n.sendCodeButton,
        busy: state.submitting,
        onPressed: cubit.requestCode,
      ),
    ];
  }

  List<Widget> _confirmStep(
    BuildContext context,
    PasswordResetState state,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<PasswordResetCubit>();
    return [
      Text(l10n.codeSentIntro(CredentialRules.normalizeEmail(state.email))),
      const SizedBox(height: AppSpacing.lg),
      TextField(
        key: codeFieldKey,
        enabled: !state.submitting,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        maxLength: 6,
        onChanged: cubit.codeChanged,
        decoration: InputDecoration(
          labelText: l10n.resetCodeLabel,
          counterText: '',
          errorText: fieldErrorText(
            l10n,
            local: state.codeError,
            server: state.serverFieldError(CredentialField.code),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      PasswordField(
        fieldKey: passwordFieldKey,
        label: l10n.newPasswordLabel,
        helperText: l10n.passwordHint(CredentialRules.passwordMinLength),
        autofillHints: const [AutofillHints.newPassword],
        enabled: !state.submitting,
        onChanged: cubit.newPasswordChanged,
        onSubmitted: (_) => cubit.confirm(),
        errorText: fieldErrorText(
          l10n,
          local: state.newPasswordError,
          server: state.serverFieldError(CredentialField.newPassword),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      if (state.bannerFailure != null) ...[
        FailureBanner(failure: state.bannerFailure),
        const SizedBox(height: AppSpacing.md),
      ],
      SubmitButton(
        key: submitKey,
        label: l10n.resetPasswordButton,
        busy: state.submitting,
        onPressed: cubit.confirm,
      ),
      TextButton(
        onPressed: state.submitting ? null : cubit.changeEmail,
        child: Text(l10n.changeEmailButton),
      ),
    ];
  }

  List<Widget> _doneStep(AppLocalizations l10n) => [
    NoticeBanner(text: l10n.passwordResetDone, icon: Icons.check_circle_outline),
    const SizedBox(height: AppSpacing.lg),
    SubmitButton(label: l10n.backToSignIn, onPressed: onBackToSignIn),
  ];
}
