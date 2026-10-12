import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/social_credentials.dart';

/// Google sign-in via `google_sign_in` 7 (singleton, `initialize` once).
///
/// Client ids are public values from the env file:
/// - [serverClientId]: the OAuth *web* client id. Required on both platforms
///   so the id token's audience is one our server accepts.
/// - [iosClientId]: the iOS client id (alternatively `GIDClientID` in
///   Info.plist).
/// Without them the button is hidden instead of failing at tap time.
final class GoogleSignInCredentialSource implements GoogleCredentialSource {
  GoogleSignInCredentialSource({this.serverClientId, this.iosClientId});

  final String? serverClientId;
  final String? iosClientId;

  Future<void>? _initialization;

  bool get _configured => switch (defaultTargetPlatform) {
    TargetPlatform.android => serverClientId != null,
    TargetPlatform.iOS => serverClientId != null && iosClientId != null,
    _ => false,
  };

  Future<void> _ensureInitialized() => _initialization ??= GoogleSignIn.instance
      .initialize(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? iosClientId
            : null,
        serverClientId: serverClientId,
      );

  @override
  Future<bool> isAvailable() async {
    if (!_configured) return false;
    try {
      await _ensureInitialized();
      return GoogleSignIn.instance.supportsAuthenticate();
    } on Object {
      return false;
    }
  }

  @override
  Future<GoogleCredential> getCredential() async {
    try {
      await _ensureInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const SocialSignInFailed('Google returned no id token');
      }
      return GoogleCredential(idToken: idToken);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialSignInCancelled();
      }
      throw SocialSignInFailed('Google sign-in failed: ${error.code.name}');
    }
  }

  @override
  Future<void> signOut() async {
    if (_initialization == null) return;
    try {
      await GoogleSignIn.instance.signOut();
    } on Object {
      // Best effort: our own session is already ended.
    }
  }
}
