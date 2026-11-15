import 'package:evilchess/core/theme/move_classification.dart';
import 'package:evilchess/features/analysis/domain/classification.dart';
import 'package:flutter_test/flutter_test.dart';

MoveClass classify({
  double before = 50,
  double after = 50,
  bool best = false,
  double? second,
  bool book = false,
  bool sacrifice = false,
  double? opponentLoss,
}) => classifyMove(
  MoveFacts(
    winBefore: before,
    winAfter: after,
    isEngineBest: best,
    secondBestWin: second,
    isBook: book,
    isSacrifice: sacrifice,
    opponentLastLoss: opponentLoss,
  ),
);

void main() {
  test('book wins over everything', () {
    expect(classify(book: true, before: 50, after: 20), MoveClass.book);
  });

  group('by win% lost', () {
    final cases = {
      0.5: MoveClass.excellent,
      1.9: MoveClass.excellent,
      2.0: MoveClass.good,
      4.9: MoveClass.good,
      5.0: MoveClass.inaccuracy,
      9.9: MoveClass.inaccuracy,
      10.0: MoveClass.mistake,
      19.9: MoveClass.mistake,
      20.0: MoveClass.blunder,
      45.0: MoveClass.blunder,
    };
    cases.forEach((loss, expected) {
      test('$loss → ${expected.name}', () {
        expect(classify(before: 60, after: 60 - loss), expected);
      });
    });
  });

  test('engine move is Best', () {
    expect(classify(best: true, before: 55, after: 55), MoveClass.best);
  });

  test('Great: the only good move', () {
    expect(
      classify(best: true, before: 60, after: 60, second: 35),
      MoveClass.great,
    );
    // Small gap → just Best.
    expect(
      classify(best: true, before: 60, after: 60, second: 55),
      MoveClass.best,
    );
    // Already completely winning → no Great.
    expect(
      classify(best: true, before: 99, after: 99, second: 80),
      MoveClass.best,
    );
  });

  test('Brilliant: a sound sacrifice', () {
    expect(
      classify(best: true, sacrifice: true, before: 70, after: 70),
      MoveClass.brilliant,
    );
    // Sacrifice that leaves you worse is not brilliant.
    expect(
      classify(best: true, sacrifice: true, before: 40, after: 40),
      MoveClass.best,
    );
    // Not when already totally winning.
    expect(
      classify(best: true, sacrifice: true, before: 98, after: 98),
      MoveClass.best,
    );
    // A bad sacrifice is classified by its loss.
    expect(classify(sacrifice: true, before: 60, after: 30), MoveClass.blunder);
  });

  test('Miss: failing to punish an opponent error', () {
    // Opponent just lost 25%; we give back 12% → Miss instead of Mistake.
    expect(classify(before: 80, after: 68, opponentLoss: 25), MoveClass.miss);
    // Small slip after an opponent error is still an Inaccuracy/Good.
    expect(classify(before: 80, after: 76, opponentLoss: 25), MoveClass.good);
    // Throwing everything away is still a Blunder.
    expect(
      classify(before: 80, after: 20, opponentLoss: 25),
      MoveClass.blunder,
    );
    // No opponent error → normal Mistake.
    expect(classify(before: 80, after: 68), MoveClass.mistake);
  });
}
