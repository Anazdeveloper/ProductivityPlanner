import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/features/subscription/data/models/entitlement_json.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/subscription_plan.dart';

void main() {
  test('reads the contract body, skipping keys it does not know', () {
    final entitlement = entitlementFromJson({
      'plan': {
        'id': 'pro',
        'features': ['feature.advanced_analytics', 'feature.teleport'],
        'limits': {'limit.active_series': null, 'limit.future_thing': 3},
      },
      'subscription': {
        'status': 'billing_issue',
        'store': 'play_store',
        'period_end': '2026-11-08T07:00:00.000Z',
        'will_renew': true,
        'management_url': 'https://play.google.com/x',
      },
      'usage': {'limit.voice_per_month': 3},
      'updated_at': '2026-10-08T07:00:00.000Z',
    });

    expect(entitlement.isPro, isTrue);
    expect(entitlement.plan.features, {Feature.advancedAnalytics});
    expect(entitlement.plan.limits, {LimitKey.activeSeries: null});
    expect(entitlement.limit(LimitKey.activeSeries), isNull);
    expect(entitlement.status, SubscriptionStatus.billingIssue);
    expect(entitlement.store, BillingStore.playStore);
    expect(entitlement.periodEnd, DateTime.utc(2026, 11, 8, 7));
    expect(entitlement.willRenew, isTrue);
    expect(entitlement.usage, {LimitKey.voicePerMonth: 3});
    expect(entitlement.manageUrl, 'https://play.google.com/x');
  });

  test('free with no subscription', () {
    final entitlement = entitlementFromJson({
      'plan': {
        'id': 'free',
        'features': <String>[],
        'limits': {'limit.active_series': 20},
      },
      'subscription': null,
    });
    expect(entitlement.isPro, isFalse);
    expect(entitlement.status, SubscriptionStatus.none);
    expect(entitlement.limit(LimitKey.activeSeries), 20);
    expect(entitlement.manageUrl, isNull);
  });

  test('a malformed body is rejected', () {
    expect(
      () => entitlementFromJson({'plan': 'pro'}),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => entitlementFromJson({
        'plan': {
          'id': 'free',
          'features': <String>[],
          'limits': {'limit.active_series': 'twenty'},
        },
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('the cache round-trips', () {
    final original = Entitlement(
      plan: SubscriptionPlan.free,
      status: SubscriptionStatus.expired,
      periodEnd: DateTime.utc(2026, 9, 1),
      usage: const {LimitKey.voicePerMonth: 2},
      updatedAt: DateTime.utc(2026, 10, 8),
    );
    expect(entitlementFromJson(entitlementToJson(original)), original);
    expect(
      entitlementFromJson(entitlementToJson(Entitlement.free)),
      Entitlement.free,
    );
  });
}
