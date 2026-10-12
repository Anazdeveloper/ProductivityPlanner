import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/core/database/user_data_store.dart';
import 'package:productivity_planner/core/device/persistent_device_id_provider.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/sync/outbox.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late AppMetaStore meta;
  final now = DateTime.utc(2026, 10, 7, 9);

  setUp(() {
    db = testDatabase();
    meta = AppMetaStore(db);
  });

  tearDown(() => db.close());

  Future<void> insertSeriesWithOccurrence(String seriesId) async {
    await db
        .into(db.taskSeries)
        .insert(
          TaskSeriesCompanion.insert(
            id: seriesId,
            lineageId: seriesId,
            title: 'Run',
            priority: 'medium',
            plannedDurationSeconds: 1800,
            startDate: '2026-10-07',
            timeZone: 'UTC',
            frequency: 'none',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.taskOccurrences)
        .insert(
          TaskOccurrencesCompanion.insert(
            id: 'occ-$seriesId',
            seriesId: seriesId,
            originalDate: '2026-10-07',
            scheduledDate: '2026-10-07',
            plannedDurationSeconds: 1800,
            status: 'scheduled',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  group('AppDatabase', () {
    test('reports a newly created database', () async {
      expect(await db.createdOnThisLaunch(), isTrue);
    });

    test('allows only one open work session per occurrence', () async {
      await insertSeriesWithOccurrence('s1');
      WorkSessionsCompanion session(String id) => WorkSessionsCompanion.insert(
        id: id,
        occurrenceId: 'occ-s1',
        startedAt: now,
      );
      await db.into(db.workSessions).insert(session('w1'));
      await expectLater(
        db.into(db.workSessions).insert(session('w2')),
        throwsA(anything),
      );
    });

    test('rejects a second occurrence for the same series and date', () async {
      await insertSeriesWithOccurrence('s1');
      await expectLater(
        db
            .into(db.taskOccurrences)
            .insert(
              TaskOccurrencesCompanion.insert(
                id: 'other-id',
                seriesId: 's1',
                originalDate: '2026-10-07',
                scheduledDate: '2026-10-08',
                plannedDurationSeconds: 60,
                status: 'scheduled',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(anything),
      );
    });

    test('stores instants as UTC and reads them back unchanged', () async {
      await insertSeriesWithOccurrence('s1');
      final row = await db.select(db.taskSeries).getSingle();
      expect(row.createdAt.toUtc(), now);
    });
  });

  group('UserDataStore', () {
    late UserDataStore store;

    setUp(() => store = UserDataStore(db: db, meta: meta));

    test('binding the same user keeps data; another user wipes it', () async {
      expect(await store.bindToUser('user-a'), isFalse);
      await insertSeriesWithOccurrence('s1');
      await meta.write(AppMetaKeys.deviceId, 'device-1');

      expect(await store.bindToUser('user-a'), isFalse);
      expect(await db.select(db.taskSeries).get(), hasLength(1));

      expect(await store.bindToUser('user-b'), isTrue);
      expect(await db.select(db.taskSeries).get(), isEmpty);
      expect(await db.select(db.taskOccurrences).get(), isEmpty);
      expect(await meta.read(AppMetaKeys.boundUserId), 'user-b');
      expect(await meta.read(AppMetaKeys.deviceId), 'device-1');
    });

    test('clearUserData removes rows, outbox and the binding', () async {
      await store.bindToUser('user-a');
      await insertSeriesWithOccurrence('s1');
      await OutboxWriter(
        db: db,
        ids: const UuidV7IdGenerator(),
        clock: FixedClock(now),
      ).enqueue(
        type: SyncOpType.seriesCreate,
        entityId: 's1',
        payload: const {},
      );

      await store.clearUserData();

      expect(await db.select(db.taskSeries).get(), isEmpty);
      expect(await db.select(db.outboxOperations).get(), isEmpty);
      expect(await meta.read(AppMetaKeys.boundUserId), isNull);
    });
  });

  group('UserDataStore.clearUserDataIfSynced', () {
    test('keeps everything while ops are pending', () async {
      final store = UserDataStore(db: db, meta: meta);
      await store.bindToUser('user-a');
      await insertSeriesWithOccurrence('s1');
      expect(await store.clearUserDataIfSynced(), isTrue);
      expect(await db.select(db.taskSeries).get(), isEmpty);

      await store.bindToUser('user-a');
      await insertSeriesWithOccurrence('s2');
      await OutboxWriter(
        db: db,
        ids: const UuidV7IdGenerator(),
        clock: FixedClock(now),
      ).enqueue(
        type: SyncOpType.seriesCreate,
        entityId: 's2',
        payload: const {},
      );
      expect(await store.clearUserDataIfSynced(), isFalse);
      expect(await db.select(db.taskSeries).get(), hasLength(1));
      expect(await meta.read(AppMetaKeys.boundUserId), 'user-a');
    });
  });

  group('OutboxWriter', () {
    test('counts pending ops and rolls back with the transaction', () async {
      final outbox = OutboxWriter(
        db: db,
        ids: const UuidV7IdGenerator(),
        clock: FixedClock(now),
      );
      await outbox.enqueue(
        type: SyncOpType.categoryCreate,
        entityId: 'c1',
        payload: const {'id': 'c1'},
      );
      await expectLater(
        db.transaction(() async {
          await outbox.enqueue(
            type: SyncOpType.categoryCreate,
            entityId: 'c2',
            payload: const {},
          );
          throw StateError('the change failed');
        }),
        throwsStateError,
      );

      expect(await outbox.watchPendingCount().first, 1);
      final op = await db.select(db.outboxOperations).getSingle();
      expect(op.type, 'category.create');
      expect(op.payload, '{"id":"c1"}');
      expect(op.payloadSchema, syncPayloadSchema);
      expect(op.occurredAt.toUtc(), now);
    });
  });

  group('PersistentDeviceIdProvider', () {
    test('creates one id and keeps it across instances', () async {
      final first = PersistentDeviceIdProvider(
        meta: meta,
        ids: SequentialIdGenerator(),
      );
      final ids = await Future.wait([first.deviceId(), first.deviceId()]);
      expect(ids.toSet(), {'id-1'});

      final relaunched = PersistentDeviceIdProvider(
        meta: meta,
        ids: SequentialIdGenerator(),
      );
      expect(await relaunched.deviceId(), 'id-1');
    });
  });

  test('foreign keys cascade from series to occurrences', () async {
    await insertSeriesWithOccurrence('s1');
    await (db.delete(db.taskSeries)..where((t) => t.id.equals('s1'))).go();
    expect(await db.select(db.taskOccurrences).get(), isEmpty);
  });
}
