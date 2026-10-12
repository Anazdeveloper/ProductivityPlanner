import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/entitlements/feature_access.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/analytics/domain/entities/analytics_period.dart';
import 'package:productivity_planner/features/analytics/domain/entities/execution_record.dart';
import 'package:productivity_planner/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/edit_task.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';

/// The records a period's report needs: the period and the one before it
/// (for the comparison).
final class WatchPeriodRecords
    implements StreamUseCase<List<ExecutionRecord>, AnalyticsPeriod> {
  const WatchPeriodRecords(this._repository);

  final AnalyticsRepository _repository;

  @override
  Stream<Result<List<ExecutionRecord>>> call(AnalyticsPeriod period) =>
      _repository.watchRecords(from: period.previous.start, to: period.end);
}

final class ActivityWindow {
  const ActivityWindow({
    required this.lineageId,
    required this.from,
    required this.to,
  });

  final String lineageId;
  final LocalDate from;
  final LocalDate to;
}

final class WatchActivityRecords
    implements StreamUseCase<List<ExecutionRecord>, ActivityWindow> {
  const WatchActivityRecords(this._repository);

  final AnalyticsRepository _repository;

  @override
  Stream<Result<List<ExecutionRecord>>> call(ActivityWindow window) =>
      _repository.watchActivity(
        window.lineageId,
        from: window.from,
        to: window.to,
      );
}

/// What the plan allows in analytics.
@immutable
final class AnalyticsAccess {
  const AnalyticsAccess({
    required this.suggestionsUnlocked,
    this.earliestDate,
  });

  /// The oldest date that can be shown; null means all history.
  final LocalDate? earliestDate;

  /// Duration suggestions are part of advanced analytics.
  final bool suggestionsUnlocked;

  bool allows(LocalDate date) {
    final earliest = earliestDate;
    return earliest == null || date >= earliest;
  }

  @override
  bool operator ==(Object other) =>
      other is AnalyticsAccess &&
      other.earliestDate == earliestDate &&
      other.suggestionsUnlocked == suggestionsUnlocked;

  @override
  int get hashCode => Object.hash(earliestDate, suggestionsUnlocked);
}

/// Analytics access for a user whose today is the given date: the history
/// window (`limit.analytics_history_days`, 30 days on the free plan) and
/// whether `feature.advanced_analytics` is included.
final class GetAnalyticsAccess implements UseCase<AnalyticsAccess, LocalDate> {
  const GetAnalyticsAccess(this._access);

  final FeatureAccessService _access;

  /// Emits when the plan changed (ask again).
  Stream<void> get changes => _access.changes;

  @override
  Future<Result<AnalyticsAccess>> call(LocalDate today) async {
    final days = _access.limit(LimitKey.analyticsHistoryDays);
    return Ok(
      AnalyticsAccess(
        earliestDate: days == null || days < 1
            ? null
            : today.addDays(-(days - 1)),
        suggestionsUnlocked: _access.canUse(Feature.advancedAnalytics),
      ),
    );
  }
}

final class ApplyDurationParams {
  const ApplyDurationParams({required this.taskId, required this.duration});

  final String taskId;
  final Duration duration;
}

/// Makes a suggested duration the task's expected duration. Like any
/// duration edit, it applies to occurrences from today that have not
/// started; history keeps the duration it was planned with.
final class ApplyDurationSuggestion
    implements UseCase<Unit, ApplyDurationParams> {
  const ApplyDurationSuggestion({
    required GetTask getTask,
    required UpdateTaskDetails updateTaskDetails,
  }) : _getTask = getTask,
       _updateTaskDetails = updateTaskDetails;

  final GetTask _getTask;
  final UpdateTaskDetails _updateTaskDetails;

  @override
  Future<Result<Unit>> call(ApplyDurationParams params) async {
    final found = await _getTask(params.taskId);
    final updated = await found.andThen(
      (task) => _updateTaskDetails(
        UpdateTaskDetailsParams(
          taskId: task.id,
          details: TaskDetails(
            title: task.title,
            plannedDuration: params.duration,
            notes: task.notes,
            categoryId: task.categoryId,
            priority: task.priority,
            reminderOffsets: task.reminderOffsets,
          ),
        ),
      ),
    );
    return updated.map((_) => unit);
  }
}
