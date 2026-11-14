import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/coming_soon.dart';
import '../../l10n/app_localizations.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).navPlay)),
      body: ComingSoon(
        icon: Icons.sports_esports_rounded,
        color: context.palette.zap,
      ),
    );
  }
}
