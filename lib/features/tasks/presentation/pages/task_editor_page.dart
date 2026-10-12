import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_editor_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/editor/editor_parts.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/editor/repeat_section.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/feedback.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/task_visuals.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Create or edit a task. Expects a [TaskEditorCubit] above it.
///
/// Voice entry opens this page pre-filled from the understood draft (with
/// the spoken sentence shown above the form), so nothing is created until
/// the person checks the details and taps Save.
class TaskEditorPage extends StatefulWidget {
  const TaskEditorPage({
    required this.onClose,
    required this.onSaved,
    this.onOpenPlans,
    super.key,
  });

  static const titleKey = Key('editor.title');
  static const saveKey = Key('editor.save');
  static const originKey = Key('editor.origin');

  final VoidCallback onClose;
  final VoidCallback onSaved;

  /// Opens the plans screen (offered when a plan limit stops a save).
  final VoidCallback? onOpenPlans;

  /// Duration choices; an edited task's own duration is added if missing.
  static const durationOptions = [
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 20),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(hours: 1),
    Duration(minutes: 90),
    Duration(hours: 2),
    Duration(hours: 3),
  ];

  /// Reminder choices; null means none.
  static const reminderOptions = <Duration?>[
    null,
    Duration.zero,
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
  ];

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  // Controllers own the text so rebuilds never move the cursor.
  final _title = TextEditingController();
  final _notes = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _prefillOnce(TaskEditorState state) {
    if (_prefilled || state.status != EditorStatus.editing) return;
    _title.text = state.title;
    _notes.text = state.notes;
    _prefilled = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<TaskEditorCubit, TaskEditorState>(
      listenWhen: (a, b) =>
          a.status != b.status || a.failure != b.failure,
      listener: (context, state) {
        if (state.status == EditorStatus.saved) widget.onSaved();
        showFailureSnackBar(
          context,
          state.failure,
          onOpenPlans: widget.onOpenPlans,
        );
      },
      builder: (context, state) {
        _prefillOnce(state);
        final cubit = context.read<TaskEditorCubit>();
        final saving = state.status == EditorStatus.saving;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: l10n.actionClose,
              icon: const Icon(Icons.close),
              onPressed: widget.onClose,
            ),
            title: Text(state.isEdit ? l10n.editTaskTitle : l10n.newTaskTitle),
          ),
          bottomNavigationBar: state.status == EditorStatus.loadFailed
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: FilledButton(
                      key: TaskEditorPage.saveKey,
                      onPressed: state.canSubmit ? cubit.submit : null,
                      child: saving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.saveButton),
                    ),
                  ),
                ),
          body: switch (state.status) {
            EditorStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            EditorStatus.loadFailed => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: FailureBanner(failure: state.failure),
            ),
            _ => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: maxTaskContentWidth,
                ),
                child: _EditorForm(
                  state: state,
                  cubit: cubit,
                  title: _title,
                  notes: _notes,
                ),
              ),
            ),
          },
        );
      },
    );
  }
}

class _EditorForm extends StatelessWidget {
  const _EditorForm({
    required this.state,
    required this.cubit,
    required this.title,
    required this.notes,
  });

  final TaskEditorState state;
  final TaskEditorCubit cubit;
  final TextEditingController title;
  final TextEditingController notes;

