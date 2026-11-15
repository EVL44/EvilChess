import 'package:dartchess/dartchess.dart';
import 'package:evilchess/core/engine/uci_engine.dart';
import 'package:evilchess/features/analysis/domain/evaluation.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_engine.dart';

void main() {
  group('UciInfo.parse', () {
    test('reads depth, multipv, cp score and pv', () {
      final info = UciInfo.parse(
        'info depth 18 seldepth 25 multipv 2 score cp -34 nodes 1 nps 1 '
        'hashfull 3 tbhits 0 time 10 pv e7e5 g1f3 b8c6',
      )!;
      expect(info.depth, 18);
      expect(info.multiPv, 2);
      expect(info.cp, -34);
      expect(info.mate, isNull);
      expect(info.pv, ['e7e5', 'g1f3', 'b8c6']);
    });

    test('reads mate scores and bounds', () {
      final info = UciInfo.parse(
        'info depth 20 score mate -3 lowerbound pv h7h6',
      )!;
      expect(info.mate, -3);
      expect(info.bound, 'lowerbound');
    });

    test('ignores lines without score/pv', () {
      expect(
        UciInfo.parse('info depth 5 currmove e2e4 currmovenumber 1'),
        isNull,
      );
      expect(UciInfo.parse('info string NNUE evaluation enabled'), isNull);
      expect(UciInfo.parse('bestmove e2e4'), isNull);
    });

    test('converts to White POV', () {
      final info = UciInfo.parse('info depth 1 score cp 50 pv a7a6')!;
      expect(info.toWhiteEval(whiteToMove: false), const Eval.cp(-50));
      expect(info.toWhiteEval(whiteToMove: true), const Eval.cp(50));
      final mate = UciInfo.parse('info depth 1 score mate 2 pv a7a6')!;
      expect(mate.toWhiteEval(whiteToMove: false), const Eval.mate(-2));
    });
  });

  group('UciEngine', () {
    test('handshake, evaluation in White POV, multipv 2', () async {
      final afterE4 = Chess.initial.play(Chess.initial.parseSan('e4')!);
      final fake = FakeUciTransport(
        script: {
          positionKey(afterE4): (
            cp: -20,
            mate: null,
            best: 'e7e5',
            secondCp: -60,
          ),
        },
      );
      final engine = UciEngine(fake);
      await engine.init();
      expect(engine.engineName, 'FakeFish 1');

      final result = await engine.evaluate(afterE4.fen, depth: 12);
      expect(result.depth, 12);
      expect(result.bestUci, 'e7e5');
      expect(result.eval, const Eval.cp(20)); // Black -20 → White +20
      expect(result.secondEval, const Eval.cp(60));
      expect(fake.sent, contains('setoption name MultiPV value 2'));
      await engine.dispose();
      expect(fake.closed, isTrue);
    });

    test('concurrent requests are serialized', () async {
      final fake = FakeUciTransport();
      final engine = UciEngine(fake);
      final a = engine.evaluate(Chess.initial.fen, depth: 5, multiPv: 1);
      final b = engine.evaluate(Chess.initial.fen, depth: 6, multiPv: 1);
      final results = await Future.wait([a, b]);
      expect(results.map((r) => r.depth), [5, 6]);
      expect(fake.searches, 2);
      // Only one "go" was outstanding at a time.
      final gos = fake.sent.where((c) => c.startsWith('go')).toList();
      expect(gos, ['go depth 5', 'go depth 6']);
    });

    test('checkmated and stalemated positions', () async {
      final engine = UciEngine(FakeUciTransport());
      // Fool's mate: White is checkmated.
      final mated = await engine.evaluate(
        'rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3',
        depth: 10,
      );
      expect(mated.eval, const Eval.mate(-1));
      expect(mated.eval.whiteWinPercent, 0);

      final stalemate = await engine.evaluate(
        '7k/5Q2/6K1/8/8/8/8/8 b - - 0 1',
        depth: 10,
      );
      expect(stalemate.eval, const Eval.cp(0));
    });
  });
}
