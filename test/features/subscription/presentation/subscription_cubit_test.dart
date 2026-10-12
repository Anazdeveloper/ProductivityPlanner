import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/features/subscription/data/purchases/purchases_gateway.dart';
import 'package:productivity_planner/features/subscription/presentation/bloc/subscription_cubit.dart';

import '../../../helpers/fake_subscription.dart';

void main() {
  late SubscriptionHarness h;

  setUp(() async {
    h = SubscriptionHarness();
    await h.repository.bindUser('u1');
  });

  Future<void> settle() => pumpEventQueue();

  test('loads offers with the annual one selected', () async {
    final cubit = h.cubit()..start();
    addTearDown(cubit.close);
    await settle();

    expect(cubit.state.offersLoad, OffersLoad.ready);
    expect(cubit.state.offers, hasLength(2));
    expect(cubit.state.selectedOfferId, 'annual');
    expect(h.remote.calls, 1, reason: 'refreshed on open');
  });

  test('a purchase makes the user Pro', () async {
    h.gateway.storeState = storePro;
    final cubit = h.cubit()..start();
    addTearDown(cubit.close);
    await settle();

    cubit.selectOffer('monthly');
    await cubit.purchase();

    expect(h.gateway.purchases, ['monthly']);
    expect(cubit.state.entitlement.isPro, isTrue);
    expect(cubit.state.upgradedCount, 1);
    expect(cubit.state.purchasing, isFalse);
  });

  test('backing out shows nothing', () async {
    final cubit = h.cubit()..start();
    addTearDown(cubit.close);
    await settle();

    h.gateway.nextError = const PurchaseException(PurchaseErrorKind.cancelled);
    await cubit.purchase();

    expect(cubit.state.failure, const Failure.cancelled());
    expect(cubit.state.upgradedCount, 0);
  });

  test('restore with nothing found says so', () async {
    final cubit = h.cubit()..start();
    addTearDown(cubit.close);
    await settle();

    await cubit.restore();

    expect(cubit.state.nothingRestoredCount, 1);
    expect(cubit.state.restoring, isFalse);
  });

  test('a build without a store shows plans but no offers', () async {
    final noStore = SubscriptionHarness(canPurchase: false);
    final cubit = noStore.cubit()..start();
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state.offersLoad, OffersLoad.unavailable);
  });
}
