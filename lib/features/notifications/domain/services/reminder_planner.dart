import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

/// Decides which reminders should be scheduled right now.
///
/// Pure: the reconciler feeds it the upcoming agenda and diffs the result
/// against what the platform holds.
///
/// Rules:
/// - only occurrences still `scheduled` (not started, not resolved) with a
///   start time and at least one reminder offset;
/// - one reminder per offset, firing at `start - offset`, only if that is
///   still in the future (no "starts in 5 minutes" two minutes before);
/// - the earliest [maxPending] across all tasks. iOS keeps at most 64
///   pending notifications per app; 48 leaves room for snoozes and pushes,
///   and the reconciler runs on every change, launch and resume, so later
///   reminders are scheduled as earlier ones fire.
final class ReminderPlanner {
  const ReminderPlanner({this.maxPending = defaultMaxPending});

  static const defaultMaxPending = 48;

  final int maxPending;

  List<ReminderRequest> plan(Iterable<AgendaItem> items, {required DateTime now}) {
    final requests = <ReminderRequest>[];
    for (final item in items) {
      final occurrence = item.occurrence;
      final start = occurrence.scheduledStart;
      if (occurrence.status != OccurrenceStatus.scheduled || start == null) {
        continue;
      }
      for (final offset in item.task.reminderOffsets.toSet()) {
        final fireAt = start.subtract(offset);
        if (!fireAt.isAfter(now)) continue;
        requests.add(
          ReminderRequest(
            id: reminderNotificationId(
              occurrence.id,
              ReminderKind.reminder,
              offset: offset,
            ),
            occurrenceId: occurrence.id,
            kind: ReminderKind.reminder,
            fireAt: fireAt,
            taskTitle: item.task.title,
            startAt: start,
            timeZone: item.task.schedule.timeZone,
          ),
        );
      }
    }
    requests.sort((a, b) {
      final byTime = a.fireAt.compareTo(b.fireAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    return requests.length <= maxPending
        ? requests
        : requests.sublist(0, maxPending);
  }

  /// Whether a snoozed reminder for [item] should still fire: the task has
  /// not been started or resolved in the meantime.
  bool snoozeStillWanted(AgendaItem item) =>
      item.occurrence.status == OccurrenceStatus.scheduled;
}
