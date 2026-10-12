import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/detail/detail_sheets.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/feedback.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// The timer's one-off feedback, wherever a [FocusTimerBloc] is shown:
/// failures and "paused X" as snackbars, and the long-session question as
/// a dialog.
class FocusTimerFeedback extends StatelessWidget {
  const FocusTimerFeedback({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<FocusTimerBloc, FocusTimerState>(
        listenWhen: (a, b) => a.failureCount != b.failureCount,
        listener: (context, state) =>
            showFailureSnackBar(context, state.failure),
      ),
      BlocListener<FocusTimerBloc, FocusTimerState>(
        listenWhen: (a, b) => a.noticeCount != b.noticeCount,
        listener: (context, state) {
          final title = state.autoPausedTitle;
          if (title == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).autoPausedNotice(title),
                ),
              ),
            );
        },
      ),
      BlocListener<FocusTimerBloc, FocusTimerState>(
        listenWhen: (a, b) =>
            a.confirmCount != b.confirmCount && b.confirmTracked != null,
        listener: (context, state) async {
          final tracked = state.confirmTracked;
          final item = state.item;
          if (tracked == null || item == null) return;
          final bloc = context.read<FocusTimerBloc>();
          final choice = await _showLongSessionDialog(context, tracked);
          if (!context.mounted) return;
          switch (choice) {
            case _LongSessionChoice.keep:
              bloc.add(const FocusTimerCompleteConfirmed());
            case _LongSessionChoice.enter:
              final took = await showActualDurationDialog(
                context,
                planned: item.occurrence.plannedDuration,
              );
              bloc.add(
                took == null
                    ? const FocusTimerConfirmationDismissed()
                    : FocusTimerCompleteConfirmed(actualDuration: took),
              );
            case null:
              bloc.add(const FocusTimerConfirmationDismissed());
          }
        },
      ),
    ],
    child: child,
  );
}

enum _LongSessionChoice { keep, enter }

/// "The timer shows 9 h 12 min. Was it left running?"
Future<_LongSessionChoice?> _showLongSessionDialog(
  BuildContext context,
  Duration tracked,
) {
  final l10n = AppLocalizations.of(context);
  final duration = formatDuration(tracked, l10n);
  return showDialog<_LongSessionChoice>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.longSessionTitle),
      content: Text(l10n.longSessionMessage(duration)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(dialogContext, _LongSessionChoice.keep),
          child: Text(l10n.longSessionKeep(duration)),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(dialogContext, _LongSessionChoice.enter),
          child: Text(l10n.longSessionEnter),
        ),
      ],
    ),
  );
}
