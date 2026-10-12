import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/plan_offer.dart';

/// The only door to subscriptions. Callers never know whether entitlement
/// comes from RevenueCat, StoreKit, Google Play Billing or a promotion:
/// the server is the source of truth (`GET me/entitlements`), the store
/// only sells.
abstract interface class SubscriptionRepository {
  /// The entitlement as known now (cached; free when nothing is known).
  Entitlement get current;

  /// [current] first, then every change.
  Stream<Entitlement> watch();

  /// Asks the server for the latest entitlement.
  Future<Result<Entitlement>> refresh();

  /// Whether this build can sell (store configured, platform supported).
  bool get canPurchase;

  /// What the store sells, with localized prices.
  Future<Result<List<PlanOffer>>> loadOffers();

  /// Buys [offerId]. Fails with `Failure.cancelled` when the person backs
  /// out. Unlocks immediately from the store's receipt, then confirms with
  /// the server.
  Future<Result<Entitlement>> purchase(String offerId);

  /// Restores purchases made with the same store account.
  Future<Result<Entitlement>> restore();

  /// Ties purchases and the cached entitlement to [userId].
  Future<void> bindUser(String userId);

  /// Back to the free plan (signed out).
  Future<void> unbindUser();
}
