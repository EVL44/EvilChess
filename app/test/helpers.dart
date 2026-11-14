import 'package:evilchess/app.dart';
import 'package:evilchess/core/settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const phoneSize = Size(400, 860);
const wideSize = Size(1280, 900);

/// Pumps the whole app with in-memory preferences at a given screen size.
Future<SharedPreferences> pumpEvilApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  Size size = phoneSize,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
      child: const EvilChessApp(),
    ),
  );
  await tester.pumpAndSettle();
  return sp;
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(EvilChessApp)));
