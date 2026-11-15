import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/engine/engine_service.dart';
import '../../core/l10n/labels.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/classification_badge.dart';
import '../../l10n/app_localizations.dart';
import '../analysis/domain/position_key.dart';
import '../reports/domain/report.dart';
import '../review/widgets/review_board.dart';
import 'data/puzzle_repository.dart';
import 'puzzles_screen.dart' show puzzleHubProvider;

/// How close (in win%) an alternative move must stay to the engine's best
/// line to be accepted as a solution. Any move that still mates counts.
const _acceptWithin = 3.0;

/// Solves puzzles made from the player's own mistakes, one after another.
class PuzzleTrainerScreen extends ConsumerStatefulWidget {
  const PuzzleTrainerScreen({super.key, required this.filter});

  final PuzzleFilter filter;

  @override
  ConsumerState<PuzzleTrainerScreen> createState() => _TrainerState();
}

class _TrainerState extends ConsumerState<PuzzleTrainerScreen> {
  List<MistakePuzzle>? _puzzles;
  int _index = 0;
  int _streak = 0;

  /// Board position: the puzzle FEN, or the position after a try.
  String? _fen;
  String? _feedback;
  bool _solved = false;
  bool _failed = false;
  bool _checking = false;

  MistakePuzzle? get _current {
    final p = _puzzles;
    return p == null || _index >= p.length ? null : p[_index];
  }

  @override
  void initState() {
    super.initState();
    ref.read(puzzleRepositoryProvider).puzzles(widget.filter).then((list) {
      if (!mounted) return;
      setState(() {
        _puzzles = list;
        _fen = list.firstOrNull?.fen;
      });
    });
  }

  void _load(int index) => setState(() {
    _index = index;
    _fen = _current?.fen;
    _feedback = null;
    _solved = false;
    _failed = false;
  });

  Future<void> _record(bool solved) async {
    final p = _current!;
    await ref
        .read(puzzleRepositoryProvider)
        .recordAttempt(p.gameId, p.ply, solved: solved);
    ref.invalidate(puzzleHubProvider);
  }

  Future<void> _onMove(NormalMove move) async {
    final l10n = AppLocalizations.of(context);
    final p = _current!;
    if (_solved || _checking) return;
    final pos = Chess.fromSetup(Setup.parseFen(p.fen));
    final uci = standardUci(pos, move);
    final played = pos.play(move);
    setState(() {
      _fen = played.fen;
      _checking = true;
    });

    var ok = uci == p.bestUci;
    var exact = ok;
    if (!ok) {
      if (played.isCheckmate) {
        ok = true; // any mate is a solution
      } else {
        // Engine-equal alternatives are accepted too.
        try {
          final engine = await ref.read(engineServiceProvider).engine;
          final r = await engine.evaluate(played.fen, depth: 12, multiPv: 1);
          final win = r.eval.winPercentFor(white: p.whiteToMove);
          ok = p.winBefore - win < _acceptWithin;
        } catch (_) {
          ok = false;
        }
      }
      exact = false;
    }
    if (!mounted || _current != p) return;

    if (ok) {
      unawaited(HapticFeedback.lightImpact());
      // Only a first-try solve counts as solved and extends the streak.
      final firstTry = !_failed;
      await _record(firstTry);
      if (!mounted) return;
      setState(() {
        _checking = false;
        _solved = true;
        if (firstTry) _streak++;
        _feedback = exact ? l10n.retryCorrect : l10n.retryGood;
      });
    } else {
      setState(() {
        _checking = false;
        _failed = true;
        _streak = 0;
        _feedback = l10n.retryWrong;
      });
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (mounted && _current == p && !_solved) {
        setState(() => _fen = p.fen);
      }
    }
  }

