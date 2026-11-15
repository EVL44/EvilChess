import '../../../core/theme/move_classification.dart';

/// Everything the classifier needs to know about one move. All win% values
/// are from the **mover's** point of view (0–100).
class MoveFacts {
  const MoveFacts({
    required this.winBefore,
    required this.winAfter,
    required this.isEngineBest,
    this.secondBestWin,
    this.isBook = false,
    this.isSacrifice = false,
    this.opponentLastLoss,
  });

  /// Mover's win% with best play from the position before the move.
  final double winBefore;

  /// Mover's win% after the move actually played.
  final double winAfter;

  /// The played move is the engine's top choice.
  final bool isEngineBest;

  /// Mover's win% after the engine's second-best move (MultiPV 2), if known.
  final double? secondBestWin;

  /// Position after the move is in the opening book.
  final bool isBook;

  /// The move gives away material (see `isSacrifice`).
  final bool isSacrifice;

  /// How much win% the opponent lost with their previous move, if known.
  final double? opponentLastLoss;

  double get loss => (winBefore - winAfter).clamp(0, 100).toDouble();
}

/// Thresholds (win% lost by the mover). Kept in one place so they are easy to
/// tune and test.
abstract final class ClassThresholds {
  static const excellent = 2.0;
  static const good = 5.0;
  static const inaccuracy = 10.0;
  static const mistake = 20.0;

  /// "Only move": the second-best move is at least this much worse.
  static const onlyMoveGap = 10.0;

  /// Opponent's previous move counts as an error to punish at this loss.
  static const opponentError = 10.0;

  /// Failing to punish: losing at least this much of that advantage.
  static const miss = 7.0;
}

/// Classifies a move. Rules, in order:
/// 1. **Book** – the resulting position is in the opening book.
/// 2. **Brilliant** – best (or practically best) move that sacrifices
///    material, isn't the only way to avoid losing, and leaves the mover OK.
/// 3. **Great** – the engine's move when every alternative is much worse.
/// 4. **Best** – the engine's move.
/// 5. **Miss** – the opponent just erred and this move gives the gift back
///    (but isn't a full blunder).
/// 6. Otherwise by win% lost: Excellent < 2, Good < 5, Inaccuracy < 10,
///    Mistake < 20, Blunder ≥ 20.
MoveClass classifyMove(MoveFacts f) {
  if (f.isBook) return MoveClass.book;

  final loss = f.loss;
  final nearBest = f.isEngineBest || loss < 1;
  final gap = f.secondBestWin == null ? 0.0 : f.winBefore - f.secondBestWin!;

  if (nearBest && f.isSacrifice && f.winAfter >= 50 && f.winBefore < 97) {
    return MoveClass.brilliant;
  }
  if (f.isEngineBest &&
      gap >= ClassThresholds.onlyMoveGap &&
      f.winBefore < 97) {
    return MoveClass.great;
  }
  if (f.isEngineBest) return MoveClass.best;

  final punishable = (f.opponentLastLoss ?? 0) >= ClassThresholds.opponentError;
  if (punishable &&
      loss >= ClassThresholds.miss &&
      loss < ClassThresholds.mistake * 1.5 &&
      f.winAfter >= 30) {
    return MoveClass.miss;
  }

  if (loss < ClassThresholds.excellent) return MoveClass.excellent;
  if (loss < ClassThresholds.good) return MoveClass.good;
  if (loss < ClassThresholds.inaccuracy) return MoveClass.inaccuracy;
  if (loss < ClassThresholds.mistake) return MoveClass.mistake;
  return MoveClass.blunder;
}
