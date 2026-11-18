import 'package:dartchess/dartchess.dart' show Role;
import 'package:flutter/foundation.dart';

import '../../analysis/domain/material.dart';
import '../../analysis/domain/motifs.dart';
import '../../games/domain/game_record.dart';

typedef SideStat = ({double? accuracy, int games, double? score});

@immutable
class OpeningStat {
  const OpeningStat({
    required this.name,
    required this.asWhite,
    required this.games,
    this.score,
    this.eco,
    this.accuracy,
  });

  /// Opening family (the part of the name before the colon).
  final String name;
  final String? eco;
  final bool asWhite;
  final int games;

  /// Average result: 1 = win, 0.5 = draw, 0 = loss (unfinished games are
  /// ignored; null when there is no finished game).
  final double? score;
  final double? accuracy;
}

/// Everything shown on the personal report screen.
@immutable
class ReportData {
  const ReportData({
    required this.gamesAnalyzed,
    this.averageAccuracy,
    this.timeline = const [],
    this.byPhase = const {},
    this.byColor = const {},
    this.bySpeed = const {},
    this.errorsByCategory = const {},
    this.timeTroubleErrors = 0,
    this.tactics = const {},
    this.errorsByPiece = const {},
    this.openings = const [],
  });

  static const empty = ReportData(gamesAnalyzed: 0);

  final int gamesAnalyzed;
  final double? averageAccuracy;

  /// The user's accuracy per game, oldest first.
  final List<({DateTime? date, double accuracy})> timeline;
  final Map<GamePhase, ({double accuracy, int moves})> byPhase;

  /// Keyed by "played White".
  final Map<bool, SideStat> byColor;
  final Map<GameSpeed, SideStat> bySpeed;

  /// Mistakes, misses and blunders per cause.
  final Map<ErrorCategory, int> errorsByCategory;
  final int timeTroubleErrors;

  /// Per tactical theme: how often the best move was found.
  final Map<TacticTheme, ({int found, int total})> tactics;
  final Map<Role, int> errorsByPiece;
  final List<OpeningStat> openings;

  bool get isEmpty => gamesAnalyzed == 0;

  int get totalErrors => errorsByCategory.values.fold(0, (a, b) => a + b);
}

/// Which of the player's own mistakes a puzzle set draws from.
@immutable
class PuzzleFilter {
  const PuzzleFilter({
    this.category,
    this.theme,
    this.phase,
    this.timeTrouble = false,
  });

  static const all = PuzzleFilter();

  final ErrorCategory? category;
  final TacticTheme? theme;
  final GamePhase? phase;
  final bool timeTrouble;

  /// Compact form for route parameters: `c:hungMaterial`, `t:fork`, …
  String encode() {
    if (category != null) return 'c:${category!.name}';
    if (theme != null) return 't:${theme!.name}';
    if (phase != null) return 'p:${phase!.name}';
    if (timeTrouble) return 'time';
    return 'all';
  }

  static PuzzleFilter decode(String? raw) {
    if (raw == null || raw == 'all') return all;
    if (raw == 'time') return const PuzzleFilter(timeTrouble: true);
    final i = raw.indexOf(':');
    if (i < 0) return all;
    final value = raw.substring(i + 1);
    T? find<T extends Enum>(List<T> values) =>
        values.where((v) => v.name == value).firstOrNull;
    return switch (raw.substring(0, i)) {
      'c' => PuzzleFilter(category: find(ErrorCategory.values)),
      't' => PuzzleFilter(theme: find(TacticTheme.values)),
      'p' => PuzzleFilter(phase: find(GamePhase.values)),
      _ => all,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is PuzzleFilter &&
      other.category == category &&
      other.theme == theme &&
      other.phase == phase &&
      other.timeTrouble == timeTrouble;

  @override
  int get hashCode => Object.hash(category, theme, phase, timeTrouble);
}

enum FocusKind { category, tactic, phase, timeTrouble }

/// One of the "things to work on this week", linked to a puzzle set.
@immutable
class FocusItem {
  const FocusItem({
    required this.kind,
    required this.filter,
    required this.severity,
    this.count = 0,
    this.rate,
  });

  final FocusKind kind;
  final PuzzleFilter filter;

  /// Higher = more urgent; used only for ordering.
  final double severity;

  /// Number of errors behind this item (category / time trouble).
  final int count;

  /// Find rate (tactic) or accuracy (phase), 0–100.
  final double? rate;
}

/// Picks up to three things to work on, most urgent first:
/// - the most frequent causes of errors,
/// - tactical themes that are missed more often than found,
/// - a game phase clearly weaker than the others,
/// - time trouble, when a good share of errors happen on a low clock.
List<FocusItem> pickFocus(ReportData r, {int max = 3}) {
  if (r.isEmpty) return const [];
  final items = <FocusItem>[];
  final games = r.gamesAnalyzed;

  r.errorsByCategory.forEach((cat, n) {
    if (n == 0) return;
    // Phase buckets are covered by the phase item below.
    if (cat == ErrorCategory.opening || cat == ErrorCategory.endgame) return;
    final weight = switch (cat) {
      ErrorCategory.mate => 1.6,
      ErrorCategory.hungMaterial => 1.4,
      ErrorCategory.missedTactic => 1.2,
      _ => 0.7,
    };
    items.add(
      FocusItem(
        kind: FocusKind.category,
        filter: PuzzleFilter(category: cat),
        severity: n / games * weight,
        count: n,
      ),
    );
  });

  r.tactics.forEach((theme, t) {
    if (t.total < 3) return;
    final rate = t.found / t.total * 100;
    if (rate >= 60) return;
    items.add(
      FocusItem(
        kind: FocusKind.tactic,
        filter: PuzzleFilter(theme: theme),
        severity: (t.total - t.found) / games * 1.3,
        count: t.total - t.found,
        rate: rate,
      ),
    );
  });

  if (r.byPhase.length >= 2) {
    final sorted = r.byPhase.entries.toList()
      ..sort((a, b) => a.value.accuracy.compareTo(b.value.accuracy));
    final worst = sorted.first;
    final best = sorted.last;
    final gap = best.value.accuracy - worst.value.accuracy;
    if (gap >= 4 && worst.value.moves >= 10) {
      items.add(
        FocusItem(
          kind: FocusKind.phase,
          filter: PuzzleFilter(phase: worst.key),
          severity: gap / 15,
          rate: worst.value.accuracy,
        ),
      );
    }
  }

  final total = r.totalErrors;
  if (total > 0 && r.timeTroubleErrors / total >= 0.15) {
    items.add(
      FocusItem(
        kind: FocusKind.timeTrouble,
        filter: const PuzzleFilter(timeTrouble: true),
        severity: r.timeTroubleErrors / games * 1.1,
        count: r.timeTroubleErrors,
      ),
    );
  }

  items.sort((a, b) => b.severity.compareTo(a.severity));
  return items.take(max).toList();
}
