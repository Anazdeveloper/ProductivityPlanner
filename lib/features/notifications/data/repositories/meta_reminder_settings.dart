import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/notification_settings.dart';

/// [ReminderSettings] in the local `app_meta` table. Device-level: they
/// survive sign-out and are reset only by reinstalling.
final class MetaReminderSettings implements ReminderSettings {
  const MetaReminderSettings(this._meta);

  final AppMetaStore _meta;

  static bool _parse(String? value) => value != 'false';

  @override
  Future<bool> remindersEnabled() async =>
      _parse(await _meta.read(AppMetaKeys.remindersEnabled));

  @override
  Future<void> setRemindersEnabled({required bool enabled}) =>
      _meta.write(AppMetaKeys.remindersEnabled, '$enabled');

  @override
  Stream<bool> watchRemindersEnabled() =>
      _meta.watch(AppMetaKeys.remindersEnabled).map(_parse).distinct();

  @override
  Future<bool> permissionPromptShown() async =>
      await _meta.read(AppMetaKeys.notificationPromptShown) != null;

  @override
  Future<void> markPermissionPromptShown() =>
      _meta.write(AppMetaKeys.notificationPromptShown, 'true');

  @override
  Future<bool> remindersSessionActive() async =>
      await _meta.read(AppMetaKeys.remindersSessionActive) == 'true';

  @override
  Future<void> setRemindersSessionActive({required bool active}) => active
      ? _meta.write(AppMetaKeys.remindersSessionActive, 'true')
      : _meta.delete(AppMetaKeys.remindersSessionActive);
}
