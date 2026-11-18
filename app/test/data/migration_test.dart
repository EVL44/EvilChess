import 'dart:io' as io;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/core/engine/engine_service.dart';
import 'package:evilchess/features/analysis/data/analysis_runner.dart';
import 'package:evilchess/features/analysis/domain/motifs.dart';
import 'package:evilchess/features/analysis/domain/opening_book.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';
import 'package:evilchess/features/games/data/game_repository.dart';
import 'package:evilchess/features/games/domain/pgn_import.dart';
import 'package:evilchess/features/puzzles/data/puzzle_repository.dart';
import 'package:evilchess/features/reports/data/report_repository.dart';
import 'package:evilchess/features/reports/domain/report.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_engine.dart';
import '../fixtures/pgns.dart';

/// Opening a database written by the Phase 1 app (schema 1) must upgrade it
/// in place: new columns and table added, analyses re-derived, nothing lost.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('schema 1 database upgrades to schema 2 with data intact', () async {
    final dir = io.Directory.systemTemp.createTempSync('evilchess-migration');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = io.File('${dir.path}/evilchess.sqlite');

    // 1. Write a database with an analysed game using the current code.
    final game = parsePgnGames(chessComPgn).single;
    String key(int i) =>
        fenKey(i == 0 ? game.initialFen : game.plies[i - 1].fenAfter);
    var db = AppDatabase(NativeDatabase(file));
    var repo = GameRepository(db);
    await repo.addGames([game], usernames: {'bob'});
    final engine = EngineService(
      () async => FakeUciTransport(
        script: {
          key(5): (cp: -10, mate: null, best: 'g7g6', secondCp: -400),
          key(6): (cp: null, mate: 1, best: 'h5f7', secondCp: 300),
        },
      ),
    );
    await AnalysisRunner(
      repository: repo,
      engineService: engine,
      book: OpeningBook.empty(),
      depth: 8,
    ).run(game);
    await engine.dispose();
    await db.close();

    // 2. Turn it into what Phase 1 left on disk, then 3. reopen it.
    db = AppDatabase(
      NativeDatabase(
        file,
        setup: (raw) {
          if (raw.select('PRAGMA user_version').first.values.first == 1) {
            return;
          }
          raw
            ..execute('DROP TABLE puzzle_attempts')
            ..execute('ALTER TABLE games DROP COLUMN analysis_version');
          for (final c in ['fen_before', 'motifs', 'opportunity', 'category']) {
            raw.execute('ALTER TABLE move_analyses DROP COLUMN $c');
          }
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(db.close);
    repo = GameRepository(db);

    // Old data is still readable.
    final summaries = await repo.watchSummaries().first;
    expect(summaries.single.analyzed, isTrue);
    expect(summaries.single.userSide, 'black');
    expect(await ReportRepository(db).build().then((r) => r.totalErrors), 0);

    // The engine-free upgrade restores motifs, categories and puzzles.
    expect(await repo.upgradeAnalyses(), 1);
    final analysis = (await repo.loadAnalysis(game.id))!;
    expect(analysis.moves[5].motifs, contains(Motif.walkedIntoMate));
    final report = await ReportRepository(db).build();
    expect(report.errorsByCategory[ErrorCategory.mate], 1);
    final puzzles = await PuzzleRepository(db).puzzles(PuzzleFilter.all);
    expect(puzzles.single.playedSan, 'Nf6');

    // The new table works.
    await PuzzleRepository(db)
        .recordAttempt(game.id, puzzles.single.ply, solved: true);
    expect(await PuzzleRepository(db).progress(PuzzleFilter.all), (
      total: 1,
      solved: 1,
    ));
  });
}
