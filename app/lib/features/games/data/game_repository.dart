import 'dart:convert';

import 'package:dartchess/dartchess.dart' show Role;
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/theme/move_classification.dart';
import '../../analysis/domain/evaluation.dart';
import '../../analysis/domain/game_analysis.dart';
import '../../analysis/domain/material.dart';
import '../../analysis/domain/motifs.dart';
import '../domain/game_record.dart';

/// Lightweight row for the game library list.
@immutable
class GameSummary {
  const GameSummary({
    required this.id,
    required this.source,
    required this.white,
    required this.black,
    required this.result,
    required this.speed,
    this.whiteElo,
    this.blackElo,
    this.playedAt,
    this.opening,
    this.userSide,
    this.whiteAccuracy,
    this.blackAccuracy,
    this.analyzed = false,
  });

  final String id;
  final GameSource source;
  final String white;
  final String black;
  final int? whiteElo;
  final int? blackElo;
  final String result;
  final GameSpeed speed;
  final DateTime? playedAt;
  final String? opening;

  /// 'white' / 'black' when the game belongs to a linked account.
  final String? userSide;
  final double? whiteAccuracy;
  final double? blackAccuracy;
  final bool analyzed;
}

/// Linked Lichess / Chess.com account.
@immutable
class LinkedAccount {
  const LinkedAccount({
    required this.provider,
    required this.username,
    this.lastSyncedAt,
    this.newestGameAt,
  });

  final GameSource provider;
  final String username;
  final DateTime? lastSyncedAt;
  final DateTime? newestGameAt;
}

/// Bump when classification / motif rules change so stored analyses are
/// refreshed (without re-running the engine) by [GameRepository.upgradeAnalyses].
const kAnalysisVersion = 2;

