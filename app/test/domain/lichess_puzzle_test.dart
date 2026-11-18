import 'package:dartchess/dartchess.dart';
import 'package:evilchess/features/puzzles/domain/lichess_puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // From the Lichess format: opponent plays first, then solver/opponent.
  const fork = LichessPuzzle(
    id: 'p1',
    fen: 'r3k3/8/8/1N6/8/8/8/4K3 b - - 0 1',
    moves: ['a8a7', 'b5c7', 'e8d7', 'c7a8'],
    rating: 1650,
  );

  test('plays the setup move, then alternates solver and opponent', () {
    final s = PuzzleSession(fork);
    expect(s.playerToMove, isFalse);
    expect(s.solverSide, Side.white);
    s.opponentMove();
    expect(s.lastMove, 'a8a7');
    expect(s.playerToMove, isTrue);

    expect(s.play('b5c7'), PuzzleMoveResult.correct);
    expect(s.playerToMove, isFalse);
    s.opponentMove();
    expect(s.play('c7a8'), PuzzleMoveResult.solved);
    expect(s.solved, isTrue);
    expect(s.mistakes, isFalse);
  });

  test('a wrong move keeps the position and is remembered', () {
    final s = PuzzleSession(fork)..opponentMove();
    final before = s.position.fen;
    expect(s.play('b5d6'), PuzzleMoveResult.wrong);
    expect(s.position.fen, before);
    expect(s.mistakes, isTrue);
    expect(s.hint, 'b5c7');
    expect(s.play('b5c7'), PuzzleMoveResult.correct);
  });

  test('illegal or out-of-turn moves are wrong', () {
    final s = PuzzleSession(fork);
    expect(s.play('b5c7'), PuzzleMoveResult.wrong, reason: 'not our turn');
    s.opponentMove();
    expect(s.play('e1e3'), PuzzleMoveResult.wrong, reason: 'illegal');
  });

  test('any mate is accepted on the final move', () {
    // Back rank: after ...a3, both Rc8# and Rd8# mate.
    const p = LichessPuzzle(
      id: 'p2',
      fen: '6k1/5ppp/8/8/p7/8/5PPP/2RR2K1 b - - 0 1',
      moves: ['a4a3', 'c1c8'],
      rating: 600,
    );
    final s = PuzzleSession(p)..opponentMove();
    expect(s.play('d1d8'), PuzzleMoveResult.solved, reason: 'also mate');

    final t = PuzzleSession(p)..opponentMove();
    expect(t.play('d1d7'), PuzzleMoveResult.wrong);
  });

  test('castling written as king-takes-rook is the same move', () {
    const p = LichessPuzzle(
      id: 'p3',
      fen: 'r3k3/8/8/8/8/8/8/R3K2R b KQq - 0 1',
      moves: ['a8a7', 'e1g1'],
      rating: 900,
    );
    final s = PuzzleSession(p)..opponentMove();
    expect(s.play('e1h1'), PuzzleMoveResult.solved);
  });

  test('JSON round-trip', () {
    final copy = LichessPuzzle.fromJson(fork.toJson());
    expect(copy.moves, fork.moves);
    expect(copy.rating, 1650);
  });
}
