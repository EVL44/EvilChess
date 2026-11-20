import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:evilchess/core/api/api_client.dart';
import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/core/engine/engine_service.dart';
import 'package:evilchess/core/settings/app_settings.dart';
import 'package:evilchess/features/analysis/data/analysis_runner.dart';
import 'package:evilchess/features/analysis/domain/opening_book.dart';
import 'package:evilchess/features/games/data/game_repository.dart';
import 'package:evilchess/features/games/domain/pgn_import.dart';
import 'package:evilchess/features/puzzles/data/puzzle_repository.dart';
import 'package:evilchess/features/reports/domain/report.dart';
import 'package:evilchess/features/sync/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_engine.dart';
import '../fakes/fake_server.dart';
import '../fixtures/pgns.dart';

/// One simulated device: its own database and preferences.
class Device {
  Device(this.server, this.prefs) : db = AppDatabase(NativeDatabase.memory());

  final FakeSyncServer server;
  final SharedPreferences prefs;
  final AppDatabase db;

  GameRepository get repo => GameRepository(db);

  SyncService get sync => SyncService(
    db,
    ApiClient(
      baseUrl: 'http://api',
      httpClient: server.client(),
      store: MemoryTokenStore()..tokens = const Tokens('a', 'r'),
    ),
    prefs,
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FakeSyncServer server;
  late Device a;
  late Device b;

  setUp(() async {
    server = FakeSyncServer(page: 3);
    // Separate prefs per device: mock values are global, so snapshot them.
    SharedPreferences.setMockInitialValues({});
    a = Device(server, await SharedPreferences.getInstance());
    b = Device(server, _SeparatePrefs());
  });
  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  test('a guest\'s games and analyses move to the account and to another '
      'device', () async {
    final game = parsePgnGames(chessComPgn).single;
    await a.repo.addGames([game], usernames: {'bob'});
    final engine = EngineService(() async => FakeUciTransport());
    await AnalysisRunner(
      repository: a.repo,
      engineService: engine,
      book: OpeningBook.empty(),
      depth: 6,
    ).run(game);
    await engine.dispose();
    await a.repo.addGames(parsePgnGames(lichessPgn));

    final pushed = await a.sync.sync('user-1');
    expect(pushed.pushed, 2);

    final pulled = await b.sync.sync('user-1');
    expect(pulled.pulled, 2);
    final summaries = await b.repo.watchSummaries().first;
    expect(summaries, hasLength(2));
    final copy = summaries.firstWhere((s) => s.id == game.id);
    expect(copy.analyzed, isTrue);
    expect(copy.userSide, 'black');
    expect((await b.repo.loadAnalysis(game.id))!.moves, hasLength(7));

    // Nothing new: nothing pushed or pulled.
    expect(await a.sync.sync('user-1'), (pushed: 0, pulled: 0));
  });

  test('deletions and colour changes travel; newer wins', () async {
    final games = parsePgnGames('$chessComPgn\n$lichessPgn');
    await a.repo.addGames(games);
    await a.sync.sync('u');
    await b.sync.sync('u');

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await b.repo.deleteGame(games.first.id);
    await b.repo.setUserSide(games.last.id, 'white');
    await b.sync.sync('u');
    await a.sync.sync('u');

    final left = await a.repo.watchSummaries().first;
    expect(left.map((g) => g.id), [games.last.id]);
    expect(left.single.userSide, 'white');
  });

  test(
    'server-side imports become local games with the user\'s colour',
    () async {
      server.put({
        'kind': 'import',
        'key': 'lichess:abcd1234',
        'payload': jsonEncode({
          'provider': 'lichess',
          'externalId': 'abcd1234',
          'url': 'https://lichess.org/abcd1234',
          'pgn': lichessPgn,
          'playedAt': 1760000000000,
          'speed': 'blitz',
          'username': 'Dave',
        }),
        'deleted': false,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });
      final r = await a.sync.sync('u');
      expect(r.pulled, 1);
      final games = await a.repo.watchSummaries().first;
      expect(games.single.id, 'lichess:abcd1234');
      expect(games.single.userSide, 'black');

      // A game deleted on purpose is not re-created by the import.
      await a.repo.deleteGame('lichess:abcd1234');
      await a.sync.sync('u');
      await b.sync.sync('u');
      expect(await b.repo.watchSummaries().first, isEmpty);
    },
  );

  test('puzzle progress and settings sync', () async {
    await a.repo.addGames(parsePgnGames(chessComPgn), usernames: {'bob'});
    final id = parsePgnGames(chessComPgn).single.id;
    await PuzzleRepository(a.db).recordAttempt(id, 5, solved: true);
    await a.prefs.setString(AppSettingsController.themeKey, 'dark');
    await a.prefs.setInt(
      AppSettingsController.updatedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    await a.sync.sync('u');
    await b.sync.sync('u');

    expect(b.prefs.getString(AppSettingsController.themeKey), 'dark');
    final attempts = await b.db.select(b.db.puzzleAttempts).get();
    expect(attempts.single.solved, isTrue);
    expect(attempts.single.ply, 5);
    expect(
      await PuzzleRepository(b.db).progress(PuzzleFilter.all),
      isA<PuzzleProgress>(),
    );
  });

  test('switching accounts on a device starts sync from scratch', () async {
    await a.repo.addGames(parsePgnGames(chessComPgn));
    await a.sync.sync('first');
    final before = server.requests;
    // Another account: everything is pushed again (to that account).
    final r = await a.sync.sync('second');
    expect(r.pushed, 1);
    expect(server.requests, greaterThan(before));
  });
}

/// A second, independent SharedPreferences for device B.
class _SeparatePrefs implements SharedPreferences {
  final _values = <String, Object>{};

  @override
  String? getString(String key) => _values[key] as String?;
  @override
  int? getInt(String key) => _values[key] as int?;
  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async => _values.remove(key) != null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
