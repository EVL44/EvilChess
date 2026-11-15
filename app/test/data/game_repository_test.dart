import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/features/analysis/domain/evaluation.dart';
import 'package:evilchess/features/analysis/domain/game_analysis.dart';
import 'package:evilchess/features/games/data/game_repository.dart';
import 'package:evilchess/features/games/domain/game_record.dart';
import 'package:evilchess/features/games/domain/pgn_import.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/pgns.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late GameRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = GameRepository(db);
  });
  tearDown(() => db.close());

  test('adds games once and marks the user side', () async {
    final games = parsePgnGames('$chessComPgn\n$lichessPgn');
    expect(await repo.addGames(games, usernames: {'alice'}), 2);
    expect(await repo.addGames(games), 0, reason: 'duplicates are ignored');

    final list = await repo.watchSummaries().first;
    // Newest first: Lichess game is 2026-10-02.
    expect(list.map((g) => g.white), ['carol', 'Alice']);
    expect(list.last.userSide, 'white');
    expect(list.first.userSide, isNull);
  });

  test('round-trips a full game', () async {
    final game = parsePgnGames(lichessPgn).single;
    await repo.addGames([game]);
    final loaded = (await repo.getGame(game.id))!;
    expect(loaded.plies.map((p) => p.san), game.plies.map((p) => p.san));
    expect(loaded.plies[2].clock, game.plies[2].clock);
    expect(loaded.timeControl, const TimeControl(300, 0));
    expect(loaded.speed, GameSpeed.blitz);
  });

  test('position cache honours depth and multipv', () async {
    const key = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -';
    const eval = PositionEval(
      eval: Eval.cp(25),
      depth: 18,
      bestUci: 'e2e4',
      pv: ['e2e4', 'e7e5'],
      secondEval: Eval.cp(15),
    );
    await repo.cacheEval(key, 2, eval);

    final hit = await repo.cachedEval(key, multiPv: 2, minDepth: 16);
    expect(hit!.eval, const Eval.cp(25));
    expect(hit.pv, ['e2e4', 'e7e5']);
    expect(hit.secondEval, const Eval.cp(15));
    // Deeper than cached → miss. MultiPV 1 request is served by MultiPV 2.
    expect(await repo.cachedEval(key, multiPv: 2, minDepth: 20), isNull);
    expect(await repo.cachedEval(key, multiPv: 1, minDepth: 10), isNotNull);
    expect(await repo.cachedEval(key, multiPv: 3, minDepth: 10), isNull);
  });

  test('linked accounts: relinking another user resets the cursor', () async {
    await repo.linkAccount(GameSource.lichess, 'carol');
    await repo.markSynced(GameSource.lichess, DateTime.utc(2026, 10));
    expect((await repo.account(GameSource.lichess))!.newestGameAt, isNotNull);

    await repo.linkAccount(GameSource.lichess, 'Carol'); // same user
    expect((await repo.account(GameSource.lichess))!.newestGameAt, isNotNull);

    await repo.linkAccount(GameSource.lichess, 'someoneelse');
    expect((await repo.account(GameSource.lichess))!.newestGameAt, isNull);
    expect(await repo.linkedUsernames(), {'someoneelse'});
  });
}
