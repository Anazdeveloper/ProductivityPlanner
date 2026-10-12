import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/features/subscription/domain/entities/subscription_plan.dart';

part 'entitlement.freezed.dart';

enum SubscriptionStatus {
  /// On the free plan, never subscribed (or long expired).
  none,
  active,

  /// In a free trial.
  trial,

  /// Active but set not to renew: Pro until the period ends.
  cancelled,

  /// Payment failed; the store keeps access for a grace period.
  billingIssue,

  /// Ended; back on the free plan.
  expired,
}

/// Where the subscription is billed (and so where it is managed).
enum BillingStore { appStore, playStore, promotional, none }

/// What the user is entitled to right now (the brief's `Entitlement`):
/// their plan, the subscription behind it, and usage of counted limits.
@freezed
abstract class Entitlement with _$Entitlement {
  const factory Entitlement({
    required SubscriptionPlan plan,
    @Default(SubscriptionStatus.none) SubscriptionStatus status,
    @Default(BillingStore.none) BillingStore store,

    /// End of the paid (or trial) period.
    DateTime? periodEnd,
    @Default(false) bool willRenew,

    /// Usage of counted limits this period (e.g. voice parses).
    @Default(<LimitKey, int>{}) Map<LimitKey, int> usage,

    /// True when the server confirmed it; false for the moments after a
    /// store purchase before the server has heard about it.
    @Default(true) bool verified,

    /// Where the person changes or cancels the subscription.
    String? managementUrl,
    DateTime? updatedAt,
  }) = _Entitlement;

  const Entitlement._();

  /// The free plan, nothing purchased.
  static const free = Entitlement(plan: SubscriptionPlan.free);

  bool get isPro => plan.tier == PlanTier.pro;

  /// Where to change or cancel: the provider's link, else the store's
  /// subscription page.
  String? get manageUrl =>
      managementUrl ??
      switch (store) {
        BillingStore.appStore => 'https://apps.apple.com/account/subscriptions',
        BillingStore.playStore =>
          'https://play.google.com/store/account/subscriptions',
        BillingStore.promotional || BillingStore.none => null,
      };

  bool canUse(Feature feature) => plan.includes(feature);

  int? limit(LimitKey key) => plan.limitOf(key);
}
