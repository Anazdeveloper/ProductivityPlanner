import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/entities/occurrence_event.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';

/// Something the user does to an occurrence.
///
/// (Named "action" because `OccurrenceCommand` is the wire-level enum in
/// `core/network/api_paths.dart`.)
sealed class OccurrenceAction {
  const OccurrenceAction();
}

/// Starts work, or resumes it when paused. Pauses any other running task.
final class StartOccurrence extends OccurrenceAction {
  const StartOccurrence();
}

final class PauseOccurrence extends OccurrenceAction {
  const PauseOccurrence();
}

/// Marks done. [actualDuration] overrides the tracked time (e.g. the user
/// did it without the timer and enters "25 min"); without it, tracked time
/// is used, or nothing if no work session was recorded.
final class CompleteOccurrence extends OccurrenceAction {
  const CompleteOccurrence({this.actualDuration});

  final Duration? actualDuration;
}

/// Only before work has started.
final class SkipOccurrence extends OccurrenceAction {
  const SkipOccurrence(this.reason);

  final SkipReason reason;
}

/// Moves to another slot. Only before work has started. A null [toTime]
/// makes it an any-time task on [toDate].
final class PostponeOccurrence extends OccurrenceAction {
  const PostponeOccurrence({required this.toDate, this.toTime});

  final LocalDate toDate;
  final LocalTime? toTime;
}

/// This occurrence should not have happened (not counted as a miss).
final class CancelOccurrence extends OccurrenceAction {
  const CancelOccurrence();
}

/// Undoes complete, skip or cancel.
final class ReopenOccurrence extends OccurrenceAction {
  const ReopenOccurrence();
}

final class UpdateOccurrenceNote extends OccurrenceAction {
  const UpdateOccurrenceNote(this.note);

  final String? note;
}

/// The result of applying an action: everything to persist, atomically.
final class LifecycleOutcome {
  const LifecycleOutcome({
    required this.transition,
    required this.occurrence,
    this.sessions = const [],
    this.events = const [],
    this.autoPausedSession,
  });

  final OccurrenceTransition transition;

  /// The updated occurrence.
  final TaskOccurrence occurrence;

  /// Work sessions to insert or update (opened or closed), including
  /// [autoPausedSession].
  final List<WorkSession> sessions;

  /// History entries to append, including the other occurrence's
  /// `paused` entry when one was auto-paused.
  final List<OccurrenceEvent> events;

  /// Another occurrence's session that was closed because this one started.
  final WorkSession? autoPausedSession;
}

/// The occurrence state machine. Pure: it decides, the repository persists.
///
/// ```text
/// scheduled ──start──▶ inProgress ◀─┐ (pause / start = resume:
///    │  │                 │          │  sessions open and close)
///    │  │                 ├──────────┘
///    │  └──complete───────┼──complete──▶ completed ─┐
///    ├──skip─────────────────────────▶ skipped ─────┼─reopen─▶ scheduled
///    ├──postpone (stays scheduled)                  │          or inProgress
///    └──cancel───────────┴──cancel──▶ cancelled ────┘          (if worked on)
/// ```
///
/// Invalid transitions fail with `Failure.conflict(INVALID_TRANSITION)`, the
/// same code the server returns.
final class OccurrenceLifecycle {
  const OccurrenceLifecycle({
    required IdGenerator ids,
    required TimeZoneConverter converter,
  }) : _ids = ids,
       _converter = converter;

  static const invalidTransition = 'INVALID_TRANSITION';

  final IdGenerator _ids;
  final TimeZoneConverter _converter;

  /// [sessions] are the occurrence's own work sessions; [otherOpenSession]
  /// is a running session of a different occurrence, if any. [timeZone] is
  /// the series' zone.
  Result<LifecycleOutcome> apply({
    required TaskOccurrence occurrence,
    required OccurrenceAction action,
    required List<WorkSession> sessions,
    required String timeZone,
    required DateTime now,
    WorkSession? otherOpenSession,
  }) {
    final context = _Context(occurrence, sessions, now);
    return switch (action) {
      StartOccurrence() => _start(context, otherOpenSession),
      PauseOccurrence() => _pause(context),
      CompleteOccurrence(:final actualDuration) => _complete(
        context,
        actualDuration,
      ),
      SkipOccurrence(:final reason) => _skip(context, reason),
      PostponeOccurrence(:final toDate, :final toTime) => _postpone(
        context,
        toDate,
        toTime,
        timeZone,
      ),
      CancelOccurrence() => _cancel(context),
      ReopenOccurrence() => _reopen(context),
      UpdateOccurrenceNote(:final note) => _updateNote(context, note),
    };
  }

