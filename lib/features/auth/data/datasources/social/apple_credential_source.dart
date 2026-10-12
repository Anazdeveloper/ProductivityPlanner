import 'package:flutter/foundation.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/social_credentials.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Native Sign in with Apple. Offered on iOS only: Android would need the
/// web flow (Service ID + redirect endpoint), and App Store guidelines only
/// require Apple sign-in on Apple platforms when other social logins exist.
final class SignInWithAppleCredentialSource implements AppleCredentialSource {
  const SignInWithAppleCredentialSource();

  @override
  Future<bool> isAvailable() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      return await SignInWithApple.isAvailable();
    } on Object {
      return false;
    }
  }

  @override
  Future<AppleCredential> getCredential({required String hashedNonce}) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final token = credential.identityToken;
      if (token == null || token.isEmpty) {
        throw const SocialSignInFailed('Apple returned no identity token');
      }
      return AppleCredential(
        identityToken: token,
        authorizationCode: credential.authorizationCode,
        givenName: credential.givenName,
        familyName: credential.familyName,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const SocialSignInCancelled();
      }
      throw SocialSignInFailed('Apple authorization failed: ${error.code.name}');
    }
  }
}
