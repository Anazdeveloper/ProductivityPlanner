import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reconcile_reminders.dart';

import '../../../helpers/fake_notifications.dart';

void main() {
  late FakeNotificationPermissions permissions;
  late FakeReminderSettings settings;

  setUp(() {
    permissions = FakeNotificationPermissions(
      permission: NotificationPermission.notDetermined,
    );
    settings = FakeReminderSettings();
  });

  ReconcileReport report({int wanted = 3, bool enabled = true}) =>
      ReconcileReport(
        permission: NotificationPermission.notDetermined,
        remindersEnabled: enabled,
        wanted: wanted,
      );

  group('PromptForRemindersIfNeeded', () {
    late PromptForRemindersIfNeeded prompt;

    setUp(() {
      prompt = PromptForRemindersIfNeeded(
        permissions: permissions,
        settings: settings,
      );
    });

    test('asks once, when there are reminders to deliver', () async {
      expect((await prompt(report())).valueOrNull, isTrue);
      expect(permissions.requests, 1);
      expect(settings.promptShown, isTrue);

      permissions.permission = NotificationPermission.notDetermined;
      expect((await prompt(report())).valueOrNull, isFalse);
      expect(permissions.requests, 1);
    });

    test('does not ask without reminders or with reminders off', () async {
      expect((await prompt(report(wanted: 0))).valueOrNull, isFalse);
      expect((await prompt(report(enabled: false))).valueOrNull, isFalse);
      expect(permissions.requests, 0);
    });
  });

  group('RequestNotificationPermission', () {
    late RequestNotificationPermission request;

    setUp(() {
      request = RequestNotificationPermission(
        permissions: permissions,
        settings: settings,
      );
    });

    test('prompts when never asked', () async {
      final access = (await request(const NoParams())).valueOrNull;
      expect(access?.permission, NotificationPermission.granted);
      expect(permissions.requests, 1);
    });

    test('opens system settings once refused', () async {
      permissions.permission = NotificationPermission.denied;
      final access = (await request(const NoParams())).valueOrNull;
      expect(access?.permission, NotificationPermission.denied);
      expect(permissions.requests, 0);
      expect(permissions.settingsOpened, 1);
    });
  });

  test('NotificationAccess.remindersActive needs both switch and OS', () {
    const granted = NotificationAccess(
      permission: NotificationPermission.granted,
    );
    expect(granted.remindersActive, isTrue);
    expect(granted.copyWith(remindersEnabled: false).remindersActive, isFalse);
    expect(
      granted
          .copyWith(permission: NotificationPermission.denied)
          .remindersActive,
      isFalse,
    );
  });
}
