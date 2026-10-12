import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:productivity_planner/core/presentation/duration_format.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/domain/entities/analytics_period.dart';
import 'package:productivity_planner/features/analytics/domain/entities/productivity_metrics.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

// Display text for analytics values. Wording lives in AppLocalizations;
// dates and numbers follow the device locale.

String _tag(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

/// "83%".
String formatPercent(BuildContext context, double ratio) =>
    NumberFormat.percentPattern(_tag(context)).format(ratio);

/// "Today", "Yesterday", "Wed, Oct 7"; "Oct 5 – 11"; "October 2026".
String periodLabel(
  BuildContext context,
  AnalyticsPeriod period,
  LocalDate today,
) {
  final l10n = AppLocalizations.of(context);
  final tag = _tag(context);
  switch (period.kind) {
    case PeriodKind.day:
      return switch (period.start.daysUntil(today)) {
        0 => l10n.dayToday,
        1 => l10n.dayYesterday,
        _ => DateFormat.MMMEd(tag).format(period.start.toDateTimeUtc()),
      };
    case PeriodKind.week:
      final start = period.start.toDateTimeUtc();
      final end = period.end.toDateTimeUtc();
      final sameMonth = period.start.month == period.end.month;
      return l10n.dateRange(
        DateFormat.MMMd(tag).format(start),
        sameMonth ? DateFormat.d(tag).format(end) : DateFormat.MMMd(tag).format(end),
      );
    case PeriodKind.month:
      return DateFormat.yMMMM(tag).format(period.start.toDateTimeUtc());
  }
}

/// "Wed, Oct 7" (bar labels for screen readers, list headings).
String formatDay(BuildContext context, LocalDate date) =>
    DateFormat.MMMEd(_tag(context)).format(date.toDateTimeUtc());

/// "Oct 7".
String formatShortDay(BuildContext context, LocalDate date) =>
    DateFormat.MMMd(_tag(context)).format(date.toDateTimeUtc());

/// Under a week's bars: "M", "T", …
String formatNarrowWeekday(BuildContext context, LocalDate date) =>
    DateFormat.EEEEE(_tag(context)).format(date.toDateTimeUtc());

/// Hours on a chart axis: "0", "30m", "1h", "2.5h".
String formatAxisHours(Duration value) {
  final minutes = value.inMinutes;
  if (minutes == 0) return '0';
  if (minutes < 60) return '${minutes}m';
  final hours = minutes / 60;
  return hours == hours.roundToDouble()
      ? '${hours.round()}h'
      : '${hours.toStringAsFixed(1)}h';
}

/// "Took 18% longer than planned", "Took 10% less…", "Close to plan".
/// Within ±10 % counts as close.
String estimateLabel(BuildContext context, double ratio) {
  final l10n = AppLocalizations.of(context);
  final change = ratio - 1;
  if (change.abs() < 0.1) return l10n.estimateAccurate;
  final percent = formatPercent(context, change.abs());
  return change > 0
      ? l10n.estimateLonger(percent)
      : l10n.estimateShorter(percent);
}

/// "Typically 5 min late", "Typically 3 min early", "Typically on time".
String typicalStartLabel(BuildContext context, Duration median) {
  final l10n = AppLocalizations.of(context);
  if (median.abs() < const Duration(minutes: 1)) return l10n.typicallyOnTime;
  final text = formatDuration(median, l10n);
  return median.isNegative ? l10n.typicallyEarly(text) : l10n.typicallyLate(text);
}

/// "Started 5 min late" / "early" / "on time" for one occurrence.
String startDelayLabel(BuildContext context, Duration delay) {
  final l10n = AppLocalizations.of(context);
  if (delay.abs() < const Duration(minutes: 1)) return l10n.startedOnTime;
  final text = formatDuration(delay, l10n);
  return delay.isNegative ? l10n.startedEarly(text) : l10n.startedLate(text);
}

String outcomeLabel(ExecutionOutcome outcome, AppLocalizations l10n) =>
    switch (outcome) {
      ExecutionOutcome.completed => l10n.outcomeDone,
      ExecutionOutcome.skipped => l10n.outcomeSkipped,
      ExecutionOutcome.missed => l10n.outcomeMissed,
      ExecutionOutcome.open => l10n.outcomeOpen,
    };
