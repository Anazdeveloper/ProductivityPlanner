import 'dart:async';

import 'package:productivity_planner/core/entitlements/feature_access.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/ticker.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/features/analytics/data/repositories/local_analytics_repository.dart';
import 'package:productivity_planner/features/analytics/domain/services/analytics_calculator.dart';
import 'package:productivity_planner/features/analytics/domain/usecases/analytics_usecases.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/activity_analytics_cubit.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/analytics_cubit.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/category_repository.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/home_time_zone.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_planner/features/tasks/domain/services/agenda_summarizer.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_status_resolver.dart';
import 'package:productivity_planner/features/tasks/domain/services/postpone_targets.dart';
import 'package:productivity_planner/features/tasks/domain/services/task_plan_policy.dart';
import 'package:productivity_planner/features/tasks/domain/services/work_timer.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/categories.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/create_task.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/edit_task.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/occurrence_actions.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/daily_planner_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_detail_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_editor_cubit.dart';
import 'package:productivity_planner/features/voice/data/english_task_parser.dart';
import 'package:productivity_planner/features/voice/domain/services/speech_to_text_engine.dart';
import 'package:productivity_planner/features/voice/domain/usecases/voice_usecases.dart';
import 'package:productivity_planner/features/voice/presentation/bloc/voice_capture_bloc.dart';

import 'fakes.dart';

