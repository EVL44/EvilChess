import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/engine/engine_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/move_classification.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/classification_badge.dart';
import '../../l10n/app_localizations.dart';
import '../analysis/domain/game_analysis.dart';
import '../analysis/domain/position_key.dart';
import 'review_controller.dart';
import 'widgets/eval_bar.dart';
import 'widgets/eval_graph.dart';
import 'widgets/move_list.dart';
import 'widgets/review_board.dart';
import 'widgets/review_summary.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  Side _orientation = Side.white;
  final _focus = FocusNode(debugLabel: 'review');

  /// Retry mode: the ply whose position (before the move) is being retried.
  int? _retryPly;
  String? _retryFen;
  String? _retryFeedback;
  bool _retrySolved = false;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  ReviewController get _ctrl =>
      ref.read(reviewControllerProvider(widget.gameId).notifier);

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (_retryPly != null) return KeyEventResult.ignored;
    switch (e.logicalKey) {
      case LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyL:
        _ctrl.next();
      case LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyH:
        _ctrl.previous();
      case LogicalKeyboardKey.home || LogicalKeyboardKey.arrowUp:
        _ctrl.first();
      case LogicalKeyboardKey.end || LogicalKeyboardKey.arrowDown:
        _ctrl.last();
      case LogicalKeyboardKey.keyM:
        _nextMistake();
      case LogicalKeyboardKey.keyF:
        _flip();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _flip() => setState(
    () => _orientation = _orientation == Side.white ? Side.black : Side.white,
  );

  void _nextMistake() {
    final s = ref.read(reviewControllerProvider(widget.gameId));
    final userSide = _orientation == Side.white;
    final found = _ctrl.nextMistake(white: userSide) || _ctrl.nextMistake();
    if (!found && mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).noMoreMistakes)),
        );
    }
    if (s.ply != ref.read(reviewControllerProvider(widget.gameId)).ply) {
      _exitRetry();
    }
  }

  void _startRetry(MoveAnalysis move) {
    final game = ref.read(reviewControllerProvider(widget.gameId)).game!;
    setState(() {
      _retryPly = move.ply;
      _retryFen = game.plies[move.ply].fenBefore;
      _retryFeedback = null;
      _retrySolved = false;
    });
  }

  void _exitRetry() => setState(() {
    _retryPly = null;
    _retryFen = null;
    _retryFeedback = null;
  });

  Future<void> _onRetryMove(NormalMove move, MoveAnalysis target) async {
    final l10n = AppLocalizations.of(context);
    final pos = Chess.fromSetup(Setup.parseFen(_retryFen!));
    final uci = standardUci(pos, move);
    final played = pos.play(move);
    setState(() => _retryFen = played.fen);

    String feedback;
    var solved = false;
    if (uci == target.bestUci) {
      feedback = l10n.retryCorrect;
      solved = true;
    } else {
      // Ask the engine whether this alternative is about as good.
      try {
        final engine = await ref.read(engineServiceProvider).engine;
        final r = await engine.evaluate(played.fen, depth: 12, multiPv: 1);
        final win = r.eval.winPercentFor(white: pos.turn == Side.white);
        solved = target.winBefore - win < 3;
        feedback = solved ? l10n.retryGood : l10n.retryWrong;
      } catch (_) {
        feedback = l10n.retryWrong;
      }
    }
    if (!mounted) return;
    setState(() {
      _retryFeedback = feedback;
      _retrySolved = solved;
    });
    if (!solved) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted && _retryPly == target.ply && !_retrySolved) {
        setState(() => _retryFen = pos.fen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(reviewControllerProvider(widget.gameId));
    final game = state.game;

    final title = game == null
        ? l10n.gameReviewTitle
        : '${game.white} – ${game.black}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: l10n.flipBoard,
            icon: const Icon(Icons.swap_vert_rounded),
            onPressed: _flip,
          ),
          if (state.status == ReviewStatus.ready)
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'reanalyze') _ctrl.analyze();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'reanalyze', child: Text(l10n.reanalyze)),
              ],
            ),
        ],
      ),
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: switch (state.status) {
          ReviewStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          ReviewStatus.notFound => Center(child: Text(l10n.gameNotFound)),
          _ => _body(context, state),
        },
      ),
    );
  }

  Widget _body(BuildContext context, ReviewState state) {
    final l10n = AppLocalizations.of(context);
    final game = state.game!;
    final analysis = state.analysis;
    final current = state.currentMove;
    final inRetry = _retryPly != null;
    final retryTarget = inRetry ? analysis!.moves[_retryPly!] : null;

    // Board contents
    final fen = inRetry ? _retryFen! : state.fen!;
    final shapes = <Shape>{};
    final annotations = <Square, Annotation>{};
    if (!inRetry && current != null) {
      final dest = Move.parse(current.uci);
      if (dest is NormalMove) {
        final glyph = current.classification.glyph;
        annotations[dest.to] = Annotation(
          symbol: glyph.text ?? _iconSymbol(current.classification),
          color: current.classification.color,
        );
      }
      if (current.bestUci != null &&
          current.bestUci != current.uci &&
          current.classification != MoveClass.book) {
        final best = Move.parse(current.bestUci!);
        if (best is NormalMove) {
          shapes.add(
            Arrow(
              color: const Color(0xCC16A34A),
              orig: best.from,
              dest: best.to,
            ),
          );
        }
      }
    }

    final evalNow = analysis == null
        ? null
        : analysis.whiteEvals[(state.ply + 1).clamp(
            0,
            analysis.whiteEvals.length - 1,
          )];

    final board = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      textDirection: TextDirection.ltr,
      children: [
        EvalBar(eval: evalNow, whiteAtBottom: _orientation == Side.white),
        const SizedBox(width: EcSpace.sm),
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: inRetry
                ? null
                : (d) {
                    final v = d.primaryVelocity ?? 0;
                    if (v < -150) _ctrl.next();
                    if (v > 150) _ctrl.previous();
                  },
            child: ReviewBoard(
              fen: fen,
              orientation: _orientation,
              lastMoveUci: inRetry
                  ? null
                  : (state.ply >= 0 ? game.plies[state.ply].uci : null),
              shapes: shapes,
              annotations: annotations,
              interactive: inRetry && !_retrySolved,
              onMove: retryTarget == null
                  ? null
                  : (m) => _onRetryMove(m, retryTarget),
            ),
          ),
        ),
      ],
    );

    final panel = <Widget>[
      if (state.status == ReviewStatus.analyzing)
        _AnalyzingCard(progress: state.progress),
      if (state.status == ReviewStatus.error)
        _ErrorCard(message: state.error ?? '', onRetry: _ctrl.analyze),
      if (inRetry)
        _RetryCard(
          target: retryTarget!,
          whiteToMove: retryTarget.whiteMoved,
          feedback: _retryFeedback,
          solved: _retrySolved,
          onShowAnswer: () {
            final pos = Chess.fromSetup(
              Setup.parseFen(game.plies[retryTarget.ply].fenBefore),
            );
            final m = retryTarget.bestUci == null
                ? null
                : parseEngineUci(pos, retryTarget.bestUci!);
            if (m != null) {
              setState(() {
                _retryFen = pos.play(m).fen;
                _retrySolved = true;
                _retryFeedback = l10n.bestWas(retryTarget.bestSan ?? '');
              });
            }
          },
          onBack: _exitRetry,
        )
      else if (analysis != null && current != null)
        _MoveInfoCard(move: current, onRetry: () => _startRetry(current))
      else if (analysis != null)
        ReviewSummary(game: game, analysis: analysis),
      if (analysis != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: EcSpace.sm),
          child: EvalGraph(
            analysis: analysis,
            currentPly: state.ply,
            onSelect: (p) {
              _exitRetry();
              _ctrl.goTo(p);
            },
          ),
        ),
    ];

    final moveList = MoveList(
      game: game,
      analysis: analysis,
      currentPly: state.ply,
      onSelect: (p) {
        _exitRetry();
        _ctrl.goTo(p);
      },
    );

    final controls = _Controls(
      enabled: !inRetry,
      hasAnalysis: analysis != null,
      onFirst: _ctrl.first,
      onPrevious: _ctrl.previous,
      onNext: _ctrl.next,
      onLast: _ctrl.last,
      onNextMistake: _nextMistake,
    );

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        if (wide) {
          final boardSize = (c.maxHeight - 32).clamp(280.0, c.maxWidth * 0.55);
          return Padding(
            padding: const EdgeInsets.all(EcSpace.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: boardSize, height: boardSize - 8, child: board),
                const SizedBox(width: EcSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: panel,
                          ),
                        ),
                      ),
                      Expanded(child: Card(child: moveList)),
                      const SizedBox(height: EcSpace.sm),
                      controls,
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(EcSpace.md),
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: c.maxWidth - 16),
                    child: AspectRatio(aspectRatio: 1.06, child: board),
                  ),
                  const SizedBox(height: EcSpace.md),
                  ...panel,
                  Card(child: moveList),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  EcSpace.sm,
                  0,
                  EcSpace.sm,
                  EcSpace.sm,
                ),
                child: controls,
              ),
            ),
          ],
        );
      },
    );
  }

  static String _iconSymbol(MoveClass c) => switch (c) {
    MoveClass.best => '★',
    MoveClass.excellent => '👍',
    MoveClass.good => '✓',
    MoveClass.book => '📖',
    MoveClass.miss => '✗',
    _ => '',
  };
}

