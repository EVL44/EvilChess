import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/coming_soon.dart';
import '../../l10n/app_localizations.dart';

class AnalyzeScreen extends StatelessWidget {
  const AnalyzeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).navAnalyze)),
      body: ComingSoon(
        icon: Icons.insights_rounded,
        color: context.palette.brand,
      ),
    );
  }
}
