import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/occurrence_event.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';

// Rows <-> entities, and enum <-> wire strings. The wire strings are the
// API's (contract §4) and are also what the database stores, so a row can be
// pushed or pulled without translation.

/// Bidirectional enum <-> string table. Unknown strings throw
/// [FormatException]: a row the app cannot understand is a bug to report,
/// not something to guess about.
final class WireEnum<T extends Enum> {
  WireEnum(this._toWire)
    : _fromWire = {for (final e in _toWire.entries) e.value: e.key};

  final Map<T, String> _toWire;
  final Map<String, T> _fromWire;

  String wire(T value) => _toWire[value] ?? value.name;

  String? wireOrNull(T? value) => value == null ? null : wire(value);

  T parse(String value) =>
      _fromWire[value] ?? (throw FormatException('Unknown $T', value));

  T? parseOrNull(String? value) => value == null ? null : parse(value);
}

final priorityWire = WireEnum<TaskPriority>({
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
});

final frequencyWire = WireEnum<RecurrenceFrequency>({
  RecurrenceFrequency.none: 'none',
  RecurrenceFrequency.daily: 'daily',
  RecurrenceFrequency.weekly: 'weekly',
  RecurrenceFrequency.monthly: 'monthly',
});

final occurrenceStatusWire = WireEnum<OccurrenceStatus>({
  OccurrenceStatus.scheduled: 'scheduled',
  OccurrenceStatus.inProgress: 'in_progress',
  OccurrenceStatus.completed: 'completed',
  OccurrenceStatus.skipped: 'skipped',
  OccurrenceStatus.cancelled: 'cancelled',
});

final skipReasonWire = WireEnum<SkipReason>({
  SkipReason.noTime: 'no_time',
  SkipReason.notNeeded: 'not_needed',
  SkipReason.tooTired: 'too_tired',
  SkipReason.forgot: 'forgot',
  SkipReason.other: 'other',
});

final sessionEndReasonWire = WireEnum<SessionEndReason>({
  SessionEndReason.paused: 'paused',
  SessionEndReason.autoPaused: 'auto_paused',
  SessionEndReason.completed: 'completed',
  SessionEndReason.cancelled: 'cancelled',
});

final transitionWire = WireEnum<OccurrenceTransition>({
  OccurrenceTransition.started: 'started',
  OccurrenceTransition.resumed: 'resumed',
  OccurrenceTransition.paused: 'paused',
  OccurrenceTransition.completed: 'completed',
  OccurrenceTransition.skipped: 'skipped',
  OccurrenceTransition.postponed: 'postponed',
  OccurrenceTransition.cancelled: 'cancelled',
  OccurrenceTransition.reopened: 'reopened',
  OccurrenceTransition.noteUpdated: 'note_updated',
});

final categoryColorWire = WireEnum<CategoryColor>({
  for (final color in CategoryColor.values) color: color.name,
});

// Lists stored as comma-separated text.

String encodeIntList(Iterable<int> values) => values.join(',');

List<int> decodeIntList(String value) => value.isEmpty
    ? const []
    : [for (final part in value.split(',')) int.parse(part)];

/// Drift returns text-stored `DateTime`s as written; normalise to UTC so
/// comparisons never mix zones.
DateTime _utc(DateTime value) => value.toUtc();

DateTime? _utcOrNull(DateTime? value) => value?.toUtc();

// Series

Task taskFromRow(TaskSeriesRow r) => Task(
  id: r.id,
  lineageId: r.lineageId,
  title: r.title,
  notes: r.notes,
  categoryId: r.categoryId,
  priority: priorityWire.parse(r.priority),
  plannedDuration: Duration(seconds: r.plannedDurationSeconds),
  schedule: TaskSchedule(
    startDate: LocalDate.parse(r.startDate),
    startTime: switch (r.startTime) {
      final time? => LocalTime.parse(time),
      null => null,
    },
    timeZone: r.timeZone,
    rule: RecurrenceRule(
      frequency: frequencyWire.parse(r.frequency),
      interval: r.interval,
      weekdays: decodeIntList(r.weekdays),
      monthDay: r.monthDay,
      until: LocalDate.tryParse(r.untilDate),
      count: r.occurrenceCount,
    ),
  ),
  reminderOffsets: [
    for (final s in decodeIntList(r.reminderOffsets)) Duration(seconds: s),
  ],
  endedOn: LocalDate.tryParse(r.endedOn),
  materializedThrough: LocalDate.tryParse(r.materializedThrough),
  version: r.version,
  createdAt: _utc(r.createdAt),
  updatedAt: _utc(r.updatedAt),
);

