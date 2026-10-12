import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Inline text for a field: the local rule violation if any, otherwise the
/// server's message for that field (already human-readable).
String? fieldErrorText(
  AppLocalizations l10n, {
  CredentialError? local,
  String? server,
}) {
  if (local != null) return credentialErrorText(l10n, local);
  if (server == null) return null;
  // Use-case validation returns CredentialError names as codes.
  final code = CredentialError.values.where((e) => e.name == server).firstOrNull;
  return code == null ? server : credentialErrorText(l10n, code);
}

String credentialErrorText(AppLocalizations l10n, CredentialError error) =>
    switch (error) {
      CredentialError.emailEmpty => l10n.errorEmailEmpty,
      CredentialError.emailInvalid => l10n.errorEmailInvalid,
      CredentialError.passwordEmpty => l10n.errorPasswordEmpty,
      CredentialError.passwordTooShort => l10n.errorPasswordTooShort(
        CredentialRules.passwordMinLength,
      ),
      CredentialError.passwordTooLong => l10n.errorPasswordTooLong(
        CredentialRules.passwordMaxLength,
      ),
      CredentialError.displayNameEmpty => l10n.errorDisplayNameEmpty,
      CredentialError.displayNameTooLong => l10n.errorDisplayNameTooLong(
        CredentialRules.displayNameMaxLength,
      ),
      CredentialError.resetCodeInvalid => l10n.errorResetCodeInvalid,
    };
