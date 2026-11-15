import 'package:dartchess/dartchess.dart';

/// A position identity that ignores the move counters, so the same position
/// reached at different move numbers shares one key (opening book lookups and
/// the analysis cache both rely on this).
///
/// Format: `<board> <turn> <castling> <ep>` — the first four FEN fields.
String positionKey(Position pos) => fenKey(pos.fen);

/// Same as [positionKey] but from a FEN string.
String fenKey(String fen) {
  final parts = fen.trim().split(RegExp(r'\s+'));
  return parts.take(4).join(' ');
}

/// Converts a dartchess move to standard UCI as engines print it.
///
/// dartchess encodes castling as "king takes own rook" (`e1h1`); engines and
/// most UIs use the king's destination square (`e1g1`).
String standardUci(Position pos, Move move) {
  if (move is NormalMove) {
    final piece = pos.board.pieceAt(move.from);
    final target = pos.board.pieceAt(move.to);
    if (piece?.role == Role.king &&
        target != null &&
        target.role == Role.rook &&
        target.color == piece!.color) {
      final kingSide = move.to.file > move.from.file;
      final dest = Square.fromCoords(
        kingSide ? File.g : File.c,
        move.from.rank,
      );
      return move.from.name + dest.name;
    }
  }
  return move.uci;
}

/// Parses an engine UCI move (`e1g1`, `e7e8q`) into a legal move in [pos],
/// or `null` when it is not legal.
Move? parseEngineUci(Position pos, String uci) {
  final raw = Move.parse(uci);
  if (raw is! NormalMove) return null;
  final move = pos.normalizeMove(raw);
  return pos.isLegal(move) ? move : null;
}
