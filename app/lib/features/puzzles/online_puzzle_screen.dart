import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chunky_button.dart';
import '../../l10n/app_localizations.dart';
import '../account/account.dart';
import '../account/error_text.dart';
import 'data/online_puzzles.dart';
import 'domain/lichess_puzzle.dart';
import 'widgets/lichess_puzzle_board.dart';

enum OnlinePuzzleMode { rated, daily }

/// Rated puzzles (one after another) or the daily puzzle.
class OnlinePuzzleScreen extends ConsumerStatefulWidget {
  const OnlinePuzzleScreen({super.key, required this.mode, this.theme});

  final OnlinePuzzleMode mode;
  final String? theme;

  @override
  ConsumerState<OnlinePuzzleScreen> createState() => _OnlinePuzzleState();
}

class _OnlinePuzzleState extends ConsumerState<OnlinePuzzleScreen> {
  LichessPuzzle? _puzzle;
  Object? _error;
  bool _solved = false;
  bool _reveal = false;
  bool _reported = false;
  String? _feedback;
  RatedResult? _rating;

  bool get _rated => widget.mode == OnlinePuzzleMode.rated;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _puzzle = null;
      _error = null;
      _solved = false;
      _reveal = false;
      _reported = false;
      _feedback = null;
      _rating = null;
    });
    final api = ref.read(onlinePuzzlesProvider);
    try {
      final p = _rated
          ? await api.next(theme: widget.theme)
          : await api.daily();
      if (mounted) setState(() => _puzzle = p);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Rated: the first result counts (a wrong move or giving up is a loss).
  Future<void> _report(bool win) async {
    if (!_rated || _reported || _puzzle == null) return;
    _reported = true;
    try {
      final r = await ref
          .read(onlinePuzzlesProvider)
          .attempt(_puzzle!.id, win: win);
      if (mounted) setState(() => _rating = r);
      unawaited(ref.read(accountProvider.notifier).refreshProfile());
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final p = _puzzle;

    Widget body;
    if (_error != null && p == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(EcSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.puzzlesUnavailable, style: text.titleMedium),
              const SizedBox(height: EcSpace.sm),
              Text(friendlyError(l10n, _error!), textAlign: TextAlign.center),
              const SizedBox(height: EcSpace.lg),
              ChunkyButton(label: l10n.tryAgain, onPressed: _load),
            ],
          ),
        ),
      );
    } else if (p == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final solver = PuzzleSession(p).solverSide;
      final board = LichessPuzzleBoard(
        key: ValueKey(p.id),
        puzzle: p,
        revealSolution: _reveal,
        onWrong: () {
          setState(() => _feedback = l10n.retryWrong);
          unawaited(_report(false));
        },
        onSolved: (clean) {
          setState(() {
            _solved = true;
            _feedback = clean ? l10n.puzzleCorrect : null;
          });
          unawaited(_report(clean));
        },
      );

      String? ratingLine;
      if (_rating != null) {
        ratingLine = _rating!.rated
            ? l10n.ratingChange(
                _rating!.rating,
                _rating!.delta >= 0
                    ? '+${_rating!.delta}'
                    : '${_rating!.delta}',
              )
            : l10n.puzzleNotRated;
      }

      final panel = Card(
        child: Padding(
          padding: const EdgeInsets.all(EcSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.findBestMove(
                  solver == Side.white ? l10n.white : l10n.black,
                ),
                style: text.titleMedium,
              ),
              Text(
                '#${p.id} · ${p.rating}',
                textDirection: TextDirection.ltr,
                style: text.bodySmall?.copyWith(color: palette.inkMuted),
              ),
              if (_feedback != null) ...[
                const SizedBox(height: EcSpace.sm),
                Text(
                  _feedback!,
                  key: const Key('puzzle-feedback'),
                  style: text.titleSmall?.copyWith(
                    color: _solved ? palette.zap : palette.hot,
                  ),
                ),
              ],
              if (ratingLine != null) ...[
                const SizedBox(height: EcSpace.xs),
                Text(
                  ratingLine,
                  key: const Key('rating-line'),
                  style: text.titleSmall,
                ),
              ],
              const SizedBox(height: EcSpace.md),
              Wrap(
                spacing: EcSpace.sm,
                runSpacing: EcSpace.sm,
                children: [
                  if (_solved && _rated)
                    ChunkyButton(
                      key: const Key('next-puzzle'),
                      label: l10n.nextPuzzle,
                      icon: Icons.arrow_forward_rounded,
                      color: palette.zap,
                      onPressed: _load,
                    ),
                  if (!_solved)
                    ChunkyButton(
                      key: const Key('show-solution'),
                      label: l10n.retryShowAnswer,
                      color: palette.sun,
                      onPressed: _reveal
                          ? null
                          : () {
                              setState(() => _reveal = true);
                              unawaited(_report(false));
                            },
                    ),
                ],
              ),
            ],
          ),
        ),
      );

      body = LayoutBuilder(
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
                  Expanded(child: panel),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_rated ? l10n.ratedPuzzles : l10n.dailyPuzzle),
      ),
      body: body,
    );
  }
}
