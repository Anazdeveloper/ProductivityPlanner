import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/error/app_permission.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// User-facing text for a [Failure]. The single mapping for the whole app so
/// wording stays consistent; strings live in `lib/l10n/arb/app_en.arb`.
///
/// Usage in a widget: `failure.message(AppLocalizations.of(context))`.
/// [CancelledFailure] maps to an empty string; callers should not show it.
extension FailureMessage on Failure {
  String message(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.failureNetwork,
    UnauthenticatedFailure() => l10n.failureUnauthenticated,
    InvalidCredentialsFailure() => l10n.failureInvalidCredentials,
    CancelledFailure() => '',
    ForbiddenFailure() => l10n.failureForbidden,
    ValidationFailure(:final message) => message ?? l10n.failureValidation,
    NotFoundFailure() => l10n.failureNotFound,
    ConflictFailure(:final code) => _conflict(code, l10n),
    ServerFailure() => l10n.failureServer,
    DatabaseFailure() => l10n.failureDatabase,
    PermissionDeniedFailure(:final permission) => _permission(permission, l10n),
    EntitlementRequiredFailure(:final feature) => _feature(feature, l10n),
    LimitReachedFailure(:final limit, :final allowed) => _limit(
      limit,
      allowed,
      l10n,
    ),
    UnexpectedFailure() => l10n.failureUnexpected,
  };
}

String _conflict(String code, AppLocalizations l10n) => switch (code) {
  'ALREADY_RESOLVED' => l10n.conflictAlreadyResolved,
  'ENTITY_DELETED' => l10n.conflictEntityDeleted,
  'INVALID_TRANSITION' => l10n.conflictInvalidTransition,
  'EMAIL_TAKEN' => l10n.conflictEmailTaken,
  'PURCHASE_PENDING' => l10n.purchasePending,
  'PURCHASE_NOT_ALLOWED' => l10n.purchaseNotAllowed,
  'PURCHASES_UNAVAILABLE' => l10n.subscriptionUnavailable,
  _ => l10n.conflictGeneric,
};

String _permission(AppPermission permission, AppLocalizations l10n) =>
    switch (permission) {
      AppPermission.notifications => l10n.permissionNotificationsDenied,
      AppPermission.exactAlarms => l10n.permissionExactAlarmsDenied,
      AppPermission.microphone => l10n.permissionMicrophoneDenied,
      AppPermission.speechRecognition => l10n.permissionSpeechDenied,
    };

String _feature(Feature feature, AppLocalizations l10n) => switch (feature) {
  Feature.advancedRecurrence => l10n.entitlementAdvancedRecurrence,
  Feature.advancedAnalytics => l10n.entitlementAdvancedAnalytics,
  Feature.insights || Feature.calendar || Feature.ai =>
    l10n.failureEntitlementRequired,
};

String _limit(LimitKey limit, int? allowed, AppLocalizations l10n) =>
    switch ((limit, allowed)) {
      (LimitKey.activeSeries, final count?) => l10n.limitActiveSeries(count),
      (LimitKey.recurringSeries, final count?) =>
        l10n.limitRecurringSeries(count),
      (LimitKey.voicePerMonth, final count?) => l10n.limitVoicePerMonth(count),
      _ => l10n.failureLimitReached,
    };
