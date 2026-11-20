import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';

import '../../analysis/domain/position_key.dart';

/// A puzzle from the Lichess database: [fen] is the position *before* the
/// opponent's move, [moves] are UCI moves starting with that opponent move,
/// then alternating solver / opponent.
@immutable
class LichessPuzzle {
  const LichessPuzzle({
    required this.id,
    required this.fen,
    required this.moves,
    required this.rating,
    this.themes = const [],
  });

  factory LichessPuzzle.fromJson(Map<String, dynamic> j) => LichessPuzzle(
    id: j['id'] as String,
    fen: j['fen'] as String,
    moves: (j['moves'] as List).cast<String>(),
    rating: (j['rating'] as num).toInt(),
    themes: (j['themes'] as List? ?? const []).cast<String>(),
  );

  final String id;
  final String fen;
  final List<String> moves;
  final int rating;
  final List<String> themes;

  Map<String, Object> toJson() => {
    'id': id,
    'fen': fen,
    'moves': moves,
    'rating': rating,
    'themes': themes,
  };
}

enum PuzzleMoveResult {
  /// Right move; the opponent answers next.
  correct,

  /// Right move and the line is finished.
  solved,

  /// Wrong move; the position stays as it was.
  wrong,
}

/// Plays through a [LichessPuzzle]. Pure, so it is easy to test; widgets
/// only draw [position] and call [opponentMove] / [play].
class PuzzleSession {
  PuzzleSession(this.puzzle)
    : position = Chess.fromSetup(Setup.parseFen(puzzle.fen));

  final LichessPuzzle puzzle;

  /// Current position on the board.
  Position position;

  /// Index of the next move in [LichessPuzzle.moves].
  int index = 0;

  /// The last move played (standard UCI), for highlighting.
  String? lastMove;

  /// True once any wrong move was played.
  bool mistakes = false;

  bool get solved => index >= puzzle.moves.length;

  /// The side the player solves for (the side to move after the first move).
  Side get solverSide =>
      Chess.fromSetup(Setup.parseFen(puzzle.fen)).turn.opposite;

  /// It is the player's turn.
  bool get playerToMove => !solved && index.isOdd;

  /// Plays the opponent's next move (the setup move, or a reply).
  void opponentMove() {
    if (solved || playerToMove) return;
    _push(puzzle.moves[index]);
  }

  /// The player's move [uci]. A move that mates is always accepted on the
  /// final move (Lichess accepts any mate there).
  PuzzleMoveResult play(String uci) {
    if (!playerToMove) return PuzzleMoveResult.wrong;
    final expected = puzzle.moves[index];
    final move = parseEngineUci(position, uci);
    if (move == null) return PuzzleMoveResult.wrong;
    final isLast = index == puzzle.moves.length - 1;
    final mates = position.play(move).isCheckmate;
    if (uci == expected || _sameMove(uci, expected) || (isLast && mates)) {
      _push(uci);
      return solved ? PuzzleMoveResult.solved : PuzzleMoveResult.correct;
    }
    mistakes = true;
    return PuzzleMoveResult.wrong;
  }

  /// The move the player should find now (for "show solution").
  String? get hint => playerToMove ? puzzle.moves[index] : null;

  void _push(String uci) {
    final move = parseEngineUci(position, uci)!;
    lastMove = standardUci(position, move);
    position = position.play(move);
    index++;
  }

  /// Puzzle data writes castling as king-to-destination; treat `e1h1` and
  /// `e1g1` (and promotions written either way) the same.
  bool _sameMove(String a, String b) {
    final ma = parseEngineUci(position, a);
    final mb = parseEngineUci(position, b);
    return ma != null && mb != null && ma == mb;
  }
}
