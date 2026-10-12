/// Endpoint paths from `contracts/api/v1.md`, relative to the base URL
/// (`…/v1/`). Only paths in the contract may appear here.
abstract final class ApiPaths {
  // Auth (Phase 3)
  static const authRegister = 'auth/register';
  static const authLogin = 'auth/login';
  static const authOAuthApple = 'auth/oauth/apple';
  static const authOAuthGoogle = 'auth/oauth/google';
  static const authRefresh = 'auth/refresh';
  static const authLogout = 'auth/logout';
  static const authPasswordForgot = 'auth/password/forgot';
  static const authPasswordReset = 'auth/password/reset';
  static const authReauth = 'auth/reauth';

  // Me
  static const me = 'me';
  static const meNotificationPreferences = 'me/notification-preferences';
  static const meEntitlements = 'me/entitlements';
  static const meExport = 'me/export';

  // Devices
  static String device(String id) => 'devices/$id';

  // Categories
  static const categories = 'categories';
  static String category(String id) => 'categories/$id';

  // Series and occurrences
  static const series = 'series';
  static String seriesById(String id) => 'series/$id';
  static String seriesSplit(String id) => 'series/$id/split';
  static const occurrences = 'occurrences';
  static String occurrence(String id) => 'occurrences/$id';
  static String occurrenceCommand(String id, OccurrenceCommand command) =>
      'occurrences/$id/${command.name}';

  // Sync
  static const syncPush = 'sync/push';
  static const syncPull = 'sync/pull';

  // Analytics and insights
  static const analyticsSummary = 'analytics/summary';
  static const analyticsTrend = 'analytics/trend';
  static const analyticsLineages = 'analytics/lineages';
  static String analyticsLineage(String id) => 'analytics/lineages/$id';
  static String analyticsDurationSuggestion(String id) =>
      'analytics/lineages/$id/duration-suggestion';
  static const insights = 'insights';
  static String insightDismiss(String id) => 'insights/$id/dismiss';
  static String insightApply(String id) => 'insights/$id/apply';

  // Subscriptions and config
  static const subscriptionStatus = 'subscriptions/status';
  static const config = 'config';
}

enum OccurrenceCommand {
  start,
  pause,
  resume,
  complete,
  skip,
  postpone,
  cancel,
  reopen,
}

/// Header names from the contract.
abstract final class ApiHeaders {
  static const authorization = 'Authorization';
  static const requestId = 'X-Request-Id';
  static const deviceId = 'X-Device-Id';
  static const idempotencyKey = 'Idempotency-Key';
  static const ifMatch = 'If-Match';
  static const reauthToken = 'X-Reauth-Token';
}
