import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Native names, so each language is recognisable whatever the UI language.
const _languageNames = {'en': 'English', 'fr': 'Français', 'ar': 'العربية'};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(EcSpace.md),
        children: [
          Text(l10n.settingsAppearance, style: text.titleMedium),
          const SizedBox(height: EcSpace.sm),
          SegmentedButton<ThemeMode>(
            key: const Key('theme-mode'),
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(l10n.themeSystem),
                icon: const Icon(Icons.brightness_auto_rounded),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(l10n.themeLight),
                icon: const Icon(Icons.light_mode_rounded),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(l10n.themeDark),
                icon: const Icon(Icons.dark_mode_rounded),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => controller.setThemeMode(s.single),
          ),
          const SizedBox(height: EcSpace.lg),
          Text(l10n.settingsLanguage, style: text.titleMedium),
          RadioGroup<String>(
            groupValue: settings.locale?.languageCode ?? '',
            onChanged: (code) => controller.setLocale(
              code == null || code.isEmpty
                  ? null
                  : supportedAppLocales.firstWhere(
                      (l) => l.languageCode == code,
                    ),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  value: '',
                  title: Text(l10n.languageSystem),
                ),
                for (final locale in supportedAppLocales)
                  RadioListTile<String>(
                    key: Key('lang-${locale.languageCode}'),
                    value: locale.languageCode,
                    title: Text(_languageNames[locale.languageCode]!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: EcSpace.lg),
          Text(l10n.settingsAbout, style: text.titleMedium),
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: Text(l10n.designSystemTitle),
            onTap: () => context.push(Routes.designSystem),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_rounded),
            title: Text(l10n.licensesTitle),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
            ),
          ),
        ],
      ),
    );
  }
}
