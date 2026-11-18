import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../analysis/domain/position_key.dart';
import '../../review/widgets/review_board.dart';
import '../domain/lichess_puzzle.dart';

/// Plays a Lichess-format puzzle on the board: the opponent's moves are made
/// automatically, the player makes theirs. Give it a new [Key] per puzzle.
class LichessPuzzleBoard extends StatefulWidget {
  const LichessPuzzleBoard({
    super.key,
    required this.puzzle,
    required this.onSolved,
    required this.onWrong,
    this.revealSolution = false,
    this.moveDelay = const Duration(milliseconds: 450),
  });

  final LichessPuzzle puzzle;

  /// Called once when the line is finished; [clean] = no wrong move.
  final void Function(bool clean) onSolved;

  /// Called for every wrong move.
  final VoidCallback onWrong;

  /// When it turns true, the remaining moves are played out.
  final bool revealSolution;

  /// Pause before an opponent move.
  final Duration moveDelay;

  @override
  State<LichessPuzzleBoard> createState() => _LichessPuzzleBoardState();
}

class _LichessPuzzleBoardState extends State<LichessPuzzleBoard> {
  late PuzzleSession _session = PuzzleSession(widget.puzzle);
  int _revision = 0;
  bool _reported = false;
  Timer? _timer;
  Timer? _flashTimer;
  bool _wrongFlash = false;

  @override
  void initState() {
    super.initState();
    _scheduleOpponent();
  }

  @override
  void didUpdateWidget(LichessPuzzleBoard old) {
    super.didUpdateWidget(old);
    if (old.puzzle.id != widget.puzzle.id) {
      _timer?.cancel();
      _session = PuzzleSession(widget.puzzle);
      _reported = false;
      _scheduleOpponent();
    }
    if (widget.revealSolution && !old.revealSolution) _reveal();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _scheduleOpponent() {
    _timer?.cancel();
    _timer = Timer(widget.moveDelay, () {
      if (!mounted || _session.solved || _session.playerToMove) return;
      setState(_session.opponentMove);
      if (_session.solved) _finish();
    });
  }

  void _finish() {
    if (_reported) return;
    _reported = true;
    widget.onSolved(!_session.mistakes);
  }

  void _onMove(NormalMove move) {
    final uci = standardUci(_session.position, move);
    final result = _session.play(uci);
    switch (result) {
      case PuzzleMoveResult.correct:
        unawaited(HapticFeedback.lightImpact());
        setState(() {});
        _scheduleOpponent();
      case PuzzleMoveResult.solved:
        unawaited(HapticFeedback.mediumImpact());
        setState(() {});
        _finish();
      case PuzzleMoveResult.wrong:
        unawaited(HapticFeedback.heavyImpact());
        setState(() {
          _revision++; // snap the piece back
          _wrongFlash = true;
        });
        widget.onWrong();
        _flashTimer?.cancel();
        _flashTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _wrongFlash = false);
        });
    }
  }

  /// Plays out the rest of the solution, one move at a time.
  void _reveal() {
    _timer?.cancel();
    void step() {
      if (!mounted || _session.solved) return;
      setState(() {
        if (_session.playerToMove) {
          _session.mistakes = true;
          _push(_session.hint!);
        } else {
          _session.opponentMove();
        }
      });
      if (_session.solved) {
        _finish();
      } else {
        _timer = Timer(widget.moveDelay, step);
      }
    }

    step();
  }

  void _push(String uci) {
    final r = _session.play(uci);
    assert(r != PuzzleMoveResult.wrong);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          width: 3,
          color: _wrongFlash ? const Color(0xFFDC2626) : Colors.transparent,
        ),
      ),
      child: ReviewBoard(
        fen: _session.position.fen,
        orientation: _session.solverSide,
        lastMoveUci: _session.lastMove,
        interactive: _session.playerToMove && !widget.revealSolution,
        onMove: _onMove,
        revision: _revision,
      ),
    );
  }
}
