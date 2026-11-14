import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/evil_logo.dart';
import '../../l10n/app_localizations.dart';

/// Top-level scaffold: a bottom navigation bar on phones, a side rail on
/// tablets/desktop/web. Both follow the text direction, so they mirror in
/// Arabic automatically.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      (Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      (Icons.insights_outlined, Icons.insights_rounded, l10n.navAnalyze),
      (Icons.extension_outlined, Icons.extension_rounded, l10n.navPuzzles),
      (
        Icons.sports_esports_outlined,
        Icons.sports_esports_rounded,
        l10n.navPlay,
      ),
      (Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
    ];

    final wide = MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint;

    if (wide) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: shell.currentIndex,
                onDestinationSelected: _go,
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: EcSpace.md),
                  child: EvilLogo(semanticLabel: l10n.appTitle),
                ),
                destinations: [
                  for (final (icon, selected, label) in destinations)
                    NavigationRailDestination(
                      icon: Icon(icon),
                      selectedIcon: Icon(selected),
                      label: Text(label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: shell),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _go,
        destinations: [
          for (final (icon, selected, label) in destinations)
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selected),
              label: label,
            ),
        ],
      ),
    );
  }
}
