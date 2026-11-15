import 'package:dartchess/dartchess.dart';

/// Classic piece values in pawns (king excluded).
int pieceValue(Role role) => switch (role) {
  Role.pawn => 1,
  Role.knight => 3,
  Role.bishop => 3,
  Role.rook => 5,
  Role.queen => 9,
  Role.king => 0,
};

/// Sum of non-pawn material for both sides (62 at the start).
int nonPawnMaterial(Board board) {
  var total = 0;
  for (final role in [Role.knight, Role.bishop, Role.rook, Role.queen]) {
    total += board.byRole(role).size * pieceValue(role);
  }
  return total;
}

/// Game phase used for reports.
enum GamePhase { opening, middlegame, endgame }

/// Simple, deterministic phase split:
/// - endgame when non-pawn material on the board is ≤ 26 (e.g. R+B+N each),
/// - opening for the first 12 moves (24 plies) while most pieces are on,
/// - middlegame otherwise.
GamePhase phaseOf(Position pos, int ply) {
  final material = nonPawnMaterial(pos.board);
  if (material <= 26) return GamePhase.endgame;
  if (ply < 24 && material >= 50) return GamePhase.opening;
  return GamePhase.middlegame;
}

/// Static exchange evaluation on [square] for [side] to capture first:
/// the material [side] can expect to win (≥ 0) by starting captures there.
int _see(Board board, Square square, Side side) {
  final target = board.pieceAt(square);
  if (target == null) return 0;
  final attackers = board.attacksTo(square, side);
  if (attackers.isEmpty) return 0;
  // Least valuable attacker first.
  Square? from;
  var best = 100;
  for (final s in attackers.squares) {
    final role = board.roleAt(s)!;
    final v = role == Role.king ? 50 : pieceValue(role);
    if (v < best) {
      best = v;
      from = s;
    }
  }
  final attacker = board.pieceAt(from!)!;
  final after = board.removePieceAt(from).setPieceAt(square, attacker);
  final gain = pieceValue(target.role) - _see(after, square, side.opposite);
  return gain > 0 ? gain : 0;
}

/// True when [move] gives away material: after it, the opponent can win at
/// least a minor piece's worth more than they could before, counting
/// what the move itself captured. Used for "Brilliant" detection.
bool isSacrifice(Position before, Move move) {
  if (move is! NormalMove) return false;
  final mover = before.turn;
  final moved = before.board.pieceAt(move.from);
  if (moved == null || moved.role == Role.king) return false;
  final captured = before.board.pieceAt(move.to);
  final capturedValue = captured != null && captured.color != mover
      ? pieceValue(captured.role)
      : 0;

  final after = before.playUnchecked(move);
  // Best material the opponent can grab now, on any of our pieces.
  var maxLoss = 0;
  for (final sq in after.board.bySide(mover).squares) {
    final role = after.board.roleAt(sq)!;
    if (role == Role.king || role == Role.pawn) continue;
    final loss = _see(after.board, sq, mover.opposite);
    if (loss > maxLoss) maxLoss = loss;
  }
  return maxLoss - capturedValue >= 2;
}
