import 'package:evilchess/features/analysis/domain/accuracy.dart';
import 'package:evilchess/features/analysis/domain/evaluation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('win%', () {
    test('matches the Lichess formula', () {
      expect(winPercentFromCp(0), 50);
      // 50 + 50 * (2 / (1 + exp(-0.00368208 * 100)) - 1) = 59.10…
      expect(winPercentFromCp(100), closeTo(59.10, 0.01));
      expect(winPercentFromCp(-100), closeTo(40.90, 0.01));
      expect(winPercentFromCp(300), closeTo(75.11, 0.01));
    });

    test('clamps at ±1000 cp', () {
      expect(winPercentFromCp(5000), winPercentFromCp(1000));
      expect(winPercentFromCp(-5000), winPercentFromCp(-1000));
      expect(winPercentFromCp(1000), closeTo(97.55, 0.01));
    });

    test('mate scores are 100 / 0', () {
      expect(const Eval.mate(3).whiteWinPercent, 100);
      expect(const Eval.mate(-2).whiteWinPercent, 0);
      expect(const Eval.mate(-2).winPercentFor(white: false), 100);
    });

    test('labels', () {
      expect(const Eval.cp(134).label, '+1.3');
      expect(const Eval.cp(-25).label, '-0.3');
      expect(const Eval.cp(0).label, '0.0');
      expect(const Eval.mate(3).label, 'M3');
      expect(const Eval.mate(-1).label, '-M1');
    });

    test('JSON round-trip', () {
      for (final e in [const Eval.cp(-42), const Eval.mate(5)]) {
        expect(Eval.fromJson(e.toJson()), e);
      }
    });
  });

  group('move accuracy', () {
    test('no loss is 100', () {
      expect(moveAccuracy(60, 60), 100);
      expect(moveAccuracy(60, 70), 100);
    });

    test('decreases with the win% drop', () {
      final small = moveAccuracy(60, 55);
      final big = moveAccuracy(60, 30);
      expect(small, greaterThan(big));
      // Lichess: 103.1668 * exp(-0.04354 * 5) - 3.1669 + 1 ≈ 80.9
      expect(small, closeTo(80.9, 0.2));
    });

    test('a total collapse is 0', () {
      expect(moveAccuracy(100, 0), 0);
    });
  });

  group('game accuracy', () {
    test('perfect play from both sides is ~100', () {
      final acc = gameAccuracy(List.filled(41, 50));
      expect(acc.white, closeTo(100, 0.01));
      expect(acc.black, closeTo(100, 0.01));
    });

    test('one blunder lowers only that side', () {
      final wins = List<double>.filled(41, 50);
      // White (moves at even indices) blunders on move index 10: 50 → 10.
      for (var i = 11; i < wins.length; i++) {
        wins[i] = 10;
      }
      final acc = gameAccuracy(wins);
      expect(acc.white, lessThan(90));
      expect(acc.black, greaterThan(99));
    });

    test('works when Black moves first', () {
      final wins = <double>[50, 50, 80, 80];
      final acc = gameAccuracy(wins, whiteMovesFirst: false);
      // Index 0 = Black, 1 = White (50 → 80 is good for White), 2 = Black.
      expect(acc.white, closeTo(100, 0.01));
      expect(acc.black, isNotNull);
    });

    test('empty game', () {
      final acc = gameAccuracy([50]);
      expect(acc.white, isNull);
      expect(acc.black, isNull);
    });

    test('one-move game only has White accuracy', () {
      final acc = gameAccuracy([50, 50]);
      expect(acc.white, closeTo(100, 0.01));
      expect(acc.black, isNull);
    });
  });
}
