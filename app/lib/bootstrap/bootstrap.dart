import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import '../core/settings/app_settings.dart';

/// Starts the full app (native platforms and the WebAssembly web build).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const EvilChessApp(),
    ),
  );
}

/// Bundled fonts are SIL OFL; show their licences on the licences screen.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (name, file) in [
      ('Nunito', 'assets/fonts/Nunito-OFL.txt'),
      ('Cairo', 'assets/fonts/Cairo-OFL.txt'),
    ]) {
      final text = await rootBundle.loadString(file);
      yield LicenseEntryWithLineBreaks([name], text);
    }
  });
}
