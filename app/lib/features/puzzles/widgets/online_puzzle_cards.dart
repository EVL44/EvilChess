import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/account.dart';
import '../../account/error_text.dart';
import '../data/online_puzzles.dart';

final _packSizeProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(onlinePuzzlesProvider).packSize(),
);

/// Daily puzzle, rated puzzles, Puzzle Rush and the offline pack.
class OnlinePuzzleCards extends ConsumerWidget {
  const OnlinePuzzleCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final account = ref.watch(accountProvider);

    Widget card({
      required Key key,
      required IconData icon,
      required Color color,
      required String title,
      required String body,
      required Widget action,
    }) => Card(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(EcRadii.md),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: EcSpace.md),
                Expanded(child: Text(title, style: text.titleMedium)),
              ],
            ),
            const SizedBox(height: EcSpace.sm),
            Text(
              body,
              style: text.bodyMedium?.copyWith(color: palette.inkMuted),
            ),
            const SizedBox(height: EcSpace.md),
            action,
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card(
          key: const Key('daily-card'),
          icon: Icons.today_rounded,
          color: palette.sun,
          title: l10n.dailyPuzzle,
          body: l10n.dailyPuzzleBody,
          action: ChunkyButton(
            label: l10n.startPuzzles,
            icon: Icons.play_arrow_rounded,
            color: palette.sun,
            onPressed: () => context.push(Routes.dailyPuzzle),
          ),
        ),
        const SizedBox(height: EcSpace.sm),
        card(
          key: const Key('rated-card'),
          icon: Icons.trending_up_rounded,
          color: palette.brand,
          title: account.signedIn
              ? '${l10n.ratedPuzzles} · ${account.profile!.puzzleRating}'
                    '${account.profile!.provisional ? '?' : ''}'
              : l10n.ratedPuzzles,
          body: account.signedIn ? l10n.ratedPuzzlesBody : l10n.signInForRated,
          action: account.signedIn
              ? ChunkyButton(
                  key: const Key('start-rated'),
                  label: l10n.startPuzzles,
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => context.push(Routes.ratedPuzzles()),
                )
              : OutlinedButton(
                  onPressed: () => context.go(Routes.profile),
                  child: Text(l10n.signInButton),
                ),
        ),
        const SizedBox(height: EcSpace.sm),
        card(
          key: const Key('rush-card'),
          icon: Icons.bolt_rounded,
          color: palette.hot,
          title: l10n.puzzleRush,
          body: l10n.puzzleRushBody,
          action: Wrap(
            spacing: EcSpace.sm,
            runSpacing: EcSpace.sm,
            children: [
              for (final (mode, label) in [
                ('3min', l10n.rush3min),
                ('5min', l10n.rush5min),
                ('survival', l10n.rushSurvival),
              ])
                FilledButton.tonal(
                  key: Key('rush-$mode'),
                  onPressed: () => context.push(Routes.rush(mode)),
                  child: Text(label),
                ),
            ],
          ),
        ),
        const SizedBox(height: EcSpace.sm),
        card(
          key: const Key('pack-card'),
          icon: Icons.download_for_offline_rounded,
          color: palette.zap,
          title: l10n.offlinePack,
          body: l10n.offlinePackBody(ref.watch(_packSizeProvider).value ?? 0),
          action: OutlinedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(onlinePuzzlesProvider).downloadPack();
                ref.invalidate(_packSizeProvider);
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(friendlyError(l10n, e))),
                );
              }
            },
            icon: const Icon(Icons.download_rounded),
            label: Text(l10n.downloadPack),
          ),
        ),
      ],
    );
  }
}
