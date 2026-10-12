import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/features/sync/presentation/bloc/sync_status_cubit.dart';
import 'package:productivity_planner/features/sync/presentation/widgets/sync_text.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// The Settings row: sync state at a glance. Expects a [SyncStatusCubit].
class SyncSettingsTile extends StatelessWidget {
  const SyncSettingsTile({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<SyncStatusCubit, SyncStatusState>(
      builder: (context, state) {
        final status = state.status;
        final line = syncStatusLine(l10n, status);
        final attention =
            state.issues.isNotEmpty ||
            (status != null && status.lastFailure != null && status.online);
        return ListTile(
          leading: Icon(
            status == null || status.online
                ? Icons.sync
                : Icons.cloud_off_outlined,
          ),
          title: Text(l10n.syncTitle),
          subtitle: line.isEmpty ? null : Text(line),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (attention)
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  semanticLabel: l10n.syncIssuesTitle,
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: onTap,
        );
      },
    );
  }
}
