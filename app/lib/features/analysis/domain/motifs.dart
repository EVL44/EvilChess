import 'package:dartchess/dartchess.dart';

import '../../games/domain/game_record.dart';
import 'evaluation.dart';
import 'game_analysis.dart';
import 'material.dart';
import 'position_key.dart';

/// What went wrong with a move (rule-based, no engine needed).
enum Motif {
  hungPiece,
  badTrade,
  missedFork,
  missedPin,
  missedSkewer,
  missedDiscoveredAttack,
  missedMate,
  walkedIntoMate,
  backRankMate,
  timeTrouble,
}

/// The tactical idea behind a (best) move.
enum TacticTheme { fork, pin, skewer, discoveredAttack, mate, backRankMate }

/// One bucket per error, for the "vulnerabilities" report.
enum ErrorCategory {
  mate,
  hungMaterial,
  missedTactic,
  opening,
  endgame,
  positional,
}

/// Motif data attached to an analysed move.
class MoveMotifs {
  const MoveMotifs({this.motifs = const [], this.opportunity, this.category});

  /// Why the move was an error (empty for good moves).
  final List<Motif> motifs;

  /// Tactical theme of the engine's best move in this position, if any.
  final TacticTheme? opportunity;

  /// Set for inaccuracies, mistakes, misses and blunders.
  final ErrorCategory? category;
}

bool _valuable(Board board, Square target, int attackerValue, Side enemy) {
  final role = board.roleAt(target)!;
  if (role == Role.king) return true;
  final v = pieceValue(role);
  if (v > attackerValue) return true;
  // Undefended minor piece or better.
  return v >= 3 && board.attacksTo(target, enemy).isEmpty;
}

bool _isSlider(Role r) => r == Role.bishop || r == Role.rook || r == Role.queen;

/// True when the final position of [lineSan] (played from [start]) is a
/// back-rank mate: king on its home rank, mated by a rook or queen on it.
(bool mate, bool backRank) _mateInLine(Position start, List<String> lineSan) {
  Position p = start;
  for (final san in lineSan) {
    final m = p.parseSan(san);
    if (m == null) break;
    p = p.play(m);
  }
  if (!p.isCheckmate) return (false, false);
  final loser = p.turn;
  final king = p.board.kingOf(loser)!;
  final homeRank = loser == Side.white ? Rank.first : Rank.eighth;
  if (king.rank != homeRank) return (true, false);
  for (final c in p.checkers.squares) {
    final role = p.board.roleAt(c);
    if ((role == Role.rook || role == Role.queen) && c.rank == king.rank) {
      return (true, true);
    }
  }
  return (true, false);
}

/// Finds the tactical idea of playing [move] in [before].
/// [lineSan] is the engine line starting with that move (for mates).
TacticTheme? detectTactic(
  Position before,
  NormalMove move, {
  List<String> lineSan = const [],
}) {
  final mover = before.turn;
  final enemy = mover.opposite;

  // 1. Forced mate at the end of the line.
  final line = lineSan.isEmpty ? [before.makeSan(move).$2] : lineSan;
  final (mate, backRank) = _mateInLine(before, line);
  if (mate) return backRank ? TacticTheme.backRankMate : TacticTheme.mate;

  final after = before.play(move);
  final board = after.board;
  final piece = board.pieceAt(move.to);
  if (piece == null) return null;
  final value = pieceValue(piece.role);
  final enemies = board.bySide(enemy);
  final occupied = board.occupied;

  // 2. Fork: the moved piece hits two or more valuable targets and isn't
  //    simply lost on its new square.
  final hit = attacks(piece, move.to, occupied) & enemies;
  final targets = hit.squares
      .where((t) => _valuable(board, t, value, enemy))
      .toList();
  final givesCheck = targets.any((t) => board.roleAt(t) == Role.king);
  final safe = staticExchange(board, move.to, enemy) == 0;
  if (targets.length >= 2 && (safe || givesCheck) && piece.role != Role.king) {
    return TacticTheme.fork;
  }

  // 3. Discovered attack: another slider now hits something valuable
  //    through the square the piece left.
  for (final s in board.bySide(mover).squares) {
    if (s == move.to) continue;
    final slider = board.pieceAt(s)!;
    if (!_isSlider(slider.role)) continue;
    final now = attacks(slider, s, occupied) & enemies;
    final was =
        attacks(slider, s, before.board.occupied) & before.board.bySide(enemy);
    for (final t in now.squares) {
      if (was.has(t)) continue;
      if (!between(s, t).has(move.from)) continue;
      if (_valuable(board, t, pieceValue(slider.role), enemy)) {
        return TacticTheme.discoveredAttack;
      }
    }
  }

  // 4. Pin / skewer along the moved slider's lines.
  if (_isSlider(piece.role) && (safe || givesCheck)) {
    for (final front in hit.squares) {
      final frontRole = board.roleAt(front)!;
      final through =
          attacks(piece, move.to, occupied.withoutSquare(front)) & enemies;
      for (final back in through.squares) {
        if (hit.has(back) || !between(move.to, back).has(front)) continue;
        final backRole = board.roleAt(back)!;
        final fv = frontRole == Role.king ? 100 : pieceValue(frontRole);
        final bv = backRole == Role.king ? 100 : pieceValue(backRole);
        if (fv > bv && bv >= 3) return TacticTheme.skewer;
        if (bv > fv && fv >= 3) return TacticTheme.pin;
      }
    }
  }
  return null;
}