class _AnalyzingCard extends StatelessWidget {
  const _AnalyzingCard({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.analyzingTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: EcSpace.xs),
            Text(
              '${l10n.analyzingBody((progress * 100).round())} · $platformEngineLabel',
            ),
            const SizedBox(height: EcSpace.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(EcRadii.pill),
              child: LinearProgressIndicator(value: progress, minHeight: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = message.contains('EngineUnavailable')
        ? l10n.engineMissing
        : l10n.analysisFailed(message);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(text),
            const SizedBox(height: EcSpace.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ChunkyButton(label: l10n.tryAgain, onPressed: onRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoveInfoCard extends StatelessWidget {
  const _MoveInfoCard({required this.move, required this.onRetry});
  final MoveAnalysis move;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final cls = move.classification;
    final showBest =
        move.bestSan != null &&
        move.bestUci != move.uci &&
        cls != MoveClass.book;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClassificationBadge(cls, size: 32),
                const SizedBox(width: EcSpace.sm),
                Expanded(
                  child: Text(
                    l10n.moveIsClass(move.san, cls.label(l10n)),
                    style: text.titleMedium?.copyWith(color: cls.color),
                  ),
                ),
                Text(
                  move.evalAfter.label,
                  textDirection: TextDirection.ltr,
                  style: text.titleSmall,
                ),
              ],
            ),
            if (showBest) ...[
              const SizedBox(height: EcSpace.sm),
              Text(l10n.bestWas(move.bestSan!), style: text.bodyLarge),
              if (move.bestLineSan.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: EcSpace.xs),
                  child: Text(
                    '${l10n.engineLine}: ${move.bestLineSan.join(' ')}',
                    textDirection: TextDirection.ltr,
                    style: text.bodySmall?.copyWith(
                      color: context.palette.inkMuted,
                    ),
                  ),
                ),
            ],
            if (move.isError) ...[
              const SizedBox(height: EcSpace.md),
              ChunkyButton(
                label: l10n.retryPosition,
                icon: Icons.replay_rounded,
                color: context.palette.hot,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RetryCard extends StatelessWidget {
  const _RetryCard({
    required this.target,
    required this.whiteToMove,
    required this.feedback,
    required this.solved,
    required this.onShowAnswer,
    required this.onBack,
  });

  final MoveAnalysis target;
  final bool whiteToMove;
  final String? feedback;
  final bool solved;
  final VoidCallback onShowAnswer;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.retryPrompt(whiteToMove ? l10n.white : l10n.black),
              style: text.titleMedium,
            ),
            if (feedback != null) ...[
              const SizedBox(height: EcSpace.sm),
              Text(
                feedback!,
                style: text.titleSmall?.copyWith(
                  color: solved ? context.palette.zap : context.palette.hot,
                ),
              ),
            ],
            const SizedBox(height: EcSpace.md),
            Wrap(
              spacing: EcSpace.sm,
              runSpacing: EcSpace.sm,
              children: [
                if (!solved)
                  ChunkyButton(
                    label: l10n.retryShowAnswer,
                    color: context.palette.sun,
                    onPressed: onShowAnswer,
                  ),
                ChunkyButton(label: l10n.retryBack, onPressed: onBack),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.enabled,
    required this.hasAnalysis,
    required this.onFirst,
    required this.onPrevious,
    required this.onNext,
    required this.onLast,
    required this.onNextMistake,
  });

  final bool enabled;
  final bool hasAnalysis;
  final VoidCallback onFirst;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onLast;
  final VoidCallback onNextMistake;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget btn(IconData icon, String tip, VoidCallback cb) =>
        IconButton.filledTonal(
          tooltip: tip,
          iconSize: 26,
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          padding: EdgeInsets.zero,
          onPressed: enabled ? cb : null,
          icon: Icon(icon),
        );
    // Playback controls keep chess direction (left = back) in every language.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          btn(Icons.first_page_rounded, l10n.firstMove, onFirst),
          const SizedBox(width: 4),
          btn(Icons.chevron_left_rounded, l10n.previousMove, onPrevious),
          const SizedBox(width: EcSpace.sm),
          Expanded(
            child: hasAnalysis
                ? Directionality(
                    textDirection: Directionality.of(context),
                    child: ChunkyButton(
                      label: l10n.nextMistake,
                      icon: Icons.bolt_rounded,
                      color: context.palette.hot,
                      expand: true,
                      onPressed: enabled ? onNextMistake : null,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: EcSpace.sm),
          btn(Icons.chevron_right_rounded, l10n.nextMove, onNext),
          const SizedBox(width: 4),
          btn(Icons.last_page_rounded, l10n.lastMove, onLast),
        ],
      ),
    );
  }
}
