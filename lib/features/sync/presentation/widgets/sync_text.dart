import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_issue.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_status.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// One line describing [status] (null while it is still loading).
String syncStatusLine(AppLocalizations l10n, SyncStatus? status) {
  if (status == null) return '';
  if (status.syncing) return l10n.syncStatusSyncing;
  if (!status.online) {
    return status.pendingChanges > 0
        ? l10n.syncStatusPending(status.pendingChanges)
        : l10n.syncStatusOffline;
  }
  if (status.pendingChanges > 0) {
    return l10n.syncStatusPending(status.pendingChanges);
  }
  if (status.lastFailure != null) return l10n.syncStatusFailed;
  if (status.lastSyncedAt == null) return l10n.syncStatusNotYet;
  return l10n.syncStatusUpToDate;
}

String syncTime(BuildContext context, DateTime instant) => DateFormat.jm(
  Localizations.localeOf(context).toLanguageTag(),
).format(instant.toLocal());

String syncIssueTitle(AppLocalizations l10n, SyncIssue issue) {
  final label = issue.label;
  if (label != null && label.trim().isNotEmpty) return label;
  return switch (issue.subject) {
    SyncIssueSubject.task || SyncIssueSubject.occurrence =>
      l10n.syncIssueUnnamedTask,
    SyncIssueSubject.category => l10n.syncIssueUnnamedCategory,
    SyncIssueSubject.other => l10n.syncIssueUnnamedOther,
  };
}

String syncIssueReason(AppLocalizations l10n, SyncIssue issue) =>
    switch (issue.reason) {
      SyncIssueReason.deleted => l10n.syncIssueDeleted,
      SyncIssueReason.conflict => l10n.syncIssueConflict,
      SyncIssueReason.plan => l10n.syncIssuePlan,
      SyncIssueReason.invalid => l10n.syncIssueInvalid,
      SyncIssueReason.failed => l10n.syncIssueFailed,
      SyncIssueReason.other => l10n.syncIssueOther,
    };
