import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_status_resolver.dart';

/// An agenda item as shown at a given moment.
@immutable
final class AgendaEntry {
  const AgendaEntry({
    required this.item,
    required this.status,
    required this.startTime,
  });

  final AgendaItem item;
  final DerivedStatus status;

  /// Wall-clock start in the series' zone; null for an any-time task.
  final LocalTime? startTime;

  String get occurrenceId => item.occurrence.id;

  LocalDate get date => item.occurrence.scheduledDate;

  bool get isDone => status == DerivedStatus.completed;

  /// Completed, skipped or cancelled: nothing left to do.
  bool get isResolved => item.occurrence.status.isResolved;

  @override
  bool operator ==(Object other) =>
      other is AgendaEntry &&
      other.item == item &&
      other.status == status &&
      other.startTime == startTime;

  @override
  int get hashCode => Object.hash(item, status, startTime);
}

/// Progress for one day ("3 of 5 done").
@immutable
final class DaySummary {
  const DaySummary({
    required this.total,
    required this.completed,
    required this.skipped,
    required this.planned,
    required this.tracked,
    this.next,
  });

  static const DaySummary empty = DaySummary(
    total: 0,
    completed: 0,
    skipped: 0,
    planned: Duration.zero,
    tracked: Duration.zero,
  );

  /// Occurrences that count (cancelled ones do not).
  final int total;
  final int completed;
  final int skipped;

  /// Sum of planned durations of counted occurrences.
  final Duration planned;

  /// Sum of measured actual durations of completed occurrences.
  final Duration tracked;

  /// What to do now (see [AgendaSummarizer.summarize]).
  final AgendaEntry? next;

  int get remaining => total - completed - skipped;

  /// Completed share of the day, 0..1.
  double get progress => total == 0 ? 0 : completed / total;

  @override
  bool operator ==(Object other) =>
      other is DaySummary &&
      other.total == total &&
      other.completed == completed &&
      other.skipped == skipped &&
      other.planned == planned &&
      other.tracked == tracked &&
      other.next == next;

  @override
  int get hashCode =>
      Object.hash(total, completed, skipped, planned, tracked, next);
}

/// Derives display state from stored agenda items: per-item status at
/// a given moment, wall-clock start times, and day summaries. Pure.
final class AgendaSummarizer {
  const AgendaSummarizer({
    required OccurrenceStatusResolver resolver,
    required TimeZoneConverter converter,
  }) : _resolver = resolver,
       _converter = converter;

  final OccurrenceStatusResolver _resolver;
  final TimeZoneConverter _converter;

  /// Items must already be in agenda order; the order is kept.
  List<AgendaEntry> entries(List<AgendaItem> items, DateTime now) {
    // One "today" per zone: most users have a single zone.
    final todayByZone = <String, LocalDate>{};
    return [
      for (final item in items) _entry(item, now, todayByZone),
    ];
  }

  AgendaEntry _entry(
    AgendaItem item,
    DateTime now,
    Map<String, LocalDate> todayByZone,
  ) {
    final zone = item.task.schedule.timeZone;
    final valid = _converter.isValidZone(zone);
    final safeZone = valid ? zone : 'UTC';
    final today = todayByZone.putIfAbsent(
      safeZone,
      () => _converter.localDate(now, safeZone),
    );
    final start = item.occurrence.scheduledStart;
    return AgendaEntry(
      item: item,
      status: _resolver.resolve(
        item.occurrence,
        openSession: item.openSession,
        now: now,
        today: today,
      ),
      startTime: start == null ? null : _converter.localTime(start, safeZone),
    );
  }

  /// Summary of [entries] (normally one day's).
  ///
  /// `next` is the first match of: running or paused, due, overdue
  /// (earliest), upcoming (earliest).
  DaySummary summarize(List<AgendaEntry> entries) {
    var total = 0;
    var completed = 0;
    var skipped = 0;
    var planned = Duration.zero;
    var tracked = Duration.zero;
    for (final entry in entries) {
      final occurrence = entry.item.occurrence;
      if (occurrence.status == OccurrenceStatus.cancelled) continue;
      total++;
      planned += occurrence.plannedDuration;
      switch (occurrence.status) {
        case OccurrenceStatus.completed:
          completed++;
          tracked += occurrence.actualDuration ?? Duration.zero;
        case OccurrenceStatus.skipped:
          skipped++;
        case OccurrenceStatus.scheduled ||
            OccurrenceStatus.inProgress ||
            OccurrenceStatus.cancelled:
          break;
      }
    }
    return DaySummary(
      total: total,
      completed: completed,
      skipped: skipped,
      planned: planned,
      tracked: tracked,
      next: _next(entries),
    );
  }

  static const List<DerivedStatus> _nextPriority = [
    DerivedStatus.inProgress,
    DerivedStatus.paused,
    DerivedStatus.due,
    DerivedStatus.overdue,
    DerivedStatus.upcoming,
  ];

  AgendaEntry? _next(List<AgendaEntry> entries) {
    for (final status in _nextPriority) {
      for (final entry in entries) {
        if (entry.status == status) return entry;
      }
    }
    return null;
  }
}
