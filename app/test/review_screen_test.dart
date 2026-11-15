import 'dart:async';

import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/core/router/app_router.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';
import 'package:evilchess/features/games/data/game_repository.dart';
import 'package:evilchess/features/games/domain/pgn_import.dart';
import 'package:evilchess/features/review/widgets/eval_graph.dart';
import 'package:evilchess/features/review/widgets/review_summary.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes/fake_engine.dart';
import 'fixtures/pgns.dart';
import 'helpers.dart';

void main() {
  final game = parsePgnGames(chessComPgn).single;
  String key(int i) =>
      fenKey(i == 0 ? game.initialFen : game.plies[i - 1].fenAfter);

  Future<AppDatabase> dbWithGame() async {
    final db = testDatabase();
    await GameRepository(db).addGames([game]);
    return db;
  }

  FakeUciTransport engine() => FakeUciTransport(
    script: {
      key(5): (cp: -10, mate: null, best: 'g7g6', secondCp: -400),
      key(6): (cp: null, mate: 1, best: 'h5f7', secondCp: 300),
    },
  );

  Future<void> openReview(WidgetTester tester) async {
    final router = containerOf(tester).read(appRouterProvider);
    unawaited(router.push(Routes.review(game.id)));
    // Analysis runs against the fake engine; wait until it is done.
    await waitFor(tester, find.byType(ReviewSummary));
  }

  testWidgets('library lists the game and opens its review', (tester) async {
    final db = await dbWithGame();
    await pumpEvilApp(tester, db: db, engine: engine());

    await tester.tap(find.text('Analyze').last);
    await settleRealAsync(tester, rounds: 5);
    expect(find.textContaining('Alice (1500)'), findsOneWidget);

    await tester.tap(find.textContaining('Alice (1500)'));
    await waitFor(tester, find.byType(ReviewSummary));
    expect(find.byType(ReviewSummary), findsOneWidget);
    expect(find.byType(EvalGraph), findsOneWidget);
  });

  testWidgets('next mistake jumps to the blunder and offers a retry', (
    tester,
  ) async {
    await pumpEvilApp(tester, db: await dbWithGame(), engine: engine());
    await openReview(tester);

    await tester.tap(find.text('Next mistake'));
    await tester.pumpAndSettle();

    expect(find.text('Nf6 is Blunder'), findsOneWidget);
    expect(find.text('Best was g6'), findsOneWidget);
    expect(find.text('Retry this position'), findsOneWidget);

    await tester.ensureVisible(find.text('Retry this position'));
    await tester.tap(find.text('Retry this position'));
    await tester.pumpAndSettle();
    expect(find.text('Find a better move for Black'), findsOneWidget);

    await tester.tap(find.text('Show answer'));
    await tester.pumpAndSettle();
    expect(find.text('Best was g6'), findsOneWidget);

    await tester.tap(find.text('Back to review'));
    await tester.pumpAndSettle();
    expect(find.text('Nf6 is Blunder'), findsOneWidget);
  });

  testWidgets('keyboard arrows step through moves', (tester) async {
    await pumpEvilApp(
      tester,
      db: await dbWithGame(),
      engine: engine(),
      size: wideSize,
    );
    await openReview(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.textContaining('e4 is'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(find.textContaining('Qxf7# is'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.byType(ReviewSummary), findsOneWidget);
  });

  testWidgets('pasting a PGN imports it', (tester) async {
    await pumpEvilApp(tester);
    final router = containerOf(tester).read(appRouterProvider);
    router.go(Routes.analyze);
    await settleRealAsync(tester, rounds: 5);

    expect(find.text('No games yet'), findsOneWidget);
    await tester.tap(find.byTooltip('Import games'));
    await settleRealAsync(tester, rounds: 3);

    await tester.enterText(find.byKey(const Key('pgn-input')), lichessPgn);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('pgn-import')));
    await tester.tap(find.byKey(const Key('pgn-import')));
    await settleRealAsync(tester, rounds: 10);

    expect(find.text('1 new game imported'), findsOneWidget);
    expect(find.textContaining('carol (1700)'), findsOneWidget);
    expect(GoRouter.of(tester.element(find.byType(Scaffold).first)), isNotNull);
  });
}
