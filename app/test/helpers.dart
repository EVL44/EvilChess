import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:evilchess/app.dart';
import 'package:evilchess/core/api/api_client.dart';
import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/core/db/database_provider.dart';
import 'package:evilchess/core/engine/engine_service.dart';
import 'package:evilchess/core/settings/app_settings.dart';
import 'package:evilchess/features/account/account.dart';
import 'package:evilchess/features/games/data/import_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_engine.dart';

const phoneSize = Size(400, 860);

/// In-memory database for widget tests. Streams close synchronously so no
/// timers are left pending when the widget tree is torn down.
AppDatabase testDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// Lets real async work (database, fake engine) run for a while, pumping
/// frames in between. Widget tests use a fake clock, so plain `pump` calls
/// don't give I/O a chance to complete.
Future<void> settleRealAsync(WidgetTester tester, {int rounds = 20}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

const wideSize = Size(1280, 900);

/// Runs real async work until [finder] matches (or a 10 s timeout).
Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 500; i++) {
    if (finder.evaluate().isNotEmpty) break;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
  expect(finder, findsWidgets);
}

/// Pumps the whole app with in-memory preferences, an in-memory database
/// and a fake engine, at a given screen size.
Future<SharedPreferences> pumpEvilApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  Size size = phoneSize,
  AppDatabase? db,
  FakeUciTransport? engine,
  http.Client? server,
  TokenStore? tokens,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final database = db ?? testDatabase();
  final fake = engine ?? FakeUciTransport();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        appDatabaseProvider.overrideWithValue(database),
        engineTransportFactoryProvider.overrideWithValue(() async => fake),
        analysisDepthProvider.overrideWithValue(8),
        apiUrlProvider.overrideWithValue('http://api'),
        tokenStoreProvider.overrideWithValue(tokens ?? MemoryTokenStore()),
        // No server unless a test provides one: every call is "offline".
        httpClientProvider.overrideWithValue(
          server ?? MockClient((_) async => throw Exception('offline')),
        ),
      ],
      child: const EvilChessApp(),
    ),
  );
  await settleRealAsync(tester, rounds: 3);
  return sp;
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(EvilChessApp)));
