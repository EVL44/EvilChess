import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/labels.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chunky_button.dart';
import '../../l10n/app_localizations.dart';
import '../bots/domain/bot.dart';
import '../bots/widgets/bot_avatar.dart';

/// The Play tab: pick a bot. Online play arrives in Phase 5.
class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPlay)),
      body: LayoutBuilder(
        builder: (context, c) {
          final columns = c.maxWidth >= 1100
              ? 3
              : c.maxWidth >= 700
              ? 2
              : 1;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  EcSpace.md,
                  EcSpace.sm,
                  EcSpace.md,
                  EcSpace.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.chooseOpponent, style: text.headlineSmall),
                      const SizedBox(height: EcSpace.xs),
                      Text(
                        l10n.botsSubtitle,
                        style: text.bodyMedium?.copyWith(
                          color: context.palette.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: EcSpace.md),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: EcSpace.sm,
                    crossAxisSpacing: EcSpace.sm,
                    mainAxisExtent: 128,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _BotCard(bot: kBots[i]),
                    childCount: kBots.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(EcSpace.lg),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.botRatingNote,
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: context.palette.inkMuted,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BotCard extends StatelessWidget {
  const _BotCard({required this.bot});

  final Bot bot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('bot-${bot.id}'),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          useSafeArea: true,
          isScrollControlled: true,
          builder: (_) => _BotSetupSheet(bot: bot),
        ),
        child: Padding(
          padding: const EdgeInsets.all(EcSpace.md),
          child: Row(
            children: [
              BotAvatar(bot: bot, size: 64),
              const SizedBox(width: EcSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            bot.name,
                            style: text.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: EcSpace.sm),
                        _Chip(
                          label: l10n.botRating(bot.rating),
                          color: bot.color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.botStyle(bot.style),
                      style: text.labelMedium?.copyWith(color: bot.color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.botBio(bot),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(EcRadii.pill),
    ),
    child: Text(
      label,
      textDirection: TextDirection.ltr,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
    ),
  );
}

enum _SideChoice { white, random, black }

class _BotSetupSheet extends StatefulWidget {
  const _BotSetupSheet({required this.bot});
  final Bot bot;

  @override
  State<_BotSetupSheet> createState() => _BotSetupSheetState();
}

class _BotSetupSheetState extends State<_BotSetupSheet> {
  _SideChoice _side = _SideChoice.white;
  bool _takebacks = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final bot = widget.bot;
    return Padding(
      padding: const EdgeInsets.fromLTRB(EcSpace.lg, 0, EcSpace.lg, EcSpace.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              BotAvatar(bot: bot, size: 72),
              const SizedBox(width: EcSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bot.name, style: text.headlineSmall),
                    Text(
                      '${l10n.botRating(bot.rating)} · ${l10n.botStyle(bot.style)}',
                      style: text.labelLarge?.copyWith(color: bot.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: EcSpace.md),
          Text(l10n.botBio(bot), style: text.bodyLarge),
          const SizedBox(height: EcSpace.lg),
          Text(l10n.playAs, style: text.titleSmall),
          const SizedBox(height: EcSpace.sm),
          SegmentedButton<_SideChoice>(
            segments: [
              ButtonSegment(
                value: _SideChoice.white,
                label: Text(l10n.white),
                icon: const Icon(Icons.circle_outlined),
              ),
              ButtonSegment(
                value: _SideChoice.random,
                label: Text(l10n.randomSide),
                icon: const Icon(Icons.shuffle_rounded),
              ),
              ButtonSegment(
                value: _SideChoice.black,
                label: Text(l10n.black),
                icon: const Icon(Icons.circle),
              ),
            ],
            selected: {_side},
            onSelectionChanged: (s) => setState(() => _side = s.single),
          ),
          const SizedBox(height: EcSpace.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.allowTakebacks),
            value: _takebacks,
            onChanged: (v) => setState(() => _takebacks = v),
          ),
          const SizedBox(height: EcSpace.md),
          ChunkyButton(
            key: const Key('start-bot-game'),
            label: l10n.playButton,
            icon: Icons.play_arrow_rounded,
            color: bot.color,
            expand: true,
            onPressed: () {
              final side = switch (_side) {
                _SideChoice.white => 'white',
                _SideChoice.black => 'black',
                _SideChoice.random =>
                  math.Random().nextBool() ? 'white' : 'black',
              };
              Navigator.of(context).pop();
              context.push(
                Routes.botGame(bot.id, side: side, takebacks: _takebacks),
              );
            },
          ),
        ],
      ),
    );
  }
}
