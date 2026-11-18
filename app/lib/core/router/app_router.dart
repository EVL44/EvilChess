import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/analyze/analyze_screen.dart';
import '../../features/bots/bot_game_screen.dart';
import '../../features/design_system/design_system_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/play/play_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/puzzles/puzzle_trainer_screen.dart';
import '../../features/puzzles/puzzles_screen.dart';
import '../../features/reports/domain/report.dart';
import '../../features/reports/report_screen.dart';
import '../../features/review/review_screen.dart';
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
  static const report = '/analyze/report';
  static String botGame(
    String botId, {
    required String side,
    required bool takebacks,
  }) => '/play/bot/$botId?side=$side&takebacks=${takebacks ? 1 : 0}';
  static String puzzleSet(String filter) =>
      '/puzzles/train/${Uri.encodeComponent(filter)}';
  static String review(String gameId) =>
      '/analyze/game/${Uri.encodeComponent(gameId)}';
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.analyze,
                builder: (context, state) => const AnalyzeScreen(),
                routes: [
                  GoRoute(
                    path: 'report',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const ReportScreen(),
                  ),
                  GoRoute(
                    path: 'game/:id',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) =>
                        ReviewScreen(gameId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.puzzles,
                builder: (context, state) => const PuzzlesScreen(),
                routes: [
                  GoRoute(
                    path: 'train/:filter',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => PuzzleTrainerScreen(
                      filter: PuzzleFilter.decode(
                        state.pathParameters['filter'],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.play,
                builder: (context, state) => const PlayScreen(),
                routes: [
                  GoRoute(
                    path: 'bot/:id',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => BotGameScreen(
                      setup: (
                        botId: state.pathParameters['id']!,
                        userSide: state.uri.queryParameters['side'] == 'black'
                            ? Side.black
                            : Side.white,
                        takebacks:
                            state.uri.queryParameters['takebacks'] != '0',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
