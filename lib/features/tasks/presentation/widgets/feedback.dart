import 'package:flutter/material.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/presentation/failure_message.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Task screens never stretch wider than this (tablets, landscape).
const double maxTaskContentWidth = 720;

/// Shows [failure] as a snackbar, replacing any current one. Does nothing
/// for null or a cancelled flow. A field error (e.g. a postpone time in the
/// past) is spelled out, since there is no field on screen to highlight.
/// A plan limit gets a "See plans" action when [onOpenPlans] is given.
void showFailureSnackBar(
  BuildContext context,
  Failure? failure, {
  VoidCallback? onOpenPlans,
}) {
  if (failure == null) return;
  final l10n = AppLocalizations.of(context);
  final text = switch (failure) {
    ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty =>
      taskFieldError(fieldErrors.keys.first, fieldErrors.values.first, l10n),
    _ => failure.message(l10n),
  };
  if (text.isEmpty) return;
  final planLimit =
      failure is EntitlementRequiredFailure || failure is LimitReachedFailure;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        action: planLimit && onOpenPlans != null
            ? SnackBarAction(label: l10n.seePlans, onPressed: onOpenPlans)
            : null,
      ),
    );
}
