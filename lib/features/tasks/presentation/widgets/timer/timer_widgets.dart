import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/features/tasks/domain/services/work_timer.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Elapsed time in large tabular digits. Screen readers get a stable
/// minute-level label instead of a value that changes every second.
class ElapsedText extends StatelessWidget {
  const ElapsedText({required this.timer, this.style, super.key});

  final TimerSnapshot timer;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final base = style ?? Theme.of(context).textTheme.displaySmall;
    return Semantics(
      label: l10n.elapsedSemantics(formatDuration(timer.tracked, l10n)),
      child: ExcludeSemantics(
        child: Text(
          formatElapsed(timer.tracked),
          style: base?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Progress against the plan: a bar plus "12 min left" / "5 min over plan".
/// Over-plan is shown with the error colour *and* words, never colour alone.
class PlanProgress extends StatelessWidget {
  const PlanProgress({required this.timer, super.key});

  final TimerSnapshot timer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final over = timer.overrun;
    final remaining = timer.remaining;
    final label = over
        ? l10n.timeOver(formatDuration(-remaining, l10n))
        : l10n.timeLeft(formatDuration(remaining, l10n));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: timer.progress,
            minHeight: 6,
            color: over ? scheme.error : scheme.primary,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.trackedOfPlanned(
                  formatDuration(timer.tracked, l10n),
                  formatDuration(timer.planned, l10n),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: over ? scheme.error : null,
                fontWeight: over ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Start / Pause / Resume, sized for the thumb.
class TimerToggleButton extends StatelessWidget {
  const TimerToggleButton({
    required this.running,
    required this.started,
    required this.onStart,
    required this.onPause,
    this.enabled = true,
    super.key,
  });

  static const buttonKey = Key('timer.toggle');

  final bool running;

  /// Worked on before (shows "Resume" rather than "Start").
  final bool started;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, label, action) = running
        ? (Icons.pause, l10n.pauseAction, onPause)
        : started
        ? (Icons.play_arrow, l10n.resumeAction, onStart)
        : (Icons.play_arrow, l10n.startAction, onStart);
    return FilledButton.icon(
      key: buttonKey,
      onPressed: enabled ? action : null,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
