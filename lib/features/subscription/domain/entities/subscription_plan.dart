import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/entitlements/feature.dart';

part 'subscription_plan.freezed.dart';

enum PlanTier { free, pro }

/// A plan and what it includes. Defined by the server (`plans` table,
/// contract §3.5); the app only reads it.
@freezed
abstract class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required PlanTier tier,
    @Default(<Feature>{}) Set<Feature> features,

    /// Limit values; a key that is absent or null is unlimited.
    @Default(<LimitKey, int?>{}) Map<LimitKey, int?> limits,
  }) = _SubscriptionPlan;

  const SubscriptionPlan._();

  /// The free plan as the server defines it (contract §3.5). Used before
  /// the first `GET me/entitlements` answer and when signed out, so a new
  /// install never starts with more than the free plan.
  static const free = SubscriptionPlan(
    tier: PlanTier.free,
    limits: {
      LimitKey.activeSeries: 20,
      LimitKey.recurringSeries: 10,
      LimitKey.remindersPerTask: 1,
      LimitKey.voicePerMonth: 30,
      LimitKey.analyticsHistoryDays: 30,
    },
  );

  /// Pro as the server defines it: every feature, no limits. Used only for
  /// the moments between a store purchase and the server confirming it.
  static const pro = SubscriptionPlan(
    tier: PlanTier.pro,
    features: {
      Feature.advancedRecurrence,
      Feature.insights,
      Feature.calendar,
      Feature.advancedAnalytics,
      Feature.ai,
    },
  );

  bool includes(Feature feature) => features.contains(feature);

  /// Null means unlimited.
  int? limitOf(LimitKey key) => limits[key];
}
