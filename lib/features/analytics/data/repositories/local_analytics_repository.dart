import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/domain/entities/execution_record.dart';
import 'package:productivity_planner/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';

/// Analytics computed on the device from the local task history.
///
/// The local database already holds every occurrence and work session the
/// person has (and, from Phase 11, everything synced from other devices),
/// so analytics work offline and update the moment something changes. It
/// reads through the tasks feature's domain interface, so the storage
/// layout stays private to that feature.
///
/// The server's `analytics/*` endpoints (contract §3.3) serve the web
/// client and server-side insights with the same metric definitions.
final class LocalAnalyticsRepository implements AnalyticsRepository {
  const LocalAnalyticsRepository(this._tasks);

  final TaskRepository _tasks;

  @override
  Stream<Result<List<ExecutionRecord>>> watchRecords({
    required LocalDate from,
    required LocalDate to,
  }) => _tasks
      .watchAgenda(from: from, to: to)
      .map((result) => result.map(_records));

  @override
  Stream<Result<List<ExecutionRecord>>> watchActivity(
    String lineageId, {
    required LocalDate from,
    required LocalDate to,
  }) => _tasks
      .watchLineage(lineageId, from: from, to: to)
      .map((result) => result.map(_records));

  static List<ExecutionRecord> _records(List<AgendaItem> items) => [
    for (final item in items) executionRecordFrom(item),
  ];
}

/// Maps a task agenda item to its analytics record.
ExecutionRecord executionRecordFrom(AgendaItem item) {
  final occurrence = item.occurrence;
  var closed = Duration.zero;
  DateTime? openStart;
  for (final session in item.sessions) {
    final ended = session.endedAt;
    if (ended == null) {
      openStart = session.startedAt;
    } else {
      closed += session.elapsed(ended);
    }
  }
  return ExecutionRecord(
    occurrenceId: occurrence.id,
    lineageId: item.task.lineageId,
    taskId: item.task.id,
    title: item.task.title,
    timeZone: item.task.schedule.timeZone,
    date: occurrence.scheduledDate,
    planned: occurrence.plannedDuration,
    seriesPlanned: item.task.plannedDuration,
    status: occurrence.status,
    closedSessionTime: closed,
    openSessionStart: openStart,
    category: item.category,
    scheduledStart: occurrence.scheduledStart,
    actualStart: occurrence.actualStart,
    actualDuration: occurrence.actualDuration,
    resolvedAt: occurrence.resolvedAt,
    postponeCount: occurrence.postponeCount,
  );
}
