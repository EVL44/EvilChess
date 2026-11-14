import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/coming_soon.dart';
import '../../l10n/app_localizations.dart';

class PuzzlesScreen extends StatelessWidget {
  const PuzzlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).navPuzzles)),
      body: ComingSoon(
        icon: Icons.extension_rounded,
        color: context.palette.hot,
      ),
    );
  }
}
