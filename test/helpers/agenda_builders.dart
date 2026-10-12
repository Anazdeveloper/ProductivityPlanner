import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';

/// A test agenda item. [start] is the UTC start (null = any time);
/// [wallTime] is the series' wall-clock start, used only for the schedule.
AgendaItem agendaItem({
  required String id,
  required LocalDate date,
  String title = 'Task',
  DateTime? start,
  LocalTime? wallTime,
  OccurrenceStatus status = OccurrenceStatus.scheduled,
  Duration planned = const Duration(minutes: 30),
  Duration? actual,
  String zone = 'Asia/Kolkata',
  RecurrenceRule rule = RecurrenceRule.once,
  Category? category,
  List<WorkSession> sessions = const [],
  TaskPriority priority = TaskPriority.medium,
  int postponeCount = 0,
  String? lineageId,
  DateTime? actualStart,
}) {
  final created = DateTime.utc(2026, 10, 1);
  return AgendaItem(
    task: Task(
      id: 'task-$id',
      lineageId: lineageId ?? 'task-$id',
      title: title,
      plannedDuration: planned,
      priority: priority,
      schedule: TaskSchedule(
        startDate: date,
        startTime: wallTime,
        timeZone: zone,
        rule: rule,
      ),
      createdAt: created,
      updatedAt: created,
    ),
    occurrence: TaskOccurrence(
      id: id,
      seriesId: 'task-$id',
      originalDate: date,
      scheduledDate: date,
      scheduledStart: start,
      originalStart: start,
      plannedDuration: planned,
      status: status,
      actualDuration: actual,
      postponeCount: postponeCount,
      actualStart: actualStart,
      createdAt: created,
      updatedAt: created,
    ),
    category: category,
    sessions: sessions,
  );
}
