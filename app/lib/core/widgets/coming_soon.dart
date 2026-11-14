import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Placeholder body for tabs that later phases will fill in.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(EcRadii.lg),
              ),
              child: Icon(icon, size: 56, color: color),
            ),
            const SizedBox(height: EcSpace.lg),
            Text(l10n.comingSoonTitle, style: text.headlineSmall),
            const SizedBox(height: EcSpace.sm),
            Text(
              l10n.comingSoonBody,
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(color: context.palette.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
