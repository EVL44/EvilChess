import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/move_classification.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/classification_badge.dart';
import '../../../core/widgets/force_ltr.dart';
import '../../../l10n/app_localizations.dart';
import '../../analysis/domain/game_analysis.dart';
import '../../games/domain/game_record.dart';

/// Numbered move list ("1. e4 e5 2. Nf3 …") with classification badges.
/// Notation always reads left-to-right, even in Arabic.
class MoveList extends StatefulWidget {
  const MoveList({
    super.key,
    required this.game,
    required this.analysis,
    required this.currentPly,
    required this.onSelect,
  });

  final GameRecord game;
  final GameAnalysis? analysis;
  final int currentPly;
  final ValueChanged<int> onSelect;

  @override
  State<MoveList> createState() => _MoveListState();
}

class _MoveListState extends State<MoveList> {
  final _keys = <int, GlobalKey>{};

  @override
  void didUpdateWidget(MoveList old) {
    super.didUpdateWidget(old);
    if (old.currentPly != widget.currentPly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _keys[widget.currentPly]?.currentContext;
        if (ctx != null && ctx.mounted) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 200),
            alignment: 0.5,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plies = widget.game.plies;
    final firstIsBlack = widget.game.initialFen.split(' ')[1] == 'b';
    final startNumber =
        int.tryParse(widget.game.initialFen.split(' ').last) ?? 1;
    final children = <Widget>[];

    for (var i = 0; i < plies.length; i++) {
      final whiteMove = (i.isEven) != firstIsBlack;
      final moveNumber = startNumber + ((i + (firstIsBlack ? 1 : 0)) ~/ 2);
      if (whiteMove || i == 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 2),
            child: Text(
              whiteMove ? '$moveNumber.' : '$moveNumber…',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: context.palette.inkMuted),
            ),
          ),
        );
      }
      children.add(
        _MoveChip(
          key: _keys.putIfAbsent(i, GlobalKey.new),
          san: plies[i].san,
          number: moveNumber,
          white: whiteMove,
          analysis: widget.analysis?.moves.elementAtOrNull(i),
          selected: i == widget.currentPly,
          onTap: () => widget.onSelect(i),
        ),
      );
    }

    return ForceLtr(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(EcSpace.sm),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          spacing: 2,
          children: children,
        ),
      ),
    );
  }
}

class _MoveChip extends StatelessWidget {
  const _MoveChip({
    super.key,
    required this.san,
    required this.number,
    required this.white,
    required this.analysis,
    required this.selected,
    required this.onTap,
  });

  final String san;
  final int number;
  final bool white;
  final MoveAnalysis? analysis;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final cls = analysis?.classification;
    final showBadge =
        cls != null &&
        cls != MoveClass.best &&
        cls != MoveClass.excellent &&
        cls != MoveClass.good &&
        cls != MoveClass.book;

    return Semantics(
      button: true,
      selected: selected,
      label: l10n.moveSemantics(
        number,
        white ? l10n.white : l10n.black,
        san,
        cls?.label(l10n) ?? '',
      ),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EcRadii.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36, minWidth: 44),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primary
                  : (showBadge ? cls.color.withValues(alpha: 0.12) : null),
              borderRadius: BorderRadius.circular(EcRadii.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showBadge) ...[
                  ClassificationBadge(cls, size: 18),
                  const SizedBox(width: 4),
                ],
                Text(
                  san,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(color: selected ? scheme.onPrimary : null),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
