import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/data/models/task_mappers.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';

// Server state of tasks entities (contract §4.3: `sync/pull` `data`, and
// the REST reads used to recover from a rejected op) → domain entities.
// Throws FormatException, and only that, for a malformed object (the sync
// engine skips such a change instead of failing the whole page).

/// [now] fills timestamps the server does not send.
Task seriesFromJson(
  Map<String, Object?> json, {
  required int version,
  required DateTime now,
}) {
  final recurrence = _map(json['recurrence'], 'recurrence');
  return Task(
    id: _string(json['id'], 'id'),
    lineageId: _string(json['lineage_id'], 'lineage_id'),
    title: _string(json['title'], 'title'),
    notes: _optString(json['notes'], 'notes'),
    categoryId: _optString(json['category_id'], 'category_id'),
    priority: priorityWire.parse(_string(json['priority'], 'priority')),
    plannedDuration: Duration(
      seconds: _int(json['planned_duration'], 'planned_duration'),
    ),
    schedule: TaskSchedule(
      startDate: _date(json['start_date'], 'start_date'),
      startTime: switch (_optString(json['start_time'], 'start_time')) {
        final String time => LocalTime.parse(time),
        null => null,
      },
      timeZone: _string(json['time_zone'], 'time_zone'),
      rule: RecurrenceRule(
        frequency: frequencyWire.parse(
          _string(recurrence['frequency'], 'recurrence.frequency'),
        ),
        interval: _optInt(recurrence['interval'], 'interval') ?? 1,
        weekdays: [
          for (final day in _list(recurrence['weekdays'], 'weekdays'))
            if (day is int) day,
        ],
        monthDay: _optInt(recurrence['month_day'], 'month_day'),
        until: _optDate(recurrence['until'], 'until'),
        count: _optInt(recurrence['count'], 'count'),
      ),
    ),
    reminderOffsets: [
      for (final seconds in _list(json['reminder_offsets'], 'reminders'))
        if (seconds is int) Duration(seconds: seconds),
    ],
    endedOn: _optDate(json['ended_on'], 'ended_on'),
    version: version,
    createdAt: now,
    updatedAt: now,
  );
}

TaskOccurrence occurrenceFromJson(
  Map<String, Object?> json, {
  required int version,
  required DateTime now,
}) => TaskOccurrence(
  id: _string(json['id'], 'id'),
  seriesId: _string(json['series_id'], 'series_id'),
  originalDate: _date(json['original_date'], 'original_date'),
  scheduledDate: _date(json['scheduled_date'], 'scheduled_date'),
  scheduledStart: _instant(json['scheduled_start']),
  originalStart: _instant(json['original_start']),
  plannedDuration: Duration(
    seconds: _int(json['planned_duration'], 'planned_duration'),
  ),
  status: occurrenceStatusWire.parse(_string(json['status'], 'status')),
  postponeCount: _optInt(json['postpone_count'], 'postpone_count') ?? 0,
  actualStart: _instant(json['actual_start']),
  actualDuration: switch (_optInt(json['actual_duration'], 'duration')) {
    final int seconds => Duration(seconds: seconds),
    null => null,
  },
  resolvedAt: _instant(json['resolved_at']),
  skipReason: skipReasonWire.parseOrNull(
    _optString(json['skip_reason'], 'skip_reason'),
  ),
  note: _optString(json['note'], 'note'),
  version: version,
  createdAt: now,
  updatedAt: now,
);

WorkSession sessionFromJson(Map<String, Object?> json) => WorkSession(
  id: _string(json['id'], 'id'),
  occurrenceId: _string(json['occurrence_id'], 'occurrence_id'),
  startedAt:
      _instant(json['started_at']) ??
      (throw const FormatException('started_at')),
  endedAt: _instant(json['ended_at']),
  endReason: sessionEndReasonWire.parseOrNull(
    _optString(json['end_reason'], 'end_reason'),
  ),
);

Category categoryFromJson(Map<String, Object?> json, {required int version}) =>
    Category(
      id: _string(json['id'], 'id'),
      name: _string(json['name'], 'name'),
      color: categoryColorWire.parse(_string(json['color_key'], 'color_key')),
      iconKey: _optString(json['icon_key'], 'icon_key'),
      sortOrder: _optInt(json['sort_order'], 'sort_order') ?? 0,
      isDefault: json['is_default'] == true,
      version: version,
    );

String _string(Object? value, String field) =>
    value is String ? value : throw FormatException('Expected text', field);

int _int(Object? value, String field) =>
    value is int ? value : throw FormatException('Expected an integer', field);

Map<String, Object?> _map(Object? value, String field) => value is Map
    ? Map<String, Object?>.from(value)
    : throw FormatException('Expected an object', field);

String? _optString(Object? value, String field) => switch (value) {
  null => null,
  final String text => text,
  _ => throw FormatException('Expected text', field),
};

int? _optInt(Object? value, String field) => switch (value) {
  null => null,
  final int number => number,
  _ => throw FormatException('Expected an integer', field),
};

List<Object?> _list(Object? value, String field) => switch (value) {
  null => const [],
  final List<Object?> items => items,
  _ => throw FormatException('Expected a list', field),
};

LocalDate _date(Object? value, String field) =>
    LocalDate.tryParse(_string(value, field)) ??
    (throw FormatException('Expected YYYY-MM-DD', field));

LocalDate? _optDate(Object? value, String field) => switch (value) {
  null => null,
  _ => _date(value, field),
};

DateTime? _instant(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toUtc() : null;
