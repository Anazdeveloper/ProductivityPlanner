import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_preferences_cubit.dart';
import 'package:productivity_planner/features/notifications/presentation/widgets/notification_feedback.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Settings → Notifications: the reminders switch, the OS permission (with
/// a way to fix it), exact timing on Android, and server push categories.
/// Expects [NotificationCubit] and [NotificationPreferencesCubit] above it.
class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  static const remindersSwitchKey = Key('notifications.reminders');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RefreshOnResume(
      onResume: context.read<NotificationCubit>().refresh,
      child: MultiBlocListener(
        listeners: [
          BlocListener<NotificationCubit, NotificationState>(
            listenWhen: (a, b) => a.failureCount != b.failureCount,
            listener: (context, state) =>
                showNotificationFailure(context, state.failure),
          ),
          BlocListener<
            NotificationPreferencesCubit,
            NotificationPreferencesState
          >(
            listenWhen: (a, b) => a.failureCount != b.failureCount,
            listener: (context, state) =>
                showNotificationFailure(context, state.failure),
          ),
        ],
        child: Scaffold(
          appBar: AppBar(title: Text(l10n.notificationSettingsTitle)),
          body: ListView(
            children: const [
              _RemindersSection(),
              Divider(),
              _PushSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.xs,
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class _RemindersSection extends StatelessWidget {
  const _RemindersSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final cubit = context.read<NotificationCubit>();
        final access = state.access;
        if (access == null) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final exact = access.exactAlarmsAllowed;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(l10n.remindersSectionTitle),
            SwitchListTile(
              key: NotificationSettingsPage.remindersSwitchKey,
              secondary: const Icon(Icons.alarm_outlined),
              title: Text(l10n.remindersSwitchTitle),
              subtitle: Text(l10n.remindersSwitchSubtitle),
              value: access.remindersEnabled,
              onChanged: state.busy
                  ? null
                  : (value) => cubit.setRemindersEnabled(enabled: value),
            ),
            if (access.remindersEnabled)
              _PermissionTile(
                permission: access.permission,
                busy: state.busy,
                onTurnOn: cubit.turnOn,
                onOpenSettings: cubit.openSystemSettings,
              ),
            if (access.remindersActive && exact == false)
              ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: Text(l10n.exactAlarmsTitle),
                subtitle: Text(l10n.permissionExactAlarmsDenied),
                trailing: TextButton(
                  onPressed: state.busy ? null : cubit.allowExactAlarms,
                  child: Text(l10n.allowAction),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.permission,
    required this.busy,
    required this.onTurnOn,
    required this.onOpenSettings,
  });

  final NotificationPermission permission;
  final bool busy;
  final VoidCallback onTurnOn;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (permission) {
      NotificationPermission.granted => ListTile(
        leading: const Icon(Icons.notifications_active_outlined),
        title: Text(l10n.systemNotificationsAllowed),
        trailing: TextButton(
          onPressed: busy ? null : onOpenSettings,
          child: Text(l10n.openSettingsAction),
        ),
      ),
      NotificationPermission.notDetermined => ListTile(
        leading: const Icon(Icons.notifications_none_outlined),
        title: Text(l10n.systemNotificationsNotAsked),
        trailing: FilledButton.tonal(
          onPressed: busy ? null : onTurnOn,
          child: Text(l10n.turnOnAction),
        ),
      ),
      NotificationPermission.denied => ListTile(
        leading: const Icon(Icons.notifications_off_outlined),
        title: Text(l10n.permissionNotificationsDenied),
        trailing: FilledButton.tonal(
          onPressed: busy ? null : onOpenSettings,
          child: Text(l10n.openSettingsAction),
        ),
      ),
    };
  }
}

class _PushSection extends StatelessWidget {
  const _PushSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<
      NotificationPreferencesCubit,
      NotificationPreferencesState
    >(
      builder: (context, state) {
        final cubit = context.read<NotificationPreferencesCubit>();
        final enabled =
            state.load == PreferencesLoad.ready && !state.saving;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(l10n.pushSectionTitle),
            if (state.load == PreferencesLoad.failure)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FailureBanner(failure: state.failure),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: cubit.load,
                        child: Text(l10n.actionRetry),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              SwitchListTile(
                secondary: const Icon(Icons.lightbulb_outline),
                title: Text(l10n.pushInsightsTitle),
                subtitle: Text(l10n.pushInsightsSubtitle),
                value: state.preferences.insights,
                onChanged: enabled
                    ? (value) => cubit.setInsights(enabled: value)
                    : null,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.insights_outlined),
                title: Text(l10n.pushWeeklySummaryTitle),
                subtitle: Text(l10n.pushWeeklySummarySubtitle),
                value: state.preferences.weeklySummary,
                onChanged: enabled
                    ? (value) => cubit.setWeeklySummary(enabled: value)
                    : null,
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                l10n.pushAlwaysDeliveredNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        );
      },
    );
  }
}
