import 'package:chessground/chessground.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

void main() {
  testWidgets('Arabic mirrors the app layout', (tester) async {
    await pumpEvilApp(tester, prefs: {'settings.locale': 'ar'});

    final nav = tester.element(find.byType(NavigationBar));
    expect(Directionality.of(nav), TextDirection.rtl);
    expect(find.text('الرئيسية'), findsOneWidget); // "Home"

    // First destination (Home) sits on the right edge in RTL.
    final home = tester.getCenter(find.text('الرئيسية'));
    final profile = tester.getCenter(find.text('الملف الشخصي'));
    expect(home.dx, greaterThan(profile.dx));
  });

  testWidgets('Arabic does NOT mirror the chessboard', (tester) async {
    await pumpEvilApp(tester, prefs: {'settings.locale': 'ar'});

    final board = tester.element(find.byType(StaticChessboard));
    expect(Directionality.of(board), TextDirection.ltr);
  });

  testWidgets('wide Arabic layout puts the rail on the right', (tester) async {
    await pumpEvilApp(tester, prefs: {'settings.locale': 'ar'}, size: wideSize);

    final rail = tester.getRect(find.byType(NavigationRail));
    expect(rail.right, wideSize.width);
  });

  testWidgets('English is left-to-right', (tester) async {
    await pumpEvilApp(tester, prefs: {'settings.locale': 'en'});

    final nav = tester.element(find.byType(NavigationBar));
    expect(Directionality.of(nav), TextDirection.ltr);
  });
}
