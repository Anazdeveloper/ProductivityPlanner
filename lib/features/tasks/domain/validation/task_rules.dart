import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';

/// Field keys in `Failure.validation.fieldErrors`. They match the API's
/// snake_case field names so server and local errors map the same way.
abstract final class TaskFields {
  static const title = 'title';
  static const notes = 'notes';
  static const plannedDuration = 'planned_duration';
  static const reminderOffsets = 'reminder_offsets';
  static const startDate = 'start_date';
  static const timeZone = 'time_zone';
  static const interval = 'interval';
  static const weekdays = 'weekdays';
  static const monthDay = 'month_day';
  static const until = 'until';
  static const count = 'count';
  static const note = 'note';
  static const actualDuration = 'actual_duration';
  static const postponeTo = 'postpone_to';
  static const categoryName = 'name';
}

/// Error codes in `Failure.validation.fieldErrors` values. The UI maps
/// them to localized messages (Phase 5).
abstract final class TaskRuleCodes {
  static const required = 'required';
  static const tooLong = 'too_long';
  static const outOfRange = 'out_of_range';
  static const invalid = 'invalid';
  static const inPast = 'in_past';
  static const unchanged = 'unchanged';

  /// Mutually exclusive with another field (e.g. `until` and `count`).
  static const conflict = 'conflict';

  /// The task is already finished; reopen it first.
  static const alreadyResolved = 'already_resolved';
}

/// Validation of task input. The same limits are enforced by the server;
/// checking locally gives instant feedback and keeps bad data out of the
/// outbox.
final class TaskRules {
  const TaskRules(this._converter);

  static const maxTitleLength = 200;
  static const maxNotesLength = 2000;
  static const maxCategoryNameLength = 40;
  /// The largest "every N" allowed for [frequency].
  static int maxInterval(RecurrenceFrequency frequency) => switch (frequency) {
    RecurrenceFrequency.none => 1,
    RecurrenceFrequency.daily => 365,
    RecurrenceFrequency.weekly => 52,
    RecurrenceFrequency.monthly => 12,
  };

  static const minDuration = Duration(minutes: 1);
  static const maxDuration = Duration(hours: 24);
  static const maxReminders = 5;
  static const maxReminderOffset = Duration(days: 7);
  static const maxCount = 1000;

  final TimeZoneConverter _converter;

  /// Full check for a new task. [today] is the current date in the draft's
  /// zone (a new task cannot start in the past).
  Result<Unit> validateDraft(TaskDraft draft, {required LocalDate today}) {
    final errors = <String, String>{
      ..._detailErrors(draft.details),
      ..._scheduleErrors(draft.schedule),
    };
    if (draft.schedule.startDate < today) {
      errors[TaskFields.startDate] = TaskRuleCodes.inPast;
    }
    return _result(errors);
  }

  Result<Unit> validateDetails(TaskDetails details) =>
      _result(_detailErrors(details));

  Result<Unit> validateSchedule(TaskSchedule schedule) =>
      _result(_scheduleErrors(schedule));

  Result<Unit> validateCategoryName(String name) {
    final trimmed = name.trim();
    return _result({
      if (trimmed.isEmpty) TaskFields.categoryName: TaskRuleCodes.required,
      if (trimmed.length > maxCategoryNameLength)
        TaskFields.categoryName: TaskRuleCodes.tooLong,
    });
  }

  Map<String, String> _detailErrors(TaskDetails d) {
    final title = d.title.trim();
    final notes = d.notes?.trim() ?? '';
    final offsets = d.reminderOffsets;
    return {
      if (title.isEmpty) TaskFields.title: TaskRuleCodes.required,
      if (title.length > maxTitleLength) TaskFields.title: TaskRuleCodes.tooLong,
      if (notes.length > maxNotesLength) TaskFields.notes: TaskRuleCodes.tooLong,
      if (d.plannedDuration < minDuration || d.plannedDuration > maxDuration)
        TaskFields.plannedDuration: TaskRuleCodes.outOfRange,
      if (offsets.length > maxReminders ||
          offsets.toSet().length != offsets.length ||
          offsets.any((o) => o.isNegative || o > maxReminderOffset))
        TaskFields.reminderOffsets: TaskRuleCodes.invalid,
    };
  }

  Map<String, String> _scheduleErrors(TaskSchedule s) {
    final rule = s.rule;
    final errors = <String, String>{};
    if (!_converter.isValidZone(s.timeZone)) {
      errors[TaskFields.timeZone] = TaskRuleCodes.invalid;
    }

    if (rule.interval < 1 || rule.interval > maxInterval(rule.frequency)) {
      errors[TaskFields.interval] = TaskRuleCodes.outOfRange;
    }

    final weekly = rule.frequency == RecurrenceFrequency.weekly;
    if (rule.weekdays.isNotEmpty &&
        (!weekly || rule.weekdays.any((d) => d < 1 || d > 7))) {
      errors[TaskFields.weekdays] = TaskRuleCodes.invalid;
    }

    final monthDay = rule.monthDay;
    if (monthDay != null &&
        (rule.frequency != RecurrenceFrequency.monthly ||
            monthDay < 1 ||
            monthDay > 31)) {
      errors[TaskFields.monthDay] = TaskRuleCodes.invalid;
    }

    final until = rule.until;
    final count = rule.count;
    if (until != null && count != null) {
      errors[TaskFields.count] = TaskRuleCodes.conflict;
    }
    if (until != null && until < s.startDate) {
      errors[TaskFields.until] = TaskRuleCodes.outOfRange;
    }
    if (count != null && (count < 1 || count > maxCount)) {
      errors[TaskFields.count] = TaskRuleCodes.outOfRange;
    }
    if (!rule.isRecurring && (until != null || count != null)) {
      errors[TaskFields.until] = TaskRuleCodes.invalid;
    }
    return errors;
  }

  Result<Unit> _result(Map<String, String> errors) => errors.isEmpty
      ? const Ok(unit)
      : Err(Failure.validation(fieldErrors: errors));
}
