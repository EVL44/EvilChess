import 'dart:math' as math;

/// Accuracy of a single move from the drop in the mover's win% (Lichess).
///
/// `103.1668 * exp(-0.04354 * drop) - 3.1669`, plus a 1-point "uncertainty
/// bonus", clamped to 0–100. A move that does not lose win% scores 100.
double moveAccuracy(double winBefore, double winAfter) {
  if (winAfter >= winBefore) return 100;
  final drop = winBefore - winAfter;
  final raw =
      103.1668100711649 * math.exp(-0.04354415386753951 * drop) -
      3.166924740191411;
  return (raw + 1).clamp(0, 100).toDouble();
}

/// Per-side game accuracy, Lichess style.
///
/// [whiteWinPercents] are White's win% for every position of the game,
/// starting with the initial position (so `length == moves + 1`).
/// [whiteMovesFirst] is false when the game starts with Black to move.
///
/// Each move's accuracy is weighted by the volatility (standard deviation of
/// win%) around it, so mistakes in sharp positions count more. The result is
/// the average of that weighted mean and the harmonic mean.
({double? white, double? black}) gameAccuracy(
  List<double> whiteWinPercents, {
  bool whiteMovesFirst = true,
}) {
  final n = whiteWinPercents.length - 1; // number of moves
  if (n < 1) return (white: null, black: null);

  final windowSize = (n ~/ 10).clamp(2, 8);
  final windows = <List<double>>[];
  // The first moves reuse the first full window (as Lichess does).
  final firstWindow = whiteWinPercents.take(windowSize).toList();
  for (var i = 0; i < math.min(windowSize - 2, n); i++) {
    windows.add(firstWindow);
  }
  for (var i = 0; i + windowSize <= whiteWinPercents.length; i++) {
    windows.add(whiteWinPercents.sublist(i, i + windowSize));
  }
  // Short games: pad so every move has a window.
  while (windows.length < n) {
    windows.add(windows.isEmpty ? whiteWinPercents : windows.last);
  }
  final weights = [
    for (final w in windows.take(n)) _stdDev(w).clamp(0.5, 12).toDouble(),
  ];

  final white = <(double acc, double weight)>[];
  final black = <(double acc, double weight)>[];
  for (var i = 0; i < n; i++) {
    final whiteMoved = (i.isEven) == whiteMovesFirst;
    final before = whiteWinPercents[i];
    final after = whiteWinPercents[i + 1];
    final acc = whiteMoved
        ? moveAccuracy(before, after)
        : moveAccuracy(100 - before, 100 - after);
    (whiteMoved ? white : black).add((acc, weights[i]));
  }

  double? combine(List<(double, double)> moves) {
    if (moves.isEmpty) return null;
    final weightSum = moves.fold<double>(0, (s, m) => s + m.$2);
    final weighted =
        moves.fold<double>(0, (s, m) => s + m.$1 * m.$2) / weightSum;
    final harmonic = _harmonicMean(moves.map((m) => m.$1).toList());
    return (weighted + harmonic) / 2;
  }

  return (white: combine(white), black: combine(black));
}

double _stdDev(List<double> xs) {
  final mean = xs.reduce((a, b) => a + b) / xs.length;
  final variance =
      xs.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
      xs.length;
  return math.sqrt(variance);
}

double _harmonicMean(List<double> xs) {
  // Accuracies of 0 would make the harmonic mean 0; Lichess floors at 1.
  final sum = xs.fold<double>(0, (s, x) => s + 1 / math.max(x, 1));
  return xs.length / sum;
}
