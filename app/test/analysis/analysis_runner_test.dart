import 'dart:io' as io;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/core/engine/engine_service.dart';
import 'package:evilchess/core/theme/move_classification.dart';
import 'package:evilchess/features/analysis/data/analysis_runner.dart';
import 'package:evilchess/features/analysis/domain/opening_book.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';
import 'package:evilchess/features/games/data/game_repository.dart';
import 'package:evilchess/features/games/domain/pgn_import.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_engine.dart';
import '../fixtures/pgns.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final book = OpeningBook.parse(
    io.File('assets/openings/book.tsv').readAsStringSync(),
  );

  test('the bundled opening book knows the main lines', () {
    expect(book.length, greaterThan(5000));
    final italian = parsePgnGames(lichessPgn).single;
    final name = book.identify(italian.plies.map((p) => fenKey(p.fenAfter)));
    expect(name?.name, contains('Italian'));
  });

  group('AnalysisRunner', () {
    late AppDatabase db;
    late GameRepository repo;
    late FakeUciTransport fake;
    late EngineService engine;
    final game = parsePgnGames(chessComPgn).single;
    // Positions: 0 start, 1 e4, 2 e5, 3 Qh5, 4 Nc6, 5 Bc4, 6 Nf6, 7 Qxf7#.
    String key(int i) =>
        fenKey(i == 0 ? game.initialFen : game.plies[i - 1].fenAfter);

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = GameRepository(db);
      fake = FakeUciTransport(
        script: {
          // After 3.Bc4 (Black to move): equal, best is g6 defending f7.
          key(5): (cp: -10, mate: null, best: 'g7g6', secondCp: -400),
          // After 3...Nf6?? White mates in one.
          key(6): (cp: null, mate: 1, best: 'h5f7', secondCp: 300),
        },
      );
      engine = EngineService(() async => fake);
    });
    tearDown(() async {
      await engine.dispose();
      await db.close();
    });

    test('classifies the blunder, finds the mate, saves results', () async {
      await repo.addGames([game]);
      final runner = AnalysisRunner(
        repository: repo,
        engineService: engine,
        book: book,
        depth: 12,
      );
      final progress = <int>[];
      final analysis = (await runner.run(
        game,
        onProgress: (done, total) => progress.add(done),
      ))!;

      expect(progress.last, 8);
      // Final position is checkmate: no search needed.
      expect(fake.searches, 7);

      final classes = analysis.moves.map((m) => m.classification).toList();
      expect(classes.take(2), everyElement(MoveClass.book)); // 1.e4 e5
      expect(classes[5], MoveClass.blunder); // 3...Nf6??
      expect(
        classes[6],
        anyOf(MoveClass.best, MoveClass.great), // 4.Qxf7#
      );
      expect(analysis.moves[5].bestSan, 'g6');
      expect(analysis.moves[5].bestLineSan.first, 'g6');
      expect(analysis.blackAccuracy, lessThan(analysis.whiteAccuracy!));

      // Persisted and reloadable.
      final loaded = (await repo.loadAnalysis(game.id))!;
      expect(loaded.moves[5].classification, MoveClass.blunder);
      expect(loaded.whiteEvals, hasLength(8));
      final summary = (await repo.watchSummaries().first).single;
      expect(summary.analyzed, isTrue);
      expect(summary.blackAccuracy, isNotNull);
    });

    test('second run is served from the position cache', () async {
      await repo.addGames([game]);
      final runner = AnalysisRunner(
        repository: repo,
        engineService: engine,
        book: book,
        depth: 12,
      );
      await runner.run(game);
      final first = fake.searches;
      await runner.run(game);
      expect(fake.searches, first, reason: 'no new engine searches');

      // A deeper request misses the cache.
      final deeper = AnalysisRunner(
        repository: repo,
        engineService: engine,
        book: book,
        depth: 20,
      );
      await deeper.run(game);
      expect(fake.searches, greaterThan(first));
    });

    test('cancelling saves nothing', () async {
      await repo.addGames([game]);
      final runner = AnalysisRunner(
        repository: repo,
        engineService: engine,
        book: book,
        depth: 12,
      );
      var calls = 0;
      final result = await runner.run(game, isCancelled: () => ++calls > 3);
      expect(result, isNull);
      expect(await repo.loadAnalysis(game.id), isNull);
    });
  });
}
