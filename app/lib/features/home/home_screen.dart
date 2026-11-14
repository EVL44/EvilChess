import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/board_preview.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/evil_logo.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    final cards = [
      _FeatureCard(
        icon: Icons.insights_rounded,
        color: palette.brand,
        title: l10n.homeAnalyzeTitle,
        body: l10n.homeAnalyzeBody,
        onTap: () => context.go(Routes.analyze),
      ),
      _FeatureCard(
        icon: Icons.extension_rounded,
        color: palette.hot,
        title: l10n.homePuzzlesTitle,
        body: l10n.homePuzzlesBody,
        onTap: () => context.go(Routes.puzzles),
      ),
      _FeatureCard(
        icon: Icons.sports_esports_rounded,
        color: palette.zap,
        title: l10n.homePlayTitle,
        body: l10n.homePlayBody,
        onTap: () => context.go(Routes.play),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final hero = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const EvilLogo(size: 56),
                    const SizedBox(width: EcSpace.md),
                    Expanded(
                      child: Text(
                        l10n.appTitle,
                        style: text.headlineMedium?.copyWith(
                          color: palette.brand,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.settingsTitle,
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () => context.push(Routes.settings),
                    ),
                  ],
                ),
                const SizedBox(height: EcSpace.lg),
                Text(l10n.homeGreeting, style: text.displaySmall),
                const SizedBox(height: EcSpace.sm),
                Text(
                  l10n.homeTagline,
                  style: text.titleMedium?.copyWith(color: palette.inkMuted),
                ),
              ],
            );

            final board = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const BoardPreview(),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(EcSpace.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: hero),
                            const SizedBox(width: EcSpace.xl),
                            Expanded(child: board),
                          ],
                        )
                      else ...[
                        hero,
                        const SizedBox(height: EcSpace.lg),
                        Center(child: board),
                      ],
                      const SizedBox(height: EcSpace.xl),
                      if (wide)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final (i, c) in cards.indexed) ...[
                                if (i > 0) const SizedBox(width: EcSpace.md),
                                Expanded(child: c),
                              ],
                            ],
                          ),
                        )
                      else
                        for (final c in cards) ...[
                          c,
                          const SizedBox(height: EcSpace.md),
                        ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(EcRadii.md),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: EcSpace.md),
            Text(title, style: text.titleLarge),
            const SizedBox(height: EcSpace.xs),
            Text(
              body,
              style: text.bodyMedium?.copyWith(color: context.palette.inkMuted),
            ),
            const SizedBox(height: EcSpace.md),
            ChunkyButton(
              label: title,
              color: color,
              icon: Icons.arrow_forward_rounded,
              expand: true,
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
