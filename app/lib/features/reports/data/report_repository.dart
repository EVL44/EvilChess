import 'package:dartchess/dartchess.dart' show Role;
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../analysis/domain/material.dart';
import '../../analysis/domain/motifs.dart';
import '../../games/domain/game_record.dart';
import '../domain/report.dart';

/// Builds the personal report with SQL aggregations over `move_analyses`.
///
/// Only the user's own moves count: games where we know which colour they
/// played (`games.user_side`), and within those only that colour's moves.
class ReportRepository {
  ReportRepository(this._db);

  final AppDatabase _db;

  /// Join + filter shared by every per-move query.
  static const _userMoves = '''
    FROM move_analyses m
    JOIN games g ON g.id = m.game_id
    WHERE g.user_side IS NOT NULL
      AND m.white_moved = (g.user_side = 'white')
  ''';

  static const _userAccuracy =
      "CASE WHEN g.user_side = 'white' THEN g.white_accuracy "
      'ELSE g.black_accuracy END';

  static const _userScore = '''
    CASE
      WHEN g.result NOT IN ('1-0', '0-1', '1/2-1/2') THEN NULL
      WHEN g.result = '1/2-1/2' THEN 0.5
      WHEN (g.result = '1-0') = (g.user_side = 'white') THEN 1.0
      ELSE 0.0
    END
  ''';

  Future<List<QueryRow>> _q(String sql) =>
      _db.customSelect(sql, readsFrom: {_db.games, _db.moveAnalyses}).get();

  Future<ReportData> build() async {
    const games = '''
      FROM games g
      WHERE g.user_side IS NOT NULL AND g.analyzed_at IS NOT NULL
    ''';

    final summary = (await _q(
      'SELECT COUNT(*) AS n, AVG($_userAccuracy) AS acc $games',
    )).single;
    final gamesAnalyzed = summary.read<int>('n');
    if (gamesAnalyzed == 0) return ReportData.empty;

    final timeline = await _q('''
      SELECT g.played_at AS t, $_userAccuracy AS acc $games
        AND $_userAccuracy IS NOT NULL
      ORDER BY COALESCE(g.played_at, g.imported_at)
    ''');

    final byPhase = await _q('''
      SELECT m.phase AS k, AVG(m.accuracy) AS acc, COUNT(*) AS n
      $_userMoves GROUP BY m.phase
    ''');

    final byColor = await _q('''
      SELECT g.user_side AS k, AVG($_userAccuracy) AS acc, COUNT(*) AS n,
             AVG($_userScore) AS score
      $games GROUP BY g.user_side
    ''');

    final bySpeed = await _q('''
      SELECT g.speed AS k, AVG($_userAccuracy) AS acc, COUNT(*) AS n,
             AVG($_userScore) AS score
      $games GROUP BY g.speed ORDER BY n DESC
    ''');

    final categories = await _q('''
      SELECT m.category AS k, COUNT(*) AS n
      $_userMoves AND m.category IS NOT NULL
        AND m.classification IN ('mistake', 'blunder', 'miss')
      GROUP BY m.category
    ''');

    final timeTrouble = (await _q('''
      SELECT COUNT(*) AS n
      $_userMoves AND m.motifs LIKE '%timeTrouble%'
        AND m.classification IN ('mistake', 'blunder', 'miss')
    ''')).single.read<int>('n');

    final tactics = await _q('''
      SELECT m.opportunity AS k,
             SUM(CASE WHEN m.uci = m.best_uci THEN 1 ELSE 0 END) AS found,
             COUNT(*) AS n
      $_userMoves AND m.opportunity IS NOT NULL
      GROUP BY m.opportunity
    ''');

    final byPiece = await _q('''
      SELECT m.piece AS k, COUNT(*) AS n
      $_userMoves AND m.classification IN ('mistake', 'blunder', 'miss')
      GROUP BY m.piece ORDER BY n DESC
    ''');

    final openings = await _q('''
      SELECT
        CASE WHEN instr(g.opening, ':') > 0
             THEN substr(g.opening, 1, instr(g.opening, ':') - 1)
             ELSE g.opening END AS name,
        MIN(g.eco) AS eco,
        g.user_side AS side,
        COUNT(*) AS n,
        AVG($_userScore) AS score,
        AVG($_userAccuracy) AS acc
      $games AND g.opening IS NOT NULL
      GROUP BY name, g.user_side
      ORDER BY n DESC, name
      LIMIT 12
    ''');

    T? enumOf<T extends Enum>(List<T> values, String? name) =>
        values.where((v) => v.name == name).firstOrNull;

    final errorCounts = <ErrorCategory, int>{};
    for (final r in categories) {
      final c = enumOf(ErrorCategory.values, r.read<String>('k'));
      if (c != null) errorCounts[c] = r.read<int>('n');
    }

    return ReportData(
      gamesAnalyzed: gamesAnalyzed,
      averageAccuracy: summary.read<double?>('acc'),
      timeline: [
        for (final r in timeline)
          (date: r.read<DateTime?>('t'), accuracy: r.read<double>('acc')),
      ],
      byPhase: {
        for (final r in byPhase)
          ?enumOf(GamePhase.values, r.read<String>('k')): (
            accuracy: r.read<double>('acc'),
            moves: r.read<int>('n'),
          ),
      },
      byColor: {
        for (final r in byColor)
          r.read<String>('k') == 'white': (
            accuracy: r.read<double?>('acc'),
            games: r.read<int>('n'),
            score: r.read<double?>('score'),
          ),
      },
      bySpeed: {
        for (final r in bySpeed)
          GameSpeed.fromName(r.read<String>('k')): (
            accuracy: r.read<double?>('acc'),
            games: r.read<int>('n'),
            score: r.read<double?>('score'),
          ),
      },
      errorsByCategory: errorCounts,
      timeTroubleErrors: timeTrouble,
      tactics: {
        for (final r in tactics)
          ?enumOf(TacticTheme.values, r.read<String>('k')): (
            found: r.read<int>('found'),
            total: r.read<int>('n'),
          ),
      },
      errorsByPiece: {
        for (final r in byPiece)
          ?enumOf(Role.values, r.read<String>('k')): r.read<int>('n'),
      },
      openings: [
        for (final r in openings)
          OpeningStat(
            name: r.read<String>('name'),
            eco: r.read<String?>('eco'),
            asWhite: r.read<String>('side') == 'white',
            games: r.read<int>('n'),
            score: r.read<double?>('score'),
            accuracy: r.read<double?>('acc'),
          ),
      ],
    );
  }

  /// Games analysed but with no known user colour (can't be in the report).
  Future<int> gamesWithoutSide() async => (await _q('''
      SELECT COUNT(*) AS n FROM games g
      WHERE g.user_side IS NULL AND g.analyzed_at IS NOT NULL
    ''')).single.read<int>('n');
}

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(ref.watch(appDatabaseProvider)),
);
