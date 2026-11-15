import 'package:dartchess/dartchess.dart';
import 'package:evilchess/features/analysis/domain/material.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';
import 'package:flutter_test/flutter_test.dart';

Position fen(String f) => Chess.fromSetup(Setup.parseFen(f));

bool sac(String f, String uci) {
  final pos = fen(f);
  return isSacrifice(pos, parseEngineUci(pos, uci)!);
}

void main() {
  group('isSacrifice', () {
    test('Greek gift Bxh7+ is a sacrifice', () {
      // Classic: bishop takes h7 pawn, king can recapture.
      expect(
        sac(
          'r1bq1rk1/pppn1ppp/4p3/3pP3/1b1P4/2NB1N2/PPP2PPP/R1BQK2R w KQ - 0 8',
          'd3h7',
        ),
        isTrue,
      );
    });

    test('a normal developing move is not', () {
      expect(sac(Chess.initial.fen, 'g1f3'), isFalse);
    });

    test('an even trade is not', () {
      // Nxd5 Nxd5: knight for knight.
      expect(
        sac(
          'rnbqkb1r/ppp1pppp/8/3n4/8/2N5/PPPP1PPP/R1BQKBNR w KQkq - 0 4',
          'c3d5',
        ),
        isFalse,
      );
    });

    test(
      'hanging the queen is a sacrifice (classification decides if good)',
      () {
        expect(
          sac(
            'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2',
            'd1h5',
          ),
          isFalse, // Qh5 is not attacked by anything yet
        );
        expect(
          sac(
            'rnbqkb1r/pppp1ppp/5n2/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 2 3',
            'd1h5',
          ),
          isTrue, // Nxh5 wins the queen
        );
      },
    );
  });

  group('phase', () {
    test('start is opening', () {
      expect(phaseOf(Chess.initial, 0), GamePhase.opening);
    });
    test('after move 12 with pieces on is middlegame', () {
      expect(phaseOf(Chess.initial, 30), GamePhase.middlegame);
    });
    test('rooks and minors only is endgame', () {
      expect(
        phaseOf(fen('r3k2r/pp3ppp/2n5/8/8/2N5/PP3PPP/R3K2R w - - 0 30'), 60),
        GamePhase.endgame,
      );
    });
    test('non-pawn material at start is 62', () {
      expect(nonPawnMaterial(Chess.initial.board), 62);
    });
  });

  test('positionKey ignores move counters', () {
    final a = fen('rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1');
    final b = fen('rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 4 9');
    expect(positionKey(a), positionKey(b));
  });

  test('standardUci converts castling', () {
    final pos = fen('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1');
    final short = pos.parseSan('O-O')!;
    final long = pos.parseSan('O-O-O')!;
    expect(standardUci(pos, short), 'e1g1');
    expect(standardUci(pos, long), 'e1c1');
    expect(parseEngineUci(pos, 'e1g1'), isNotNull);
  });
}
