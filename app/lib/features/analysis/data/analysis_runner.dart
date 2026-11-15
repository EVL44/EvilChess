import 'dart:convert';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/engine/engine_service.dart';
import '../../games/data/game_repository.dart';
import '../../games/domain/game_record.dart';
import '../domain/evaluation.dart';
import '../domain/game_analysis.dart';
import '../domain/opening_book.dart';
import '../domain/position_key.dart';

/// Runs a full-game analysis: every position is searched once (MultiPV 2),
/// reusing cached results, then moves are classified and the result saved.
class AnalysisRunner {
  AnalysisRunner({
    required this.repository,
    required this.engineService,
    required this.book,
    required this.depth,
  });

  final GameRepository repository;
  final EngineService engineService;
  final OpeningBook book;
  final int depth;

  static const multiPv = 2;

  /// Analyses [game]. [onProgress] gets (positions done, total).
  /// Set [isCancelled] to stop early (nothing is saved then).
  Future<GameAnalysis?> run(
    GameRecord game, {
    void Function(int done, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final fens = [game.initialFen, for (final p in game.plies) p.fenAfter];
    final total = fens.length;
    final results = <PositionEval>[];
    UciEngine? engine;

    for (var i = 0; i < total; i++) {
      if (isCancelled?.call() ?? false) return null;
      final fen = fens[i];
      final result =
          _terminal(fen) ??
          await repository.cachedEval(
            fenKey(fen),
            multiPv: multiPv,
            minDepth: depth,
          ) ??
          await () async {
            if (engine == null) {
              engine = await engineService.engine;
              await engine!.newGame();
            }
            final r = await engine!.evaluate(
              fen,
              depth: depth,
              multiPv: multiPv,
            );
            await repository.cacheEval(fenKey(fen), multiPv, r);
            return r;
          }();
      results.add(result);
      onProgress?.call(i + 1, total);
    }

    final analysis = analyzeGame(game, results, book: book);
    await repository.saveAnalysis(game.id, analysis, depth: depth);
    return analysis;
  }

  /// Checkmate / stalemate / dead positions need no engine.
  static PositionEval? _terminal(String fen) {
    final pos = Chess.fromSetup(Setup.parseFen(fen));
    if (pos.isCheckmate) {
      return PositionEval.terminal(
        Eval.checkmated(whiteToMove: pos.turn == Side.white),
      );
    }
    if (pos.isStalemate || pos.isInsufficientMaterial) {
      return const PositionEval.terminal(Eval.cp(0));
    }
    return null;
  }
}

/// The opening book, loaded once from assets.
final openingBookProvider = FutureProvider<OpeningBook>((ref) async {
  try {
    // `load` + decode instead of `loadString`: no shared cache entry and no
    // background isolate for this one-off read.
    final data = await rootBundle.load(OpeningBook.assetPath);
    return OpeningBook.parse(
      utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      ),
    );
  } on FlutterError {
    return OpeningBook.empty();
  }
});

final analysisRunnerProvider = FutureProvider<AnalysisRunner>((ref) async {
  return AnalysisRunner(
    repository: ref.watch(gameRepositoryProvider),
    engineService: ref.watch(engineServiceProvider),
    book: await ref.watch(openingBookProvider.future),
    depth: ref.watch(analysisDepthProvider),
  );
});
