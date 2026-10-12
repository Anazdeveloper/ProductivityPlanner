import 'package:productivity_planner/config/router/app_routes.dart';
import 'package:productivity_planner/config/router/auth_gate.dart';

/// Route protection as a pure function so every case is unit-testable.
///
/// - unknown: hold on the splash while the session is restored.
/// - unauthenticated: public pages (sign-in, register, forgot password) are
///   allowed; anything else goes to sign-in, remembering where the user was
///   going (e.g. a notification deep link) in `?from=`.
/// - authenticated: leave public pages, returning to `from` if it is safe.
///
/// Returns the path to redirect to, or `null` to stay.
String? resolveAuthRedirect(AuthGateStatus status, Uri location) {
  final path = location.path;
  final intended = _intendedLocation(location);

  switch (status) {
    case AuthGateStatus.unknown:
      if (path == AppRoutes.splash) return null;
      return _withFrom(AppRoutes.splash, intended);
    case AuthGateStatus.unauthenticated:
      if (path != AppRoutes.splash && AppRoutes.publicPaths.contains(path)) {
        return null;
      }
      return _withFrom(AppRoutes.signIn, intended);
    case AuthGateStatus.authenticated:
      if (AppRoutes.publicPaths.contains(path)) {
        return intended ?? AppRoutes.today;
      }
      return null;
  }
}

/// The page the user actually wants: their current location, or the `from`
/// they carried through splash/sign-in. Root and public pages are not targets.
String? _intendedLocation(Uri location) {
  if (AppRoutes.publicPaths.contains(location.path)) {
    return safeInternalLocation(location.queryParameters['from']);
  }
  if (location.path == '/' || location.path.isEmpty) return null;
  return location.toString();
}

String _withFrom(String path, String? from) => from == null
    ? path
    : Uri(path: path, queryParameters: {'from': from}).toString();

/// Accepts only in-app paths, so `?from=` cannot become an open redirect.
String? safeInternalLocation(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (!raw.startsWith('/') || raw.startsWith('//')) return null;
  final parsed = Uri.tryParse(raw);
  if (parsed == null || parsed.hasScheme || parsed.hasAuthority) return null;
  if (AppRoutes.publicPaths.contains(parsed.path)) return null;
  return raw;
}
