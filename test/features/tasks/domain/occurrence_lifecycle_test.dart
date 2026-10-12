import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';

import '../../../helpers/fakes.dart';

const _zone = 'Asia/Kolkata';
final _t0 = DateTime.utc(2026, 10, 7, 3, 30); // 09:00 in Kolkata

TaskOccurrence _occurrence({
  OccurrenceStatus status = OccurrenceStatus.scheduled,
  DateTime? start,
}) => TaskOccurrence(
  id: 'occ-1',
  seriesId: 'series-1',
  originalDate: LocalDate(2026, 10, 7),
  scheduledDate: LocalDate(2026, 10, 7),
  scheduledStart: start ?? _t0,
  originalStart: start ?? _t0,
  plannedDuration: const Duration(minutes: 30),
  status: status,
  createdAt: _t0,
  updatedAt: _t0,
);

void main() {
  late OccurrenceLifecycle lifecycle;

  setUp(() {
    lifecycle = OccurrenceLifecycle(
      ids: SequentialIdGenerator(),
      converter: TzTimeZoneConverter(),
    );
  });

  LifecycleOutcome ok(Result<LifecycleOutcome> result) => switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw TestFailure('Expected Ok, got $failure'),
  };

  Failure err(Result<LifecycleOutcome> result) => switch (result) {
    Ok(:final value) => throw TestFailure('Expected Err, got $value'),
    Err(:final failure) => failure,
  };

  Result<LifecycleOutcome> apply(
    TaskOccurrence occurrence,
    OccurrenceAction action, {
    List<WorkSession> sessions = const [],
    WorkSession? other,
    DateTime? now,
  }) => lifecycle.apply(
    occurrence: occurrence,
    action: action,
    sessions: sessions,
    otherOpenSession: other,
    timeZone: _zone,
    now: now ?? _t0,
  );

  group('start', () {
    test('opens a session and records the actual start', () {
      final outcome = ok(apply(_occurrence(), const StartOccurrence()));
      expect(outcome.transition, OccurrenceTransition.started);
      expect(outcome.occurrence.status, OccurrenceStatus.inProgress);
      expect(outcome.occurrence.actualStart, _t0);
      expect(outcome.sessions.single.isOpen, isTrue);
      expect(outcome.events.single.type, OccurrenceTransition.started);
    });

    test('resumes a paused occurrence, keeping the first actual start', () {
      final paused = _occurrence(
        status: OccurrenceStatus.inProgress,
      ).copyWith(actualStart: _t0);
      final later = _t0.add(const Duration(minutes: 20));
      final outcome = ok(
        apply(
          paused,
          const StartOccurrence(),
          sessions: [
            WorkSession(
              id: 's1',
              occurrenceId: 'occ-1',
              startedAt: _t0,
              endedAt: _t0.add(const Duration(minutes: 10)),
              endReason: SessionEndReason.paused,
            ),
          ],
          now: later,
        ),
      );
      expect(outcome.transition, OccurrenceTransition.resumed);
      expect(outcome.occurrence.actualStart, _t0);
      expect(outcome.sessions.single.startedAt, later);
    });

    test('auto-pauses another running occurrence', () {
      final other = WorkSession(
        id: 'other-session',
        occurrenceId: 'occ-2',
        startedAt: _t0.subtract(const Duration(minutes: 5)),
      );
      final outcome = ok(
        apply(_occurrence(), const StartOccurrence(), other: other),
      );
      final paused = outcome.autoPausedSession;
      expect(paused?.id, 'other-session');
      expect(paused?.endedAt, _t0);
      expect(paused?.endReason, SessionEndReason.autoPaused);
      expect(outcome.sessions, hasLength(2));
      expect(
        outcome.events.map((e) => (e.occurrenceId, e.type)),
        [
          ('occ-1', OccurrenceTransition.started),
          ('occ-2', OccurrenceTransition.paused),
        ],
      );
    });

    test('is rejected while already running or once resolved', () {
      final running = _occurrence(status: OccurrenceStatus.inProgress);
      final open = WorkSession(id: 's', occurrenceId: 'occ-1', startedAt: _t0);
      expect(
        err(apply(running, const StartOccurrence(), sessions: [open])),
        isA<ConflictFailure>().having(
          (f) => f.code,
          'code',
          OccurrenceLifecycle.invalidTransition,
        ),
      );
      expect(
        err(
          apply(
            _occurrence(status: OccurrenceStatus.completed),
            const StartOccurrence(),
          ),
        ),
        isA<ConflictFailure>(),
      );
    });
  });

  group('pause', () {
    test('closes the running session', () {
      final open = WorkSession(id: 's', occurrenceId: 'occ-1', startedAt: _t0);
      final now = _t0.add(const Duration(minutes: 12));
      final outcome = ok(
        apply(
          _occurrence(status: OccurrenceStatus.inProgress),
          const PauseOccurrence(),
          sessions: [open],
          now: now,
        ),
      );
      expect(outcome.occurrence.status, OccurrenceStatus.inProgress);
      expect(outcome.sessions.single.endedAt, now);
      expect(outcome.sessions.single.endReason, SessionEndReason.paused);
    });

    test('is rejected when nothing is running', () {
      expect(
        err(apply(_occurrence(), const PauseOccurrence())),
        isA<ConflictFailure>(),
      );
    });
  });

  group('complete', () {
    test('sums all sessions, including the one it closes', () {
      final sessions = [
        WorkSession(
          id: 's1',
          occurrenceId: 'occ-1',
          startedAt: _t0,
          endedAt: _t0.add(const Duration(minutes: 10)),
        ),
        WorkSession(
          id: 's2',
          occurrenceId: 'occ-1',
          startedAt: _t0.add(const Duration(minutes: 20)),
        ),
      ];
      final now = _t0.add(const Duration(minutes: 35));
      final outcome = ok(
        apply(
          _occurrence(status: OccurrenceStatus.inProgress),
          const CompleteOccurrence(),
          sessions: sessions,
          now: now,
        ),
      );
      expect(outcome.occurrence.status, OccurrenceStatus.completed);
      expect(outcome.occurrence.actualDuration, const Duration(minutes: 25));
      expect(outcome.occurrence.actualStart, _t0);
      expect(outcome.occurrence.resolvedAt, now);
      expect(outcome.sessions.single.id, 's2');
      expect(outcome.sessions.single.endReason, SessionEndReason.completed);
    });

    test('without any session leaves the duration unmeasured', () {
      final outcome = ok(apply(_occurrence(), const CompleteOccurrence()));
      expect(outcome.occurrence.actualDuration, isNull);
      expect(outcome.sessions, isEmpty);
    });

    test('an entered duration overrides tracked time', () {
      final outcome = ok(
        apply(
          _occurrence(),
          const CompleteOccurrence(actualDuration: Duration(minutes: 25)),
        ),
      );
      expect(outcome.occurrence.actualDuration, const Duration(minutes: 25));
      expect(outcome.events.single.data, {'entered_duration': 1500});
    });

    test('rejects an impossible entered duration', () {
      expect(
        err(
          apply(
            _occurrence(),
            const CompleteOccurrence(actualDuration: Duration(hours: 25)),
          ),
        ),
        const Failure.validation(
          fieldErrors: {TaskFields.actualDuration: TaskRuleCodes.outOfRange},
        ),
      );
    });
  });

  group('skip', () {
    test('records the reason', () {
      final outcome = ok(
        apply(_occurrence(), const SkipOccurrence(SkipReason.noTime)),
      );
      expect(outcome.occurrence.status, OccurrenceStatus.skipped);
      expect(outcome.occurrence.skipReason, SkipReason.noTime);
    });

    test('is not allowed once started', () {
      expect(
        err(
          apply(
            _occurrence(status: OccurrenceStatus.inProgress),
            const SkipOccurrence(SkipReason.other),
          ),
        ),
        isA<ConflictFailure>(),
      );
    });
  });

  group('postpone', () {
    test('moves the slot, keeps the original start and counts', () {
      final outcome = ok(
        apply(
          _occurrence(),
          PostponeOccurrence(
            toDate: LocalDate(2026, 10, 8),
            toTime: LocalTime(18, 0),
          ),
        ),
      );
      final o = outcome.occurrence;
      expect(o.status, OccurrenceStatus.scheduled);
      expect(o.scheduledDate, LocalDate(2026, 10, 8));
      expect(o.scheduledStart, DateTime.utc(2026, 10, 8, 12, 30));
      expect(o.originalStart, _t0);
      expect(o.originalDate, LocalDate(2026, 10, 7));
      expect(o.postponeCount, 1);
      expect(outcome.events.single.data['to_date'], '2026-10-08');
    });

    test('to a date without a time makes it any-time', () {
      final outcome = ok(
        apply(_occurrence(), PostponeOccurrence(toDate: LocalDate(2026, 10, 9))),
      );
      expect(outcome.occurrence.scheduledStart, isNull);
      expect(outcome.occurrence.isAnyTime, isTrue);
    });

    test('rejects a slot in the past or the same slot', () {
      expect(
        err(
          apply(
            _occurrence(),
            PostponeOccurrence(
              toDate: LocalDate(2026, 10, 7),
              toTime: LocalTime(8, 0),
            ),
          ),
        ),
        const Failure.validation(
          fieldErrors: {TaskFields.postponeTo: TaskRuleCodes.inPast},
        ),
      );
      expect(
        err(
          apply(
            _occurrence(start: _t0.add(const Duration(hours: 2))),
            PostponeOccurrence(
              toDate: LocalDate(2026, 10, 7),
              toTime: LocalTime(11, 0),
            ),
          ),
        ),
        const Failure.validation(
          fieldErrors: {TaskFields.postponeTo: TaskRuleCodes.unchanged},
        ),
      );
    });
  });

  group('cancel and reopen', () {
    test('cancel closes a running session', () {
      final open = WorkSession(id: 's', occurrenceId: 'occ-1', startedAt: _t0);
      final outcome = ok(
        apply(
          _occurrence(status: OccurrenceStatus.inProgress),
          const CancelOccurrence(),
          sessions: [open],
        ),
      );
      expect(outcome.occurrence.status, OccurrenceStatus.cancelled);
      expect(outcome.sessions.single.endReason, SessionEndReason.cancelled);
    });

    test('reopen clears the resolution', () {
      final skipped = _occurrence(status: OccurrenceStatus.skipped).copyWith(
        skipReason: SkipReason.forgot,
        resolvedAt: _t0,
      );
      final outcome = ok(apply(skipped, const ReopenOccurrence()));
      expect(outcome.occurrence.status, OccurrenceStatus.scheduled);
      expect(outcome.occurrence.skipReason, isNull);
      expect(outcome.occurrence.resolvedAt, isNull);
    });

    test('reopening worked-on occurrence returns it to paused', () {
      final completed = _occurrence(status: OccurrenceStatus.completed)
          .copyWith(actualDuration: const Duration(minutes: 10));
      final outcome = ok(
        apply(
          completed,
          const ReopenOccurrence(),
          sessions: [
            WorkSession(
              id: 's1',
              occurrenceId: 'occ-1',
              startedAt: _t0,
              endedAt: _t0.add(const Duration(minutes: 10)),
            ),
          ],
        ),
      );
      expect(outcome.occurrence.status, OccurrenceStatus.inProgress);
      expect(outcome.occurrence.actualDuration, isNull);
    });

    test('reopen is only for resolved occurrences', () {
      expect(
        err(apply(_occurrence(), const ReopenOccurrence())),
        isA<ConflictFailure>(),
      );
    });
  });

  group('note', () {
    test('trims, and an empty note clears it', () {
      final withNote = ok(
        apply(_occurrence(), const UpdateOccurrenceNote('  felt good ')),
      ).occurrence;
      expect(withNote.note, 'felt good');
      final cleared = ok(
        apply(withNote, const UpdateOccurrenceNote('   ')),
      ).occurrence;
      expect(cleared.note, isNull);
    });

    test('rejects a note over the limit', () {
      expect(
        err(
          apply(
            _occurrence(),
            UpdateOccurrenceNote('x' * (TaskRules.maxNotesLength + 1)),
          ),
        ),
        isA<ValidationFailure>(),
      );
    });
  });
}
