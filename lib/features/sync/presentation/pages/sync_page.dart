import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/failure_message.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_issue.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_status.dart';
import 'package:productivity_planner/features/sync/presentation/bloc/sync_status_cubit.dart';
import 'package:productivity_planner/features/sync/presentation/widgets/sync_text.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Sync status, "Sync now", and changes the server refused. Expects a
/// [SyncStatusCubit].
class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  static const syncNowKey = Key('sync.now');
  static const dismissAllKey = Key('sync.dismissAll');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<SyncStatusCubit, SyncStatusState>(
          listenWhen: (a, b) => a.failureCount != b.failureCount,
          listener: (context, state) {
            final text = state.failure?.message(l10n) ?? '';
            if (text.isNotEmpty) _snack(context, text);
          },
        ),
        BlocListener<SyncStatusCubit, SyncStatusState>(
          listenWhen: (a, b) => a.syncedCount != b.syncedCount,
          listener: (context, _) => _snack(context, l10n.syncDoneMessage),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.syncTitle)),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: BlocBuilder<SyncStatusCubit, SyncStatusState>(
                builder: (context, state) => ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _StatusCard(state: state),
                    if (state.issues.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _IssuesHeader(count: state.issues.length),
                      for (final issue in state.issues)
                        _IssueTile(issue: issue),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});

  final SyncStatusState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = state.status ?? const SyncStatus();
    final lastSynced = status.lastSyncedAt;
    final failure = status.lastFailure;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon(status), color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    syncStatusLine(l10n, state.status),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (lastSynced != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.syncLastSynced(syncTime(context, lastSynced)),
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              status.online
                  ? l10n.syncExplanation
                  : l10n.syncOfflineExplanation,
              style: theme.textTheme.bodyMedium,
            ),
            if (failure != null && status.online && !state.syncing) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                failure.message(l10n),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.icon(
                key: SyncPage.syncNowKey,
                onPressed: state.syncing
                    ? null
                    : context.read<SyncStatusCubit>().syncNow,
                icon: state.syncing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(l10n.syncNowAction),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _icon(SyncStatus status) {
    if (!status.online) return Icons.cloud_off_outlined;
    if (status.syncing) return Icons.sync;
    if (status.upToDate) return Icons.cloud_done_outlined;
    return Icons.cloud_upload_outlined;
  }
}

class _IssuesHeader extends StatelessWidget {
  const _IssuesHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.syncIssuesTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (count > 1)
          TextButton(
            key: SyncPage.dismissAllKey,
            onPressed: context.read<SyncStatusCubit>().dismissAll,
            child: Text(l10n.syncIssueDismissAll),
          ),
      ],
    );
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({required this.issue});

  final SyncIssue issue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(syncIssueTitle(l10n, issue)),
      subtitle: Text(
        '${syncIssueReason(l10n, issue)}\n${l10n.syncIssueCode(issue.code)}',
      ),
      isThreeLine: true,
      trailing: IconButton(
        tooltip: l10n.syncIssueDismiss,
        icon: const Icon(Icons.close),
        onPressed: () =>
            unawaited(context.read<SyncStatusCubit>().dismiss(issue.id)),
      ),
    );
  }
}
