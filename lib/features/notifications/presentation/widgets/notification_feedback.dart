import 'package:flutter/material.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/presentation/failure_message.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Shows [failure] once as a snackbar; nothing for null or cancelled.
void showNotificationFailure(BuildContext context, Failure? failure) {
  if (failure == null) return;
  final text = failure.message(AppLocalizations.of(context));
  if (text.isEmpty) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// Calls [onResume] when the app returns to the foreground, e.g. after the
/// user changed notification permission in the system settings.
class RefreshOnResume extends StatefulWidget {
  const RefreshOnResume({
    required this.onResume,
    required this.child,
    super.key,
  });

  final VoidCallback onResume;
  final Widget child;

  @override
  State<RefreshOnResume> createState() => _RefreshOnResumeState();
}

class _RefreshOnResumeState extends State<RefreshOnResume> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onResume: () => widget.onResume());
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
