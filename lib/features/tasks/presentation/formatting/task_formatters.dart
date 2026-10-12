import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productivity_planner/core/presentation/duration_format.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

export 'package:productivity_planner/core/presentation/duration_format.dart'
    show formatDuration;

// Display text for task values. All user-facing wording goes through
// AppLocalizations; dates and times follow the device locale (12/24 h).

String _localeTag(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

/// A running timer: "4:05", "12:05", "1:02:03". Never negative.
String formatElapsed(Duration duration) {
  final total = duration.isNegative ? 0 : duration.inSeconds;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  String two(int value) => value.toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${two(minutes)}:${two(seconds)}'
      : '$minutes:${two(seconds)}';
}

/// "9:30 AM" or "09:30", per the device setting.
String formatTime(BuildContext context, LocalTime time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: time.hour, minute: time.minute),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

/// "Wednesday, October 7".
String formatLongDate(BuildContext context, LocalDate date) =>
    DateFormat.MMMMEEEEd(_localeTag(context)).format(date.toDateTimeUtc());

/// "Wed, Oct 7".
String formatShortDate(BuildContext context, LocalDate date) =>
    DateFormat.MMMEd(_localeTag(context)).format(date.toDateTimeUtc());

/// "October 2026".
String formatMonthYear(BuildContext context, LocalDate date) =>
    DateFormat.yMMMM(_localeTag(context)).format(date.toDateTimeUtc());

/// "Today", "Tomorrow", "Yesterday" or a short date.
String formatRelativeDay(
  BuildContext context,
  LocalDate date,
  LocalDate today,
) {
  final l10n = AppLocalizations.of(context);
  return switch (today.daysUntil(date)) {
    0 => l10n.dayToday,
    1 => l10n.dayTomorrow,
    -1 => l10n.dayYesterday,
    _ => formatShortDate(context, date),
  };
}

/// Weekday label for an ISO weekday (1 = Monday): "Mon" or, if [narrow],
/// "M".
String formatWeekday(BuildContext context, int isoWeekday, {bool narrow = false}) {
  // 2024-01-01 was a Monday.
  final day = LocalDate(2024, 1, isoWeekday).toDateTimeUtc();
  final tag = _localeTag(context);
  return (narrow ? DateFormat.EEEEE(tag) : DateFormat.E(tag)).format(day);
}

String statusLabel(DerivedStatus status, AppLocalizations l10n) =>
    switch (status) {
      DerivedStatus.upcoming => l10n.statusUpcoming,
      DerivedStatus.due => l10n.statusDue,
      DerivedStatus.overdue => l10n.statusOverdue,
      DerivedStatus.missed => l10n.statusMissed,
      DerivedStatus.inProgress => l10n.statusInProgress,
      DerivedStatus.paused => l10n.statusPaused,
      DerivedStatus.completed => l10n.statusCompleted,
      DerivedStatus.skipped => l10n.statusSkipped,
      DerivedStatus.cancelled => l10n.statusCancelled,
    };

String priorityLabel(TaskPriority priority, AppLocalizations l10n) =>
    switch (priority) {
      TaskPriority.low => l10n.priorityLow,
      TaskPriority.medium => l10n.priorityMedium,
      TaskPriority.high => l10n.priorityHigh,
    };

String skipReasonLabel(SkipReason reason, AppLocalizations l10n) =>
    switch (reason) {
      SkipReason.noTime => l10n.skipReasonNoTime,
      SkipReason.notNeeded => l10n.skipReasonNotNeeded,
      SkipReason.tooTired => l10n.skipReasonTooTired,
      SkipReason.forgot => l10n.skipReasonForgot,
      SkipReason.other => l10n.skipReasonOther,
    };

String frequencyLabel(RecurrenceFrequency frequency, AppLocalizations l10n) =>
    switch (frequency) {
      RecurrenceFrequency.none => l10n.repeatNone,
      RecurrenceFrequency.daily => l10n.repeatDaily,
      RecurrenceFrequency.weekly => l10n.repeatWeekly,
      RecurrenceFrequency.monthly => l10n.repeatMonthly,
    };

/// "Every day", "Every 2 weeks on Mon, Wed", "Monthly on day 15".
String recurrenceSummary(
  BuildContext context,
  RecurrenceRule rule, {
  required LocalDate startDate,
}) {
  final l10n = AppLocalizations.of(context);
  final n = rule.interval;
  switch (rule.frequency) {
    case RecurrenceFrequency.none:
      return l10n.repeatNone;
    case RecurrenceFrequency.daily:
      return l10n.repeatEveryNDays(n);
    case RecurrenceFrequency.weekly:
      final days = rule.weekdays.isEmpty ? [startDate.weekday] : rule.weekdays;
      final names = days.map((d) => formatWeekday(context, d)).join(', ');
      return l10n.repeatEveryNWeeksOn(n, names);
    case RecurrenceFrequency.monthly:
      return l10n.repeatEveryNMonthsOnDay(n, rule.monthDay ?? startDate.day);
  }
}

/// "5 min before", "At start time".
String reminderLabel(Duration offset, AppLocalizations l10n) => offset == Duration.zero
    ? l10n.reminderAtStart
    : l10n.reminderBefore(formatDuration(offset, l10n));

/// Message for a `TaskRuleCodes` value on a `TaskFields` field.
String taskFieldError(String field, String code, AppLocalizations l10n) =>
    switch ((field, code)) {
      (TaskFields.title, TaskRuleCodes.required) => l10n.errorTitleRequired,
      (TaskFields.title, TaskRuleCodes.tooLong) => l10n.errorTitleTooLong(
        TaskRules.maxTitleLength,
      ),
      (TaskFields.notes || TaskFields.note, TaskRuleCodes.tooLong) =>
        l10n.errorNotesTooLong(TaskRules.maxNotesLength),
      (TaskFields.startDate, TaskRuleCodes.inPast) => l10n.errorDateInPast,
      (TaskFields.startDate, TaskRuleCodes.alreadyResolved) =>
        l10n.errorAlreadyResolved,
      (TaskFields.plannedDuration, _) => l10n.errorDurationRange,
      (TaskFields.until, _) => l10n.errorUntilBeforeStart,
      (TaskFields.count, _) => l10n.errorCountRange(TaskRules.maxCount),
      (TaskFields.interval, _) => l10n.errorIntervalRange,
      (TaskFields.postponeTo, TaskRuleCodes.inPast) => l10n.errorPostponeInPast,
      (TaskFields.postponeTo, _) => l10n.errorPostponeUnchanged,
      (TaskFields.categoryName, TaskRuleCodes.required) =>
        l10n.errorCategoryNameRequired,
      _ => l10n.failureValidation,
    };
