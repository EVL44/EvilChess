import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Languages the app ships with. `null` in [AppSettings.locale] means "follow
/// the system language".
const supportedAppLocales = [Locale('en'), Locale('fr'), Locale('ar')];

@immutable
class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.locale});

  final ThemeMode themeMode;
  final Locale? locale;

  AppSettings copyWith({ThemeMode? themeMode, Locale? Function()? locale}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: locale != null ? locale() : this.locale,
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.locale == locale;

  @override
  int get hashCode => Object.hash(themeMode, locale);
}

/// Overridden in `main()` (and in tests) with a real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

/// Reads and persists user-facing app settings (theme, language).
class AppSettingsController extends Notifier<AppSettings> {
  static const themeKey = 'settings.themeMode';
  static const localeKey = 'settings.locale';

  /// When the user last changed a synced setting (ms since epoch).
  static const updatedAtKey = 'settings.updatedAt';
  static const _kTheme = themeKey;
  static const _kLocale = localeKey;

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final theme =
        ThemeMode.values.asNameMap()[prefs.getString(_kTheme)] ??
        ThemeMode.system;
    final code = prefs.getString(_kLocale);
    final locale = supportedAppLocales
        .where((l) => l.languageCode == code)
        .firstOrNull;
    return AppSettings(themeMode: theme, locale: locale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_kTheme, mode.name);
    await _touch();
  }

  Future<void> _touch() =>
      _prefs.setInt(updatedAtKey, DateTime.now().millisecondsSinceEpoch);

  /// Re-reads settings after sync changed them.
  void reload() => ref.invalidateSelf();

  /// Pass `null` to follow the system language.
  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: () => locale);
    if (locale == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, locale.languageCode);
    }
    await _touch();
  }
}