/// In-memory [TaskRepository] for widget/router tests, where drift's
/// stream queries do not mix well with fake async. Holds agenda items the
/// test sets; writes are recorded, not applied.
final class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository([List<AgendaItem> items = const []]) : _items = items;

  List<AgendaItem> _items;
  final _changes = StreamController<void>.broadcast(sync: true);
  final List<TaskDraft> created = [];
  final List<(String, OccurrenceAction)> actions = [];

  final List<(String, TaskDetails)> detailUpdates = [];
  final List<(String, LocalDate, TaskSchedule)> reschedules = [];

  /// When set, every action fails with it.
  Failure? actionFailure;

  List<AgendaItem> get items => _items;

  set items(List<AgendaItem> value) {
    _items = value;
    _changes.add(null);
  }

  Stream<T> _live<T>(T Function() read) => Stream<T>.multi((c) {
    c.add(read());
    final sub = _changes.stream.listen((_) => c.add(read()));
    c.onCancel = sub.cancel;
  });

  @override
  Stream<Result<List<AgendaItem>>> watchAgenda({
    required LocalDate from,
    required LocalDate to,
  }) => _live(
    () => Ok([
      for (final i in _items)
        if (i.occurrence.scheduledDate >= from &&
            i.occurrence.scheduledDate <= to)
          i,
    ]),
  );

  @override
  Stream<Result<AgendaItem?>> watchAgendaItem(String occurrenceId) => _live(
    () => Ok(_items.where((i) => i.occurrence.id == occurrenceId).firstOrNull),
  );

  @override
  Stream<Result<List<AgendaItem>>> watchInProgress() => _live(
    () => Ok([
      for (final i in _items)
        if (i.occurrence.status == OccurrenceStatus.inProgress) i,
    ]),
  );

  @override
  Stream<Result<List<AgendaItem>>> watchLineage(
    String lineageId, {
    required LocalDate from,
    required LocalDate to,
  }) => _live(
    () => Ok([
      for (final i in _items)
        if (i.task.lineageId == lineageId &&
            i.occurrence.scheduledDate >= from &&
            i.occurrence.scheduledDate <= to)
          i,
    ]),
  );

  @override
  Future<Result<Task>> getTask(String taskId) async {
    for (final item in _items) {
      if (item.task.id == taskId) return Ok(item.task);
    }
    return const Err(Failure.notFound(entity: 'task'));
  }

  @override
  Future<Result<List<Task>>> listTasks() async => Ok([
    ...{for (final item in _items) item.task.id: item.task}.values,
  ]);

  @override
  Future<Result<Task>> createTask(TaskDraft draft) async {
    created.add(draft);
    final now = DateTime.utc(2026, 10, 7);
    return Ok(
      Task(
        id: 'task-${created.length}',
        lineageId: 'task-${created.length}',
        title: draft.details.title,
        plannedDuration: draft.details.plannedDuration,
        schedule: draft.schedule,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<Result<LifecycleOutcome>> applyAction(
    String occurrenceId,
    OccurrenceAction action,
  ) async {
    actions.add((occurrenceId, action));
    final failure = actionFailure;
    if (failure != null) return Err(failure);
    final item = _items.where((i) => i.occurrence.id == occurrenceId);
    if (item.isEmpty) return const Err(Failure.notFound());
    return Ok(
      LifecycleOutcome(
        transition: OccurrenceTransition.noteUpdated,
        occurrence: item.first.occurrence,
      ),
    );
  }

  @override
  Future<Result<Task>> updateTaskDetails(
    String taskId,
    TaskDetails details,
  ) async {
    detailUpdates.add((taskId, details));
    return await getTask(taskId);
  }

  @override
  Future<Result<Task>> rescheduleFrom(
    String taskId, {
    required LocalDate fromDate,
    required TaskSchedule schedule,
  }) async {
    reschedules.add((taskId, fromDate, schedule));
    return await getTask(taskId);
  }

  @override
  Future<Result<Unit>> endTask(
    String taskId, {
    required LocalDate lastDate,
  }) async => const Ok(unit);

  @override
  Future<Result<Unit>> deleteTask(String taskId) async => const Ok(unit);

  @override
  Future<Result<int>> materializeOccurrences() async => const Ok(0);
}

final class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository([this.categories = const []]);

  final List<Category> categories;

  @override
  Stream<Result<List<Category>>> watchCategories() =>
      Stream.value(Ok(categories));

  @override
  Future<Result<Category>> createCategory({
    required String name,
    required CategoryColor color,
  }) async => Ok(Category(id: 'c-$name', name: name, color: color));

  @override
  Future<Result<Unit>> ensureDefaultCategories(String userId) async =>
      const Ok(unit);
}

final class FixedHomeTimeZone implements HomeTimeZone {
  const FixedHomeTimeZone([this.zone = 'Asia/Kolkata']);

  final String zone;

  @override
  Future<String> current() async => zone;
}

/// Ticks only when the test says so.
final class ManualTicker implements Ticker {
  final _controller = StreamController<DateTime>.broadcast();

  void tick(DateTime now) => _controller.add(now);

  @override
  Stream<DateTime> ticks() => _controller.stream;
}

/// Builds the task screen cubits with real use cases over [tasks].
final class TaskCubitFactory {
  TaskCubitFactory({
    required this.tasks,
    required this.clock,
    CategoryRepository? categories,
    HomeTimeZone homeTimeZone = const FixedHomeTimeZone(),
    Ticker? ticker,
    this.access = const UnrestrictedFeatureAccess(),
  }) : categories = categories ?? FakeCategoryRepository(),
       _home = homeTimeZone,
       ticker = ticker ?? ManualTicker();

  final TaskRepository tasks;
  final CategoryRepository categories;

  /// The plan task limits are checked against.
  final FeatureAccessService access;
  final FixedClock clock;
  final Ticker ticker;
  final HomeTimeZone _home;
  final converter = TzTimeZoneConverter();

  TaskRules get _rules => TaskRules(converter);

  AgendaSummarizer get summarizer => AgendaSummarizer(
    resolver: const OccurrenceStatusResolver(),
    converter: converter,
  );

  CreateTask get _create => CreateTask(
    repository: tasks,
    rules: _rules,
    policy: TaskPlanPolicy(access),
    converter: converter,
    clock: clock,
  );

  DailyPlannerCubit planner(PlannerScope scope) => DailyPlannerCubit(
    scope: scope,
    watchAgenda: WatchAgenda(tasks),
    getHomeToday: GetHomeToday(
      homeTimeZone: _home,
      converter: converter,
      clock: clock,
    ),
    getHomeTimeZone: GetHomeTimeZone(homeTimeZone: _home, converter: converter),
    applyAction: ApplyOccurrenceAction(tasks),
    createTask: _create,
    summarizer: summarizer,
    clock: clock,
    ticker: ticker,
  );

  TaskEditorCubit editor(TaskEditorArgs args) => TaskEditorCubit(
    args: args,
    createTask: _create,
    updateTaskDetails: UpdateTaskDetails(repository: tasks, rules: _rules),
    rescheduleTaskFrom: RescheduleTaskFrom(
      repository: tasks,
      rules: _rules,
      policy: TaskPlanPolicy(access),
      converter: converter,
      clock: clock,
    ),
    getTask: GetTask(tasks),
    getHomeTimeZone: GetHomeTimeZone(homeTimeZone: _home, converter: converter),
    watchCategories: WatchCategories(categories),
    converter: converter,
    clock: clock,
  );

  FocusTimerBloc focusTimer(FocusTarget target) => FocusTimerBloc(
    target: target,
    watchActiveWork: WatchActiveWork(tasks),
    watchAgendaItem: WatchAgendaItem(tasks),
    applyAction: ApplyOccurrenceAction(tasks),
    workTimer: const WorkTimer(),
    clock: clock,
    ticker: ticker,
  );

  AnalyticsCubit analytics({
    FeatureAccessService access = const UnrestrictedFeatureAccess(),
  }) => AnalyticsCubit(
    watchPeriodRecords: WatchPeriodRecords(LocalAnalyticsRepository(tasks)),
    getHomeToday: GetHomeToday(
      homeTimeZone: _home,
      converter: converter,
      clock: clock,
    ),
    getAccess: GetAnalyticsAccess(access),
    calculator: AnalyticsCalculator(converter),
    clock: clock,
    ticker: ticker,
  );

  ActivityAnalyticsCubit activity(
    String lineageId, {
    FeatureAccessService access = const UnrestrictedFeatureAccess(),
  }) => ActivityAnalyticsCubit(
    lineageId: lineageId,
    watchActivityRecords: WatchActivityRecords(
      LocalAnalyticsRepository(tasks),
    ),
    getHomeToday: GetHomeToday(
      homeTimeZone: _home,
      converter: converter,
      clock: clock,
    ),
    getAccess: GetAnalyticsAccess(access),
    applySuggestion: ApplyDurationSuggestion(
      getTask: GetTask(tasks),
      updateTaskDetails: UpdateTaskDetails(repository: tasks, rules: _rules),
    ),
    calculator: AnalyticsCalculator(converter),
    clock: clock,
  );

  /// Voice capture with the real English parser over [categories].
  VoiceCaptureBloc voice(SpeechToTextEngine engine) => VoiceCaptureBloc(
    prepareSpeech: PrepareSpeech(engine),
    listenForSpeech: ListenForSpeech(engine),
    stopListening: StopListening(engine),
    parseSpokenTask: ParseSpokenTask(
      parser: const EnglishTaskTextParser(),
      getHomeTimeZone: GetHomeTimeZone(homeTimeZone: _home, converter: converter),
      watchCategories: WatchCategories(categories),
      converter: converter,
      clock: clock,
    ),
  );

  TaskDetailCubit detail(String occurrenceId) => TaskDetailCubit(
    occurrenceId: occurrenceId,
    watchAgendaItem: WatchAgendaItem(tasks),
    applyAction: ApplyOccurrenceAction(tasks),
    endTask: EndTask(repository: tasks, converter: converter, clock: clock),
    deleteTask: DeleteTask(tasks),
    summarizer: summarizer,
    postponeTargets: PostponeTargets(converter),
    converter: converter,
    clock: clock,
    ticker: ticker,
  );
}
