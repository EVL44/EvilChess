import 'dart:async';

import 'package:dartchess/dartchess.dart' show Side;
import 'package:evilchess/core/api/api_client.dart';
import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/core/router/app_router.dart';
import 'package:evilchess/features/games/data/game_repository.dart';
import 'package:evilchess/features/games/domain/pgn_import.dart';
import 'package:evilchess/features/review/widgets/review_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes/fake_api.dart';
import 'fixtures/pgns.dart';
import 'helpers.dart';

/// Taps [square] (e.g. 'e2') on the board, for either orientation.
Future<void> tapSquare(
  WidgetTester tester,
  String square, {
  Side orientation = Side.white,
}) async {
  final rect = tester.getRect(find.byType(ReviewBoard));
  final size = rect.width / 8;
  var file = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
  var rank = int.parse(square[1]);
  if (orientation == Side.black) {
    file = 7 - file;
    rank = 9 - rank;
  }
  await tester.tapAt(
    Offset(rect.left + (file + 0.5) * size, rect.top + (8 - rank + 0.5) * size),
  );
  await tester.pump();
}

/// Lets the puzzle board's opponent-move timers fire.
Future<void> letOpponentMove(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign up from the Profile tab uploads the guest\'s games', (
    tester,
  ) async {
    final api = FakeApi();
    final db = testDatabase();
    await tester.runAsync(
      () => GameRepository(db).addGames(parsePgnGames(chessComPgn)),
    );
    await pumpEvilApp(tester, db: db, server: api.client());
    containerOf(tester).read(appRouterProvider).go(Routes.profile);
    await settleRealAsync(tester, rounds: 3);

    expect(find.text('Sign in'), findsWidgets);
    await tester.tap(find.byKey(const Key('toggle-register')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email')), 'Ada@Example.com');
    await tester.enterText(find.byKey(const Key('password')), 'longpassword');
    await tester.enterText(find.byKey(const Key('display-name')), 'Ada');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('submit-auth')));
    await tester.tap(find.byKey(const Key('submit-auth')));

    await waitFor(tester, find.byKey(const Key('profile-name')));
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('ada@example.com'), findsOneWidget);
    await waitFor(tester, find.text('Synced: 1 sent, 0 received'));
    expect(api.sync.requests, greaterThan(0));

    await tester.ensureVisible(find.byKey(const Key('sign-out')));
    await tester.tap(find.byKey(const Key('sign-out')));
    await waitFor(tester, find.byKey(const Key('submit-auth')));
  });

  testWidgets('a wrong password is explained', (tester) async {
    final api = FakeApi()
      ..users['bob@example.com'] = (password: 'rightpass1', name: 'bob');
    await pumpEvilApp(tester, server: api.client());
    containerOf(tester).read(appRouterProvider).go(Routes.profile);
    await settleRealAsync(tester, rounds: 3);

    await tester.enterText(find.byKey(const Key('email')), 'bob@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'wrongpass1');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('submit-auth')));
    await tester.tap(find.byKey(const Key('submit-auth')));
    await waitFor(tester, find.text('Wrong email or password.'));
  });

  testWidgets('rated puzzle: solve the fork, rating goes up', (tester) async {
    final api = FakeApi()
      ..users['ada@example.com'] = (password: 'x', name: 'Ada')
      ..signedInEmail = 'ada@example.com';
    await pumpEvilApp(
      tester,
      server: api.client(),
      tokens: MemoryTokenStore()..tokens = const Tokens('a', 'r'),
    );
    await waitFor(tester, find.text('Home'));
    unawaited(
      containerOf(tester).read(appRouterProvider).push(Routes.ratedPuzzles()),
    );
    await waitFor(tester, find.text('Find the best move for White'));
    await letOpponentMove(tester); // ...Ra7

    await tapSquare(tester, 'b5');
    await tapSquare(tester, 'c7'); // Nc7+ forks king and rook
    await letOpponentMove(tester); // ...Kd7
    await tapSquare(tester, 'c7');
    await tapSquare(tester, 'a8'); // Nxa8

    await waitFor(tester, find.byKey(const Key('rating-line')));
    expect(find.text('Rating 1520 (+20)'), findsOneWidget);
    expect(find.text('Correct!'), findsOneWidget);
    expect(api.attempts, {'fork1': true});
  });

  testWidgets('the daily puzzle works without an account', (tester) async {
    final api = FakeApi();
    await pumpEvilApp(tester, server: api.client());
    containerOf(tester).read(appRouterProvider).go(Routes.puzzles);
    await settleRealAsync(tester, rounds: 3);
    expect(
      find.text('Sign in to play rated puzzles and keep a puzzle rating.'),
      findsOneWidget,
    );

    unawaited(
      containerOf(tester).read(appRouterProvider).push(Routes.dailyPuzzle),
    );
    await waitFor(tester, find.text('Find the best move for White'));
    await letOpponentMove(tester);
    await tapSquare(tester, 'd1');
    await tapSquare(tester, 'd8'); // also mate: accepted
    await waitFor(tester, find.text('Correct!'));
    expect(api.attempts, isEmpty, reason: 'daily is unrated');
  });

  testWidgets('Puzzle Rush offline uses the saved pack; 3 strikes end it', (
    tester,
  ) async {
    final db = testDatabase();
    await tester.runAsync(() async {
      for (final p in [matePuzzle, forkPuzzle]) {
        await db
            .into(db.cachedPuzzles)
            .insert(
              CachedPuzzlesCompanion.insert(
                id: p['id']! as String,
                fen: p['fen']! as String,
                moves: (p['moves']! as List).join(' '),
                rating: p['rating']! as int,
                themes: '',
                fetchedAt: DateTime.now(),
              ),
            );
      }
    });
    await pumpEvilApp(tester, db: db); // no server at all
    unawaited(
      containerOf(tester).read(appRouterProvider).push(Routes.rush('survival')),
    );
    await waitFor(
      tester,
      find.text('Offline: playing puzzles saved on this device.'),
    );
    expect(find.text('Score 0'), findsOneWidget);

    // Puzzle 1 (mate, 700): solve it.
    await letOpponentMove(tester);
    await tapSquare(tester, 'c1');
    await tapSquare(tester, 'c8');
    await tester.pumpAndSettle();
    expect(find.text('Score 1'), findsOneWidget);

    // Puzzle 2 (fork): a wrong move is a strike; the pack then runs out.
    await letOpponentMove(tester);
    await tapSquare(tester, 'b5');
    await tapSquare(tester, 'd6');
    await tester.pumpAndSettle();
    await waitFor(tester, find.byKey(const Key('rush-final')));
    expect(find.text('Score 1'), findsOneWidget);
  });
}
