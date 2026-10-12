import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/session/fresh_install_guard.dart';
import 'package:productivity_planner/config/session/profile_home_time_zone.dart';
import 'package:productivity_planner/config/session/user_session_coordinator.dart';
import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/core/database/user_data_store.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/auth/data/datasources/session_storage.dart';
import 'package:productivity_planner/features/auth/data/models/auth_dtos.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/tasks/data/repositories/category_repository_impl.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/categories.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/occurrence_actions.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_sync.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

const _userA = '0192a1f0-7c3e-7d4a-9b2e-3f5c8d1e2a40';
const _userB = '0192a1f0-7c3e-7d4a-9b2e-3f5c8d1e2a41';

void main() {
  late FixedClock clock;
  late TasksTestHarness h;
  late FakeAuthRepository auth;
  late UserSessionCoordinator coordinator;
  late SyncTestRig sync;

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 10, 7, 9));
    h = TasksTestHarness(clock: clock);
    auth = FakeAuthRepository();
    sync = SyncTestRig(h);
    coordinator = UserSessionCoordinator(
      watchAuthState: WatchAuthState(auth),
      userData: UserDataStore(db: h.db, meta: h.meta),
      ensureDefaultCategories: EnsureDefaultCategories(h.categories),
      ensureOccurrences: EnsureOccurrencesMaterialized(h.tasks),
      syncEngine: sync.engine,
      logger: RecordingLogger(),
      reporter: h.reporter,
    )..start();
  });

  tearDown(() async {
    await pumpEventQueue();
    await coordinator.dispose();
    await h.dispose();
  });

  /// Auth states reach the coordinator asynchronously; let them arrive,
  /// then wait until it has handled all of them.
  Future<void> settle() async {
    await pumpEventQueue();
    await coordinator.idle;
  }

  Future<int> categoryCount() async =>
      (await h.db.select(h.db.categories).get()).length;

  test('signing in binds the data and seeds categories', () async {
    auth.emit(AuthState.authenticated(testUser.copyWith(id: _userA)));
    await settle();

    expect(await h.meta.read(AppMetaKeys.boundUserId), _userA);
    expect(await categoryCount(), 5);
    expect(h.reporter.errors, isEmpty);
  });

  test('an expired session keeps the data; signing out clears it', () async {
    auth.emit(AuthState.authenticated(testUser.copyWith(id: _userA)));
    await settle();

    auth.emit(
      const AuthState.unauthenticated(reason: SignOutReason.sessionExpired),
    );
    await settle();
    expect(await categoryCount(), 5);

    auth
      ..emit(AuthState.authenticated(testUser.copyWith(id: _userA)))
      ..emit(
        const AuthState.unauthenticated(reason: SignOutReason.userSignedOut),
      );
    await settle();
    expect(await categoryCount(), 0);
    expect(await h.meta.read(AppMetaKeys.boundUserId), isNull);
  });

  test('signing out keeps data that has unsynced changes', () async {
    auth.emit(AuthState.authenticated(testUser.copyWith(id: _userA)));
    await settle();
    await h.categories.createCategory(
      name: 'Errands',
      color: CategoryColor.pink,
    );

    auth.emit(
      const AuthState.unauthenticated(reason: SignOutReason.userSignedOut),
    );
    await settle();

    expect(await categoryCount(), 6);
    expect(await h.meta.read(AppMetaKeys.boundUserId), _userA);
  });

  test("a different user replaces the previous user's data", () async {
    auth.emit(AuthState.authenticated(testUser.copyWith(id: _userA)));
    await settle();
    auth
      ..emit(
        const AuthState.unauthenticated(reason: SignOutReason.sessionExpired),
      )
      ..emit(AuthState.authenticated(testUser.copyWith(id: _userB)));
    await settle();

    expect(await h.meta.read(AppMetaKeys.boundUserId), _userB);
    final ids = (await h.db.select(h.db.categories).get()).map((c) => c.id);
    expect(ids, hasLength(5));
    expect(ids, contains(defaultCategoryId(_userB, 'work')));
    expect(ids, isNot(contains(defaultCategoryId(_userA, 'work'))));
  });

  test('resuming tops up occurrences only while signed in', () async {
    coordinator.appResumed();
    await settle();
    expect(h.reporter.errors, isEmpty);

    auth.emit(AuthState.authenticated(testUser.copyWith(id: _userA)));
    await settle();
    await h.tasks.createTask(
      TaskDraft(
        details: const TaskDetails(
          title: 'Read',
          plannedDuration: Duration(minutes: 20),
        ),
        schedule: TaskSchedule(
          startDate: LocalDate(2026, 10, 7),
          timeZone: 'UTC',
          rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        ),
      ),
    );
    final before = (await h.db.select(h.db.taskOccurrences).get()).length;

    clock.current = clock.current.add(const Duration(days: 2));
    coordinator.appResumed();
    await settle();

    final after = (await h.db.select(h.db.taskOccurrences).get()).length;
    expect(after - before, 2);
  });

  group('ProfileHomeTimeZone', () {
    test('uses the profile zone when signed in, else the device', () async {
      final zone = ProfileHomeTimeZone(
        watchAuthState: WatchAuthState(auth),
        device: const FakeDeviceContext(zone: 'Europe/Berlin'),
      );
      expect(await zone.current(), 'Europe/Berlin');
      auth.emit(
        AuthState.authenticated(
          testUser.copyWith(id: _userA, timeZone: 'Asia/Kolkata'),
        ),
      );
      expect(await zone.current(), 'Asia/Kolkata');
    });
  });

  group('prepared user (sync gate)', () {
    test('is announced when the data is ready, cleared on sign-out', () async {
      final seen = <String?>[];
      final subscription = coordinator.watchPreparedUser().listen(seen.add);
      addTearDown(subscription.cancel);

      auth.emit(AuthState.authenticated(testUser.copyWith(id: _userA)));
      await settle();
      // Announced after seeding: categories exist by then.
      expect(coordinator.preparedUserId, _userA);
      expect(await categoryCount(), 5);

      auth.emit(
        const AuthState.unauthenticated(reason: SignOutReason.sessionExpired),
      );
      await settle();

      expect(seen, [null, _userA, null]);
    });

    test('sign-out waits for a sync run before clearing the data', () async {
      auth.emit(AuthState.authenticated(testUser.copyWith(id: _userA)));
      await settle();

      final gate = Completer<void>();
      sync.server.pushGate = gate;
      await h.categories.createCategory(
        name: 'Garden',
        color: CategoryColor.green,
      );
      final run = sync.engine.sync();

      auth.emit(
        const AuthState.unauthenticated(reason: SignOutReason.userSignedOut),
      );
      await pumpEventQueue();
      // Still waiting on the run: nothing cleared yet.
      expect(await categoryCount(), 6);

      gate.complete();
      expect(await run, isNull);
      await settle();
      // The push emptied the outbox, so sign-out could clear everything.
      expect(await categoryCount(), 0);
    });
  });

  group('discardSessionFromPreviousInstall', () {
    test('clears the stored session only when the database is new', () async {
      final storage = _CountingSessionStorage();
      await discardSessionFromPreviousInstall(
        database: h.db,
        sessionStorage: storage,
        logger: RecordingLogger(),
        reporter: h.reporter,
      );
      expect(storage.clears, 1);
    });
  });
}

final class _CountingSessionStorage implements SessionStorage {
  int clears = 0;

  @override
  Future<void> clear() async => clears++;

  @override
  Future<StoredSessionDto?> read() async => null;

  @override
  Future<void> write(StoredSessionDto session) async {}
}
