import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Bottom navigation on phones, navigation rail on tablets and landscape.
/// Each tab keeps its own navigation stack (StatefulShellRoute).
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  static const double _railBreakpoint = 840;

  final StatefulNavigationShell navigationShell;

  static List<_Tab> _tabs(AppLocalizations l10n) => [
    _Tab(l10n.tabToday, Icons.today_outlined, Icons.today),
    _Tab(l10n.tabPlanner, Icons.calendar_month_outlined, Icons.calendar_month),
    _Tab(l10n.tabInsights, Icons.insights_outlined, Icons.insights),
    _Tab(l10n.tabSettings, Icons.settings_outlined, Icons.settings),
  ];

  void _onSelect(int index) => navigationShell.goBranch(
    index,
    // Tapping the active tab returns to its root.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs(AppLocalizations.of(context));
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _railBreakpoint) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onSelect,
                  destinations: [
                    for (final tab in tabs)
                      NavigationRailDestination(
                        icon: Icon(tab.icon),
                        selectedIcon: Icon(tab.selectedIcon),
                        label: Text(tab.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onSelect,
            destinations: [
              for (final tab in tabs)
                NavigationDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.selectedIcon),
                  label: tab.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

final class _Tab {
  const _Tab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
