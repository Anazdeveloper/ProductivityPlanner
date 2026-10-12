import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_preferences.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_preferences_cubit.dart';

import '../../../helpers/fake_notifications.dart';

void main() {
  group('NotificationCubit', () {
    late FakeNotificationPermissions permissions;
    late FakeReminderSettings settings;

    setUp(() {
      permissions = FakeNotificationPermissions(
        permission: NotificationPermission.notDetermined,
      );
      settings = FakeReminderSettings();
    });

    NotificationCubit build() => buildNotificationCubit(
      permissions: permissions,
      settings: settings,
    );

    test('loads the current access on creation', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await pumpEventQueue();
      expect(cubit.state.access?.permission, NotificationPermission.notDetermined);
      expect(cubit.state.showPermissionBanner, isTrue);
    });

    test('turn on prompts and hides the banner when granted', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await pumpEventQueue();

      await cubit.turnOn();

      expect(permissions.requests, 1);
      expect(cubit.state.access?.permission, NotificationPermission.granted);
      expect(cubit.state.showPermissionBanner, isFalse);
    });

    test('the switch turns reminders off and hides the banner', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await pumpEventQueue();

      await cubit.setRemindersEnabled(enabled: false);
      await pumpEventQueue();

      expect(cubit.state.access?.remindersEnabled, isFalse);
      expect(cubit.state.showPermissionBanner, isFalse);
    });

    test('exact alarms (Android) can be allowed', () async {
      permissions
        ..permission = NotificationPermission.granted
        ..exactAlarms = false;
      final cubit = build();
      addTearDown(cubit.close);
      await pumpEventQueue();
      expect(cubit.state.access?.exactAlarmsAllowed, isFalse);

      await cubit.allowExactAlarms();
      expect(cubit.state.access?.exactAlarmsAllowed, isTrue);
    });
  });

  group('NotificationPreferencesCubit', () {
    late FakeNotificationPreferencesRepository repository;

    setUp(() => repository = FakeNotificationPreferencesRepository());

    blocTest<NotificationPreferencesCubit, NotificationPreferencesState>(
      'loads, then saves a change',
      build: () => buildPreferencesCubit(repository),
      act: (cubit) async {
        await cubit.load();
        await cubit.setWeeklySummary(enabled: false);
      },
      // The initial "loading" state is not re-emitted.
      expect: () => [
        const NotificationPreferencesState(load: PreferencesLoad.ready),
        const NotificationPreferencesState(
          load: PreferencesLoad.ready,
          preferences: NotificationPreferences(weeklySummary: false),
          saving: true,
        ),
        const NotificationPreferencesState(
          load: PreferencesLoad.ready,
          preferences: NotificationPreferences(weeklySummary: false),
        ),
      ],
      verify: (_) => expect(repository.stored.weeklySummary, isFalse),
    );

    blocTest<NotificationPreferencesCubit, NotificationPreferencesState>(
      'rolls back when the server rejects the change',
      build: () => buildPreferencesCubit(repository),
      act: (cubit) async {
        await cubit.load();
        repository.saveFailure = const Failure.network();
        await cubit.setInsights(enabled: false);
      },
      skip: 2, // ready, then the optimistic change
      expect: () => [
        const NotificationPreferencesState(
          load: PreferencesLoad.ready,
          failure: Failure.network(),
          failureCount: 1,
        ),
      ],
    );
  });
}
