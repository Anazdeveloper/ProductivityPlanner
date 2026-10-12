import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/domain/entities/execution_record.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

/// A test analytics record (Asia/Kolkata unless [zone] says otherwise).
ExecutionRecord execution({
  required String id,
  required LocalDate date,
  OccurrenceStatus status = OccurrenceStatus.scheduled,
  String lineageId = 'run',
  String? title,
  Duration planned = const Duration(minutes: 30),
  Duration? seriesPlanned,
  Duration? actual,
  DateTime? scheduledStart,
  DateTime? actualStart,
  Duration closedSessions = Duration.zero,
  DateTime? openSince,
  int postponeCount = 0,
  String zone = 'Asia/Kolkata',
}) => ExecutionRecord(
  occurrenceId: id,
  lineageId: lineageId,
  taskId: 'task-$lineageId',
  title: title ?? lineageId,
  timeZone: zone,
  date: date,
  planned: planned,
  seriesPlanned: seriesPlanned ?? planned,
  status: status,
  closedSessionTime: closedSessions,
  openSessionStart: openSince,
  scheduledStart: scheduledStart,
  actualStart: actualStart,
  actualDuration: actual,
  postponeCount: postponeCount,
);
