import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';

part 'work_timer.freezed.dart';

/// The timer of one occurrence at one moment, derived from its persisted
/// work sessions and the clock. Nothing counts in memory: after the app
/// is killed, reopened or the device sleeps, the same inputs give the
/// same elapsed time.
@freezed
abstract class TimerSnapshot with _$TimerSnapshot {
  const factory TimerSnapshot({
    required String occurrenceId,

    /// A work session is open right now.
    required bool running,

    /// Time across all sessions, the open one counted up to now.
    required Duration tracked,

    /// Length of the open session so far (zero when paused).
    required Duration currentSession,
    required Duration planned,
  }) = _TimerSnapshot;

  const TimerSnapshot._();

  /// Positive while within the plan, negative once over it.
  Duration get remaining => planned - tracked;

  bool get overrun => tracked > planned;

  /// Share of the planned duration used, 0..1 (capped; see [overrun]).
  double get progress {
    if (planned <= Duration.zero) return 1;
    final share = tracked.inMilliseconds / planned.inMilliseconds;
    return share.clamp(0, 1).toDouble();
  }
}

/// Builds timer snapshots and judges whether a tracked time is believable.
final class WorkTimer {
  const WorkTimer();

  /// Anything above this is almost certainly a timer left running.
  static const maxPlausibleSession = Duration(hours: 12);

  /// A session may run this many times over its plan before we ask.
  static const overrunFactor = 3;

  /// ...but short tasks get at least this much slack.
  static const minimumSlack = Duration(hours: 2);

  /// The snapshot for [item], or null when it has never been started.
  TimerSnapshot? snapshot(AgendaItem item, DateTime now) {
    final occurrence = item.occurrence;
    if (item.sessions.isEmpty &&
        occurrence.status != OccurrenceStatus.inProgress) {
      return null;
    }
    final open = item.openSession;
    return TimerSnapshot(
      occurrenceId: occurrence.id,
      running: open != null,
      tracked: totalTracked(item.sessions, now),
      currentSession: open?.elapsed(now) ?? Duration.zero,
      planned: occurrence.plannedDuration,
    );
  }

  /// Whether completing with [tracked] should first ask the user to confirm
  /// or correct it ("You tracked 9 h 12 min. Was the timer left running?").
  bool isImplausible(Duration tracked, Duration planned) {
    if (tracked > maxPlausibleSession) return true;
    final byFactor = planned * overrunFactor;
    final bySlack = planned + minimumSlack;
    final limit = byFactor > bySlack ? byFactor : bySlack;
    return tracked > limit;
  }
}

/// The occurrence a person is working on: the one with a running session,
/// otherwise the most recently paused one. Null when nothing is in
/// progress.
AgendaItem? pickActiveWork(Iterable<AgendaItem> inProgress) {
  AgendaItem? best;
  DateTime? bestAt;
  for (final item in inProgress) {
    if (item.occurrence.status != OccurrenceStatus.inProgress) continue;
    if (item.openSession != null) return item;
    final last = _lastActivity(item.sessions);
    if (last == null) continue;
    if (bestAt == null || last.isAfter(bestAt)) {
      best = item;
      bestAt = last;
    }
  }
  return best;
}

DateTime? _lastActivity(List<WorkSession> sessions) {
  DateTime? latest;
  for (final session in sessions) {
    final at = session.endedAt ?? session.startedAt;
    if (latest == null || at.isAfter(latest)) latest = at;
  }
  return latest;
}
