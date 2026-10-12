import 'package:flutter/material.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.onOpenProfile,
    required this.onOpenSubscription,
    required this.onOpenNotifications,
    required this.onSignOut,
    this.syncTile,
    super.key,
  });

  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSubscription;
  final VoidCallback onSignOut;

  /// The sync status row, built by the router (it comes from another
  /// feature).
  final Widget? syncTile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.profileTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenProfile,
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.settingsNotifications),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenNotifications,
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(l10n.subscriptionTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenSubscription,
          ),
          if (syncTile case final tile?) tile,
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.signOutAction),
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}
