import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// An engine score. Exactly one of [cp] / [mate] is set.
///
/// Stored from **White's point of view** throughout the app, so evals of
/// consecutive positions can be compared directly.
@immutable
class Eval {
  const Eval.cp(int this.cp) : mate = null;
  const Eval.mate(int this.mate) : cp = null;

  /// Centipawns, positive = White is better.
  final int? cp;

  /// Moves to mate; positive = White mates, negative = Black mates.
  final int? mate;

  /// Score of a final checkmate position: the side to move has lost.
  static Eval checkmated({required bool whiteToMove}) =>
      Eval.mate(whiteToMove ? -1 : 1);

  bool get isMate => mate != null;

  /// Same score seen by the other side.
  Eval negate() => cp != null ? Eval.cp(-cp!) : Eval.mate(-mate!);

  /// White's winning chances in percent (0–100), Lichess formula.
  double get whiteWinPercent {
    if (mate != null) return mate! > 0 ? 100 : 0;
    return winPercentFromCp(cp!);
  }

  /// Win% for the given side.
  double winPercentFor({required bool white}) =>
      white ? whiteWinPercent : 100 - whiteWinPercent;

  /// Short human label: `+1.4`, `-0.3`, `M3`, `-M2`.
  String get label {
    if (mate != null) {
      return mate! >= 0 ? 'M${mate!.abs()}' : '-M${mate!.abs()}';
    }
    final pawns = cp! / 100;
    final s = pawns.abs().toStringAsFixed(1);
    if (cp == 0) return '0.0';
    return pawns > 0 ? '+$s' : '-$s';
  }

  Map<String, Object> toJson() => cp != null ? {'cp': cp!} : {'mate': mate!};

  factory Eval.fromJson(Map<String, Object?> json) => json['mate'] != null
      ? Eval.mate((json['mate']! as num).toInt())
      : Eval.cp((json['cp']! as num).toInt());

  @override
  bool operator ==(Object other) =>
      other is Eval && other.cp == cp && other.mate == mate;

  @override
  int get hashCode => Object.hash(cp, mate);

  @override
  String toString() => 'Eval($label)';
}

/// Lichess: `50 + 50 * (2 / (1 + exp(-0.00368208 * cp)) - 1)`, with the
/// centipawns clamped to ±1000.
double winPercentFromCp(int cp) {
  final c = cp.clamp(-1000, 1000);
  return 50 + 50 * (2 / (1 + math.exp(-0.00368208 * c)) - 1);
}