int? _mateFor(Eval e, {required bool white}) =>
    e.mate == null ? null : (white ? e.mate! : -e.mate!);

/// Remaining time below which a mistake counts as "time trouble":
/// 10% of the base time, at most 30 s and at least 5 s.
Duration timeTroubleThreshold(TimeControl tc) =>
    Duration(seconds: (tc.baseSeconds * 0.1).round().clamp(5, 30));

/// Works out the motifs of every move of an analysed game, using only what
/// is stored (positions, evals, best moves and lines).
List<MoveMotifs> annotateMotifs(GameRecord game, List<MoveAnalysis> moves) {
  final result = <MoveMotifs>[];
  for (var i = 0; i < moves.length; i++) {
    final m = moves[i];
    final ply = game.plies[i];
    final before = Chess.fromSetup(Setup.parseFen(ply.fenBefore));
    final after = Chess.fromSetup(Setup.parseFen(ply.fenAfter));
    final mover = before.turn;
    final white = mover == Side.white;
    final played = parseEngineUci(before, m.uci);
    final best = m.bestUci == null ? null : parseEngineUci(before, m.bestUci!);
    final next = i + 1 < moves.length ? moves[i + 1] : null;

    // Tactical idea of the best move (for find-rates and "missed X").
    TacticTheme? theme;
    if (best is NormalMove) {
      theme = detectTactic(before, best, lineSan: m.bestLineSan);
    }
    final found = m.bestUci != null && m.bestUci == m.uci;
    final opportunity = (found || m.isMistakeOrWorse) ? theme : null;

    if (!m.isError || played is! NormalMove) {
      result.add(MoveMotifs(opportunity: opportunity));
      continue;
    }

    final motifs = <Motif>{};
    final mateBefore = _mateFor(m.evalBefore, white: white);
    final mateAfter = _mateFor(m.evalAfter, white: white);

    if ((mateBefore ?? 0) > 0 && !((mateAfter ?? 0) > 0)) {
      motifs.add(Motif.missedMate);
    }
    if ((mateAfter ?? 0) < 0 && !((mateBefore ?? 0) < 0)) {
      motifs.add(Motif.walkedIntoMate);
      final line = next?.bestLineSan ?? const <String>[];
      if (line.isNotEmpty && _mateInLine(after, line).$2) {
        motifs.add(Motif.backRankMate);
      }
    }

    // Material given away by the move itself.
    final captured = before.board.pieceAt(played.to);
    final capturedValue = captured != null && captured.color != mover
        ? pieceValue(captured.role)
        : 0;
    final lossOnSquare = staticExchange(after.board, played.to, mover.opposite);
    if (capturedValue > 0 && capturedValue - lossOnSquare <= -2) {
      motifs.add(Motif.badTrade);
    } else if (next?.bestUci != null) {
      final reply = parseEngineUci(after, next!.bestUci!);
      if (reply is NormalMove) {
        final victim = after.board.pieceAt(reply.to);
        if (victim != null &&
            victim.color == mover &&
            staticExchange(after.board, reply.to, mover.opposite) >= 2) {
          motifs.add(Motif.hungPiece);
        }
      }
    }

    // What the best move would have done.
    if (!found) {
      switch (theme) {
        case TacticTheme.fork:
          motifs.add(Motif.missedFork);
        case TacticTheme.pin:
          motifs.add(Motif.missedPin);
        case TacticTheme.skewer:
          motifs.add(Motif.missedSkewer);
        case TacticTheme.discoveredAttack:
          motifs.add(Motif.missedDiscoveredAttack);
        case TacticTheme.mate:
          motifs.add(Motif.missedMate);
        case TacticTheme.backRankMate:
          motifs
            ..add(Motif.missedMate)
            ..add(Motif.backRankMate);
        case null:
          break;
      }
    }

    final tc = game.timeControl;
    if (tc != null && m.clock != null && m.clock! <= timeTroubleThreshold(tc)) {
      motifs.add(Motif.timeTrouble);
    }

    result.add(
      MoveMotifs(
        motifs: motifs.toList(),
        opportunity: opportunity,
        category: _category(motifs, m.phase),
      ),
    );
  }
  return result;
}

ErrorCategory _category(Set<Motif> motifs, GamePhase phase) {
  if (motifs.contains(Motif.walkedIntoMate)) return ErrorCategory.mate;
  if (motifs.contains(Motif.hungPiece) || motifs.contains(Motif.badTrade)) {
    return ErrorCategory.hungMaterial;
  }
  const tactical = {
    Motif.missedFork,
    Motif.missedPin,
    Motif.missedSkewer,
    Motif.missedDiscoveredAttack,
    Motif.missedMate,
  };
  if (motifs.any(tactical.contains)) return ErrorCategory.missedTactic;
  return switch (phase) {
    GamePhase.opening => ErrorCategory.opening,
    GamePhase.endgame => ErrorCategory.endgame,
    GamePhase.middlegame => ErrorCategory.positional,
  };
}

/// The piece the opponent can win after an error with [Motif.hungPiece]
/// ([fenAfter] is the position after the error, [replyUci] their best move).
Role? hungPieceRole(String fenAfter, String? replyUci) {
  if (replyUci == null) return null;
  final pos = Chess.fromSetup(Setup.parseFen(fenAfter));
  final reply = parseEngineUci(pos, replyUci);
  return reply is NormalMove ? pos.board.roleAt(reply.to) : null;
}
