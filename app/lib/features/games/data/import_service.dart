import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/game_record.dart';
import '../domain/pgn_import.dart';
import 'game_repository.dart';
import 'online_import.dart';

/// Result of an import run.
typedef ImportResult = ({int fetched, int added});

class ImportService {
  ImportService(this._repo, this._client);

  final GameRepository _repo;
  final http.Client _client;

  /// Imports every game in [pgnText]. Throws [PgnImportException] when
  /// nothing in it is a playable game.
  Future<ImportResult> importPgn(String pgnText) async {
    final games = parsePgnGames(pgnText);
    if (games.isEmpty) {
      throw const PgnImportException('No playable game found in this PGN.');
    }
    final added = await _repo.addGames(
      games,
      usernames: await _repo.linkedUsernames(),
    );
    return (fetched: games.length, added: added);
  }

  /// Fetches games for the linked [provider] account that are newer than the
  /// last sync. Saves in batches so progress survives interruptions, and
  /// reports the number fetched so far through [onProgress].
  Future<ImportResult> sync(
    GameSource provider, {
    void Function(int fetched)? onProgress,
  }) async {
    final account = await _repo.account(provider);
    if (account == null) {
      throw ImportException('No ${provider.name} account linked');
    }
    final usernames = await _repo.linkedUsernames();
    final since = account.newestGameAt;

    final stream = switch (provider) {
      GameSource.lichess => LichessImporter(
        _client,
      ).fetchGames(account.username, since: since),
      GameSource.chesscom => ChessComImporter(
        _client,
      ).fetchGames(account.username, since: since),
      _ => throw ArgumentError('Cannot sync $provider'),
    };

    var fetched = 0;
    var added = 0;
    DateTime? newest = since;
    final batch = <GameRecord>[];

    Future<void> flush() async {
      if (batch.isEmpty) return;
      added += await _repo.addGames(batch, usernames: usernames);
      batch.clear();
      await _repo.markSynced(provider, newest);
    }

    await for (final game in stream) {
      fetched++;
      batch.add(game);
      final t = game.playedAt;
      if (t != null && (newest == null || t.isAfter(newest))) newest = t;
      if (batch.length >= 50) await flush();
      onProgress?.call(fetched);
    }
    await flush();
    await _repo.markSynced(provider, newest);
    return (fetched: fetched, added: added);
  }
}

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final importServiceProvider = Provider<ImportService>(
  (ref) => ImportService(
    ref.watch(gameRepositoryProvider),
    ref.watch(httpClientProvider),
  ),
);
