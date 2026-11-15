import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';

import '../../../core/theme/move_classification.dart';
import '../../games/domain/game_record.dart';
import 'accuracy.dart';
import 'classification.dart';
import 'evaluation.dart';
import 'material.dart';
import 'opening_book.dart';
import 'position_key.dart';

/// Engine result for one position. Scores are from White's point of view.
@immutable
class PositionEval {
  const PositionEval({
    required this.eval,
    required this.depth,
    this.bestUci,
    this.pv = const [],
    this.secondEval,
  });

  /// A finished game position (mate / stalemate): no search needed.
  const PositionEval.terminal(this.eval)
    : depth = 0,
      bestUci = null,
      pv = const [],
      secondEval = null;

  final Eval eval;
  final int depth;
  final String? bestUci;

  /// Principal variation in UCI.
  final List<String> pv;

  /// Score of the second-best move (MultiPV 2), when there is one.
  final Eval? secondEval;

  Map<String, Object?> toJson() => {
    'e': eval.toJson(),
    'd': depth,
    if (bestUci != null) 'b': bestUci,
    if (pv.isNotEmpty) 'pv': pv.join(' '),
    if (secondEval != null) 's': secondEval!.toJson(),
  };

  factory PositionEval.fromJson(Map<String, Object?> json) => PositionEval(
    eval: Eval.fromJson((json['e']! as Map).cast<String, Object?>()),
    depth: (json['d']! as num).toInt(),
    bestUci: json['b'] as String?,
    pv: (json['pv'] as String?)?.split(' ') ?? const [],
    secondEval: json['s'] == null
        ? null
        : Eval.fromJson((json['s']! as Map).cast<String, Object?>()),
  );
}

/// The analysed result of one move.
@immutable
class MoveAnalysis {
  const MoveAnalysis({
    required this.ply,
    required this.san,
    required this.uci,
    required this.whiteMoved,
    required this.classification,
    required this.accuracy,
    required this.winBefore,
    required this.winAfter,
    required this.evalBefore,
    required this.evalAfter,
    required this.phase,
    required this.piece,
    this.bestUci,
    this.bestSan,
    this.bestLineSan = const [],
    this.clock,
  });

  /// 0-based half-move index.
  final int ply;
  final String san;
  final String uci;
  final bool whiteMoved;
  final MoveClass classification;
  final double accuracy;

  /// Mover's win% before (with best play) and after the move.
  final double winBefore;
  final double winAfter;

  /// White-POV evals of the position before and after the move.
  final Eval evalBefore;
  final Eval evalAfter;
  final GamePhase phase;
  final Role piece;
  final String? bestUci;
  final String? bestSan;

  /// Engine's principal line from the position before the move, in SAN.
  final List<String> bestLineSan;
  final Duration? clock;

  double get winLoss => (winBefore - winAfter).clamp(0, 100).toDouble();

  bool get isError =>
      classification == MoveClass.inaccuracy ||
      classification == MoveClass.mistake ||
      classification == MoveClass.blunder ||
      classification == MoveClass.miss;

  /// Moves worth jumping to with "Next mistake".
  bool get isMistakeOrWorse =>
      classification == MoveClass.mistake ||
      classification == MoveClass.blunder ||
      classification == MoveClass.miss;
}

@immutable
class GameAnalysis {
  const GameAnalysis({
    required this.moves,
    required this.whiteAccuracy,
    required this.blackAccuracy,
    required this.whiteEvals,
    this.opening,
  });

  final List<MoveAnalysis> moves;
  final double? whiteAccuracy;
  final double? blackAccuracy;

  /// White-POV eval of every position (length = moves + 1), for the graph.
  final List<Eval> whiteEvals;
  final OpeningName? opening;

  Map<MoveClass, int> countsFor({required bool white}) {
    final counts = {for (final c in MoveClass.values) c: 0};
    for (final m in moves.where((m) => m.whiteMoved == white)) {
      counts[m.classification] = counts[m.classification]! + 1;
    }
    return counts;
  }
}

/// Builds the full analysis of [game] from per-position engine results.
///
/// [positions] has one entry per position: the start position and the
/// position after every move (`game.plies.length + 1` entries).
GameAnalysis analyzeGame(
  GameRecord game,
  List<PositionEval> positions, {
  OpeningBook? book,
}) {
  assert(positions.length == game.plies.length + 1);
  final openingBook = book ?? OpeningBook.empty();

  final moves = <MoveAnalysis>[];
  var stillInBook = true;
  double? lastLoss;

  for (var i = 0; i < game.plies.length; i++) {
    final ply = game.plies[i];
    final before = positions[i];
    final after = positions[i + 1];
    final pos = Chess.fromSetup(Setup.parseFen(ply.fenBefore));
    final white = pos.turn == Side.white;
    final move = parseEngineUci(pos, ply.uci)!;

    final winBefore = before.eval.winPercentFor(white: white);
    final winAfter = after.eval.winPercentFor(white: white);
    final secondWin = before.secondEval?.winPercentFor(white: white);
    final isBest = before.bestUci != null && before.bestUci == ply.uci;

    final afterKey = fenKey(ply.fenAfter);
    stillInBook = stillInBook && openingBook.contains(afterKey);

    final facts = MoveFacts(
      // When the played move is the engine's, "before" can't be worse
      // than "after" except for search noise; don't punish it.
      winBefore: isBest ? winAfter : winBefore,
      winAfter: winAfter,
      isEngineBest: isBest,
      secondBestWin: secondWin,
      isBook: stillInBook,
      isSacrifice: isSacrifice(pos, move),
      opponentLastLoss: lastLoss,
    );
    final cls = classifyMove(facts);

    String? bestSan;
    final bestLine = <String>[];
    if (before.pv.isNotEmpty) {
      Position p = pos;
      for (final uci in before.pv.take(8)) {
        final m = parseEngineUci(p, uci);
        if (m == null) break;
        final (next, san) = p.makeSan(m);
        bestLine.add(san);
        p = next;
      }
      bestSan = bestLine.firstOrNull;
    }

    moves.add(
      MoveAnalysis(
        ply: i,
        san: ply.san,
        uci: ply.uci,
        whiteMoved: white,
        classification: cls,
        accuracy: moveAccuracy(facts.winBefore, winAfter),
        winBefore: facts.winBefore,
        winAfter: winAfter,
        evalBefore: before.eval,
        evalAfter: after.eval,
        phase: phaseOf(pos, i),
        piece: pos.board.roleAt((move as NormalMove).from) ?? Role.pawn,
        bestUci: before.bestUci,
        bestSan: bestSan,
        bestLineSan: bestLine,
        clock: ply.clock,
      ),
    );
    lastLoss = facts.loss;
  }

  final whiteWins = [for (final p in positions) p.eval.whiteWinPercent];
  final firstTurnWhite =
      Chess.fromSetup(Setup.parseFen(game.initialFen)).turn == Side.white;
  final acc = gameAccuracy(whiteWins, whiteMovesFirst: firstTurnWhite);

  return GameAnalysis(
    moves: moves,
    whiteAccuracy: acc.white,
    blackAccuracy: acc.black,
    whiteEvals: [for (final p in positions) p.eval],
    opening: openingBook.identify(game.plies.map((p) => fenKey(p.fenAfter))),
  );
}
