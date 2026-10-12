import 'package:productivity_planner/core/database/app_database.dart';

/// Keys in the `app_meta` table. One place so they never collide.
abstract final class AppMetaKeys {
  static const deviceId = 'device_id';
  static const boundUserId = 'bound_user_id';

  /// Sync pull cursor (Phase 11). Cleared with the user's data.
  static const syncCursor = 'sync_cursor';

  /// Notifications (Phase 6). Device-level: kept across sign-outs.
  static const remindersEnabled = 'reminders_enabled';
  static const notificationPromptShown = 'notification_prompt_shown';
  static const notificationPermissionAsked = 'notification_permission_asked';
  static const remindersSessionActive = 'reminders_session_active';

  /// Subscriptions (Phase 10): the last known entitlement, with its user.
  static const entitlementCache = 'entitlement_cache';
}

/// Typed access to the `app_meta` key/value table.
final class AppMetaStore {
  const AppMetaStore(this._db);

  final AppDatabase _db;

  Future<String?> read(String key) async {
    final row = await (_db.select(
      _db.appMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// Emits the value now and whenever it changes (null when absent).
  Stream<String?> watch(String key) =>
      (_db.select(_db.appMeta)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value)
          .distinct();

  Future<void> write(String key, String value) => _db
      .into(_db.appMeta)
      .insertOnConflictUpdate(
        AppMetaCompanion.insert(key: key, value: value),
      );

  Future<void> delete(String key) =>
      (_db.delete(_db.appMeta)..where((t) => t.key.equals(key))).go();
}
