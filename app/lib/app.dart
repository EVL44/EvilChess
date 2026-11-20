import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router/app_router.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'features/account/account.dart';
import 'features/sync/sync_controller.dart';
import 'l10n/app_localizations.dart';

class EvilChessApp extends ConsumerWidget {
  const EvilChessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final router = ref.watch(appRouterProvider);

    // Sync as soon as a session starts (sign-in, or app start while signed
    // in). The first sync after signing in uploads the guest's data.
    ref.listen(accountProvider.select((a) => a.profile?.id), (prev, next) {
      if (next != null && next != prev) {
        ref.read(syncProvider.notifier).sync();
      }
    });

    final effectiveLanguage =
        (settings.locale ?? WidgetsBinding.instance.platformDispatcher.locale)
            .languageCode;
    final arabic = effectiveLanguage == 'ar';

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(arabic: arabic),
      darkTheme: AppTheme.dark(arabic: arabic),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
    );
  }
}
