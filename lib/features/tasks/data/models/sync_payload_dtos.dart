import 'package:json_annotation/json_annotation.dart';
import 'package:productivity_planner/features/tasks/data/models/task_mappers.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';

part 'sync_payload_dtos.g.dart';

// Outbox payloads (contract §4.1). snake_case and null-omission come from
// build.yaml. Phase 11 reuses the series/category shapes to read `sync/pull`.

@JsonSerializable()
class RecurrenceDto {
  const RecurrenceDto({
    required this.frequency,
    required this.interval,
    required this.weekdays,
    this.monthDay,
    this.until,
    this.count,
  });

  factory RecurrenceDto.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceDtoFromJson(json);

  final String frequency;
  final int interval;
  final List<int> weekdays;
  final int? monthDay;

  /// `YYYY-MM-DD`, inclusive.
  final String? until;
  final int? count;

  Map<String, dynamic> toJson() => _$RecurrenceDtoToJson(this);
}

/// Full snapshot of a series (`series.create`, `series.update`, and the new
/// half of `series.split`). Full snapshots keep the server's merge simple:
/// with `base_version` it can detect a concurrent edit and resolve it.
@JsonSerializable()
class SeriesDto {
  const SeriesDto({
    required this.id,
    required this.lineageId,
    required this.title,
    required this.priority,
    required this.plannedDuration,
    required this.startDate,
    required this.timeZone,
    required this.recurrence,
    required this.reminderOffsets,
    this.notes,
    this.categoryId,
    this.startTime,
    this.endedOn,
  });

  factory SeriesDto.fromJson(Map<String, dynamic> json) =>
      _$SeriesDtoFromJson(json);

  factory SeriesDto.fromTask(Task task) {
    final schedule = task.schedule;
    final rule = schedule.rule;
    return SeriesDto(
      id: task.id,
      lineageId: task.lineageId,
      title: task.title,
      notes: task.notes,
      categoryId: task.categoryId,
      priority: priorityWire.wire(task.priority),
      plannedDuration: task.plannedDuration.inSeconds,
      startDate: schedule.startDate.toString(),
      startTime: schedule.startTime?.toString(),
      timeZone: schedule.timeZone,
      recurrence: RecurrenceDto(
        frequency: frequencyWire.wire(rule.frequency),
        interval: rule.interval,
        weekdays: rule.weekdays,
        monthDay: rule.monthDay,
        until: rule.until?.toString(),
        count: rule.count,
      ),
      reminderOffsets: [for (final d in task.reminderOffsets) d.inSeconds],
      endedOn: task.endedOn?.toString(),
    );
  }

  final String id;
  final String lineageId;
  final String title;
  final String? notes;
  final String? categoryId;
  final String priority;

  /// Seconds.
  final int plannedDuration;
  final String startDate;

  /// `HH:mm`; absent for any-time tasks.
  final String? startTime;
  final String timeZone;
  final RecurrenceDto recurrence;

  /// Seconds before start.
  final List<int> reminderOffsets;
  final String? endedOn;

  Map<String, dynamic> toJson() => _$SeriesDtoToJson(this);
}

/// `series.split`: the source series ends the day before [splitDate] and
/// [newSeries] (same lineage) starts on it.
@JsonSerializable()
class SeriesSplitDto {
  const SeriesSplitDto({
    required this.sourceSeriesId,
    required this.splitDate,
    required this.newSeries,
  });

  factory SeriesSplitDto.fromJson(Map<String, dynamic> json) =>
      _$SeriesSplitDtoFromJson(json);

  final String sourceSeriesId;
  final String splitDate;
  final SeriesDto newSeries;

  Map<String, dynamic> toJson() => _$SeriesSplitDtoToJson(this);
}

/// Payload of every `occurrence.*` op except `occurrence.update`.
///
/// Carries `series_id` + `original_date` because occurrences are created
/// locally and never pushed: the server materializes the same row (same
/// deterministic id) on first use. The op's `entity_id` is the occurrence
/// id and its `occurred_at` is when the action happened.
@JsonSerializable()
class OccurrenceActionDto {
  const OccurrenceActionDto({
    required this.seriesId,
    required this.originalDate,
    this.sessionId,
    this.actualDuration,
    this.reason,
    this.toDate,
    this.toStart,
  });

  factory OccurrenceActionDto.fromJson(Map<String, dynamic> json) =>
      _$OccurrenceActionDtoFromJson(json);

  OccurrenceActionDto.of(
    TaskOccurrence occurrence, {
    this.sessionId,
    this.actualDuration,
    this.reason,
    this.toDate,
    this.toStart,
  }) : seriesId = occurrence.seriesId,
       originalDate = occurrence.originalDate.toString();

  final String seriesId;
  final String originalDate;

  /// start/resume: the session opened; pause/complete/cancel: the session
  /// closed (if any).
  final String? sessionId;

  /// complete: seconds spent; absent = not measured.
  final int? actualDuration;

  /// skip: reason code.
  final String? reason;

  /// postpone: new local date, and new UTC start (absent = any time).
  final String? toDate;
  final String? toStart;

  Map<String, dynamic> toJson() => _$OccurrenceActionDtoToJson(this);
}

/// `occurrence.update`. `note: null` clears the note, so it is always sent.
@JsonSerializable()
class OccurrenceNoteDto {
  const OccurrenceNoteDto({
    required this.seriesId,
    required this.originalDate,
    required this.note,
  });

  factory OccurrenceNoteDto.fromJson(Map<String, dynamic> json) =>
      _$OccurrenceNoteDtoFromJson(json);

  final String seriesId;
  final String originalDate;

  @JsonKey(includeIfNull: true)
  final String? note;

  Map<String, dynamic> toJson() => _$OccurrenceNoteDtoToJson(this);
}

@JsonSerializable()
class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.name,
    required this.colorKey,
    required this.sortOrder,
    this.iconKey,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);

  factory CategoryDto.fromCategory(Category category) => CategoryDto(
    id: category.id,
    name: category.name,
    colorKey: categoryColorWire.wire(category.color),
    iconKey: category.iconKey,
    sortOrder: category.sortOrder,
  );

  final String id;
  final String name;
  final String colorKey;
  final String? iconKey;
  final int sortOrder;

  Map<String, dynamic> toJson() => _$CategoryDtoToJson(this);
}
