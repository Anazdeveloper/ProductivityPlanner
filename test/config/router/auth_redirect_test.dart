import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/router/app_routes.dart';
import 'package:productivity_planner/config/router/auth_gate.dart';
import 'package:productivity_planner/config/router/auth_redirect.dart';

void main() {
  String? redirect(AuthGateStatus status, String location) =>
      resolveAuthRedirect(status, Uri.parse(location));

  group('unknown session', () {
    test('holds on splash and remembers the destination', () {
      expect(
        redirect(AuthGateStatus.unknown, '/occurrences/abc'),
        '/splash?from=%2Foccurrences%2Fabc',
      );
    });

    test('stays on splash', () {
      expect(redirect(AuthGateStatus.unknown, AppRoutes.splash), isNull);
    });
  });

  group('signed out', () {
    test('protected route goes to sign-in with from', () {
      expect(
        redirect(AuthGateStatus.unauthenticated, AppRoutes.today),
        '/sign-in?from=%2Ftoday',
      );
    });

    test('root goes to plain sign-in', () {
      expect(
        redirect(AuthGateStatus.unauthenticated, '/'),
        AppRoutes.signIn,
      );
    });

    test('splash forwards its from to sign-in', () {
      expect(
        redirect(
          AuthGateStatus.unauthenticated,
          '/splash?from=%2Foccurrences%2Fabc',
        ),
        '/sign-in?from=%2Foccurrences%2Fabc',
      );
    });

    test('register and forgot-password are reachable signed out', () {
      expect(
        redirect(AuthGateStatus.unauthenticated, '/register?from=%2Ftoday'),
        isNull,
      );
      expect(
        redirect(AuthGateStatus.unauthenticated, AppRoutes.forgotPassword),
        isNull,
      );
    });

    test('stays on sign-in', () {
      expect(
        redirect(AuthGateStatus.unauthenticated, '/sign-in?from=%2Ftoday'),
        isNull,
      );
    });
  });

  group('signed in', () {
    test('protected route is allowed', () {
      expect(redirect(AuthGateStatus.authenticated, AppRoutes.today), isNull);
    });

    test('sign-in returns to the remembered destination', () {
      expect(
        redirect(
          AuthGateStatus.authenticated,
          '/sign-in?from=%2Foccurrences%2Fabc',
        ),
        '/occurrences/abc',
      );
    });

    test('finishing registration returns to the remembered destination', () {
      expect(
        redirect(
          AuthGateStatus.authenticated,
          '/register?from=%2Foccurrences%2Fabc',
        ),
        '/occurrences/abc',
      );
    });

    test('sign-in without from goes to Today', () {
      expect(
        redirect(AuthGateStatus.authenticated, AppRoutes.signIn),
        AppRoutes.today,
      );
    });

    test('external or protocol-relative from is ignored (no open redirect)', () {
      expect(
        redirect(
          AuthGateStatus.authenticated,
          '/sign-in?from=https%3A%2F%2Fevil.example',
        ),
        AppRoutes.today,
      );
      expect(
        redirect(AuthGateStatus.authenticated, '/sign-in?from=%2F%2Fevil.example'),
        AppRoutes.today,
      );
    });

    test('from pointing at a public page is ignored (no redirect loop)', () {
      expect(
        redirect(AuthGateStatus.authenticated, '/sign-in?from=%2Fsplash'),
        AppRoutes.today,
      );
    });
  });
}