/// Every column except `deleted_at`, so an upsert never undeletes.
TaskSeriesCompanion taskToCompanion(Task t) {
  final schedule = t.schedule;
  final rule = schedule.rule;
  return TaskSeriesCompanion.insert(
    id: t.id,
    lineageId: t.lineageId,
    title: t.title,
    notes: Value(t.notes),
    categoryId: Value(t.categoryId),
    priority: priorityWire.wire(t.priority),
    plannedDurationSeconds: t.plannedDuration.inSeconds,
    startDate: schedule.startDate.toString(),
    startTime: Value(schedule.startTime?.toString()),
    timeZone: schedule.timeZone,
    frequency: frequencyWire.wire(rule.frequency),
    interval: Value(rule.interval),
    weekdays: Value(encodeIntList(rule.weekdays)),
    monthDay: Value(rule.monthDay),
    untilDate: Value(rule.until?.toString()),
    occurrenceCount: Value(rule.count),
    reminderOffsets: Value(
      encodeIntList(t.reminderOffsets.map((d) => d.inSeconds)),
    ),
    endedOn: Value(t.endedOn?.toString()),
    materializedThrough: Value(t.materializedThrough?.toString()),
    version: Value(t.version),
    createdAt: t.createdAt,
    updatedAt: t.updatedAt,
  );
}

// Occurrences

TaskOccurrence occurrenceFromRow(TaskOccurrenceRow r) => TaskOccurrence(
  id: r.id,
  seriesId: r.seriesId,
  originalDate: LocalDate.parse(r.originalDate),
  scheduledDate: LocalDate.parse(r.scheduledDate),
  scheduledStart: _utcOrNull(r.scheduledStart),
  originalStart: _utcOrNull(r.originalStart),
  plannedDuration: Duration(seconds: r.plannedDurationSeconds),
  status: occurrenceStatusWire.parse(r.status),
  postponeCount: r.postponeCount,
  actualStart: _utcOrNull(r.actualStart),
  actualDuration: switch (r.actualDurationSeconds) {
    final seconds? => Duration(seconds: seconds),
    null => null,
  },
  resolvedAt: _utcOrNull(r.resolvedAt),
  skipReason: skipReasonWire.parseOrNull(r.skipReason),
  note: r.note,
  version: r.version,
  createdAt: _utc(r.createdAt),
  updatedAt: _utc(r.updatedAt),
);

TaskOccurrencesCompanion occurrenceToCompanion(TaskOccurrence o) =>
    TaskOccurrencesCompanion.insert(
      id: o.id,
      seriesId: o.seriesId,
      originalDate: o.originalDate.toString(),
      scheduledDate: o.scheduledDate.toString(),
      scheduledStart: Value(o.scheduledStart),
      originalStart: Value(o.originalStart),
      plannedDurationSeconds: o.plannedDuration.inSeconds,
      status: occurrenceStatusWire.wire(o.status),
      postponeCount: Value(o.postponeCount),
      actualStart: Value(o.actualStart),
      actualDurationSeconds: Value(o.actualDuration?.inSeconds),
      resolvedAt: Value(o.resolvedAt),
      skipReason: Value(skipReasonWire.wireOrNull(o.skipReason)),
      note: Value(o.note),
      version: Value(o.version),
      createdAt: o.createdAt,
      updatedAt: o.updatedAt,
    );

// Work sessions and events

WorkSession sessionFromRow(WorkSessionRow r) => WorkSession(
  id: r.id,
  occurrenceId: r.occurrenceId,
  startedAt: _utc(r.startedAt),
  endedAt: _utcOrNull(r.endedAt),
  endReason: sessionEndReasonWire.parseOrNull(r.endReason),
);

WorkSessionsCompanion sessionToCompanion(WorkSession s) =>
    WorkSessionsCompanion.insert(
      id: s.id,
      occurrenceId: s.occurrenceId,
      startedAt: s.startedAt,
      endedAt: Value(s.endedAt),
      endReason: Value(sessionEndReasonWire.wireOrNull(s.endReason)),
    );

OccurrenceEventsCompanion eventToCompanion(OccurrenceEvent e) =>
    OccurrenceEventsCompanion.insert(
      id: e.id,
      occurrenceId: e.occurrenceId,
      type: transitionWire.wire(e.type),
      occurredAt: e.occurredAt,
      data: Value(jsonEncode(e.data)),
    );

OccurrenceEvent eventFromRow(OccurrenceEventRow r) => OccurrenceEvent(
  id: r.id,
  occurrenceId: r.occurrenceId,
  type: transitionWire.parse(r.type),
  occurredAt: _utc(r.occurredAt),
  data: (jsonDecode(r.data) as Map<String, dynamic>).cast<String, Object?>(),
);

// Categories

Category categoryFromRow(CategoryRow r) => Category(
  id: r.id,
  name: r.name,
  color: categoryColorWire.parse(r.colorKey),
  iconKey: r.iconKey,
  sortOrder: r.sortOrder,
  isDefault: r.isDefault,
  version: r.version,
);

CategoriesCompanion categoryToCompanion(Category c, {required DateTime now}) =>
    CategoriesCompanion.insert(
      id: c.id,
      name: c.name,
      colorKey: categoryColorWire.wire(c.color),
      iconKey: Value(c.iconKey),
      sortOrder: Value(c.sortOrder),
      isDefault: Value(c.isDefault),
      version: Value(c.version),
      createdAt: now,
      updatedAt: now,
    );
