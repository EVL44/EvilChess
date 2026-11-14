import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/analyze/analyze_screen.dart';
import '../../features/design_system/design_system_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/play/play_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/puzzles/puzzles_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';

abstract final class Routes {
  static const home = '/';
  static const analyze = '/analyze';
  static const puzzles = '/puzzles';
  static const play = '/play';
  static const profile = '/profile';
  static const settings = '/settings';
  static const designSystem = '/design-system';
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          _branch(Routes.home, const HomeScreen()),
          _branch(Routes.analyze, const AnalyzeScreen()),
          _branch(Routes.puzzles, const PuzzlesScreen()),
          _branch(Routes.play, const PlayScreen()),
          _branch(Routes.profile, const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.designSystem,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const DesignSystemScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => screen)],
);
