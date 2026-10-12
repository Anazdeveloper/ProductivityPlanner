import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/plan_offer.dart';

/// A store purchase provider: RevenueCat today; StoreKit or Play Billing
/// directly would be another implementation. Only the subscription data
/// layer talks to it.
abstract interface class PurchasesGateway {
  /// False when this build cannot sell (no store key configured).
  bool get isAvailable;

  /// Attributes purchases to [userId] (so the server's webhook knows whose
  /// they are) and restores that user's store state.
  Future<void> identify(String userId);

  /// Forgets the user (signed out).
  Future<void> reset();

  /// Throws [PurchaseException].
  Future<List<PlanOffer>> offers();

  /// Throws [PurchaseException] (kind `cancelled` when the person backs
  /// out of the store sheet).
  Future<StoreEntitlement> purchase(String offerId);

  /// Throws [PurchaseException].
  Future<StoreEntitlement> restore();
}

/// What the store says right now (before the server has confirmed it).
@immutable
final class StoreEntitlement {
  const StoreEntitlement({
    required this.active,
    this.status = SubscriptionStatus.none,
    this.store = BillingStore.none,
    this.periodEnd,
    this.willRenew = false,
    this.managementUrl,
  });

  static const none = StoreEntitlement(active: false);

  /// The Pro entitlement is active in the store.
  final bool active;
  final SubscriptionStatus status;
  final BillingStore store;
  final DateTime? periodEnd;
  final bool willRenew;
  final String? managementUrl;

  @override
  bool operator ==(Object other) =>
      other is StoreEntitlement &&
      other.active == active &&
      other.status == status &&
      other.store == store &&
      other.periodEnd == periodEnd &&
      other.willRenew == willRenew &&
      other.managementUrl == managementUrl;

  @override
  int get hashCode =>
      Object.hash(active, status, store, periodEnd, willRenew, managementUrl);
}

enum PurchaseErrorKind {
  cancelled,
  network,

  /// Purchases are disabled on this device (parental controls, MDM).
  notAllowed,

  /// Waiting for approval (Ask to Buy, pending payment).
  pending,
  unavailable,
  unknown,
}

final class PurchaseException implements Exception {
  const PurchaseException(this.kind, [this.detail]);

  final PurchaseErrorKind kind;
  final String? detail;

  @override
  String toString() => 'PurchaseException($kind${detail == null ? '' : ', $detail'})';
}

/// The gateway for builds without a store key: shows plans, sells nothing.
final class UnavailablePurchasesGateway implements PurchasesGateway {
  const UnavailablePurchasesGateway();

  @override
  bool get isAvailable => false;

  @override
  Future<void> identify(String userId) async {}

  @override
  Future<void> reset() async {}

  @override
  Future<List<PlanOffer>> offers() async =>
      throw const PurchaseException(PurchaseErrorKind.unavailable);

  @override
  Future<StoreEntitlement> purchase(String offerId) async =>
      throw const PurchaseException(PurchaseErrorKind.unavailable);

  @override
  Future<StoreEntitlement> restore() async =>
      throw const PurchaseException(PurchaseErrorKind.unavailable);
}
