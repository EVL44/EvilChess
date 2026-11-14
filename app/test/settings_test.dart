import 'package:evilchess/core/settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  group('AppSettingsController', () {
    Future<ProviderContainer> make(Map<String, Object> values) async {
      SharedPreferences.setMockInitialValues(values);
      final sp = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('defaults to system theme and system language', () async {
      final c = await make({});
      expect(c.read(appSettingsProvider), const AppSettings());
    });

    test('loads saved values and ignores unknown ones', () async {
      var c = await make({
        'settings.themeMode': 'dark',
        'settings.locale': 'fr',
      });
      expect(c.read(appSettingsProvider).themeMode, ThemeMode.dark);
      expect(c.read(appSettingsProvider).locale, const Locale('fr'));

      c = await make({'settings.themeMode': 'neon', 'settings.locale': 'xx'});
      expect(c.read(appSettingsProvider), const AppSettings());
    });

    test('persists changes', () async {
      final c = await make({});
      final ctrl = c.read(appSettingsProvider.notifier);
      await ctrl.setThemeMode(ThemeMode.light);
      await ctrl.setLocale(const Locale('ar'));

      final sp = c.read(sharedPreferencesProvider);
      expect(sp.getString('settings.themeMode'), 'light');
      expect(sp.getString('settings.locale'), 'ar');

      await ctrl.setLocale(null);
      expect(sp.getString('settings.locale'), isNull);
      expect(c.read(appSettingsProvider).locale, isNull);
    });
  });

  testWidgets('switching to dark mode changes the theme', (tester) async {
    final sp = await pumpEvilApp(tester, prefs: {'settings.locale': 'en'});
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Appearance'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(sp.getString('settings.themeMode'), 'dark');
  });

  testWidgets('switching language updates the UI live', (tester) async {
    await pumpEvilApp(tester, prefs: {'settings.locale': 'en'});
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lang-fr')));
    await tester.pumpAndSettle();

    expect(find.text('Paramètres'), findsOneWidget);
    expect(
      containerOf(tester).read(appSettingsProvider).locale,
      const Locale('fr'),
    );
  });
}
