import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/move_classification.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/classification_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../analysis/domain/game_analysis.dart';
import '../../games/domain/game_record.dart';

/// Animated "Game Review" card: accuracy rings for both players and how many
/// moves of each class they played.
class ReviewSummary extends StatelessWidget {
  const ReviewSummary({super.key, required this.game, required this.analysis});

  final GameRecord game;
  final GameAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final white = analysis.countsFor(white: true);
    final black = analysis.countsFor(white: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _Player(
                    name: game.white,
                    elo: game.whiteElo,
                    accuracy: analysis.whiteAccuracy,
                    color: const Color(0xFFF7F3FF),
                  ),
                ),
                Expanded(
                  child: _Player(
                    name: game.black,
                    elo: game.blackElo,
                    accuracy: analysis.blackAccuracy,
                    color: const Color(0xFF2B2140),
                  ),
                ),
              ],
            ),
            if (analysis.opening != null) ...[
              const SizedBox(height: EcSpace.sm),
              Text(
                '${l10n.openingLabel}: ${analysis.opening!.eco} ${analysis.opening!.name}',
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(
                  color: context.palette.inkMuted,
                ),
              ),
            ],
            const SizedBox(height: EcSpace.md),
            for (final cls in MoveClass.values)
              if (white[cls]! + black[cls]! > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${white[cls]}',
                          textAlign: TextAlign.center,
                          style: text.titleSmall?.copyWith(color: cls.color),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ClassificationBadge(
                            cls,
                            size: 22,
                            showLabel: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${black[cls]}',
                          textAlign: TextAlign.center,
                          style: text.titleSmall?.copyWith(color: cls.color),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player({
    required this.name,
    required this.elo,
    required this.accuracy,
    required this.color,
  });

  final String name;
  final int? elo;
  final double? accuracy;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final acc = accuracy ?? 0;
    return Column(
      children: [
        Semantics(
          label: '${l10n.accuracyShort} ${acc.toStringAsFixed(1)}',
          excludeSemantics: true,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: acc),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => SizedBox(
              width: 76,
              height: 76,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: v / 100,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      backgroundColor: context.palette.surfaceAlt,
                      color: _ringColor(context, v),
                    ),
                  ),
                  Text(
                    accuracy == null ? '–' : v.toStringAsFixed(1),
                    style: text.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: EcSpace.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: context.palette.inkMuted),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: text.titleSmall,
              ),
            ),
          ],
        ),
        if (elo != null)
          Text(
            '$elo',
            style: text.bodySmall?.copyWith(color: context.palette.inkMuted),
          ),
      ],
    );
  }

  Color _ringColor(BuildContext context, double v) {
    final p = context.palette;
    if (v >= 85) return p.zap;
    if (v >= 70) return p.sun;
    return p.hot;
  }
}
