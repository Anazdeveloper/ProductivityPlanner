import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

part 'task_schedule.freezed.dart';

/// When a series produces occurrences. Semantics (shared with the server,
/// vectors in `contracts/vectors/recurrence.json`):
///
/// - `daily`: every [interval] days from the start date.
/// - `weekly`: on [weekdays] (ISO, 1 = Monday) of every [interval]-th week,
///   counting ISO weeks from the week containing the start date. Empty
///   [weekdays] means the start date's weekday.
/// - `monthly`: on [monthDay] (default: the start date's day) of every
///   [interval]-th month. Months without that day are skipped (RFC 5545)
///   and do not consume [count].
/// - [until] is inclusive. [count] counts occurrences from the start date.
@freezed
abstract class RecurrenceRule with _$RecurrenceRule {
  const factory RecurrenceRule({
    required RecurrenceFrequency frequency,
    @Default(1) int interval,
    @Default(<int>[]) List<int> weekdays,
    int? monthDay,
    LocalDate? until,
    int? count,
  }) = _RecurrenceRule;

  const RecurrenceRule._();

  static const RecurrenceRule once = RecurrenceRule(
    frequency: RecurrenceFrequency.none,
  );

  bool get isRecurring => frequency != RecurrenceFrequency.none;
}

@freezed
abstract class TaskSchedule with _$TaskSchedule {
  const factory TaskSchedule({
    /// First date of the series (in [timeZone]).
    required LocalDate startDate,

    /// IANA zone the dates and times are expressed in. Usually the user's
    /// home zone; kept per series so travel does not move a 7:00 run.
    required String timeZone,

    /// Null means "any time that day": no start instant, no reminder.
    LocalTime? startTime,
    @Default(RecurrenceRule.once) RecurrenceRule rule,
  }) = _TaskSchedule;
}
