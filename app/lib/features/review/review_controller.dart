import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/data/analysis_runner.dart';
import '../analysis/domain/game_analysis.dart';
import '../games/data/game_repository.dart';
import '../games/domain/game_record.dart';

enum ReviewStatus { loading, notFound, analyzing, ready, error }

@immutable
class ReviewState {
  const ReviewState({
    this.status = ReviewStatus.loading,
    this.game,
    this.analysis,
    this.done = 0,
    this.total = 0,
    this.ply = -1,
    this.error,
  });

  final ReviewStatus status;
  final GameRecord? game;
  final GameAnalysis? analysis;

  /// Analysis progress (positions searched / total).
  final int done;
  final int total;

  /// Index of the last move played on the board; -1 = start position.
  final int ply;
  final String? error;

  int get moveCount => game?.plies.length ?? 0;

  double get progress => total == 0 ? 0 : done / total;

  /// FEN on the board for the current [ply].
  String? get fen {
    final g = game;
    if (g == null) return null;
    return ply < 0 ? g.initialFen : g.plies[ply].fenAfter;
  }

  MoveAnalysis? get currentMove =>
      (analysis == null || ply < 0) ? null : analysis!.moves[ply];

  ReviewState copyWith({
    ReviewStatus? status,
    GameRecord? game,
    GameAnalysis? analysis,
    int? done,
    int? total,
    int? ply,
    String? error,
  }) => ReviewState(
    status: status ?? this.status,
    game: game ?? this.game,
    analysis: analysis ?? this.analysis,
    done: done ?? this.done,
    total: total ?? this.total,
    ply: ply ?? this.ply,
    error: error ?? this.error,
  );
}

/// Loads a game, analyses it if needed, and tracks the move being viewed.
class ReviewController extends Notifier<ReviewState> {
  ReviewController(this.gameId);

  final String gameId;
  bool _disposed = false;

  @override
  ReviewState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    unawaited(_load());
    return const ReviewState();
  }

  Future<void> _load() async {
    final repo = ref.read(gameRepositoryProvider);
    final game = await repo.getGame(gameId);
    if (_disposed) return;
    if (game == null) {
      state = state.copyWith(status: ReviewStatus.notFound);
      return;
    }
    final saved = await repo.loadAnalysis(gameId);
    if (_disposed) return;
    if (saved != null && saved.moves.length == game.plies.length) {
      state = state.copyWith(
        status: ReviewStatus.ready,
        game: game,
        analysis: saved,
      );
      return;
    }
    state = state.copyWith(status: ReviewStatus.analyzing, game: game);
    await analyze();
  }

  /// (Re-)runs the engine over the whole game.
  Future<void> analyze() async {
    final game = state.game;
    if (game == null) return;
    state = state.copyWith(
      status: ReviewStatus.analyzing,
      done: 0,
      total: game.plies.length + 1,
    );
    try {
      final runner = await ref.read(analysisRunnerProvider.future);
      final result = await runner.run(
        game,
        isCancelled: () => _disposed,
        onProgress: (done, total) {
          if (!_disposed) state = state.copyWith(done: done, total: total);
        },
      );
      if (_disposed || result == null) return;
      state = state.copyWith(status: ReviewStatus.ready, analysis: result);
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(status: ReviewStatus.error, error: '$e');
    }
  }

  void goTo(int ply) {
    final clamped = ply.clamp(-1, state.moveCount - 1);
    if (clamped != state.ply) state = state.copyWith(ply: clamped);
  }

  void next() => goTo(state.ply + 1);
  void previous() => goTo(state.ply - 1);
  void first() => goTo(-1);
  void last() => goTo(state.moveCount - 1);

  /// Jumps to the next Mistake / Miss / Blunder after the current move,
  /// optionally only for one side. Returns false if there is none.
  bool nextMistake({bool? white}) {
    final moves = state.analysis?.moves;
    if (moves == null) return false;
    for (final m in moves.skip(state.ply + 1)) {
      if (m.isMistakeOrWorse && (white == null || m.whiteMoved == white)) {
        goTo(m.ply);
        return true;
      }
    }
    return false;
  }
}

final reviewControllerProvider = NotifierProvider.autoDispose
    .family<ReviewController, ReviewState, String>(ReviewController.new);
