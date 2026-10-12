/// Validation outcomes. Their `name` doubles as the field-error code carried
/// in `Failure.validation(fieldErrors: {field: code})`, which the UI turns
/// into localised text.
enum CredentialError {
  emailEmpty,
  emailInvalid,
  passwordEmpty,
  passwordTooShort,
  passwordTooLong,
  displayNameEmpty,
  displayNameTooLong,
  resetCodeInvalid,
}

/// Field keys shared by local validation and the server's `errors[].field`.
abstract final class CredentialField {
  static const email = 'email';
  static const password = 'password';
  static const newPassword = 'new_password';
  static const displayName = 'display_name';
  static const code = 'code';
}

/// Account input rules (approved design: passwords 10–128 characters, no
/// composition rules). Pure functions so forms and use cases share them.
abstract final class CredentialRules {
  static const passwordMinLength = 10;
  static const passwordMaxLength = 128;
  static const displayNameMaxLength = 60;

  // Deliberately permissive: the server is the authority (it sends the reset
  // email). This only catches obvious typos.
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final _resetCodePattern = RegExp(r'^\d{6}$');

  static String normalizeEmail(String raw) => raw.trim().toLowerCase();

  static CredentialError? email(String raw) {
    final value = normalizeEmail(raw);
    if (value.isEmpty) return CredentialError.emailEmpty;
    if (!_emailPattern.hasMatch(value)) return CredentialError.emailInvalid;
    return null;
  }

  /// For sign-in: existing accounts may predate today's rules, so only
  /// emptiness is checked locally.
  static CredentialError? existingPassword(String value) =>
      value.isEmpty ? CredentialError.passwordEmpty : null;

  /// For registration and password reset.
  static CredentialError? newPassword(String value) {
    if (value.isEmpty) return CredentialError.passwordEmpty;
    if (value.length < passwordMinLength) {
      return CredentialError.passwordTooShort;
    }
    if (value.length > passwordMaxLength) {
      return CredentialError.passwordTooLong;
    }
    return null;
  }

  static CredentialError? displayName(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return CredentialError.displayNameEmpty;
    if (value.length > displayNameMaxLength) {
      return CredentialError.displayNameTooLong;
    }
    return null;
  }

  static CredentialError? resetCode(String raw) =>
      _resetCodePattern.hasMatch(raw.trim())
      ? null
      : CredentialError.resetCodeInvalid;

  /// Collects the errors for a form, keyed by [CredentialField].
  static Map<String, String> collect(Map<String, CredentialError?> checks) => {
    for (final entry in checks.entries)
      if (entry.value case final error?) entry.key: error.name,
  };
}
