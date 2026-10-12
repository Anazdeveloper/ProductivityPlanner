import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/entitlements/feature_access.dart';

/// A fixed plan: an analytics history window, advanced analytics, other
/// features and limits as given (the free plan in Phase 10: 30 days, no
/// advanced analytics).
final class FakeFeatureAccess implements FeatureAccessService {
  const FakeFeatureAccess({
    this.historyDays,
    this.advancedAnalytics = false,
    this.features = const {},
    this.limits = const {},
  });

  final int? historyDays;
  final bool advancedAnalytics;
  final Set<Feature> features;
  final Map<LimitKey, int> limits;

  @override
  bool canUse(Feature feature) =>
      features.contains(feature) ||
      (feature == Feature.advancedAnalytics && advancedAnalytics);

  @override
  int? limit(LimitKey key) =>
      key == LimitKey.analyticsHistoryDays ? historyDays : limits[key];

  @override
  Stream<void> get changes => const Stream.empty();
}
