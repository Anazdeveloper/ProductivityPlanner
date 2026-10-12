import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/session/subscription_sync.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_subscription.dart';

void main() {
  late FakeAuthRepository auth;
  late SubscriptionHarness h;
  late SubscriptionSync sync;

  setUp(() {
    auth = FakeAuthRepository(initial: const AuthState.unauthenticated());
    h = SubscriptionHarness();
    sync = SubscriptionSync(
      watchAuthState: WatchAuthState(auth),
      subscriptions: h.repository,
      clock: h.clock,
      logger: h.logger,
    )..start();
    addTearDown(sync.dispose);
  });

  test('sign-in binds the user and asks the server', () async {
    h.remote.entitlement = proEntitlement;
    auth.emit(const AuthState.authenticated(testUser));
    await pumpEventQueue();
    await sync.idle;

    expect(h.gateway.identified, [testUser.id]);
    expect(h.repository.current, proEntitlement);
  });

  test('sign-out goes back to free', () async {
    h.remote.entitlement = proEntitlement;
    auth.emit(const AuthState.authenticated(testUser));
    await pumpEventQueue();
    await sync.idle;

    auth.emit(const AuthState.unauthenticated());
    await pumpEventQueue();
    await sync.idle;

    expect(h.repository.current, Entitlement.free);
    expect(h.gateway.resets, 1);
  });

  test('resume refreshes only when stale or unconfirmed', () async {
    auth.emit(const AuthState.authenticated(testUser));
    await pumpEventQueue();
    await sync.idle;
    expect(h.remote.calls, 1);

    sync.appResumed();
    await sync.idle;
    expect(h.remote.calls, 1, reason: 'fresh');

    h.clock.current = h.clock.current.add(const Duration(hours: 7));
    sync.appResumed();
    await pumpEventQueue();
    await sync.idle;
    expect(h.remote.calls, 2);
  });
}
