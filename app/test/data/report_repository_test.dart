import 'package:dartchess/dartchess.dart' show Role;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/core/engine/engine_service.dart';
import 'package:evilchess/features/analysis/data/analysis_runner.dart';
import 'package:evilchess/features/analysis/domain/material.dart';
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

const hungQueenPgn = '''
[White "someone"]
[Black "bob"]
[Result "1-0"]
[Date "2026.10.05"]
[TimeControl "600"]

1. d4 e5 2. dxe5 Qg5 3. Bxg5 1-0
''';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late GameRepository repo;

  /// Imports [pgn] as bob's game and analyses it with scripted evals.
  Future<String> addAnalysed(String pgn, Map<int, FakeLine> script) async {
    final game = parsePgnGames(pgn).single;
    String key(int i) =>
        fenKey(i == 0 ? game.initialFen : game.plies[i - 1].fenAfter);
    await repo.addGames([game], usernames: {'bob'});
    final engine = EngineService(
      () async => FakeUciTransport(
        script: {for (final e in script.entries) key(e.key): e.value},
      ),
    );
    await AnalysisRunner(
      repository: repo,
      engineService: engine,
      book: OpeningBook.empty(),
      depth: 10,
    ).run(game);
    await engine.dispose();
    return game.id;
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = GameRepository(db);
    // bob (Black) walks into mate…
    await addAnalysed(chessComPgn, {
      5: (cp: -10, mate: null, best: 'g7g6', secondCp: -400),
      6: (cp: null, mate: 1, best: 'h5f7', secondCp: 300),
    });
    // …and hangs his queen.
    await addAnalysed(hungQueenPgn, {
      3: (cp: -80, mate: null, best: 'b8c6', secondCp: -120),
      4: (cp: 900, mate: null, best: 'c1g5', secondCp: 100),
    });
  });
  tearDown(() => db.close());

  group('ReportRepository', () {
    test('aggregates only the user\'s own moves', () async {
      final r = await ReportRepository(db).build();

      expect(r.gamesAnalyzed, 2);
      expect(r.averageAccuracy, isNotNull);
      expect(r.timeline, hasLength(2));
      expect(
        r.timeline.first.date!.isAtSameMomentAs(
          DateTime.utc(2026, 10, 1, 18, 22, 5),
        ),
        isTrue,
      );

      // Both games as Black, both lost.
      expect(r.byColor.keys, [false]);
      expect(r.byColor[false]!.games, 2);
      expect(r.byColor[false]!.score, 0);

      expect(r.errorsByCategory, {
        ErrorCategory.mate: 1,
        ErrorCategory.hungMaterial: 1,
      });
      expect(r.totalErrors, 2);
      expect(r.errorsByPiece, {Role.knight: 1, Role.queen: 1});
      expect(r.byPhase.keys, contains(GamePhase.opening));
      // White's found mate is not bob's: no "mate found" for him.
      expect(r.tactics[TacticTheme.mate], isNull);
    });

    test('empty when no game has a known side', () async {
      final other = AppDatabase(NativeDatabase.memory());
      final r = await ReportRepository(other).build();
      expect(r.isEmpty, isTrue);
      await other.close();
    });

    test('unfinished games do not count as wins', () async {
      await addAnalysed('[White "x"]\n[Black "bob"]\n\n1. e4 e5 *', {});
      final r = await ReportRepository(db).build();
      expect(r.byColor[false]!.games, 3);
      expect(r.byColor[false]!.score, 0, reason: 'still 0 of 2 finished');
    });

    test('games without a known side are counted separately', () async {
      final game = parsePgnGames('1. d4 d5 2. c4 e6 *').single;
      await repo.addGames([game]);
      expect(await ReportRepository(db).gamesWithoutSide(), 0);
      final engine = EngineService(() async => FakeUciTransport());
      await AnalysisRunner(
        repository: repo,
        engineService: engine,
        book: OpeningBook.empty(),
        depth: 10,
      ).run(game);
      await engine.dispose();
      expect(await ReportRepository(db).gamesWithoutSide(), 1);

      await repo.setUserSide(game.id, 'white');
      expect(await ReportRepository(db).gamesWithoutSide(), 0);
      expect((await ReportRepository(db).build()).gamesAnalyzed, 3);
    });
  });

  group('PuzzleRepository', () {
    test('turns the user\'s mistakes into puzzles', () async {
      final puzzles = PuzzleRepository(db);
      final all = await puzzles.puzzles(PuzzleFilter.all);

      expect(all, hasLength(2));
      expect(all.every((p) => !p.whiteToMove), isTrue, reason: 'bob is Black');
      final queen = all.firstWhere((p) => p.playedSan == 'Qg5');
      expect(queen.bestUci, 'b8c6');
      expect(queen.bestSan, 'Nc6');
      expect(queen.fen, contains(' b '));
      expect(queen.solved, isNull);
    });

    test('filters by cause', () async {
      final puzzles = PuzzleRepository(db);
      final mate = await puzzles.puzzles(
        const PuzzleFilter(category: ErrorCategory.mate),
      );
      expect(mate.single.playedSan, 'Nf6');
      expect(
        await puzzles.puzzles(const PuzzleFilter(phase: GamePhase.endgame)),
        isEmpty,
      );
    });

    test('tracks progress and puts solved puzzles last', () async {
      final puzzles = PuzzleRepository(db);
      final first = (await puzzles.puzzles(PuzzleFilter.all)).first;
      expect(await puzzles.progress(PuzzleFilter.all), (total: 2, solved: 0));

      await puzzles.recordAttempt(first.gameId, first.ply, solved: false);
      expect(await puzzles.progress(PuzzleFilter.all), (total: 2, solved: 0));
      await puzzles.recordAttempt(first.gameId, first.ply, solved: true);
      // A later failure does not un-solve it.
      await puzzles.recordAttempt(first.gameId, first.ply, solved: false);
      expect(await puzzles.progress(PuzzleFilter.all), (total: 2, solved: 1));

      final again = await puzzles.puzzles(PuzzleFilter.all);
      expect(again.last.gameId, first.gameId);
      expect(again.last.solved, isTrue);
      expect(again.first.solved, isNull);
    });
  });

  test('upgradeAnalyses re-derives motifs without the engine', () async {
    // Simulate rows written by the Phase 1 app: no motifs, version 0.
    await db.customStatement(
      'UPDATE move_analyses SET motifs = NULL, category = NULL, '
      'opportunity = NULL, fen_before = NULL',
    );
    await db.customStatement('UPDATE games SET analysis_version = 0');
    expect((await ReportRepository(db).build()).totalErrors, 0);

    expect(await repo.upgradeAnalyses(), 2);
    expect(await repo.upgradeAnalyses(), 0, reason: 'already current');

    final r = await ReportRepository(db).build();
    expect(r.errorsByCategory[ErrorCategory.mate], 1);
    expect(await PuzzleRepository(db).puzzles(PuzzleFilter.all), hasLength(2));
  });

  group('pickFocus', () {
    test('ranks the biggest problems first, max three', () {
      const report = ReportData(
        gamesAnalyzed: 10,
        errorsByCategory: {
          ErrorCategory.hungMaterial: 12,
          ErrorCategory.missedTactic: 6,
          ErrorCategory.positional: 5,
          ErrorCategory.mate: 1,
        },
        timeTroubleErrors: 8,
        tactics: {
          TacticTheme.fork: (found: 1, total: 6),
          TacticTheme.pin: (found: 5, total: 6),
        },
        byPhase: {
          GamePhase.opening: (accuracy: 90, moves: 100),
          GamePhase.middlegame: (accuracy: 84, moves: 200),
          GamePhase.endgame: (accuracy: 70, moves: 80),
        },
      );
      final focus = pickFocus(report);

      expect(focus, hasLength(3));
      expect(focus.first.kind, FocusKind.category);
      expect(focus.first.filter.category, ErrorCategory.hungMaterial);
      expect(focus.first.count, 12);
      // Forks (1 of 6 found) qualify; pins (5 of 6) never do.
      final all = pickFocus(report, max: 10);
      expect(all.any((f) => f.filter.theme == TacticTheme.fork), isTrue);
      expect(all.any((f) => f.filter.theme == TacticTheme.pin), isFalse);
      expect(all.any((f) => f.filter.phase == GamePhase.endgame), isTrue);
      expect(all.any((f) => f.kind == FocusKind.timeTrouble), isTrue);
      // Sorted by severity.
      for (var i = 1; i < all.length; i++) {
        expect(all[i - 1].severity, greaterThanOrEqualTo(all[i].severity));
      }
    });

    test('nothing to say without data', () {
      expect(pickFocus(ReportData.empty), isEmpty);
    });
  });

  test('PuzzleFilter survives a route round-trip', () {
    for (final f in const [
      PuzzleFilter.all,
      PuzzleFilter(category: ErrorCategory.hungMaterial),
      PuzzleFilter(theme: TacticTheme.fork),
      PuzzleFilter(phase: GamePhase.endgame),
      PuzzleFilter(timeTrouble: true),
    ]) {
      expect(PuzzleFilter.decode(f.encode()), f);
    }
    expect(PuzzleFilter.decode('garbage'), PuzzleFilter.all);
  });
}
