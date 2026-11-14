import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/move_classification.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/board_preview.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/classification_badge.dart';
import '../../l10n/app_localizations.dart';

/// Living style guide: every token and core component in one place, in the
/// current theme and language. Handy for checking dark mode and RTL.
class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: EcSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleLarge),
          const SizedBox(height: EcSpace.md),
          child,
        ],
      ),
    );

    final swatches = {
      'brand': palette.brand,
      'hot': palette.hot,
      'zap': palette.zap,
      'sun': palette.sun,
      'surface': scheme.surface,
      'surfaceAlt': palette.surfaceAlt,
      'ink': scheme.onSurface,
      'inkMuted': palette.inkMuted,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.designSystemTitle)),
      body: ListView(
        padding: const EdgeInsets.all(EcSpace.lg),
        children: [
          section(
            'Colours',
            Wrap(
              spacing: EcSpace.md,
              runSpacing: EcSpace.md,
              children: [
                for (final MapEntry(:key, :value) in swatches.entries)
                  Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: value,
                          borderRadius: BorderRadius.circular(EcRadii.md),
                          border: Border.all(
                            color: palette.surfaceAlt,
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: EcSpace.xs),
                      Text(key, style: text.labelSmall),
                    ],
                  ),
              ],
            ),
          ),
          section(
            'Typography',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeGreeting, style: text.displaySmall),
                Text(l10n.homeAnalyzeTitle, style: text.headlineSmall),
                Text(l10n.homePuzzlesTitle, style: text.titleLarge),
                Text(l10n.homeTagline, style: text.bodyLarge),
                Text(l10n.comingSoonBody, style: text.bodySmall),
              ],
            ),
          ),
          section(
            'Buttons',
            Wrap(
              spacing: EcSpace.md,
              runSpacing: EcSpace.md,
              children: [
                ChunkyButton(label: l10n.buttonPrimary, onPressed: () {}),
                ChunkyButton(
                  label: l10n.homePuzzlesTitle,
                  icon: Icons.extension_rounded,
                  color: palette.hot,
                  onPressed: () {},
                ),
                ChunkyButton(
                  label: l10n.homePlayTitle,
                  icon: Icons.bolt_rounded,
                  color: palette.zap,
                  onPressed: () {},
                ),
                ChunkyButton(
                  label: l10n.buttonSecondary,
                  color: palette.sun,
                  onPressed: () {},
                ),
                ChunkyButton(label: l10n.comingSoonTitle, onPressed: null),
                FilledButton(onPressed: () {}, child: Text(l10n.buttonPrimary)),
                OutlinedButton(
                  onPressed: () {},
                  child: Text(l10n.buttonSecondary),
                ),
              ],
            ),
          ),
          section(
            'Move classifications',
            Wrap(
              spacing: EcSpace.lg,
              runSpacing: EcSpace.md,
              children: [
                for (final c in MoveClass.values)
                  ClassificationBadge(c, showLabel: true),
              ],
            ),
          ),
          section(
            'Board (never mirrors)',
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(width: 320, child: BoardPreview()),
            ),
          ),
        ],
      ),
    );
  }
}
