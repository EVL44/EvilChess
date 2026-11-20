import 'package:chessground/chessground.dart';
import 'package:evilchess/core/widgets/chunky_button.dart';
import 'package:evilchess/core/widgets/classification_badge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

void main() {
  testWidgets('phone layout uses a bottom bar with five tabs', (tester) async {
    await pumpEvilApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Ready to be evil?'), findsOneWidget);
    expect(find.byType(StaticChessboard), findsOneWidget);
  });

  testWidgets('wide layout uses a side rail', (tester) async {
    await pumpEvilApp(tester, size: wideSize);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('tapping a tab shows that screen', (tester) async {
    await pumpEvilApp(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Puzzles'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily puzzle'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Puzzles')),
      findsOneWidget,
    );
  });

  testWidgets('home feature card navigates to its tab', (tester) async {
    await pumpEvilApp(tester);

    final button = find.widgetWithText(ChunkyButton, 'Review a game');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Analyze')),
      findsOneWidget,
    );
  });

  testWidgets('settings and design system screens open', (tester) async {
    await pumpEvilApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);

    await tester.tap(find.text('Design system'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Move classifications'), 200);
    expect(find.text('Move classifications'), findsOneWidget);
    expect(find.byType(ClassificationBadge), findsWidgets);
  });
}
