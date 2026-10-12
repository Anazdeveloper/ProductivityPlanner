import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/session/device_sync.dart';
import 'package:productivity_planner/config/session/reminder_sync.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/time/ticker.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';
import 'package:productivity_planner/features/notifications/domain/services/reminder_planner.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/push.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reconcile_reminders.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/home_time_zone.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_notifications.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

const _zone = 'Asia/Kolkata';

final class _Zone implements HomeTimeZone {
  @override
  Future<String> current() async => _zone;
}

/// Ticks only when the test says so.
final class _ManualTicker implements Ticker {
  @override
  Stream<DateTime> ticks() => const Stream.empty();
}

void main() {
  group('ReminderSync', () {
    late FixedClock clock;
    late TasksTestHarness h;
    late FakeAuthRepository auth;
    late FakeReminderScheduler scheduler;
    late FakeNotificationPermissions permissions;
    late FakeReminderSettings settings;
    late ReminderSync sync;

    setUp(() {
      clock = FixedClock(DateTime.utc(2026, 10, 7, 2));
      h = TasksTestHarness(clock: clock);
      auth = FakeAuthRepository();
      scheduler = FakeReminderScheduler();
      permissions = FakeNotificationPermissions();
      settings = FakeReminderSettings();
      final zone = _Zone();
      final reconcile = ReconcileReminders(
        tasks: h.tasks,
        scheduler: scheduler,
        permissions: permissions,
        settings: settings,
        planner: const ReminderPlanner(),
        homeTimeZone: zone,
        converter: h.converter,
        clock: clock,
      );
      sync = ReminderSync(
        watchAuthState: WatchAuthState(auth),
        watchAgenda: WatchAgenda(h.tasks),
        getHomeToday: GetHomeToday(
          homeTimeZone: zone,
          converter: h.converter,
          clock: clock,
        ),
        reconcile: reconcile,
        activate: ActivateReminderSession(settings),
        cancelAll: CancelAllReminders(
          scheduler: scheduler,
          settings: settings,
        ),
        promptIfNeeded: PromptForRemindersIfNeeded(
          permissions: permissions,
          settings: settings,
        ),
        watchRemindersEnabled: WatchRemindersEnabled(settings),
        ticker: _ManualTicker(),
        logger: RecordingLogger(),
        reporter: h.reporter,
        debounce: Duration.zero,
      )..start();
    });

    tearDown(() async {
      await sync.dispose();
      await h.dispose();
    });

    Future<void> settle() async {
      await pumpEventQueue();
      await sync.idle;
      await pumpEventQueue();
      await sync.idle;
    }

    Future<void> createTask() => h.tasks.createTask(
      TaskDraft(
        details: const TaskDetails(
          title: 'Read',
          plannedDuration: Duration(minutes: 20),
        ),
        schedule: TaskSchedule(
          startDate: LocalDate(2026, 10, 7),
          startTime: LocalTime(9, 0),
          timeZone: _zone,
        ),
      ),
    );

    test('reconciles after sign-in and whenever tasks change', () async {
      auth.emit(const AuthState.authenticated(testUser));
      await settle();
      expect(scheduler.scheduled, isEmpty);
      expect(settings.sessionActive, isTrue);

      await createTask();
      await settle();

      expect(scheduler.reminders, hasLength(1));
      expect(h.reporter.errors, isEmpty);
    });

    test('signing out cancels every reminder', () async {
      auth.emit(const AuthState.authenticated(testUser));
      await createTask();
      await settle();
      expect(scheduler.reminders, hasLength(1));

      auth.emit(
        const AuthState.unauthenticated(reason: SignOutReason.userSignedOut),
      );
      await settle();
      expect(scheduler.scheduled, isEmpty);
      expect(settings.sessionActive, isFalse);

      // Changes while signed out schedule nothing.
      await createTask();
      await settle();
      expect(scheduler.scheduled, isEmpty);
    });

    test('asks for permission once, after a save, then schedules', () async {
      permissions.permission = NotificationPermission.notDetermined;
      // Tasks with reminders already exist at sign-in: no prompt at launch.
      await createTask();
      auth.emit(const AuthState.authenticated(testUser));
      await settle();
      expect(permissions.requests, 0);

      await createTask();
      await settle();
      expect(permissions.requests, 0, reason: 'database changes never prompt');

      sync.requestReconcile(allowPrompt: true); // the editor saved
      await settle();

      expect(permissions.requests, 1);
      expect(scheduler.reminders, hasLength(2));
    });

    test('does not prompt while the app is in the background', () async {
      permissions.permission = NotificationPermission.notDetermined;
      sync.appPaused();
      auth.emit(const AuthState.authenticated(testUser));
      await settle();
      await createTask();
      sync.requestReconcile(allowPrompt: true);
      await settle();

      expect(permissions.requests, 0);
      expect(scheduler.scheduled, isEmpty);
    });

    test('a cold start into a signed-out state clears notifications', () async {
      await scheduler.schedule(
        ReminderRequest(
          id: 1,
          occurrenceId: 'old',
          kind: ReminderKind.reminder,
          fireAt: DateTime.utc(2026, 10, 8),
          taskTitle: 'From the revoked session',
          startAt: DateTime.utc(2026, 10, 8, 0, 5),
          timeZone: _zone,
        ),
      );
      auth.emit(
        const AuthState.unauthenticated(reason: SignOutReason.sessionExpired),
      );
      await settle();
      expect(scheduler.scheduled, isEmpty);
    });

    test('the reminders switch is followed', () async {
      auth.emit(const AuthState.authenticated(testUser));
      await createTask();
      await settle();

      await settings.setRemindersEnabled(enabled: false);
      await settle();
      expect(scheduler.scheduled, isEmpty);

      await settings.setRemindersEnabled(enabled: true);
      await settle();
      expect(scheduler.reminders, hasLength(1));
    });
  });

  group('DeviceSync', () {
    late FixedClock clock;
    late FakeAuthRepository auth;
    late FakePushMessaging push;
    late FakeReminderSettings settings;
    late FakeDeviceRegistrationRepository devices;
    late DeviceSync sync;

    setUp(() {
      auth = FakeAuthRepository();
      push = FakePushMessaging();
      settings = FakeReminderSettings();
      devices = FakeDeviceRegistrationRepository();
      clock = FixedClock(DateTime.utc(2026, 10, 7, 9));
      sync = DeviceSync(
        watchAuthState: WatchAuthState(auth),
        push: push,
        watchRemindersEnabled: WatchRemindersEnabled(settings),
        registerDevice: RegisterDevice(
          push: push,
          settings: settings,
          devices: devices,
        ),
        clock: clock,
        logger: RecordingLogger(),
      )..start();
    });

    tearDown(() => sync.dispose());

    Future<void> settle() async {
      await pumpEventQueue();
      await sync.idle;
    }

    test('registers on sign-in, token refresh and switch change', () async {
      await settle();
      expect(devices.calls, isEmpty, reason: 'signed out');

      auth.emit(const AuthState.authenticated(testUser));
      await settle();
      expect(devices.calls, [('token-1', true)]);

      push.currentToken = 'token-2';
      push.refreshes.add('token-2');
      await settle();
      await settings.setRemindersEnabled(enabled: false);
      await settle();

      expect(devices.calls, [
        ('token-1', true),
        ('token-2', true),
        ('token-2', false),
      ]);
    });

    test('retries on resume after an offline failure', () async {
      devices.nextFailure = const Failure.network();
      auth.emit(const AuthState.authenticated(testUser));
      await settle();
      expect(devices.calls, hasLength(1));

      sync.appResumed();
      await settle();
      expect(devices.calls, hasLength(2));

      sync.appResumed();
      await settle();
      expect(devices.calls, hasLength(2), reason: 'already registered');

      clock.current = clock.current.add(const Duration(hours: 13));
      sync.appResumed();
      await settle();
      expect(devices.calls, hasLength(3), reason: 'refreshed after 12 h');
    });
  });
}
