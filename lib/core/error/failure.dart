import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/error/app_permission.dart';

part 'failure.freezed.dart';

/// Every expected error the app can surface. Data-layer exceptions are mapped
/// to one of these at the repository boundary; nothing above `data/` ever sees
/// a raw exception.
///
/// Pure Dart: usable from domain code.
@freezed
sealed class Failure with _$Failure {
  /// No connectivity, DNS failure, timeout. Local writes still succeed.
  const factory Failure.network() = NetworkFailure;

  /// Access token rejected and refresh failed; user must sign in again.
  const factory Failure.unauthenticated() = UnauthenticatedFailure;

  /// Email/password sign-in rejected (`401 INVALID_CREDENTIALS`).
  const factory Failure.invalidCredentials() = InvalidCredentialsFailure;

  /// The user dismissed a flow (Apple/Google sheet, permission prompt).
  /// Not an error: the UI shows nothing.
  const factory Failure.cancelled() = CancelledFailure;

  /// Authenticated but not allowed (e.g. another user's resource).
  const factory Failure.forbidden() = ForbiddenFailure;

  /// Input rejected locally or by the server (`errors[]` in problem+json).
  const factory Failure.validation({
    @Default(<String, String>{}) Map<String, String> fieldErrors,
    String? message,
  }) = ValidationFailure;

  const factory Failure.notFound({String? entity}) = NotFoundFailure;

  /// Sync/lifecycle conflicts, carrying the server's stable code, e.g.
  /// `ALREADY_RESOLVED`, `INVALID_TRANSITION`, `STALE_VERSION`, `ENTITY_DELETED`.
  const factory Failure.conflict({required String code, String? message}) =
      ConflictFailure;

  const factory Failure.server({
    int? statusCode,
    String? code,
    String? requestId,
  }) = ServerFailure;

  /// Local database read/write failed.
  const factory Failure.database({String? message}) = DatabaseFailure;

  const factory Failure.permissionDenied({
    required AppPermission permission,
    @Default(false) bool permanently,
  }) = PermissionDeniedFailure;

  /// The current plan does not include [feature]; UI maps this to a paywall.
  const factory Failure.entitlementRequired({required Feature feature}) =
      EntitlementRequiredFailure;

  /// The current plan's [limit] is exhausted.
  const factory Failure.limitReached({required LimitKey limit, int? allowed}) =
      LimitReachedFailure;

  /// A bug. Reported to error tracking; shown to the user generically.
  const factory Failure.unexpected({Object? cause, StackTrace? stackTrace}) =
      UnexpectedFailure;
}
