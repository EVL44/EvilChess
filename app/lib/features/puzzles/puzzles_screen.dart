import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/labels.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chunky_button.dart';
import '../../l10n/app_localizations.dart';
import '../analysis/domain/material.dart';
import '../analysis/domain/motifs.dart';
import '../analyze/analyze_screen.dart' show gameSummariesProvider;
import '../games/data/game_repository.dart';
import '../reports/domain/report.dart';
import 'data/puzzle_repository.dart';
import 'widgets/online_puzzle_cards.dart';

typedef PuzzleHub = ({
  PuzzleProgress all,
  List<(PuzzleFilter, PuzzleProgress)> sets,
});

/// Puzzle counts for the hub: everything, plus each themed set that has at
/// least one puzzle. Refreshes when games change or a session ends.
final puzzleHubProvider = FutureProvider.autoDispose<PuzzleHub>((ref) async {
  ref.watch(gameSummariesProvider);
  await ref.watch(gameRepositoryProvider).upgradeAnalyses();
  final repo = ref.watch(puzzleRepositoryProvider);
  final all = await repo.progress(PuzzleFilter.all);
  final sets = <(PuzzleFilter, PuzzleProgress)>[];
  if (all.total > 0) {
    final filters = [
      for (final c in ErrorCategory.values) PuzzleFilter(category: c),
      for (final t in TacticTheme.values) PuzzleFilter(theme: t),
      for (final p in GamePhase.values) PuzzleFilter(phase: p),
      const PuzzleFilter(timeTrouble: true),
    ];
    for (final f in filters) {
      final p = await repo.progress(f);
      if (p.total > 0) sets.add((f, p));
    }
  }
  return (all: all, sets: sets);
});

/// The Puzzles tab. Phase 2 ships "From my mistakes"; rated puzzles, Puzzle
/// Rush and the daily puzzle need the server (Phase 4).
class PuzzlesScreen extends ConsumerWidget {
  const PuzzlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final hub = ref.watch(puzzleHubProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPuzzles)),
      body: hub.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (h) => ListView(
          padding: const EdgeInsets.all(EcSpace.md),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const OnlinePuzzleCards(),
                    const SizedBox(height: EcSpace.lg),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(EcSpace.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: palette.hot.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(EcRadii.md),
                              ),
                              child: Icon(
                                Icons.extension_rounded,
                                color: palette.hot,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: EcSpace.md),
                            Text(
                              l10n.puzzlesFromMistakes,
                              style: text.titleLarge,
                            ),
                            const SizedBox(height: EcSpace.xs),
                            Text(
                              h.all.total == 0
                                  ? l10n.puzzlesEmptyBody
                                  : l10n.puzzlesFromMistakesBody,
                              style: text.bodyMedium?.copyWith(
                                color: palette.inkMuted,
                              ),
                            ),
                            if (h.all.total > 0) ...[
                              const SizedBox(height: EcSpace.md),
                              _Progress(progress: h.all, color: palette.hot),
                              const SizedBox(height: EcSpace.md),
                              ChunkyButton(
                                key: const Key('start-puzzles'),
                                label: l10n.startPuzzles,
                                icon: Icons.play_arrow_rounded,
                                color: palette.hot,
                                onPressed: () => context.push(
                                  Routes.puzzleSet(PuzzleFilter.all.encode()),
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: EcSpace.md),
                              ChunkyButton(
                                label: l10n.navAnalyze,
                                icon: Icons.insights_rounded,
                                onPressed: () => context.go(Routes.analyze),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (h.sets.isNotEmpty) ...[
                      const SizedBox(height: EcSpace.lg),
                      Text(l10n.puzzleThemesTitle, style: text.titleMedium),
                      const SizedBox(height: EcSpace.sm),
                      for (final (filter, progress) in h.sets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: EcSpace.sm),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => context.push(
                                Routes.puzzleSet(filter.encode()),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(EcSpace.md),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.filterTitle(filter),
                                            style: text.titleSmall,
                                          ),
                                          const SizedBox(height: EcSpace.xs),
                                          _Progress(
                                            progress: progress,
                                            color: palette.brand,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: EcSpace.sm),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: EcSpace.lg),
                    Text(
                      l10n.otherModesSoon,
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(color: palette.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.progress, required this.color});

  final PuzzleProgress progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.puzzleProgress(progress.solved, progress.total),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(EcRadii.pill),
          child: LinearProgressIndicator(
            value: progress.total == 0 ? 0 : progress.solved / progress.total,
            minHeight: 8,
            color: color,
            backgroundColor: context.palette.surfaceAlt,
          ),
        ),
      ],
    );
  }
}
