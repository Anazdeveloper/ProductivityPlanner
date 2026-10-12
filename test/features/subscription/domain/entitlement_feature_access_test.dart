import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/features/subscription/domain/services/entitlement_feature_access.dart';

import '../../../helpers/fake_subscription.dart';

void main() {
  test('answers from the current plan and reports plan changes', () async {
    final h = SubscriptionHarness();
    final access = EntitlementFeatureAccess(h.repository);
    var changes = 0;
    final sub = access.changes.listen((_) => changes++);
    addTearDown(sub.cancel);

    expect(access.canUse(Feature.advancedAnalytics), isFalse);
    expect(access.limit(LimitKey.analyticsHistoryDays), 30);

    await h.repository.bindUser('u1');
    await pumpEventQueue();
    expect(changes, 0, reason: 'still the free plan');

    h.remote.entitlement = proEntitlement;
    await h.repository.refresh();
    await pumpEventQueue();

    expect(changes, 1);
    expect(access.canUse(Feature.advancedAnalytics), isTrue);
    expect(access.limit(LimitKey.analyticsHistoryDays), isNull);
  });
}