class GameRepository {
  GameRepository(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------- games

  /// Inserts games that are not stored yet. Returns how many were new.
  /// [usernames] (lower-case) mark which side the user played.
  Future<int> addGames(
    List<GameRecord> games, {
    Set<String> usernames = const {},
  }) async {
    if (games.isEmpty) return 0;
    final ids = games.map((g) => g.id).toList();
    final existing =
        await (_db.selectOnly(_db.games)
              ..addColumns([_db.games.id])
              ..where(_db.games.id.isIn(ids)))
            .map((r) => r.read(_db.games.id)!)
            .get();
    final known = existing.toSet();
    final fresh = games.where((g) => !known.contains(g.id)).toList();
    final now = DateTime.now();
    await _db.batch((b) {
      b.insertAll(_db.games, [
        for (final g in fresh) _toCompanion(g, now, usernames),
      ], mode: InsertMode.insertOrIgnore);
      // Re-adding a game cancels an earlier deletion.
      b.deleteWhere(_db.deletedGames, (t) => t.id.isIn(fresh.map((g) => g.id)));
    });
    return fresh.length;
  }

  GamesCompanion _toCompanion(
    GameRecord g,
    DateTime now,
    Set<String> usernames,
  ) {
    String? side;
    if (usernames.contains(g.white.toLowerCase())) side = 'white';
    if (usernames.contains(g.black.toLowerCase())) side = 'black';
    return GamesCompanion.insert(
      id: g.id,
      source: g.source.name,
      externalId: Value(g.externalId),
      url: Value(g.url),
      white: g.white,
      black: g.black,
      whiteElo: Value(g.whiteElo),
      blackElo: Value(g.blackElo),
      result: g.result,
      playedAt: Value(g.playedAt),
      timeControl: Value(g.timeControl?.toString()),
      speed: g.speed.name,
      eco: Value(g.eco),
      opening: Value(g.opening),
      event: Value(g.event),
      initialFen: g.initialFen,
      pliesJson: jsonEncode([for (final p in g.plies) p.toJson()]),
      pgn: g.pgn,
      userSide: Value(side),
      importedAt: now,
      updatedAt: Value(now.millisecondsSinceEpoch),
    );
  }

  /// All games, newest first.
  Stream<List<GameSummary>> watchSummaries() {
    final q = _db.select(_db.games)
      ..orderBy([
        (t) => OrderingTerm(
          expression: coalesce([t.playedAt, t.importedAt]),
          mode: OrderingMode.desc,
        ),
      ]);
    return q.watch().map((rows) => rows.map(_summary).toList());
  }

  GameSummary _summary(GameRow r) => GameSummary(
    id: r.id,
    source: GameSource.values.byName(r.source),
    white: r.white,
    black: r.black,
    whiteElo: r.whiteElo,
    blackElo: r.blackElo,
    result: r.result,
    speed: GameSpeed.fromName(r.speed),
    playedAt: r.playedAt,
    opening: r.opening,
    userSide: r.userSide,
    whiteAccuracy: r.whiteAccuracy,
    blackAccuracy: r.blackAccuracy,
    analyzed: r.analyzedAt != null,
  );

  Future<GameRecord?> getGame(String id) async {
    final r = await (_db.select(
      _db.games,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (r == null) return null;
    final plies = (jsonDecode(r.pliesJson) as List)
        .map((e) => GamePly.fromJson((e as Map).cast<String, Object?>()))
        .toList();
    return GameRecord(
      id: r.id,
      source: GameSource.values.byName(r.source),
      externalId: r.externalId,
      url: r.url,
      white: r.white,
      black: r.black,
      whiteElo: r.whiteElo,
      blackElo: r.blackElo,
      result: r.result,
      playedAt: r.playedAt,
      timeControl: TimeControl.parse(r.timeControl),
      speed: GameSpeed.fromName(r.speed),
      eco: r.eco,
      opening: r.opening,
      event: r.event,
      initialFen: r.initialFen,
      plies: plies,
      pgn: r.pgn,
    );
  }

  /// Deletes a game here and remembers the deletion for sync.
  Future<void> deleteGame(String id) => _db.transaction(() async {
    await (_db.delete(_db.games)..where((t) => t.id.equals(id))).go();
    await _db
        .into(_db.deletedGames)
        .insertOnConflictUpdate(
          DeletedGamesCompanion.insert(
            id: id,
            deletedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  });

  // ------------------------------------------------------------- analysis

  /// Saves an analysis. [fenBefore] (one FEN per ply) lets puzzles start
  /// from each position without re-reading the game.
  Future<void> saveAnalysis(
    String gameId,
    GameAnalysis analysis, {
    required int depth,
    List<String>? fenBefore,
  }) => _db.transaction(() async {
    await (_db.delete(
      _db.moveAnalyses,
    )..where((t) => t.gameId.equals(gameId))).go();
    await _db.batch((b) {
      b.insertAll(_db.moveAnalyses, [
        for (final m in analysis.moves)
          MoveAnalysesCompanion.insert(
            gameId: gameId,
            ply: m.ply,
            whiteMoved: m.whiteMoved,
            san: m.san,
            uci: m.uci,
            classification: m.classification.name,
            accuracy: m.accuracy,
            winBefore: m.winBefore,
            winAfter: m.winAfter,
            evalBefore: jsonEncode(m.evalBefore.toJson()),
            evalAfter: jsonEncode(m.evalAfter.toJson()),
            bestUci: Value(m.bestUci),
            bestSan: Value(m.bestSan),
            bestLine: Value(
              m.bestLineSan.isEmpty ? null : m.bestLineSan.join(' '),
            ),
            phase: m.phase.name,
            piece: m.piece.name,
            clockMs: Value(m.clock?.inMilliseconds),
            fenBefore: Value(fenBefore?.elementAtOrNull(m.ply)),
            motifs: Value(
              m.motifs.isEmpty ? null : m.motifs.map((x) => x.name).join(','),
            ),
            opportunity: Value(m.opportunity?.name),
            category: Value(m.category?.name),
          ),
      ]);
    });
    await (_db.update(_db.games)..where((t) => t.id.equals(gameId))).write(
      GamesCompanion(
        analyzedAt: Value(DateTime.now()),
        analysisDepth: Value(depth),
        analysisVersion: const Value(kAnalysisVersion),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        whiteAccuracy: Value(analysis.whiteAccuracy),
        blackAccuracy: Value(analysis.blackAccuracy),
        // Fill in the opening when the source PGN had none.
        eco: analysis.opening == null
            ? const Value.absent()
            : Value(analysis.opening!.eco),
        opening: analysis.opening == null
            ? const Value.absent()
            : Value(analysis.opening!.name),
      ),
    );
  });

  Future<GameAnalysis?> loadAnalysis(String gameId) async {
    final game = await (_db.select(
      _db.games,
    )..where((t) => t.id.equals(gameId))).getSingleOrNull();
    if (game == null || game.analyzedAt == null) return null;
    final rows =
        await (_db.select(_db.moveAnalyses)
              ..where((t) => t.gameId.equals(gameId))
              ..orderBy([(t) => OrderingTerm.asc(t.ply)]))
            .get();
    if (rows.isEmpty) return null;
    Eval eval(String s) =>
        Eval.fromJson((jsonDecode(s) as Map).cast<String, Object?>());
    final moves = [
      for (final r in rows)
        MoveAnalysis(
          ply: r.ply,
          san: r.san,
          uci: r.uci,
          whiteMoved: r.whiteMoved,
          classification: MoveClass.values.byName(r.classification),
          accuracy: r.accuracy,
          winBefore: r.winBefore,
          winAfter: r.winAfter,
          evalBefore: eval(r.evalBefore),
          evalAfter: eval(r.evalAfter),
          phase: GamePhase.values.byName(r.phase),
          piece: Role.values.byName(r.piece),
          bestUci: r.bestUci,
          bestSan: r.bestSan,
          bestLineSan: r.bestLine?.split(' ') ?? const [],
          clock: r.clockMs == null ? null : Duration(milliseconds: r.clockMs!),
          motifs: [
            for (final name in (r.motifs ?? '').split(','))
              if (name.isNotEmpty) Motif.values.byName(name),
          ],
          opportunity: r.opportunity == null
              ? null
              : TacticTheme.values.byName(r.opportunity!),
          category: r.category == null
              ? null
              : ErrorCategory.values.byName(r.category!),
        ),
    ];
    return GameAnalysis(
      moves: moves,
      whiteAccuracy: game.whiteAccuracy,
      blackAccuracy: game.blackAccuracy,
      whiteEvals: [moves.first.evalBefore, for (final m in moves) m.evalAfter],
      opening: game.eco == null || game.opening == null
          ? null
          : (eco: game.eco!, name: game.opening!),
    );
  }

  /// Re-derives motifs for games analysed with older rules. Needs no engine:
  /// everything is recomputed from the stored evals and best moves.
  /// Returns how many games were upgraded.
  Future<int> upgradeAnalyses() async {
    final stale =
        await (_db.select(_db.games)..where(
              (t) =>
                  t.analyzedAt.isNotNull() &
                  t.analysisVersion.isSmallerThanValue(kAnalysisVersion),
            ))
            .get();
    for (final row in stale) {
      final game = await getGame(row.id);
      final analysis = await loadAnalysis(row.id);
      if (game == null ||
          analysis == null ||
          analysis.moves.length != game.plies.length) {
        continue;
      }
      final motifs = annotateMotifs(game, analysis.moves);
      final upgraded = GameAnalysis(
        moves: [
          for (var i = 0; i < analysis.moves.length; i++)
            analysis.moves[i].withMotifs(motifs[i]),
        ],
        whiteAccuracy: analysis.whiteAccuracy,
        blackAccuracy: analysis.blackAccuracy,
        whiteEvals: analysis.whiteEvals,
        opening: analysis.opening,
      );
      await saveAnalysis(
        row.id,
        upgraded,
        depth: row.analysisDepth ?? 0,
        fenBefore: [for (final p in game.plies) p.fenBefore],
      );
    }
    return stale.length;
  }

  /// Marks which colour the user played in a game (null = unknown).
  Future<void> setUserSide(String gameId, String? side) =>
      (_db.update(_db.games)..where((t) => t.id.equals(gameId))).write(
        GamesCompanion(
          userSide: Value(side),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<String?> userSide(String gameId) async {
    final r = await (_db.select(
      _db.games,
    )..where((t) => t.id.equals(gameId))).getSingleOrNull();
    return r?.userSide;
  }

  /// Ids of games that have not been analysed yet, newest first.
  Future<List<String>> unanalyzedGameIds() async {
    final q = _db.selectOnly(_db.games)
      ..addColumns([_db.games.id])
      ..where(_db.games.analyzedAt.isNull())
      ..orderBy([
        OrderingTerm(
          expression: coalesce([_db.games.playedAt, _db.games.importedAt]),
          mode: OrderingMode.desc,
        ),
      ]);
    return q.map((r) => r.read(_db.games.id)!).get();
  }

  // -------------------------------------------------------- position cache

  /// A cached result for [fenKey] searched to at least [minDepth].
  Future<PositionEval?> cachedEval(
    String fenKey, {
    required int multiPv,
    required int minDepth,
  }) async {
    final row =
        await (_db.select(_db.positionEvals)
              ..where(
                (t) =>
                    t.fenKey.equals(fenKey) &
                    t.multiPv.isBiggerOrEqualValue(multiPv) &
                    t.depth.isBiggerOrEqualValue(minDepth),
              )
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return PositionEval.fromJson(
      (jsonDecode(row.json) as Map).cast<String, Object?>(),
    );
  }

  Future<void> cacheEval(String fenKey, int multiPv, PositionEval eval) => _db
      .into(_db.positionEvals)
      .insertOnConflictUpdate(
        PositionEvalsCompanion.insert(
          fenKey: fenKey,
          multiPv: multiPv,
          depth: eval.depth,
          json: jsonEncode(eval.toJson()),
          updatedAt: DateTime.now(),
        ),
      );

  // ------------------------------------------------------ linked accounts

  Stream<List<LinkedAccount>> watchAccounts() => _db
      .select(_db.linkedAccounts)
      .watch()
      .map((rows) => rows.map(_account).toList());

  Future<LinkedAccount?> account(GameSource provider) async {
    final r = await (_db.select(
      _db.linkedAccounts,
    )..where((t) => t.provider.equals(provider.name))).getSingleOrNull();
    return r == null ? null : _account(r);
  }

  LinkedAccount _account(LinkedAccountRow r) => LinkedAccount(
    provider: GameSource.values.byName(r.provider),
    username: r.username,
    lastSyncedAt: r.lastSyncedAt,
    newestGameAt: r.newestGameAt,
  );

  /// Links (or re-links) an account. Changing the username resets the sync
  /// cursor so the new account is imported from the start.
  Future<void> linkAccount(GameSource provider, String username) async {
    final current = await account(provider);
    final same = current?.username.toLowerCase() == username.toLowerCase();
    await _db
        .into(_db.linkedAccounts)
        .insertOnConflictUpdate(
          LinkedAccountsCompanion.insert(
            provider: provider.name,
            username: username,
            lastSyncedAt: Value(same ? current!.lastSyncedAt : null),
            newestGameAt: Value(same ? current!.newestGameAt : null),
          ),
        );
  }

  Future<void> unlinkAccount(GameSource provider) => (_db.delete(
    _db.linkedAccounts,
  )..where((t) => t.provider.equals(provider.name))).go();

  Future<void> markSynced(GameSource provider, DateTime? newestGameAt) async {
    await (_db.update(
      _db.linkedAccounts,
    )..where((t) => t.provider.equals(provider.name))).write(
      LinkedAccountsCompanion(
        lastSyncedAt: Value(DateTime.now()),
        newestGameAt: newestGameAt == null
            ? const Value.absent()
            : Value(newestGameAt),
      ),
    );
  }

  Future<Set<String>> linkedUsernames() async {
    final rows = await _db.select(_db.linkedAccounts).get();
    return rows.map((r) => r.username.toLowerCase()).toSet();
  }
}

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepository(ref.watch(appDatabaseProvider)),
);
