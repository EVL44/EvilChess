import 'dart:async';

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/labels.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chunky_button.dart';
import '../../l10n/app_localizations.dart';
import '../review/widgets/move_list.dart';
import '../review/widgets/review_board.dart';
import 'bot_game_controller.dart';
import 'widgets/bot_avatar.dart';

class BotGameScreen extends ConsumerStatefulWidget {
  const BotGameScreen({super.key, required this.setup});

  final BotGameSetup setup;

  @override
  ConsumerState<BotGameScreen> createState() => _BotGameScreenState();
}

class _BotGameScreenState extends ConsumerState<BotGameScreen> {
  bool _flipped = false;

  BotGameController get _ctrl =>
      ref.read(botGameProvider(widget.setup).notifier);

  Future<void> _confirmResign() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.resignConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('confirm-resign'),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.resign),
          ),
        ],
      ),
    );
    if (ok ?? false) _ctrl.resign();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(botGameProvider(widget.setup));
    ref.listen(botGameProvider(widget.setup).select((s) => s.plies.length), (
      prev,
      next,
    ) {
      if ((next) > (prev ?? 0)) unawaited(HapticFeedback.selectionClick());
    });

    final bot = state.bot;
    final bottomSide = _flipped ? state.userSide.opposite : state.userSide;

    final shapes = <Shape>{};
    if (state.hintUci != null) {
      final m = Move.parse(state.hintUci!);
      if (m is NormalMove) {
        shapes.add(
          Arrow(color: const Color(0xCC16A34A), orig: m.from, dest: m.to),
        );
      }
    }

    final board = ReviewBoard(
      fen: state.fen,
      orientation: bottomSide,
      lastMoveUci: state.plies.lastOrNull?.uci,
      shapes: shapes,
      interactive: state.userToMove && !state.thinking,
      onMove: _ctrl.userMove,
      semanticLabel: l10n.boardLabel,
    );

    final botBar = _PlayerBar(
      leading: BotAvatar(bot: bot, size: 40),
      name: bot.name,
      detail: l10n.botRating(bot.rating),
      status: state.thinking ? l10n.botThinking(bot.name) : null,
    );
    final youBar = _PlayerBar(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: context.palette.brand.withValues(alpha: 0.18),
        child: Icon(Icons.person_rounded, color: context.palette.brand),
      ),
      name: l10n.you,
      status: state.userToMove ? l10n.yourTurn : null,
    );

    final panel = <Widget>[
      if (state.isOver) _GameOverCard(state: state, onRematch: _ctrl.rematch),
      if (state.error != null)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(EcSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.botError(state.error!)),
                const SizedBox(height: EcSpace.sm),
                ChunkyButton(label: l10n.tryAgain, onPressed: _ctrl.retryBot),
              ],
            ),
          ),
        ),
      Card(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: MoveList(
            game: state.record,
            analysis: null,
            currentPly: state.plies.length - 1,
            onSelect: (_) {},
          ),
        ),
      ),
    ];

    final controls = Wrap(
      alignment: WrapAlignment.center,
      spacing: EcSpace.sm,
      runSpacing: EcSpace.sm,
      children: [
        FilledButton.tonalIcon(
          key: const Key('hint'),
          onPressed: state.userToMove && !state.hintLoading ? _ctrl.hint : null,
          icon: const Icon(Icons.lightbulb_rounded),
          label: Text(l10n.hint),
        ),
        if (state.takebacks)
          FilledButton.tonalIcon(
            key: const Key('takeback'),
            onPressed: state.canTakeBack ? _ctrl.takeBack : null,
            icon: const Icon(Icons.undo_rounded),
            label: Text(l10n.takeBack),
          ),
        FilledButton.tonalIcon(
          key: const Key('resign'),
          onPressed: state.isOver ? null : _confirmResign,
          icon: const Icon(Icons.flag_rounded),
          label: Text(l10n.resign),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(bot.name),
        actions: [
          IconButton(
            tooltip: l10n.flipBoard,
            icon: const Icon(Icons.swap_vert_rounded),
            onPressed: () => setState(() => _flipped = !_flipped),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth >= 900) {
            final size = (c.maxHeight - 140).clamp(260.0, c.maxWidth * 0.55);
            return Padding(
              padding: const EdgeInsets.all(EcSpace.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: size,
                    child: Column(
                      children: [
                        botBar,
                        const SizedBox(height: EcSpace.sm),
                        SizedBox(width: size, height: size, child: board),
                        const SizedBox(height: EcSpace.sm),
                        youBar,
                      ],
                    ),
                  ),
                  const SizedBox(width: EcSpace.lg),
                  Expanded(
                    child: ListView(
                      children: [
                        ...panel,
                        const SizedBox(height: EcSpace.md),
                        controls,
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(EcSpace.md),
            children: [
              botBar,
              const SizedBox(height: EcSpace.sm),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: c.maxWidth - 32),
                child: board,
              ),
              const SizedBox(height: EcSpace.sm),
              youBar,
              const SizedBox(height: EcSpace.md),
              controls,
              const SizedBox(height: EcSpace.md),
              ...panel,
            ],
          );
        },
      ),
    );
  }
}

class _PlayerBar extends StatelessWidget {
  const _PlayerBar({
    required this.leading,
    required this.name,
    this.detail,
    this.status,
  });

  final Widget leading;
  final String name;
  final String? detail;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        leading,
        const SizedBox(width: EcSpace.sm),
        Flexible(
          child: Text(
            name,
            style: text.titleSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(width: EcSpace.sm),
          Text(
            detail!,
            textDirection: TextDirection.ltr,
            style: text.labelMedium?.copyWith(color: context.palette.inkMuted),
          ),
        ],
        const Spacer(),
        if (status != null)
          Text(
            status!,
            style: text.labelLarge?.copyWith(color: context.palette.brand),
          ),
      ],
    );
  }
}

class _GameOverCard extends StatelessWidget {
  const _GameOverCard({required this.state, required this.onRematch});

  final BotGameState state;
  final VoidCallback onRematch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final won = state.userWon;
    final (title, color, icon) = switch (won) {
      true => (l10n.youWon, palette.zap, Icons.emoji_events_rounded),
      false => (
        l10n.youLost,
        palette.hot,
        Icons.sentiment_dissatisfied_rounded,
      ),
      null => (l10n.gameDrawn, palette.sun, Icons.handshake_rounded),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 36),
                const SizedBox(width: EcSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        key: const Key('game-result'),
                        style: text.headlineSmall?.copyWith(color: color),
                      ),
                      if (state.end != null)
                        Text(
                          '${state.result!.replaceAll('1/2', '½')} · ${l10n.gameEnd(state.end!)}',
                          style: text.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: EcSpace.md),
            Wrap(
              spacing: EcSpace.sm,
              runSpacing: EcSpace.sm,
              children: [
                ChunkyButton(
                  key: const Key('review-game'),
                  label: l10n.reviewGame,
                  icon: Icons.insights_rounded,
                  onPressed: state.savedGameId == null
                      ? null
                      : () => context.push(Routes.review(state.savedGameId!)),
                ),
                ChunkyButton(
                  key: const Key('rematch'),
                  label: l10n.rematch,
                  icon: Icons.replay_rounded,
                  color: state.bot.color,
                  onPressed: onRematch,
                ),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.newOpponent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