  Future<void> _showAnswer() async {
    final l10n = AppLocalizations.of(context);
    final p = _current!;
    final pos = Chess.fromSetup(Setup.parseFen(p.fen));
    final best = parseEngineUci(pos, p.bestUci);
    await _record(false);
    if (!mounted || best == null) return;
    setState(() {
      _fen = pos.play(best).fen;
      _solved = true;
      _failed = true;
      _streak = 0;
      _feedback = l10n.bestWas(p.bestSan ?? p.bestUci);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final puzzles = _puzzles;
    final p = _current;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filterTitle(widget.filter)),
        actions: [
          if (puzzles != null && p != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: EcSpace.md),
              child: Center(
                child: Text(
                  l10n.puzzleCounter(_index + 1, puzzles.length),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
        ],
      ),
      body: puzzles == null
          ? const Center(child: CircularProgressIndicator())
          : p == null
          ? _Finished(empty: puzzles.isEmpty)
          : _puzzleBody(context, p, puzzles.length),
    );
  }

  Widget _puzzleBody(BuildContext context, MistakePuzzle p, int total) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final side = p.whiteToMove ? l10n.white : l10n.black;

    final board = ReviewBoard(
      fen: _fen ?? p.fen,
      orientation: p.whiteToMove ? Side.white : Side.black,
      interactive: !_solved && !_checking && _fen == p.fen,
      onMove: _onMove,
      semanticLabel: l10n.boardLabel,
    );

    final panel = Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClassificationBadge(p.classification, size: 30),
                const SizedBox(width: EcSpace.sm),
                Expanded(
                  child: Text(
                    l10n.puzzleFindBetter(p.playedSan, side),
                    style: text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: EcSpace.xs),
            Text(
              [
                '${p.white} – ${p.black}',
                if (p.theme != null) l10n.theme(p.theme!),
              ].join(' · '),
              style: text.bodySmall?.copyWith(color: palette.inkMuted),
            ),
            if (_feedback != null) ...[
              const SizedBox(height: EcSpace.md),
              Text(
                _feedback!,
                key: const Key('puzzle-feedback'),
                style: text.titleSmall?.copyWith(
                  color: _solved && !_failed ? palette.zap : palette.hot,
                ),
              ),
            ],
            if (_solved && p.bestLineSan.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: EcSpace.xs),
                child: Text(
                  '${l10n.engineLine}: ${p.bestLineSan.join(' ')}',
                  textDirection: TextDirection.ltr,
                  style: text.bodySmall?.copyWith(color: palette.inkMuted),
                ),
              ),
            const SizedBox(height: EcSpace.md),
            Row(
              children: [
                Icon(Icons.local_fire_department_rounded, color: palette.sun),
                const SizedBox(width: 4),
                Text(l10n.puzzleStreak(_streak), style: text.labelLarge),
              ],
            ),
            const SizedBox(height: EcSpace.md),
            Wrap(
              spacing: EcSpace.sm,
              runSpacing: EcSpace.sm,
              children: [
                if (_solved)
                  ChunkyButton(
                    key: const Key('puzzle-next'),
                    label: l10n.puzzleNext,
                    icon: Icons.arrow_forward_rounded,
                    color: palette.zap,
                    onPressed: () => _load(_index + 1),
                  )
                else
                  ChunkyButton(
                    key: const Key('puzzle-answer'),
                    label: l10n.retryShowAnswer,
                    color: palette.sun,
                    onPressed: _checking ? null : _showAnswer,
                  ),
                OutlinedButton.icon(
                  onPressed: () => context.push(Routes.review(p.gameId)),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(l10n.puzzleOpenGame),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= 900) {
          final size = (c.maxHeight - 32).clamp(280.0, c.maxWidth * 0.55);
          return Padding(
            padding: const EdgeInsets.all(EcSpace.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: size, height: size, child: board),
                const SizedBox(width: EcSpace.lg),
                Expanded(child: SingleChildScrollView(child: panel)),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(EcSpace.md),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: c.maxWidth - 32),
              child: board,
            ),
            const SizedBox(height: EcSpace.md),
            panel,
          ],
        );
      },
    );
  }
}

class _Finished extends StatelessWidget {
  const _Finished({required this.empty});

  /// No puzzle matched at all (as opposed to having gone through them).
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              empty ? Icons.extension_off_rounded : Icons.celebration_rounded,
              size: 72,
              color: context.palette.zap,
            ),
            const SizedBox(height: EcSpace.md),
            Text(
              empty ? l10n.puzzlesEmptyTitle : l10n.puzzleAllDone,
              textAlign: TextAlign.center,
              style: text.headlineSmall,
            ),
            if (empty) ...[
              const SizedBox(height: EcSpace.sm),
              Text(
                l10n.puzzlesEmptyBody,
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(
                  color: context.palette.inkMuted,
                ),
              ),
            ],
            const SizedBox(height: EcSpace.lg),
            ChunkyButton(label: l10n.close, onPressed: () => context.pop()),
          ],
        ),
      ),
    );
  }
}
