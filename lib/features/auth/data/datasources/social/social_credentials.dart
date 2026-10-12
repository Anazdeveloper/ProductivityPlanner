/// Data-layer exceptions from social providers. The repository maps them to
/// `Failure.cancelled` / `Failure.unexpected`.
final class SocialSignInCancelled implements Exception {
  const SocialSignInCancelled();
}

final class SocialSignInFailed implements Exception {
  const SocialSignInFailed(this.reason);

  final String reason;

  @override
  String toString() => 'SocialSignInFailed($reason)';
}

final class AppleCredential {
  const AppleCredential({
    required this.identityToken,
    this.authorizationCode,
    this.givenName,
    this.familyName,
  });

  final String identityToken;
  final String? authorizationCode;

  /// Apple sends the name only on the first authorisation.
  final String? givenName;
  final String? familyName;

  String? get fullName {
    final parts = [givenName, familyName]
        .whereType<String>()
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' ');
  }
}

final class GoogleCredential {
  const GoogleCredential({required this.idToken});

  final String idToken;
}

/// Interactive Sign in with Apple.
abstract interface class AppleCredentialSource {
  Future<bool> isAvailable();

  /// [hashedNonce] = SHA-256 of the raw nonce later sent to our server.
  /// Throws [SocialSignInCancelled] or [SocialSignInFailed].
  Future<AppleCredential> getCredential({required String hashedNonce});
}

/// Interactive Google sign-in.
abstract interface class GoogleCredentialSource {
  Future<bool> isAvailable();

  /// Throws [SocialSignInCancelled] or [SocialSignInFailed].
  Future<GoogleCredential> getCredential();

  /// Clears Google's cached account so the next sign-in shows the picker.
  Future<void> signOut();
}
