enum Flavor { dev, staging, prod }

/// Build-time configuration. Values come from
/// `--dart-define-from-file=env/<file>.json`. Only public values belong
/// here: API base URL, OAuth client ids, public SDK keys, DSNs. Never secrets.
final class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.apiBaseUrl,
    this.useMockApi = false,
    this.googleServerClientId,
    this.googleIosClientId,
    this.revenueCatAppleKey,
    this.revenueCatGoogleKey,
  });

  /// Reads compile-time defines. Throws at startup (not later, mid-request)
  /// if the build was produced without its env file.
  factory AppEnvironment.fromDartDefines(Flavor flavor) {
    const rawBaseUrl = String.fromEnvironment('API_BASE_URL');
    const useMockApi = bool.fromEnvironment('USE_MOCK_API');
    const googleServerClientId = String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
    );
    const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
    const revenueCatAppleKey = String.fromEnvironment('REVENUECAT_APPLE_KEY');
    const revenueCatGoogleKey = String.fromEnvironment(
      'REVENUECAT_GOOGLE_KEY',
    );

    final baseUrl = Uri.tryParse(rawBaseUrl);
    if (rawBaseUrl.isEmpty || baseUrl == null || !baseUrl.hasScheme) {
      throw StateError(
        'API_BASE_URL is missing or invalid. '
        'Run with --dart-define-from-file=env/${flavor.name}.json',
      );
    }
    if (useMockApi && flavor == Flavor.prod) {
      throw StateError('USE_MOCK_API must never be enabled in prod builds.');
    }
    return AppEnvironment(
      flavor: flavor,
      apiBaseUrl: baseUrl,
      useMockApi: useMockApi,
      googleServerClientId: _nonEmpty(googleServerClientId),
      googleIosClientId: _nonEmpty(googleIosClientId),
      revenueCatAppleKey: _nonEmpty(revenueCatAppleKey),
      revenueCatGoogleKey: _nonEmpty(revenueCatGoogleKey),
    );
  }

  final Flavor flavor;
  final Uri apiBaseUrl;

  /// Replaces the network with the in-app mock backend (dev only).
  final bool useMockApi;

  /// OAuth *web* client id; Google sign-in is hidden when absent.
  final String? googleServerClientId;

  /// OAuth iOS client id; Google sign-in is hidden on iOS when absent.
  final String? googleIosClientId;

  /// RevenueCat public SDK keys (per platform). Without one, the app shows
  /// plans but cannot sell (development builds).
  final String? revenueCatAppleKey;
  final String? revenueCatGoogleKey;

  bool get isProduction => flavor == Flavor.prod;

  static String? _nonEmpty(String value) => value.isEmpty ? null : value;
}
