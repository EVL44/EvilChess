import 'dart:async';

import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/core/engine/engine_service.dart';
import 'package:evilchess/core/router/app_router.dart';
import 'package:evilchess/features/analysis/data/analysis_runner.dart';
import 'package:evilchess/features/analysis/domain/opening_book.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';
import 'package:evilchess/features/games/data/game_repository.dart';
import 'package:evilchess/features/games/domain/pgn_import.dart';
import 'package:evilchess/features/puzzles/data/puzzle_repository.dart';
import 'package:evilchess/features/reports/domain/report.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes/fake_engine.dart';
import 'fixtures/pgns.dart';
import 'helpers.dart';

const hungQueenPgn = '''
[White "someone"]
[Black "bob"]
[Result "1-0"]
[Date "2026.10.05"]

1. d4 e5 2. dxe5 Qg5 3. Bxg5 1-0
''';

Map<String, FakeLine> scriptFor(String pgn, Map<int, FakeLine> byPly) {
  final game = parsePgnGames(pgn).single;
  String key(int i) =>
      fenKey(i == 0 ? game.initialFen : game.plies[i - 1].fenAfter);
  return {for (final e in byPly.entries) key(e.key): e.value};
}

final mateScript = scriptFor(chessComPgn, {
  5: (cp: -10, mate: null, best: 'g7g6', secondCp: -400),
  6: (cp: null, mate: 1, best: 'h5f7', secondCp: 300),
});
final queenScript = scriptFor(hungQueenPgn, {
  3: (cp: -80, mate: null, best: 'b8c6', secondCp: -120),
  4: (cp: 900, mate: null, best: 'c1g5', secondCp: 100),
});

/// A database holding bob's two lost games, optionally already analysed.
Future<AppDatabase> bobsGames({bool analysed = true}) async {
  final db = testDatabase();
  final repo = GameRepository(db);
  final games = [
    parsePgnGames(chessComPgn).single,
    parsePgnGames(hungQueenPgn).single,
  ];
  await repo.addGames(games, usernames: {'bob'});
  if (analysed) {
    final engine = EngineService(
      () async => FakeUciTransport(script: {...mateScript, ...queenScript}),
    );
    final runner = AnalysisRunner(
      repository: repo,
      engineService: engine,
      book: OpeningBook.empty(),
      depth: 8,
    );
    for (final g in games) {
      await runner.run(g);
    }
    await engine.dispose();
  }
  return db;
}

void main() {
  testWidgets('report shows causes of mistakes and links to practice', (
    tester,
  ) async {
    final db = (await tester.runAsync(bobsGames))!;
    await pumpEvilApp(tester, db: db);
    unawaited(containerOf(tester).read(appRouterProvider).push(Routes.report));
    await waitFor(tester, find.text('3 things to work on this week'));

    expect(find.text('2 games analyzed'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Where your mistakes come from'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Hanging material'), findsOneWidget);
    expect(find.text('Walking into mate'), findsOneWidget);

    // Back to the top, where the focus list is.
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 3000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('practice-0')));
    await waitFor(tester, find.textContaining('Find a better move for Black'));
  });

  testWidgets('report explains what is missing when there is no data', (
    tester,
  ) async {
    await pumpEvilApp(tester);
    unawaited(containerOf(tester).read(appRouterProvider).push(Routes.report));
    await waitFor(tester, find.text('No report yet'));
  });

  testWidgets('puzzle trainer walks through the user\'s mistakes', (
    tester,
  ) async {
    final db = (await tester.runAsync(bobsGames))!;
    await pumpEvilApp(tester, db: db);
    containerOf(tester).read(appRouterProvider).go(Routes.puzzles);
    await waitFor(tester, find.text('0 of 2 solved'));
    expect(find.text('Train a weakness'), findsOneWidget);

    await tester.tap(find.byKey(const Key('start-puzzles')));
    await waitFor(tester, find.text('1 / 2'));
    expect(find.textContaining('You played'), findsOneWidget);

    // Give up on the first: it is recorded as failed and the answer shows.
    await tester.ensureVisible(find.byKey(const Key('puzzle-answer')));
    await tester.tap(find.byKey(const Key('puzzle-answer')));
    await waitFor(tester, find.textContaining('Best was'));
    await tester.ensureVisible(find.byKey(const Key('puzzle-next')));
    await tester.tap(find.byKey(const Key('puzzle-next')));
    await waitFor(tester, find.text('2 / 2'));

    await tester.ensureVisible(find.byKey(const Key('puzzle-answer')));
    await tester.tap(find.byKey(const Key('puzzle-answer')));
    await waitFor(tester, find.byKey(const Key('puzzle-next')));
    await tester.ensureVisible(find.byKey(const Key('puzzle-next')));
    await tester.tap(find.byKey(const Key('puzzle-next')));
    await waitFor(tester, find.textContaining("That's all of them"));

    final progress = (await tester.runAsync(
      () => PuzzleRepository(db).progress(PuzzleFilter.all),
    ))!;
    expect(progress, (total: 2, solved: 0));
  });

  testWidgets('"Analyze all" analyses every game in the library', (
    tester,
  ) async {
    final db = (await tester.runAsync(() => bobsGames(analysed: false)))!;
    await pumpEvilApp(
      tester,
      db: db,
      engine: FakeUciTransport(script: {...mateScript, ...queenScript}),
    );
    containerOf(tester).read(appRouterProvider).go(Routes.analyze);
    await waitFor(tester, find.byKey(const Key('analyze-all')));
    expect(find.text('Not analyzed'), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('analyze-all')));
    for (var i = 0; i < 300; i++) {
      if (find.text('Not analyzed').evaluate().isEmpty) break;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('Not analyzed'), findsNothing);
    expect(find.byKey(const Key('analyze-all')), findsNothing);
  });

  testWidgets('review explains a hung piece in plain words', (tester) async {
    final db = (await tester.runAsync(bobsGames))!;
    await pumpEvilApp(tester, db: db);
    final game = parsePgnGames(hungQueenPgn).single;
    unawaited(
      containerOf(tester).read(appRouterProvider).push(Routes.review(game.id)),
    );
    await waitFor(tester, find.text('Next mistake'));

    await tester.tap(find.text('Next mistake'));
    await tester.pumpAndSettle();
    expect(find.text('Qg5 is Blunder'), findsOneWidget);
    expect(
      find.text('This leaves your queen hanging — it can simply be taken.'),
      findsOneWidget,
    );
  });
}
