import 'dart:convert';

import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/features/subscription/data/models/entitlement_json.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';

/// The last server-confirmed entitlement, kept so Pro stays Pro offline
/// and on a cold start before the network answers. Stored with its user
/// id: another account on this device never inherits it.
abstract interface class EntitlementCache {
  /// Null when nothing is cached for [userId].
  Future<Entitlement?> read(String userId);

  Future<void> write(String userId, Entitlement entitlement);

  Future<void> clear();
}

/// [EntitlementCache] in the `app_meta` table.
final class MetaEntitlementCache implements EntitlementCache {
  const MetaEntitlementCache(this._meta);

  final AppMetaStore _meta;

  @override
  Future<Entitlement?> read(String userId) async {
    final raw = await _meta.read(AppMetaKeys.entitlementCache);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic> || json['user_id'] != userId) {
        return null;
      }
      final entitlement = json['entitlement'];
      if (entitlement is! Map<String, dynamic>) return null;
      return entitlementFromJson(entitlement);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(String userId, Entitlement entitlement) => _meta.write(
    AppMetaKeys.entitlementCache,
    jsonEncode({
      'user_id': userId,
      'entitlement': entitlementToJson(entitlement),
    }),
  );

  @override
  Future<void> clear() => _meta.delete(AppMetaKeys.entitlementCache);
}
