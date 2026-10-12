import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/features/subscription/data/models/entitlement_json.dart';
import 'package:productivity_planner/features/subscription/data/purchases/purchases_gateway.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/plan_offer.dart';
import 'package:productivity_planner/features/subscription/domain/entities/subscription_plan.dart';

/// `GET me/entitlements` (contract §3.5) for the mock backend. Starts on
/// the free plan; [grantPro] plays the part of the store webhook.
final class SubscriptionMockBackend {
  SubscriptionMockBackend({required Clock clock}) : _clock = clock;

  final Clock _clock;
  Entitlement entitlement = Entitlement.free;

  void register(MockApiAdapter adapter) {
    adapter.on(
      'GET',
      ApiPaths.meEntitlements,
      (_) => MockResponse.json(entitlementToJson(entitlement)),
    );
  }

  void grantPro({Duration period = const Duration(days: 30)}) {
    final now = _clock.now().toUtc();
    entitlement = Entitlement(
      plan: SubscriptionPlan.pro,
      status: SubscriptionStatus.active,
      store: BillingStore.appStore,
      periodEnd: now.add(period),
      willRenew: true,
      managementUrl: 'https://apps.apple.com/account/subscriptions',
      updatedAt: now,
    );
  }
}

/// A store for mock builds: two offers, purchases succeed after a short
/// delay and tell [backend] (as the real store's webhook would).
final class MockPurchasesGateway implements PurchasesGateway {
  MockPurchasesGateway(this.backend);

  final SubscriptionMockBackend backend;

  static const _delay = Duration(milliseconds: 600);

  @override
  bool get isAvailable => true;

  @override
  Future<void> identify(String userId) async {}

  @override
  Future<void> reset() async {}

  @override
  Future<List<PlanOffer>> offers() async {
    await Future<void>.delayed(_delay);
    return const [
      PlanOffer(
        id: 'mock_annual',
        period: OfferPeriod.annual,
        price: r'$39.99',
        pricePerMonth: r'$3.33',
        freeTrial: Duration(days: 7),
      ),
      PlanOffer(id: 'mock_monthly', period: OfferPeriod.monthly, price: r'$4.99'),
    ];
  }

  @override
  Future<StoreEntitlement> purchase(String offerId) async {
    await Future<void>.delayed(_delay);
    backend.grantPro(
      period: offerId == 'mock_annual'
          ? const Duration(days: 365)
          : const Duration(days: 30),
    );
    return _store();
  }

  @override
  Future<StoreEntitlement> restore() async {
    await Future<void>.delayed(_delay);
    return _store();
  }

  StoreEntitlement _store() {
    final e = backend.entitlement;
    return e.isPro
        ? StoreEntitlement(
            active: true,
            status: e.status,
            store: e.store,
            periodEnd: e.periodEnd,
            willRenew: e.willRenew,
            managementUrl: e.managementUrl,
          )
        : StoreEntitlement.none;
  }
}