  Result<LifecycleOutcome> _start(_Context c, WorkSession? other) {
    final status = c.occurrence.status;
    final resuming = status == OccurrenceStatus.inProgress;
    if (status != OccurrenceStatus.scheduled && !resuming) {
      return _invalid('start', status);
    }
    if (c.openSession != null) return _invalid('start (running)', status);

    final opened = WorkSession(
      id: _ids.newId(),
      occurrenceId: c.occurrence.id,
      startedAt: c.now,
    );
    final sessions = <WorkSession>[opened];
    final events = <OccurrenceEvent>[];
    WorkSession? autoPaused;
    if (other != null &&
        other.isOpen &&
        other.occurrenceId != c.occurrence.id) {
      autoPaused = _close(other, c.now, SessionEndReason.autoPaused);
      sessions.add(autoPaused);
      events.add(
        _event(
          other.occurrenceId,
          OccurrenceTransition.paused,
          c.now,
          const {'reason': 'auto'},
        ),
      );
    }

    final transition = resuming
        ? OccurrenceTransition.resumed
        : OccurrenceTransition.started;
    events.insert(0, _event(c.occurrence.id, transition, c.now));
    return Ok(
      LifecycleOutcome(
        transition: transition,
        occurrence: c.occurrence.copyWith(
          status: OccurrenceStatus.inProgress,
          actualStart: c.occurrence.actualStart ?? c.now,
          updatedAt: c.now,
        ),
        sessions: sessions,
        events: events,
        autoPausedSession: autoPaused,
      ),
    );
  }

  Result<LifecycleOutcome> _pause(_Context c) {
    final open = c.openSession;
    if (c.occurrence.status != OccurrenceStatus.inProgress || open == null) {
      return _invalid('pause', c.occurrence.status);
    }
    return Ok(
      LifecycleOutcome(
        transition: OccurrenceTransition.paused,
        occurrence: c.occurrence.copyWith(updatedAt: c.now),
        sessions: [_close(open, c.now, SessionEndReason.paused)],
        events: [_event(c.occurrence.id, OccurrenceTransition.paused, c.now)],
      ),
    );
  }

  Result<LifecycleOutcome> _complete(_Context c, Duration? entered) {
    final status = c.occurrence.status;
    if (status != OccurrenceStatus.scheduled &&
        status != OccurrenceStatus.inProgress) {
      return _invalid('complete', status);
    }
    if (entered != null &&
        (entered.isNegative || entered > TaskRules.maxDuration)) {
      return const Err(
        Failure.validation(
          fieldErrors: {TaskFields.actualDuration: TaskRuleCodes.outOfRange},
        ),
      );
    }

    final open = c.openSession;
    final closed = open == null
        ? null
        : _close(open, c.now, SessionEndReason.completed);
    final allSessions = closed == null
        ? c.sessions
        : [for (final s in c.sessions) s.id == closed.id ? closed : s];
    final tracked = allSessions.isEmpty
        ? null
        : totalTracked(allSessions, c.now);
    final firstStart = allSessions.isEmpty
        ? null
        : allSessions
              .map((s) => s.startedAt)
              .reduce((a, b) => a.isBefore(b) ? a : b);

    return Ok(
      LifecycleOutcome(
        transition: OccurrenceTransition.completed,
        occurrence: c.occurrence.copyWith(
          status: OccurrenceStatus.completed,
          actualDuration: entered ?? tracked,
          actualStart: c.occurrence.actualStart ?? firstStart,
          resolvedAt: c.now,
          updatedAt: c.now,
        ),
        sessions: [if (closed case final session?) session],
        events: [
          _event(
            c.occurrence.id,
            OccurrenceTransition.completed,
            c.now,
            {if (entered?.inSeconds case final seconds?) 'entered_duration': seconds},
          ),
        ],
      ),
    );
  }

  Result<LifecycleOutcome> _skip(_Context c, SkipReason reason) {
    if (c.occurrence.status != OccurrenceStatus.scheduled) {
      return _invalid('skip', c.occurrence.status);
    }
    return Ok(
      LifecycleOutcome(
        transition: OccurrenceTransition.skipped,
        occurrence: c.occurrence.copyWith(
          status: OccurrenceStatus.skipped,
          skipReason: reason,
          resolvedAt: c.now,
          updatedAt: c.now,
        ),
        events: [
          _event(c.occurrence.id, OccurrenceTransition.skipped, c.now, {
            'reason': reason.name,
          }),
        ],
      ),
    );
  }

