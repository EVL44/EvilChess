import 'dart:async';

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

/// Puzzle Rush: solve as many as possible, easiest first. A wrong move is a
/// strike and skips to the next puzzle; three strikes end the run. Timed
/// modes also end when the clock runs out.
class RushScreen extends ConsumerStatefulWidget {
  const RushScreen({super.key, required this.mode});

  /// `3min`, `5min` or `survival`.
  final String mode;

  @override
  ConsumerState<RushScreen> createState() => _RushScreenState();
}

class _RushScreenState extends ConsumerState<RushScreen> {
  static const maxStrikes = 3;

  List<LichessPuzzle>? _puzzles;
  bool _offline = false;
  Object? _error;
  int _index = 0;
  int _score = 0;
  int _strikes = 0;
  Duration? _left;
  Timer? _clock;
  bool _over = false;
  ({int best, bool newBest})? _best;

  Duration? get _limit => switch (widget.mode) {
    '3min' => const Duration(minutes: 3),
    '5min' => const Duration(minutes: 5),
    _ => null,
  };

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    _clock?.cancel();
    setState(() {
      _puzzles = null;
      _error = null;
      _index = 0;
      _score = 0;
      _strikes = 0;
      _over = false;
      _best = null;
      _left = _limit;
    });
    try {
      final (list, offline) = await ref
          .read(onlinePuzzlesProvider)
          .batch(count: 60);
      if (!mounted) return;
      setState(() {
        _puzzles = list;
        _offline = offline;
      });
      if (_limit != null) {
        _clock = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted || _over) return;
          final left = _left! - const Duration(seconds: 1);
          setState(() => _left = left);
          if (left <= Duration.zero) unawaited(_end());
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _next() {
    if (_index + 1 >= (_puzzles?.length ?? 0)) {
      unawaited(_end());
    } else {
      setState(() => _index++);
    }
  }

  Future<void> _end() async {
    if (_over) return;
    _clock?.cancel();
    setState(() => _over = true);
    if (ref.read(accountProvider).signedIn && !_offline) {
      try {
        final best = await ref
            .read(onlinePuzzlesProvider)
            .submitRush(widget.mode, _score);
        if (mounted) setState(() => _best = best);
      } catch (_) {
        // Offline or server error: the run still counts here.
      }
    }
  }

  String _clockText(Duration d) {
    final s = d.inSeconds.clamp(0, 3600);
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final puzzles = _puzzles;

    Widget body;
    if (_error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(EcSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyError(l10n, _error!), textAlign: TextAlign.center),
              const SizedBox(height: EcSpace.lg),
              ChunkyButton(label: l10n.tryAgain, onPressed: _start),
            ],
          ),
        ),
      );
    } else if (puzzles == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_over || puzzles.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(EcSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, size: 72, color: palette.sun),
              Text(
                _strikes >= maxStrikes ? l10n.rushStruckOut : l10n.rushTimeUp,
                style: text.headlineSmall,
              ),
              const SizedBox(height: EcSpace.sm),
              Text(
                l10n.rushScore(_score),
                key: const Key('rush-final'),
                style: text.displaySmall?.copyWith(color: palette.brand),
              ),
              if (_best != null)
                Text(
                  _best!.newBest
                      ? l10n.rushNewBest
                      : l10n.rushBest(_best!.best),
                  style: text.titleMedium?.copyWith(
                    color: _best!.newBest ? palette.zap : null,
                  ),
                ),
              const SizedBox(height: EcSpace.lg),
              ChunkyButton(
                key: const Key('rush-again'),
                label: l10n.rushPlayAgain,
                icon: Icons.replay_rounded,
                onPressed: _start,
              ),
            ],
          ),
        ),
      );
    } else {
      final p = puzzles[_index];
      final header = Row(
        children: [
          Text(
            l10n.rushScore(_score),
            key: const Key('rush-score'),
            style: text.headlineSmall?.copyWith(color: palette.brand),
          ),
          const Spacer(),
          for (var i = 0; i < maxStrikes; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                i < _strikes ? Icons.close_rounded : Icons.circle_outlined,
                color: i < _strikes ? palette.hot : palette.inkMuted,
              ),
            ),
          if (_left != null) ...[
            const SizedBox(width: EcSpace.md),
            Text(
              _clockText(_left!),
              textDirection: TextDirection.ltr,
              style: text.headlineSmall,
            ),
          ],
        ],
      );
      final board = LichessPuzzleBoard(
        key: ValueKey('${p.id}-$_index'),
        puzzle: p,
        moveDelay: const Duration(milliseconds: 250),
        onSolved: (clean) {
          if (clean) setState(() => _score++);
          _next();
        },
        onWrong: () {
          setState(() => _strikes++);
          if (_strikes >= maxStrikes) {
            unawaited(_end());
          } else {
            _next();
          }
        },
      );
      body = LayoutBuilder(
        builder: (context, c) => ListView(
          padding: const EdgeInsets.all(EcSpace.md),
          children: [
            header,
            if (_offline)
              Padding(
                padding: const EdgeInsets.only(top: EcSpace.xs),
                child: Text(
                  l10n.playingOffline,
                  style: text.bodySmall?.copyWith(color: palette.inkMuted),
                ),
              ),
            const SizedBox(height: EcSpace.md),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (c.maxHeight - 120).clamp(260.0, 640.0),
                ),
                child: board,
              ),
            ),
          ],
        ),
      );
    }

    final title = switch (widget.mode) {
      '3min' => l10n.rush3min,
      '5min' => l10n.rush5min,
      _ => l10n.rushSurvival,
    };
    return Scaffold(
      appBar: AppBar(title: Text('${l10n.puzzleRush} · $title')),
      body: body,
    );
  }
}
