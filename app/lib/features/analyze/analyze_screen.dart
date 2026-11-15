import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chunky_button.dart';
import '../../l10n/app_localizations.dart';
import '../games/data/game_repository.dart';
import '../games/domain/game_record.dart';
import '../games/ui/import_sheet.dart';

final gameSummariesProvider = StreamProvider<List<GameSummary>>(
  (ref) => ref.watch(gameRepositoryProvider).watchSummaries(),
);

/// The Analyze tab: your game library plus import.
class AnalyzeScreen extends ConsumerWidget {
  const AnalyzeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final games = ref.watch(gameSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navAnalyze),
        actions: [
          IconButton(
            tooltip: l10n.importGames,
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => showImportSheet(context),
          ),
        ],
      ),
      floatingActionButton: (games.value?.isNotEmpty ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => showImportSheet(context),
              icon: const Icon(Icons.download_rounded),
              label: Text(l10n.importGames),
            )
          : null,
      body: games.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? const _EmptyLibrary()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  EcSpace.md,
                  EcSpace.sm,
                  EcSpace.md,
                  96,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: EcSpace.sm),
                itemBuilder: (context, i) => _GameCard(
                  game: list[i],
                  onTap: () => context.push(Routes.review(list[i].id)),
                  onDelete: () =>
                      ref.read(gameRepositoryProvider).deleteGame(list[i].id),
                ),
              ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(EcSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: context.palette.brand.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(EcRadii.lg),
              ),
              child: Icon(
                Icons.insights_rounded,
                size: 56,
                color: context.palette.brand,
              ),
            ),
            const SizedBox(height: EcSpace.lg),
            Text(l10n.noGamesTitle, style: text.headlineSmall),
            const SizedBox(height: EcSpace.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                l10n.noGamesBody,
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(
                  color: context.palette.inkMuted,
                ),
              ),
            ),
            const SizedBox(height: EcSpace.lg),
            ChunkyButton(
              label: l10n.importGames,
              icon: Icons.download_rounded,
              onPressed: () => showImportSheet(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.onTap,
    required this.onDelete,
  });

  final GameSummary game;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  IconData get _speedIcon => switch (game.speed) {
    GameSpeed.ultraBullet || GameSpeed.bullet => Icons.bolt_rounded,
    GameSpeed.blitz => Icons.local_fire_department_rounded,
    GameSpeed.rapid => Icons.timer_rounded,
    GameSpeed.classical => Icons.hourglass_bottom_rounded,
    GameSpeed.correspondence => Icons.mail_rounded,
    GameSpeed.unknown => Icons.extension_rounded,
  };

  Color _resultColor(BuildContext context) {
    final side = game.userSide;
    if (side == null || game.result == '*') return context.palette.inkMuted;
    if (game.result == '1/2-1/2') return context.palette.sun;
    final userWon = (game.result == '1-0') == (side == 'white');
    return userWon ? context.palette.zap : context.palette.hot;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final muted = context.palette.inkMuted;
    String player(String name, int? elo) => elo == null ? name : '$name ($elo)';
    final date = game.playedAt == null
        ? null
        : MaterialLocalizations.of(context)
              .formatShortDate(game.playedAt!.toLocal());

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _confirmDelete(context),
        child: Padding(
          padding: const EdgeInsets.all(EcSpace.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _resultColor(context).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(EcRadii.md),
                ),
                child: Icon(_speedIcon, color: _resultColor(context)),
              ),
              const SizedBox(width: EcSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${player(game.white, game.whiteElo)}  vs  ${player(game.black, game.blackElo)}',
                      style: text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        game.result.replaceAll('1/2', '½'),
                        ?date,
                        ?game.opening,
                      ].join(' · '),
                      style: text.bodySmall?.copyWith(color: muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: EcSpace.sm),
              if (game.analyzed)
                _AccuracyPill(
                  white: game.whiteAccuracy,
                  black: game.blackAccuracy,
                  label: l10n.accuracyShort,
                )
              else
                Text(
                  l10n.notAnalyzed,
                  style: text.labelSmall?.copyWith(color: muted),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.deleteGame),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.deleteGame),
          ),
        ],
      ),
    );
    if (ok ?? false) onDelete();
  }
}

class _AccuracyPill extends StatelessWidget {
  const _AccuracyPill({
    required this.white,
    required this.black,
    required this.label,
  });

  final double? white;
  final double? black;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    String f(double? v) => v == null ? '–' : v.toStringAsFixed(0);
    return Semantics(
      label: '$label ${f(white)} / ${f(black)}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(EcRadii.pill),
        ),
        child: Text(
          '${f(white)} | ${f(black)}',
          textDirection: TextDirection.ltr,
          style: text.labelLarge,
        ),
      ),
    );
  }
}
