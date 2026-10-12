/// What the HTTP layer needs from the session. Implemented by the auth
/// feature (`AuthSessionManager`), which refreshes through the public client
/// so refreshing can never recurse through the auth interceptor.
abstract interface class AuthTokenProvider {
  /// The current access token, or null when signed out.
  Future<String?> accessToken();

  /// Exchanges the refresh token for a new pair (rotation).
  Future<TokenRefreshResult> refresh();

  /// Called once when [refresh] reports the session is over.
  Future<void> onSessionExpired();
}

sealed class TokenRefreshResult {
  const TokenRefreshResult();
}

/// New tokens stored; retry with [accessToken].
final class TokenRefreshed extends TokenRefreshResult {
  const TokenRefreshed(this.accessToken);

  final String accessToken;
}

/// The server rejected the refresh token (expired, revoked, reused).
/// The user must sign in again.
final class TokenRefreshRejected extends TokenRefreshResult {
  const TokenRefreshRejected();
}

/// The refresh could not be attempted (offline, timeout, 5xx). The session
/// is kept; the original request fails as a network error.
final class TokenRefreshUnavailable extends TokenRefreshResult {
  const TokenRefreshUnavailable();
}
