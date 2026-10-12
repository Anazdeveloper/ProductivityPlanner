import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/entitlements/feature_access.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';

/// What the plan allows for tasks, asked through [FeatureAccessService]
/// (the server enforces the same rules on sync, contract §3.5):
///
/// - `limit.active_series`: series that can still produce occurrences
///   (not ended, `until` not passed).
/// - `limit.recurring_series`: the repeating ones among them.
/// - `feature.advanced_recurrence`: "every N" with N > 1.
///
/// An existing task is never taken away: an edit is only checked for what
/// it adds (becoming repeating, a larger interval).
final class TaskPlanPolicy {
  const TaskPlanPolicy(this._access);

  final FeatureAccessService _access;

  /// Null when allowed. [tasks] are the user's series; [editing] is the
  /// series being changed (null for a new one).
  Failure? check(
    TaskSchedule schedule, {
    required List<Task> tasks,
    required LocalDate today,
    Task? editing,
  }) {
    final rule = schedule.rule;
    final before = editing?.schedule.rule;

    if (rule.isRecurring &&
        rule.interval > 1 &&
        rule.interval > (before?.interval ?? 1) &&
        !_access.canUse(Feature.advancedRecurrence)) {
      return const Failure.entitlementRequired(
        feature: Feature.advancedRecurrence,
      );
    }

    final others = [
      for (final task in tasks)
        if (task.id != editing?.id && isActive(task, today)) task,
    ];

    // An edited task that still counts adds nothing; one that had ended
    // (or a past one-off moved to a future day) comes back as new use.
    final counted = editing != null && isActive(editing, today);

    final maxActive = _access.limit(LimitKey.activeSeries);
    if (!counted && maxActive != null && others.length >= maxActive) {
      return Failure.limitReached(
        limit: LimitKey.activeSeries,
        allowed: maxActive,
      );
    }

    final maxRecurring = _access.limit(LimitKey.recurringSeries);
    final becomesRecurring =
        rule.isRecurring && !(counted && (before?.isRecurring ?? false));
    if (becomesRecurring && maxRecurring != null) {
      final recurring = others.where((t) => t.isRecurring).length;
      if (recurring >= maxRecurring) {
        return Failure.limitReached(
          limit: LimitKey.recurringSeries,
          allowed: maxRecurring,
        );
      }
    }
    return null;
  }

  /// Can still produce occurrences from [today]. A one-off task counts
  /// until its day has passed.
  static bool isActive(Task task, LocalDate today) {
    if (!task.isRecurring) return task.schedule.startDate >= today;
    final last = task.lastPossibleDate;
    return last == null || last >= today;
  }
}
