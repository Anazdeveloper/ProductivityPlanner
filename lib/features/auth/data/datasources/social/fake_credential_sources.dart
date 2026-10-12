import 'package:productivity_planner/features/auth/data/datasources/social/social_credentials.dart';

/// Tokens the mock backend accepts (`auth_mock_routes.dart`).
abstract final class FakeProviderTokens {
  static const apple = 'mock-apple-id-token';
  static const google = 'mock-google-id-token';
}

/// Used with the mock backend so social sign-in works without Apple/Google
/// configuration, and in tests.
final class FakeAppleCredentialSource implements AppleCredentialSource {
  FakeAppleCredentialSource({this.available = true, this.cancel = false});

  bool available;
  bool cancel;
  String? lastHashedNonce;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<AppleCredential> getCredential({required String hashedNonce}) async {
    if (cancel) throw const SocialSignInCancelled();
    lastHashedNonce = hashedNonce;
    return const AppleCredential(
      identityToken: FakeProviderTokens.apple,
      givenName: 'Apple',
      familyName: 'Tester',
    );
  }
}

final class FakeGoogleCredentialSource implements GoogleCredentialSource {
  FakeGoogleCredentialSource({this.available = true, this.cancel = false});

  bool available;
  bool cancel;
  int signOutCalls = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<GoogleCredential> getCredential() async {
    if (cancel) throw const SocialSignInCancelled();
    return const GoogleCredential(idToken: FakeProviderTokens.google);
  }

  @override
  Future<void> signOut() async => signOutCalls++;
}
