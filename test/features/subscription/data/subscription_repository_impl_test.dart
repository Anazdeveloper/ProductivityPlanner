import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/subscription/data/purchases/purchases_gateway.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/subscription_plan.dart';

import '../../../helpers/fake_subscription.dart';

void main() {
  late SubscriptionHarness h;

  setUp(() => h = SubscriptionHarness());

  test('starts free; binding a user loads their cache and identifies', () async {
    expect(h.repository.current, Entitlement.free);
    h.cache.byUser['u1'] = proEntitlement;

    await h.repository.bindUser('u1');

    expect(h.repository.current, proEntitlement);
    expect(h.gateway.identified, ['u1']);
  });

  test('another user never inherits the cache', () async {
    h.cache.byUser['u1'] = proEntitlement;
    await h.repository.bindUser('u2');
    expect(h.repository.current, Entitlement.free);
  });

  test('refresh takes the server answer and caches it', () async {
    await h.repository.bindUser('u1');
    h.remote.entitlement = proEntitlement;

    final result = await h.repository.refresh();

    expect(result.valueOrNull, proEntitlement);
    expect(h.repository.current, proEntitlement);
    expect(h.cache.byUser['u1'], proEntitlement);
  });

  test('a failed refresh keeps what is known', () async {
    h.cache.byUser['u1'] = proEntitlement;
    await h.repository.bindUser('u1');
    h.remote.error = Exception('offline');

    final result = await h.repository.refresh();

    expect(result.isErr, isTrue);
    expect(h.repository.current, proEntitlement);
  });

  test('a cached Pro long past its period counts as free', () async {
    h.cache.byUser['u1'] = proEntitlement.copyWith(
      periodEnd: h.clock.current.subtract(const Duration(days: 4)),
    );
    await h.repository.bindUser('u1');
    expect(h.repository.current.isPro, isFalse);
    expect(h.repository.current.status, SubscriptionStatus.expired);
  });

  group('purchase', () {
    setUp(() async {
      await h.repository.bindUser('u1');
      h.gateway.storeState = storePro;
    });

    test('unlocks at once, unconfirmed while the server catches up', () async {
      final result = await h.repository.purchase('annual');

      expect(h.gateway.purchases, ['annual']);
      final entitlement = result.valueOrNull;
      expect(entitlement?.isPro, isTrue);
      expect(entitlement?.verified, isFalse);
      expect(h.remote.calls, 1, reason: 'asked the server straight away');

      // The webhook arrives; the next refresh confirms.
      h.remote.entitlement = proEntitlement;
      await h.repository.refresh();
      expect(h.repository.current, proEntitlement);
      expect(h.repository.current.verified, isTrue);
    });

    test('the unconfirmed unlock ends after 24 hours', () async {
      await h.repository.purchase('annual');
      h.clock.current = h.clock.current.add(const Duration(hours: 25));
      await h.repository.refresh();
      expect(h.repository.current.isPro, isFalse);
    });

    test('backing out is a cancelled failure, nothing changes', () async {
      h.gateway.nextError = const PurchaseException(PurchaseErrorKind.cancelled);
      final result = await h.repository.purchase('annual');
      expect(result, const Err<Entitlement>(Failure.cancelled()));
      expect(h.repository.current.isPro, isFalse);
    });

    test('a pending purchase is reported as such', () async {
      h.gateway.nextError = const PurchaseException(PurchaseErrorKind.pending);
      final result = await h.repository.purchase('annual');
      expect(
        result.failureOrNull,
        const Failure.conflict(code: 'PURCHASE_PENDING'),
      );
    });
  });

  test('restore with nothing to restore stays free', () async {
    await h.repository.bindUser('u1');
    final result = await h.repository.restore();
    expect(result.valueOrNull?.isPro, isFalse);
  });

  test('sign-out returns to free, clears the cache and the store user', () async {
    h.cache.byUser['u1'] = proEntitlement;
    await h.repository.bindUser('u1');
    final seen = <Entitlement>[];
    final sub = h.repository.watch().listen(seen.add);
    addTearDown(sub.cancel);

    await h.repository.unbindUser();
    await pumpEventQueue();

    expect(h.repository.current, Entitlement.free);
    expect(h.cache.clears, 1);
    expect(h.gateway.resets, 1);
    expect(seen.map((e) => e.plan.tier), [PlanTier.pro, PlanTier.free]);
  });

  test('offers come from the store; an unavailable store is reported', () async {
    expect((await h.repository.loadOffers()).valueOrNull, hasLength(2));
    h.gateway.nextError = const PurchaseException(
      PurchaseErrorKind.unavailable,
    );
    expect(
      (await h.repository.loadOffers()).failureOrNull,
      const Failure.conflict(code: 'PURCHASES_UNAVAILABLE'),
    );
  });
}
