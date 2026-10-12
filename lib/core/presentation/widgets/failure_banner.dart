import 'package:flutter/material.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/failure_message.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Inline, screen-reader-announced error message for a [Failure].
/// Renders nothing for `null` or a cancelled flow.
class FailureBanner extends StatelessWidget {
  const FailureBanner({required this.failure, super.key});

  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final current = failure;
    if (current == null) return const SizedBox.shrink();
    final text = current.message(AppLocalizations.of(context));
    if (text.isEmpty) return const SizedBox.shrink();
    return NoticeBanner(text: text, icon: Icons.error_outline, isError: true);
  }
}

/// Tonal banner for errors and informational notices.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    required this.text,
    required this.icon,
    this.isError = false,
    super.key,
  });

  final String text;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = isError
        ? scheme.errorContainer
        : scheme.secondaryContainer;
    final foreground = isError
        ? scheme.onErrorContainer
        : scheme.onSecondaryContainer;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
