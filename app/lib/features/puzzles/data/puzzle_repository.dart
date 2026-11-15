import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/theme/move_classification.dart';
import '../../analysis/domain/motifs.dart';
import '../../reports/domain/report.dart';

/// A puzzle made from a mistake in one of the player's own games: find a
/// better move than the one that was played.
@immutable
class MistakePuzzle {
  const MistakePuzzle({
    required this.gameId,
    required this.ply,
    required this.fen,
    required this.bestUci,
    required this.playedSan,
    required this.classification,
    required this.winBefore,
    required this.white,
    required this.black,
    this.bestSan,
    this.bestLineSan = const [],
    this.playedAt,
    this.theme,
    this.solved,
  });

  final String gameId;
  final int ply;

  /// Position to solve (before the mistake).
  final String fen;
  final String bestUci;
  final String? bestSan;
  final List<String> bestLineSan;

  /// What was played in the game.
  final String playedSan;
  final MoveClass classification;

  /// Mover's win% with best play (alternatives must stay close to it).
  final double winBefore;
  final String white;
  final String black;
  final DateTime? playedAt;
  final TacticTheme? theme;

  /// null = never tried.
  final bool? solved;

  bool get whiteToMove => fen.split(' ').elementAtOrNull(1) != 'b';
}

typedef PuzzleProgress = ({int total, int solved});

class PuzzleRepository {
  PuzzleRepository(this._db);

  final AppDatabase _db;

  /// When we know which colour the user played in at least one game, only
  /// their own mistakes become puzzles; otherwise every mistake in the
  /// library does (e.g. a pasted PGN collection).
  Future<bool> _hasUserGames() async {
    final r = await _db
        .customSelect(
          'SELECT EXISTS(SELECT 1 FROM games WHERE user_side IS NOT NULL '
          'AND analyzed_at IS NOT NULL) AS e',
          readsFrom: {_db.games},
        )
        .getSingle();
    return r.read<bool>('e');
  }

  String _where(PuzzleFilter f, {required bool userOnly}) {
    final parts = [
      "m.classification IN ('mistake', 'blunder', 'miss')",
      'm.best_uci IS NOT NULL',
      'm.fen_before IS NOT NULL',
      'm.uci <> m.best_uci',
      if (userOnly) ...[
        'g.user_side IS NOT NULL',
        "m.white_moved = (g.user_side = 'white')",
      ],
      if (f.category != null) "m.category = '${f.category!.name}'",
      if (f.theme != null) "m.opportunity = '${f.theme!.name}'",
      if (f.phase != null) "m.phase = '${f.phase!.name}'",
      if (f.timeTrouble) "m.motifs LIKE '%timeTrouble%'",
    ];
    return parts.join(' AND ');
  }

  /// Puzzles for [filter]: never-tried first, then failed, then solved;
  /// biggest mistakes first within each group.
  Future<List<MistakePuzzle>> puzzles(
    PuzzleFilter filter, {
    int limit = 50,
  }) async {
    final where = _where(filter, userOnly: await _hasUserGames());
    final rows = await _db
        .customSelect(
          '''
      SELECT m.game_id, m.ply, m.fen_before, m.best_uci, m.best_san,
             m.best_line, m.san, m.classification, m.win_before, m.win_after,
             m.opportunity, g.white, g.black, g.played_at, a.solved
      FROM move_analyses m
      JOIN games g ON g.id = m.game_id
      LEFT JOIN puzzle_attempts a ON a.game_id = m.game_id AND a.ply = m.ply
      WHERE $where
      ORDER BY CASE WHEN a.solved IS NULL THEN 0 WHEN a.solved = 0 THEN 1
                    ELSE 2 END,
               (m.win_before - m.win_after) DESC, m.game_id, m.ply
      LIMIT $limit
      ''',
          readsFrom: {_db.moveAnalyses, _db.games, _db.puzzleAttempts},
        )
        .get();
    return [
      for (final r in rows)
        MistakePuzzle(
          gameId: r.read<String>('game_id'),
          ply: r.read<int>('ply'),
          fen: r.read<String>('fen_before'),
          bestUci: r.read<String>('best_uci'),
          bestSan: r.read<String?>('best_san'),
          bestLineSan: r.read<String?>('best_line')?.split(' ') ?? const [],
          playedSan: r.read<String>('san'),
          classification: MoveClass.values.byName(
            r.read<String>('classification'),
          ),
          winBefore: r.read<double>('win_before'),
          white: r.read<String>('white'),
          black: r.read<String>('black'),
          playedAt: r.read<DateTime?>('played_at'),
          theme: TacticTheme.values
              .where((t) => t.name == r.read<String?>('opportunity'))
              .firstOrNull,
          solved: r.read<bool?>('solved'),
        ),
    ];
  }

  /// How many puzzles match [filter] and how many are already solved.
  Future<PuzzleProgress> progress(PuzzleFilter filter) async {
    final where = _where(filter, userOnly: await _hasUserGames());
    final r = await _db
        .customSelect(
          '''
      SELECT COUNT(*) AS total,
             COALESCE(SUM(CASE WHEN a.solved = 1 THEN 1 ELSE 0 END), 0) AS solved
      FROM move_analyses m
      JOIN games g ON g.id = m.game_id
      LEFT JOIN puzzle_attempts a ON a.game_id = m.game_id AND a.ply = m.ply
      WHERE $where
      ''',
          readsFrom: {_db.moveAnalyses, _db.games, _db.puzzleAttempts},
        )
        .getSingle();
    return (total: r.read<int>('total'), solved: r.read<int>('solved'));
  }

  /// Records an attempt. A puzzle stays solved once it has been solved.
  Future<void> recordAttempt(
    String gameId,
    int ply, {
    required bool solved,
  }) async {
    final existing =
        await (_db.select(_db.puzzleAttempts)
              ..where((t) => t.gameId.equals(gameId) & t.ply.equals(ply)))
            .getSingleOrNull();
    await _db
        .into(_db.puzzleAttempts)
        .insertOnConflictUpdate(
          PuzzleAttemptsCompanion.insert(
            gameId: gameId,
            ply: ply,
            solved: solved || (existing?.solved ?? false),
            attempts: Value((existing?.attempts ?? 0) + 1),
            lastAttemptAt: DateTime.now(),
          ),
        );
  }
}

final puzzleRepositoryProvider = Provider<PuzzleRepository>(
  (ref) => PuzzleRepository(ref.watch(appDatabaseProvider)),
);