  Result<LifecycleOutcome> _postpone(
    _Context c,
    LocalDate toDate,
    LocalTime? toTime,
    String timeZone,
  ) {
    final o = c.occurrence;
    if (o.status != OccurrenceStatus.scheduled) {
      return _invalid('postpone', o.status);
    }
    final toStart = toTime == null
        ? null
        : _converter.toUtc(toDate, toTime, timeZone);
    final today = _converter.localDate(c.now, timeZone);
    final inPast = toStart == null
        ? toDate < today
        : !toStart.isAfter(c.now);
    final unchanged = toDate == o.scheduledDate && toStart == o.scheduledStart;
    if (inPast || unchanged) {
      return Err(
        Failure.validation(
          fieldErrors: {
            TaskFields.postponeTo: inPast
                ? TaskRuleCodes.inPast
                : TaskRuleCodes.unchanged,
          },
        ),
      );
    }

    return Ok(
      LifecycleOutcome(
        transition: OccurrenceTransition.postponed,
        occurrence: o.copyWith(
          scheduledDate: toDate,
          scheduledStart: toStart,
          postponeCount: o.postponeCount + 1,
          updatedAt: c.now,
        ),
        events: [
          _event(o.id, OccurrenceTransition.postponed, c.now, {
            'from_date': o.scheduledDate.toString(),
            if (o.scheduledStart?.toIso8601String() case final from?)
              'from_start': from,
            'to_date': toDate.toString(),
            if (toStart?.toIso8601String() case final to?) 'to_start': to,
          }),
        ],
      ),
    );
  }

  Result<LifecycleOutcome> _cancel(_Context c) {
    final status = c.occurrence.status;
    if (status != OccurrenceStatus.scheduled &&
        status != OccurrenceStatus.inProgress) {
      return _invalid('cancel', status);
    }
    final open = c.openSession;
    return Ok(
      LifecycleOutcome(
        transition: OccurrenceTransition.cancelled,
        occurrence: c.occurrence.copyWith(
          status: OccurrenceStatus.cancelled,
          resolvedAt: c.now,
          updatedAt: c.now,
        ),
        sessions: [
          if (open != null) _close(open, c.now, SessionEndReason.cancelled),
        ],
        events: [
          _event(c.occurrence.id, OccurrenceTransition.cancelled, c.now),
        ],
      ),
    );
  }

  Result<LifecycleOutcome> _reopen(_Context c) {
    final status = c.occurrence.status;
    if (!status.isResolved) return _invalid('reopen', status);
    // Keep tracked time: an occurrence that was worked on goes back to
    // "paused", not to "not started".
    final next = c.sessions.isEmpty
        ? OccurrenceStatus.scheduled
        : OccurrenceStatus.inProgress;
    return Ok(
      LifecycleOutcome(
        transition: OccurrenceTransition.reopened,
        occurrence: c.occurrence.copyWith(
          status: next,
          resolvedAt: null,
          actualDuration: null,
          skipReason: null,
          updatedAt: c.now,
        ),
        events: [
          _event(c.occurrence.id, OccurrenceTransition.reopened, c.now, {
            'from': status.name,
          }),
        ],
      ),
    );
  }

  Result<LifecycleOutcome> _updateNote(_Context c, String? note) {
    final trimmed = note?.trim();
    final normalized = trimmed == null || trimmed.isEmpty ? null : trimmed;
    if (normalized != null && normalized.length > TaskRules.maxNotesLength) {
      return const Err(
        Failure.validation(
          fieldErrors: {TaskFields.note: TaskRuleCodes.tooLong},
        ),
      );
    }
    return Ok(
      LifecycleOutcome(
        transition: OccurrenceTransition.noteUpdated,
        occurrence: c.occurrence.copyWith(note: normalized, updatedAt: c.now),
        events: [
          _event(c.occurrence.id, OccurrenceTransition.noteUpdated, c.now),
        ],
      ),
    );
  }

  WorkSession _close(WorkSession s, DateTime now, SessionEndReason reason) {
    // A corrected device clock can put now before the start.
    final end = now.isBefore(s.startedAt) ? s.startedAt : now;
    return s.copyWith(endedAt: end, endReason: reason);
  }

  OccurrenceEvent _event(
    String occurrenceId,
    OccurrenceTransition type,
    DateTime at, [
    Map<String, Object?> data = const {},
  ]) => OccurrenceEvent(
    id: _ids.newId(),
    occurrenceId: occurrenceId,
    type: type,
    occurredAt: at,
    data: data,
  );

  Result<LifecycleOutcome> _invalid(String action, OccurrenceStatus from) =>
      Err(
        Failure.conflict(
          code: invalidTransition,
          message: 'Cannot $action an occurrence that is ${from.name}',
        ),
      );
}

final class _Context {
  _Context(this.occurrence, this.sessions, this.now);

  final TaskOccurrence occurrence;
  final List<WorkSession> sessions;
  final DateTime now;

  WorkSession? get openSession {
    for (final s in sessions) {
      if (s.isOpen) return s;
    }
    return null;
  }
}