  String? _error(String field, AppLocalizations l10n) {
    final code = state.fieldErrors[field];
    return code == null ? null : taskFieldError(field, code, l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled = state.status == EditorStatus.editing;
    final time = state.time;
    final scheduleStart = state.editsFromDate
        ? (state.editFrom ?? state.today)
        : state.date;
    final durations = {
      ...TaskEditorPage.durationOptions,
      state.duration,
    }.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        if (state.originText case final origin? when origin.isNotEmpty) ...[
          NoticeBanner(
            key: TaskEditorPage.originKey,
            text: l10n.voiceDraftBanner(origin),
            icon: Icons.mic_none,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TextField(
          key: TaskEditorPage.titleKey,
          controller: title,
          enabled: enabled,
          autofocus: !state.isEdit && state.title.isEmpty,
          maxLength: TaskRules.maxTitleLength,
          textCapitalization: TextCapitalization.sentences,
          onChanged: cubit.titleChanged,
          decoration: InputDecoration(
            labelText: l10n.editorTitleLabel,
            hintText: l10n.editorTitleHint,
            errorText: _error(TaskFields.title, l10n),
            counterText: '',
          ),
        ),

        // When
        EditorSection(
          label: l10n.editorWhen,
          errorText: _error(TaskFields.startDate, l10n),
          child: Column(
            children: [
              if (state.editsFromDate)
                NoticeBanner(
                  icon: Icons.info_outline,
                  text: l10n.editorChangesApplyFrom(
                    formatLongDate(context, scheduleStart),
                  ),
                )
              else
                PickerTile(
                  icon: Icons.event_outlined,
                  label: l10n.editorDate,
                  value: formatRelativeDay(context, state.date, state.today),
                  onTap: enabled ? () => _pickDate(context) : null,
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.schedule),
                title: Text(l10n.editorSetTime),
                value: time != null,
                onChanged: enabled
                    ? (on) => cubit.timeChanged(on ? LocalTime(9, 0) : null)
                    : null,
              ),
              if (time != null)
                PickerTile(
                  icon: Icons.access_time,
                  label: l10n.editorStartTime,
                  value: formatTime(context, time),
                  onTap: enabled ? () => _pickTime(context, time) : null,
                ),
            ],
          ),
        ),

        // Duration
        EditorSection(
          label: l10n.editorDuration,
          errorText: _error(TaskFields.plannedDuration, l10n),
          child: ChoiceChipGroup<Duration>(
            options: durations,
            selected: state.duration,
            enabled: enabled,
            labelOf: (d) => formatDuration(d, l10n),
            onSelected: cubit.durationChanged,
          ),
        ),

        RepeatSection(
          state: state,
          cubit: cubit,
          startDate: scheduleStart,
          enabled: enabled,
        ),

        // Reminder
        EditorSection(
          label: l10n.editorReminder,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChoiceChipGroup<Duration?>(
                options: TaskEditorPage.reminderOptions,
                selected: time == null ? null : state.reminder,
                enabled: enabled && time != null,
                labelOf: (d) =>
                    d == null ? l10n.reminderNone : reminderLabel(d, l10n),
                onSelected: cubit.reminderChanged,
              ),
              if (time == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    l10n.reminderNeedsTime,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),

        // Priority
        EditorSection(
          label: l10n.editorPriority,
          child: SegmentedButton<TaskPriority>(
            segments: [
              for (final p in TaskPriority.values)
                ButtonSegment(value: p, label: Text(priorityLabel(p, l10n))),
            ],
            selected: {state.priority},
            onSelectionChanged: enabled
                ? (selection) => cubit.priorityChanged(selection.first)
                : null,
          ),
        ),

        // Category
        EditorSection(
          label: l10n.editorCategory,
          child: ChoiceChipGroup<Category?>(
            options: [null, ...state.categories],
            selected: _selectedCategory,
            enabled: enabled,
            labelOf: (c) => c?.name ?? l10n.categoryNone,
            avatarOf: (c) => c == null ? null : CategoryDot(color: c.color),
            onSelected: (c) => cubit.categoryChanged(c?.id),
          ),
        ),

        // Notes
        EditorSection(
          label: l10n.editorNotes,
          child: TextField(
            controller: notes,
            enabled: enabled,
            minLines: 2,
            maxLines: 6,
            maxLength: TaskRules.maxNotesLength,
            textCapitalization: TextCapitalization.sentences,
            onChanged: cubit.notesChanged,
            decoration: InputDecoration(
              hintText: l10n.editorNotesHint,
              errorText: _error(TaskFields.notes, l10n),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Category? get _selectedCategory {
    for (final c in state.categories) {
      if (c.id == state.categoryId) return c;
    }
    return null;
  }

  Future<void> _pickDate(BuildContext context) async {
    final first = state.today;
    final initial = state.date < first ? first : state.date;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.toDateTimeUtc(),
      firstDate: first.toDateTimeUtc(),
      lastDate: first.addDays(365 * 5).toDateTimeUtc(),
    );
    if (picked != null) cubit.dateChanged(LocalDate.fromDateTime(picked));
  }

  Future<void> _pickTime(BuildContext context, LocalTime current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked != null) cubit.timeChanged(LocalTime(picked.hour, picked.minute));
  }
}
