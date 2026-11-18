import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/api_client.dart';
import '../../core/db/app_database.dart';
import '../../core/db/database_provider.dart';
import '../../core/settings/app_settings.dart';
import '../account/account.dart';
import '../games/domain/game_record.dart';
import '../games/domain/pgn_import.dart';

typedef SyncResult = ({int pushed, int pulled});

/// Keeps this device's library in step with the account on the server.
///
/// Push: every game, deletion and puzzle attempt changed since the last
/// push (the first sync after signing in pushes everything — that is how a
/// guest's data moves into a new account). Pull: everything the server
/// stored after our cursor, applied when newer than what we have. Games
/// imported by the server arrive as "import" items holding a PGN.
class SyncService {
  SyncService(this._db, this._api, this._prefs);

  final AppDatabase _db;
  final ApiClient _api;
  final SharedPreferences _prefs;

  static const _kUser = 'sync.userId';
  static const _kCursor = 'sync.cursor';
  static const _kLastPush = 'sync.lastPushAt';
  static const _kLastSync = 'sync.lastSyncAt';

  DateTime? get lastSyncAt {
    final ms = _prefs.getInt(_kLastSync);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<SyncResult> sync(String userId) async {
    // A different account on this device starts from scratch.
    if (_prefs.getString(_kUser) != userId) {
      await _prefs.setString(_kUser, userId);
      await _prefs.remove(_kCursor);
      await _prefs.remove(_kLastPush);
    }
    final started = DateTime.now();
    final lastPushMs = _prefs.getInt(_kLastPush);
    final lastPush = lastPushMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(lastPushMs);

    final changes = await _localChanges(lastPush);
    var cursor = _prefs.getInt(_kCursor) ?? 0;
    var pulled = 0;
    var first = true;
    var i = 0;
    // Push in chunks; each response also carries a page of remote changes.
    while (first || i < changes.length) {
      first = false;
      final chunk = changes.skip(i).take(200).toList();
      i += chunk.length;
      var more = true;
      while (more) {
        final res = await _api.post('/api/v1/sync', {
          'since': cursor,
          'changes': chunk,
        }) as Map<String, dynamic>;
        chunk.clear();
        for (final c in (res['changes'] as List).cast<Map<String, dynamic>>()) {
          if (await _apply(c)) pulled++;
        }
        cursor = (res['cursor'] as num).toInt();
        more = res['hasMore'] as bool? ?? false;
        await _prefs.setInt(_kCursor, cursor);
      }
    }
    await _prefs.setInt(_kLastPush, started.millisecondsSinceEpoch);
    await _prefs.setInt(_kLastSync, DateTime.now().millisecondsSinceEpoch);
    return (pushed: changes.length, pulled: pulled);
  }

  // --------------------------------------------------------------- push

  Future<List<Map<String, Object?>>> _localChanges(DateTime? since) async {
    final out = <Map<String, Object?>>[];
    final sinceMs = since?.millisecondsSinceEpoch;
    final games =
        await (_db.select(_db.games)..where(
              (t) => sinceMs == null
                  ? const Constant(true)
                  // Rows from before sync existed have no updatedAt: use
                  // their import time (seconds → ms).
                  : coalesce([
                      t.updatedAt,
                      t.importedAt.unixepoch * const Constant(1000),
                    ]).isBiggerThanValue(sinceMs),
            ))
            .get();
    for (final g in games) {
      final moves = await (_db.select(
        _db.moveAnalyses,
      )..where((t) => t.gameId.equals(g.id))).get();
      out.add({
        'kind': 'game',
        'key': _key(g.id),
        'payload': jsonEncode({
          'game': g.toJson(),
          'moves': [for (final m in moves) m.toJson()],
        }),
        'deleted': false,
        'updatedAt': _iso(_changedAt(g)),
      });
    }

    final deleted =
        await (_db.select(_db.deletedGames)..where(
              (t) => sinceMs == null
                  ? const Constant(true)
                  : t.deletedAt.isBiggerThanValue(sinceMs),
            ))
            .get();
    for (final d in deleted) {
      out.add({
        'kind': 'game',
        'key': _key(d.id),
        'deleted': true,
        'updatedAt': _iso(DateTime.fromMillisecondsSinceEpoch(d.deletedAt)),
      });
    }

    final attempts =
        await (_db.select(_db.puzzleAttempts)..where(
              (t) => since == null
                  ? const Constant(true)
                  : t.lastAttemptAt.isBiggerThanValue(since),
            ))
            .get();
    for (final a in attempts) {
      out.add({
        'kind': 'puzzleAttempt',
        'key': _key('${a.gameId}#${a.ply}'),
        'payload': jsonEncode(a.toJson()),
        'deleted': false,
        'updatedAt': _iso(a.lastAttemptAt),
      });
    }

    final settingsAt = _prefs.getInt(AppSettingsController.updatedAtKey);
    if (settingsAt != null &&
        (since == null || settingsAt > since.millisecondsSinceEpoch)) {
      out.add({
        'kind': 'settings',
        'key': 'app',
        'payload': jsonEncode({
          'themeMode': _prefs.getString(AppSettingsController.themeKey),
          'locale': _prefs.getString(AppSettingsController.localeKey),
        }),
        'deleted': false,
        'updatedAt': _iso(DateTime.fromMillisecondsSinceEpoch(settingsAt)),
      });
    }
    return out;
  }

  // --------------------------------------------------------------- pull

  /// Applies one remote change; returns true when something changed here.
  Future<bool> _apply(Map<String, dynamic> c) async {
    final kind = c['kind'] as String;
    final key = _unkey(c['key'] as String);
    final at = DateTime.parse(c['updatedAt'] as String).toLocal();
    final deleted = c['deleted'] as bool? ?? false;
    final payload = c['payload'] as String?;

    switch (kind) {
      case 'game':
        final local = await (_db.select(
          _db.games,
        )..where((t) => t.id.equals(key))).getSingleOrNull();
        final localAt = local == null ? null : _changedAt(local);
        if (localAt != null && !at.isAfter(localAt)) return false;
        if (deleted) {
          if (local == null) return false;
          await (_db.delete(_db.games)..where((t) => t.id.equals(key))).go();
          return true;
        }
        final data = jsonDecode(payload!) as Map<String, dynamic>;
        final row = GameRow.fromJson(data['game'] as Map<String, dynamic>)
            .copyWith(updatedAt: Value(at.millisecondsSinceEpoch));
        await _db.transaction(() async {
          await _db.into(_db.games).insertOnConflictUpdate(row);
          await (_db.delete(
            _db.moveAnalyses,
          )..where((t) => t.gameId.equals(key))).go();
          await _db.batch(
            (b) => b.insertAll(_db.moveAnalyses, [
              for (final m in (data['moves'] as List))
                MoveAnalysisRow.fromJson(m as Map<String, dynamic>),
            ]),
          );
          await (_db.delete(
            _db.deletedGames,
          )..where((t) => t.id.equals(key))).go();
        });
        return true;

      case 'import':
        if (deleted || payload == null) return false;
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final provider = data['provider'] as String;
        final source = provider == 'lichess'
            ? GameSource.lichess
            : GameSource.chesscom;
        final game = parseSinglePgn(
          data['pgn'] as String,
          source: source,
          externalId: data['externalId'] as String,
          url: data['url'] as String?,
        );
        if (game == null) return false;
        final exists = await (_db.select(
          _db.games,
        )..where((t) => t.id.equals(game.id))).getSingleOrNull();
        if (exists != null) return false;
        final tombstone = await (_db.select(
          _db.deletedGames,
        )..where((t) => t.id.equals(game.id))).getSingleOrNull();
        if (tombstone != null) return false; // deleted on purpose here
        final username = (data['username'] as String? ?? '').toLowerCase();
        final playedAt = data['playedAt'] == null
            ? game.playedAt
            : DateTime.fromMillisecondsSinceEpoch(
                (data['playedAt'] as num).toInt(),
                isUtc: true,
              );
        await _db
            .into(_db.games)
            .insert(
              GamesCompanion.insert(
                id: game.id,
                source: game.source.name,
                externalId: Value(game.externalId),
                url: Value(game.url),
                white: game.white,
                black: game.black,
                whiteElo: Value(game.whiteElo),
                blackElo: Value(game.blackElo),
                result: game.result,
                playedAt: Value(playedAt),
                timeControl: Value(game.timeControl?.toString()),
                speed:
                    GameSpeed.fromName(data['speed'] as String?) ==
                        GameSpeed.unknown
                    ? game.speed.name
                    : GameSpeed.fromName(data['speed'] as String?).name,
                eco: Value(game.eco),
                opening: Value(game.opening),
                event: Value(game.event),
                initialFen: game.initialFen,
                pliesJson: jsonEncode([for (final p in game.plies) p.toJson()]),
                pgn: game.pgn,
                userSide: Value(
                  game.white.toLowerCase() == username
                      ? 'white'
                      : game.black.toLowerCase() == username
                      ? 'black'
                      : null,
                ),
                importedAt: at,
                updatedAt: Value(at.millisecondsSinceEpoch),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        return true;

      case 'puzzleAttempt':
        if (deleted || payload == null) return false;
        final row = PuzzleAttemptRow.fromJson(
          jsonDecode(payload) as Map<String, dynamic>,
        );
        final game = await (_db.select(
          _db.games,
        )..where((t) => t.id.equals(row.gameId))).getSingleOrNull();
        if (game == null) return false; // its game hasn't arrived (yet)
        final local =
            await (_db.select(_db.puzzleAttempts)..where(
                  (t) => t.gameId.equals(row.gameId) & t.ply.equals(row.ply),
                ))
                .getSingleOrNull();
        if (local != null && !row.lastAttemptAt.isAfter(local.lastAttemptAt)) {
          return false;
        }
        await _db.into(_db.puzzleAttempts).insertOnConflictUpdate(row);
        return true;

      case 'settings':
        if (deleted || payload == null) return false;
        final local = _prefs.getInt(AppSettingsController.updatedAtKey);
        if (local != null && local >= at.millisecondsSinceEpoch) return false;
        final data = jsonDecode(payload) as Map<String, dynamic>;
        await _setOrRemove(AppSettingsController.themeKey, data['themeMode']);
        await _setOrRemove(AppSettingsController.localeKey, data['locale']);
        await _prefs.setInt(
          AppSettingsController.updatedAtKey,
          at.millisecondsSinceEpoch,
        );
        return true;
    }
    return false;
  }

  Future<void> _setOrRemove(String key, Object? value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else {
      await _prefs.remove(key);
    }
  }

  /// Keys may only contain `[\w:.-]`; game ids like `pgn:<hash>` already do,
  /// but `#` (puzzle attempts) is mapped to `.`.
  static String _key(String id) => id.replaceAll('#', '..');
  static String _unkey(String key) => key.replaceAll('..', '#');

  static String _iso(DateTime t) => t.toUtc().toIso8601String();

  static DateTime _changedAt(GameRow g) => g.updatedAt == null
      ? g.importedAt
      : DateTime.fromMillisecondsSinceEpoch(g.updatedAt!);
}

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);
