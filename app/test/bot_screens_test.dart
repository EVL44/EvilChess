import 'package:dartchess/dartchess.dart' show Side;
import 'package:evilchess/core/router/app_router.dart';
import 'package:evilchess/features/bots/bot_game_controller.dart';
import 'package:evilchess/features/bots/domain/bot.dart';
import 'package:evilchess/features/review/widgets/review_board.dart';
import 'package:evilchess/features/review/widgets/review_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

/// Taps the centre of [square] (e.g. 'e2') on a White-oriented board.
Future<void> tapSquare(WidgetTester tester, String square) async {
  final rect = tester.getRect(find.byType(ReviewBoard));
  final size = rect.width / 8;
  final file = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
  final rank = int.parse(square[1]);
  await tester.tapAt(
    Offset(rect.left + (file + 0.5) * size, rect.top + (8 - rank + 0.5) * size),
  );
  await tester.pump();
}

const pipGame = (botId: 'pip', userSide: Side.white, takebacks: true);

/// Number of moves in the running game against Pip.
int movesPlayed(WidgetTester tester) =>
    containerOf(tester).read(botGameProvider(pipGame)).plies.length;

Future<void> waitForMoves(WidgetTester tester, int n) async {
  for (var i = 0; i < 300 && movesPlayed(tester) < n; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
  expect(movesPlayed(tester), n);
}

void main() {
  setUp(() => BotGameController.thinkTime = (_) => Duration.zero);

  testWidgets('Play tab lists the whole cast', (tester) async {
    await pumpEvilApp(tester, size: wideSize);
    containerOf(tester).read(appRouterProvider).go(Routes.play);
    await settleRealAsync(tester, rounds: 3);

    expect(find.text('Choose your opponent'), findsOneWidget);
    for (final bot in kBots) {
      expect(find.text(bot.name), findsOneWidget);
    }
  });

  testWidgets('play a move, the bot answers, resign, review the game', (
    tester,
  ) async {
    await pumpEvilApp(tester);
    containerOf(tester).read(appRouterProvider).go(Routes.play);
    await settleRealAsync(tester, rounds: 3);

    await tester.tap(find.byKey(const Key('bot-pip')));
    await tester.pumpAndSettle();
    expect(find.text('Allow takebacks'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-bot-game')));
    await waitFor(tester, find.text('Your move'));

    await tapSquare(tester, 'e2');
    await tapSquare(tester, 'e4');
    // e4 is played and Pip replies.
    await waitForMoves(tester, 2);
    expect(find.text('e4'), findsOneWidget);
    expect(find.text('Your move'), findsOneWidget);

    // Take it back: both moves disappear.
    await tester.ensureVisible(find.byKey(const Key('takeback')));
    await tester.tap(find.byKey(const Key('takeback')));
    await tester.pumpAndSettle();
    expect(find.text('e4'), findsNothing);

    expect(movesPlayed(tester), 0);

    await tapSquare(tester, 'd2');
    await tapSquare(tester, 'd4');
    await waitForMoves(tester, 2);
    expect(find.text('d4'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('resign')));
    await tester.tap(find.byKey(const Key('resign')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-resign')));
    await waitFor(tester, find.text('You lost'));
    expect(find.textContaining('by resignation'), findsOneWidget);

    // The game was saved; reviewing it runs the analysis.
    final review = find.byKey(const Key('review-game'));
    await tester.ensureVisible(review);
    await waitFor(tester, review);
    await tester.tap(review);
    await waitFor(tester, find.byType(ReviewSummary));
    expect(find.textContaining('Pip (bot)'), findsWidgets);
  });
}
