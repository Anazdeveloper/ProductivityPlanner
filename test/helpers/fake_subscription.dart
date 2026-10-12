import 'package:productivity_planner/features/subscription/data/datasources/entitlement_cache.dart';
import 'package:productivity_planner/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:productivity_planner/features/subscription/data/purchases/purchases_gateway.dart';
import 'package:productivity_planner/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/plan_offer.dart';
import 'package:productivity_planner/features/subscription/domain/entities/subscription_plan.dart';
import 'package:productivity_planner/features/subscription/domain/usecases/subscription_usecases.dart';
import 'package:productivity_planner/features/subscription/presentation/bloc/subscription_cubit.dart';

import 'fakes.dart';

/// Pro as the server reports it after a purchase.
final proEntitlement = Entitlement(
  plan: SubscriptionPlan.pro,
  status: SubscriptionStatus.active,
  store: BillingStore.appStore,
  periodEnd: DateTime.utc(2026, 11, 8),
  willRenew: true,
);

/// The server: answers [entitlement], or throws [error] when set.
final class FakeSubscriptionRemote implements SubscriptionRemoteDataSource {
  Entitlement entitlement = Entitlement.free;
  Exception? error;
  int calls = 0;

  @override
  Future<Entitlement> getEntitlement() async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return entitlement;
  }
}

final class FakePurchasesGateway implements PurchasesGateway {
  FakePurchasesGateway({this.isAvailable = true});

  @override
  bool isAvailable;

  List<PlanOffer> offerList = const [
    PlanOffer(id: 'monthly', period: OfferPeriod.monthly, price: r'$4.99'),
    PlanOffer(
      id: 'annual',
      period: OfferPeriod.annual,
      price: r'$39.99',
      pricePerMonth: r'$3.33',
      freeTrial: Duration(days: 7),
    ),
  ];

  /// What the store reports after a purchase or restore.
  StoreEntitlement storeState = StoreEntitlement.none;

  /// Thrown by the next purchase/restore/offers call, when set.
  PurchaseException? nextError;

  final List<String> identified = [];
  final List<String> purchases = [];
  int resets = 0;

  @override
  Future<void> identify(String userId) async => identified.add(userId);

  @override
  Future<void> reset() async => resets++;

  @override
  Future<List<PlanOffer>> offers() async {
    _throwIfSet();
    return offerList;
  }

  @override
  Future<StoreEntitlement> purchase(String offerId) async {
    _throwIfSet();
    purchases.add(offerId);
    return storeState;
  }

  @override
  Future<StoreEntitlement> restore() async {
    _throwIfSet();
    return storeState;
  }

  void _throwIfSet() {
    final error = nextError;
    nextError = null;
    if (error != null) throw error;
  }
}

/// An active Pro subscription as the store reports it.
final storePro = StoreEntitlement(
  active: true,
  status: SubscriptionStatus.active,
  store: BillingStore.appStore,
  periodEnd: DateTime.utc(2026, 11, 8),
  willRenew: true,
);

final class MemoryEntitlementCache implements EntitlementCache {
  final Map<String, Entitlement> byUser = {};
  int clears = 0;

  @override
  Future<Entitlement?> read(String userId) async => byUser[userId];

  @override
  Future<void> write(String userId, Entitlement entitlement) async =>
      byUser[userId] = entitlement;

  @override
  Future<void> clear() async {
    clears++;
    byUser.clear();
  }
}

/// The repository over fakes, plus a cubit factory.
final class SubscriptionHarness {
  SubscriptionHarness({FixedClock? clock, bool canPurchase = true})
    : clock = clock ?? FixedClock(DateTime.utc(2026, 10, 8, 7)),
      gateway = FakePurchasesGateway(isAvailable: canPurchase);

  final FixedClock clock;
  final remote = FakeSubscriptionRemote();
  final FakePurchasesGateway gateway;
  final cache = MemoryEntitlementCache();
  final logger = RecordingLogger();
  final reporter = RecordingErrorReporter();

  late final repository = SubscriptionRepositoryImpl(
    remote: remote,
    gateway: gateway,
    cache: cache,
    clock: clock,
    logger: logger,
    reporter: reporter,
  );

  SubscriptionCubit cubit() => SubscriptionCubit(
    watchEntitlement: WatchEntitlement(repository),
    refreshEntitlement: RefreshEntitlement(repository),
    loadOffers: LoadPlanOffers(repository),
    purchasePlan: PurchasePlan(repository),
    restorePurchases: RestorePurchases(repository),
  );
}
