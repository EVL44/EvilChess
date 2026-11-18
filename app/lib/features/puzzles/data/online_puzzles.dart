import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../account/account.dart';
import '../domain/lichess_puzzle.dart';

/// Result of a rated attempt.
typedef RatedResult = ({bool rated, int rating, int delta, bool provisional});

/// Puzzles from the server (Lichess database), plus an offline pack.
class OnlinePuzzles {
  OnlinePuzzles(this._api, this._db);

  final ApiClient _api;
  final AppDatabase _db;

  static const rushModes = ['3min', '5min', 'survival'];

  Future<LichessPuzzle> daily() async => LichessPuzzle.fromJson(
    await _api.send('GET', '/api/v1/puzzles/daily', auth: false)
        as Map<String, dynamic>,
  );

  Future<LichessPuzzle> next({String? theme}) async => LichessPuzzle.fromJson(
    await _api.get(
      '/api/v1/puzzles/next',
      query: theme == null ? null : {'theme': theme},
    ) as Map<String, dynamic>,
  );

  Future<RatedResult> attempt(String id, {required bool win}) async {
    final j = await _api.post('/api/v1/puzzles/$id/attempt', {
      'win': win,
    }) as Map<String, dynamic>;
    return (
      rated: j['rated'] as bool,
      rating: (j['rating'] as num).toInt(),
      delta: (j['delta'] as num).toInt(),
      provisional: j['provisional'] as bool? ?? false,
    );
  }

  /// Puzzles from easy to hard. Falls back to the offline pack when the
  /// server can't be reached; the second value says which was used.
  Future<(List<LichessPuzzle>, bool offline)> batch({
    int count = 40,
    int from = 600,
    int to = 2600,
  }) async {
    try {
      final list = await _api.send(
        'GET',
        '/api/v1/puzzles/batch',
        query: {'count': '$count', 'from': '$from', 'to': '$to'},
        auth: false,
      ) as List;
      return (
        [
          for (final j in list)
            LichessPuzzle.fromJson(j as Map<String, dynamic>),
        ],
        false,
      );
    } on ApiException catch (e) {
      if (!e.isNetwork) rethrow;
      final cached = await offlinePack(limit: count);
      if (cached.isEmpty) rethrow;
      return (cached, true);
    }
  }

  /// Downloads [count] puzzles for offline use. Returns how many are stored.
  Future<int> downloadPack({int count = 100}) async {
    final list = await _api.send(
      'GET',
      '/api/v1/puzzles/batch',
      query: {'count': '$count', 'from': '500', 'to': '2700'},
      auth: false,
    ) as List;
    final now = DateTime.now();
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(_db.cachedPuzzles, [
        for (final j in list.cast<Map<String, dynamic>>())
          CachedPuzzlesCompanion.insert(
            id: j['id'] as String,
            fen: j['fen'] as String,
            moves: (j['moves'] as List).join(' '),
            rating: (j['rating'] as num).toInt(),
            themes: (j['themes'] as List? ?? const []).join(' '),
            fetchedAt: now,
          ),
      ]);
    });
    return packSize();
  }

  Future<int> packSize() async {
    final count = _db.cachedPuzzles.id.count();
    final row = await (_db.selectOnly(
      _db.cachedPuzzles,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  /// A shuffled selection from the pack, easiest first.
  Future<List<LichessPuzzle>> offlinePack({int limit = 40}) async {
    final rows =
        await (_db.select(_db.cachedPuzzles)
              ..orderBy([(t) => OrderingTerm.random()])
              ..limit(limit))
            .get();
    rows.sort((a, b) => a.rating.compareTo(b.rating));
    return [
      for (final r in rows)
        LichessPuzzle(
          id: r.id,
          fen: r.fen,
          moves: r.moves.split(' '),
          rating: r.rating,
          themes: r.themes.isEmpty ? const [] : r.themes.split(' '),
        ),
    ];
  }

  Future<Map<String, int>> rushBests() async {
    final j = await _api.get('/api/v1/rush') as Map<String, dynamic>;
    return j.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  Future<({int best, bool newBest})> submitRush(String mode, int score) async {
    final j = await _api.post('/api/v1/rush', {
      'mode': mode,
      'score': score,
    }) as Map<String, dynamic>;
    return (best: (j['best'] as num).toInt(), newBest: j['newBest'] as bool);
  }
}

final onlinePuzzlesProvider = Provider<OnlinePuzzles>(
  (ref) => OnlinePuzzles(
    ref.watch(apiClientProvider),
    ref.watch(appDatabaseProvider),
  ),
);
