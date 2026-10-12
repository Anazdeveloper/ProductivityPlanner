import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/subscription_plan.dart';

// `GET me/entitlements` (contract §3.5) ↔ [Entitlement]. Written by hand
// rather than generated: unknown feature and limit keys must be skipped,
// not rejected, so the server can add plan contents without breaking
// older apps. Throws FormatException for a malformed body.

const _statusWire = <String, SubscriptionStatus>{
  'none': SubscriptionStatus.none,
  'active': SubscriptionStatus.active,
  'trial': SubscriptionStatus.trial,
  'cancelled': SubscriptionStatus.cancelled,
  'billing_issue': SubscriptionStatus.billingIssue,
  'expired': SubscriptionStatus.expired,
};

const _storeWire = <String, BillingStore>{
  'app_store': BillingStore.appStore,
  'play_store': BillingStore.playStore,
  'promotional': BillingStore.promotional,
};

Entitlement entitlementFromJson(Map<String, dynamic> json) {
  final plan = _map(json['plan'], 'plan');
  final features = <Feature>{
    for (final key in _list(plan['features'], 'plan.features'))
      for (final feature in Feature.values)
        if (feature.key == key) feature,
  };
  final limits = <LimitKey, int?>{
    for (final MapEntry(:key, :value)
        in _map(plan['limits'], 'plan.limits').entries)
      for (final limit in LimitKey.values)
        if (limit.key == key) limit: _intOrNull(value, 'plan.limits.$key'),
  };
  final subscription = json['subscription'] == null
      ? const <String, dynamic>{}
      : _map(json['subscription'], 'subscription');
  final usage = <LimitKey, int>{
    for (final MapEntry(:key, :value)
        in (json['usage'] == null
                ? const <String, dynamic>{}
                : _map(json['usage'], 'usage'))
            .entries)
      for (final limit in LimitKey.values)
        if (limit.key == key && value is int) limit: value,
  };
  return Entitlement(
    plan: SubscriptionPlan(
      tier: plan['id'] == 'free' ? PlanTier.free : PlanTier.pro,
      features: features,
      limits: limits,
    ),
    status: _statusWire[subscription['status']] ?? SubscriptionStatus.none,
    store: _storeWire[subscription['store']] ?? BillingStore.none,
    periodEnd: _instant(subscription['period_end']),
    willRenew: subscription['will_renew'] == true,
    managementUrl: subscription['management_url'] as String?,
    usage: usage,
    updatedAt: _instant(json['updated_at']),
  );
}

/// The same shape, for the local cache.
Map<String, dynamic> entitlementToJson(Entitlement e) => {
  'plan': {
    'id': e.plan.tier == PlanTier.free ? 'free' : 'pro',
    'features': [for (final f in e.plan.features) f.key],
    'limits': {
      for (final MapEntry(:key, :value) in e.plan.limits.entries)
        key.key: value,
    },
  },
  'subscription': {
    'status': _statusWire.entries
        .firstWhere(
          (w) => w.value == e.status,
          orElse: () => const MapEntry('none', SubscriptionStatus.none),
        )
        .key,
    if (_storeKey(e.store) case final store?) 'store': store,
    if (e.periodEnd case final end?) 'period_end': end.toUtc().toIso8601String(),
    'will_renew': e.willRenew,
    if (e.managementUrl case final url?) 'management_url': url,
  },
  'usage': {
    for (final MapEntry(:key, :value) in e.usage.entries) key.key: value,
  },
  if (e.updatedAt case final at?) 'updated_at': at.toUtc().toIso8601String(),
};

String? _storeKey(BillingStore store) {
  for (final MapEntry(:key, :value) in _storeWire.entries) {
    if (value == store) return key;
  }
  return null;
}

Map<String, dynamic> _map(Object? value, String field) => value is Map
    ? Map<String, dynamic>.from(value)
    : throw FormatException('Expected an object', field);

List<Object?> _list(Object? value, String field) =>
    value is List ? value : throw FormatException('Expected a list', field);

int? _intOrNull(Object? value, String field) => switch (value) {
  null => null,
  final int number => number,
  _ => throw FormatException('Expected an integer or null', field),
};

DateTime? _instant(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toUtc() : null;
