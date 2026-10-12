import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// What the user picked in the postpone sheet.
sealed class PostponeChoice {
  const PostponeChoice();
}

final class PostponeLaterToday extends PostponeChoice {
  const PostponeLaterToday();
}

final class PostponeTomorrow extends PostponeChoice {
  const PostponeTomorrow();
}

final class PostponeToSlot extends PostponeChoice {
  const PostponeToSlot(this.date, this.time);

  final LocalDate date;
  final LocalTime? time;
}

/// Bottom sheet: later today / tomorrow / pick a date and time.
Future<PostponeChoice?> showPostponeSheet(
  BuildContext context, {
  required bool canLaterToday,
  required LocalDate today,
  required bool hasTime,
}) => showModalBottomSheet<PostponeChoice>(
  context: context,
  showDragHandle: true,
  builder: (sheetContext) {
    final l10n = AppLocalizations.of(sheetContext);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canLaterToday)
            ListTile(
              leading: const Icon(Icons.hourglass_bottom),
              title: Text(l10n.postponeLaterToday),
              onTap: () =>
                  Navigator.pop(sheetContext, const PostponeLaterToday()),
            ),
          ListTile(
            leading: const Icon(Icons.wb_twilight),
            title: Text(l10n.postponeTomorrow),
            onTap: () => Navigator.pop(sheetContext, const PostponeTomorrow()),
          ),
          ListTile(
            leading: const Icon(Icons.edit_calendar_outlined),
            title: Text(l10n.postponePick),
            onTap: () async {
              final slot = await _pickSlot(
                sheetContext,
                today: today,
                withTime: hasTime,
              );
              if (slot != null && sheetContext.mounted) {
                Navigator.pop(sheetContext, slot);
              }
            },
          ),
        ],
      ),
    );
  },
);

Future<PostponeToSlot?> _pickSlot(
  BuildContext context, {
  required LocalDate today,
  required bool withTime,
}) async {
  final date = await showDatePicker(
    context: context,
    initialDate: today.addDays(1).toDateTimeUtc(),
    firstDate: today.toDateTimeUtc(),
    lastDate: today.addDays(365).toDateTimeUtc(),
  );
  if (date == null || !context.mounted) return null;
  if (!withTime) return PostponeToSlot(LocalDate.fromDateTime(date), null);
  final time = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 9, minute: 0),
  );
  if (time == null) return null;
  return PostponeToSlot(
    LocalDate.fromDateTime(date),
    LocalTime(time.hour, time.minute),
  );
}

/// Bottom sheet listing skip reasons.
Future<SkipReason?> showSkipSheet(BuildContext context) =>
    showModalBottomSheet<SkipReason>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Text(
                  l10n.skipWhy,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              for (final reason in SkipReason.values)
                ListTile(
                  title: Text(skipReasonLabel(reason, l10n)),
                  onTap: () => Navigator.pop(sheetContext, reason),
                ),
            ],
          ),
        );
      },
    );

/// Dialog to enter how long a task took (completing without the timer).
Future<Duration?> showActualDurationDialog(
  BuildContext context, {
  required Duration planned,
}) => showDialog<Duration>(
  context: context,
  builder: (dialogContext) => _DurationDialog(initial: planned),
);

class _DurationDialog extends StatefulWidget {
  const _DurationDialog({required this.initial});

  final Duration initial;

  @override
  State<_DurationDialog> createState() => _DurationDialogState();
}

class _DurationDialogState extends State<_DurationDialog> {
  static const _step = 5;

  /// Longer sessions are rare when completing by hand; 4 h keeps the
  /// slider precise.
  static const _sliderMax = 240;

  late int _minutes = math.min(
    math.max(widget.initial.inMinutes, _step),
    _sliderMax,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.actualDurationTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDuration(Duration(minutes: _minutes), l10n),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Slider(
            value: _minutes.toDouble(),
            min: _step.toDouble(),
            max: _sliderMax.toDouble(),
            divisions: (_sliderMax - _step) ~/ _step,
            label: formatDuration(Duration(minutes: _minutes), l10n),
            onChanged: (v) => setState(() => _minutes = v.round()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, Duration(minutes: _minutes)),
          child: Text(l10n.markDone),
        ),
      ],
    );
  }
}

/// Dialog to edit the occurrence note. Returns the new text (possibly
/// empty, which clears it) or null when cancelled.
Future<String?> showNoteDialog(BuildContext context, {String? initial}) =>
    showDialog<String>(
      context: context,
      builder: (dialogContext) => _NoteDialog(initial: initial ?? ''),
    );

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initial});

  final String initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.noteTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        maxLength: TaskRules.maxNotesLength,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: l10n.noteHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.saveButton),
        ),
      ],
    );
  }
}

/// Yes/no confirmation for destructive actions.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext);
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
