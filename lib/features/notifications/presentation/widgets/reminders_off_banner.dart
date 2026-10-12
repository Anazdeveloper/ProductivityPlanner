import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:productivity_planner/features/notifications/presentation/widgets/notification_feedback.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// "Reminders are off" with a one-tap fix, shown on Today when the user
/// wants reminders but the OS does not allow them. Renders nothing
/// otherwise. Expects a [NotificationCubit] above it.
///
/// Today belongs to the tasks feature, so the router passes this widget in
/// (features never import each other's presentation).
class RemindersOffBanner extends StatelessWidget {
  const RemindersOffBanner({super.key});

  static const turnOnKey = Key('reminders.turnOn');

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationCubit>();
    return RefreshOnResume(
      onResume: cubit.refresh,
      child: BlocConsumer<NotificationCubit, NotificationState>(
        listenWhen: (a, b) => a.failureCount != b.failureCount,
        listener: (context, state) =>
            showNotificationFailure(context, state.failure),
        builder: (context, state) {
          if (!state.showPermissionBanner) return const SizedBox.shrink();
          final l10n = AppLocalizations.of(context);
          final scheme = Theme.of(context).colorScheme;
          final denied =
              state.access?.permission == NotificationPermission.denied;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Material(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      color: scheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.remindersOffBanner,
                        style: TextStyle(color: scheme.onSecondaryContainer),
                      ),
                    ),
                    TextButton(
                      key: turnOnKey,
                      onPressed: state.busy ? null : cubit.turnOn,
                      child: Text(
                        denied ? l10n.openSettingsAction : l10n.turnOnAction,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
