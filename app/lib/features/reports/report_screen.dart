import 'package:dartchess/dartchess.dart' show Role;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/labels.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/force_ltr.dart';
import '../../l10n/app_localizations.dart';
import '../analysis/domain/material.dart';
import '../analyze/analyze_screen.dart' show gameSummariesProvider;
import '../games/data/game_repository.dart';
import '../games/domain/game_record.dart';
import '../games/ui/import_sheet.dart';
import 'data/report_repository.dart';
import 'domain/report.dart';

typedef ReportBundle = ({ReportData report, int withoutSide});

/// The personal report, rebuilt whenever the game library changes.
final reportProvider = FutureProvider.autoDispose<ReportBundle>((ref) async {
  ref.watch(gameSummariesProvider);
  // Bring analyses saved by older versions up to date (no engine needed).
  await ref.watch(gameRepositoryProvider).upgradeAnalyses();
  final repo = ref.watch(reportRepositoryProvider);
  return (
    report: await repo.build(),
    withoutSide: await repo.gamesWithoutSide(),
  );
});

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bundle = ref.watch(reportProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myReport)),
      body: bundle.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (b) => b.report.isEmpty
            ? _EmptyReport(withoutSide: b.withoutSide)
            : _ReportBody(report: b.report, withoutSide: b.withoutSide),
      ),
    );
  }
}

class _EmptyReport extends StatelessWidget {
  const _EmptyReport({required this.withoutSide});
  final int withoutSide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(EcSpace.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.query_stats_rounded,
                size: 72,
                color: context.palette.hot,
              ),
              const SizedBox(height: EcSpace.md),
              Text(l10n.reportEmptyTitle, style: text.headlineSmall),
              const SizedBox(height: EcSpace.sm),
              Text(
                l10n.reportEmptyBody,
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(
                  color: context.palette.inkMuted,
                ),
              ),
              if (withoutSide > 0) ...[
                const SizedBox(height: EcSpace.md),
                Text(
                  l10n.reportGamesWithoutSide(withoutSide),
                  textAlign: TextAlign.center,
                  style: text.bodyMedium,
                ),
              ],
              const SizedBox(height: EcSpace.lg),
              ChunkyButton(
                label: l10n.importGames,
                icon: Icons.download_rounded,
                onPressed: () => showImportSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.withoutSide});

  final ReportData report;
  final int withoutSide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final focus = pickFocus(report);
    String pct(double? v) => v == null ? '–' : '${v.toStringAsFixed(1)}%';

    final maxCategory = report.errorsByCategory.values.fold(
      1,
      (a, b) => a > b ? a : b,
    );
    final categories = report.errorsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final tactics = report.tactics.entries.toList()
      ..sort(
        (a, b) => (a.value.found / a.value.total).compareTo(
          b.value.found / b.value.total,
        ),
      );
    final maxPiece = report.errorsByPiece.values.fold(
      1,
      (a, b) => a > b ? a : b,
    );

    final sections = <Widget>[
      if (focus.isNotEmpty)
        _Section(
          title: l10n.focusTitle,
          icon: Icons.flag_rounded,
          color: palette.hot,
          child: Column(
            children: [
              for (final (i, item) in focus.indexed)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : EcSpace.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: palette.hot.withValues(alpha: 0.18),
                        child: Text(
                          '${i + 1}',
                          style: text.titleSmall?.copyWith(color: palette.hot),
                        ),
                      ),
                      const SizedBox(width: EcSpace.md),
                      Expanded(
                        child: Text(l10n.focus(item), style: text.bodyLarge),
                      ),
                      const SizedBox(width: EcSpace.sm),
                      FilledButton.tonal(
                        key: Key('practice-$i'),
                        onPressed: () => context.push(
                          Routes.puzzleSet(item.filter.encode()),
                        ),
                        child: Text(l10n.practice),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      _Section(
        title: l10n.averageAccuracy,
        icon: Icons.speed_rounded,
        color: palette.brand,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: EcSpace.md,
              children: [
                Text(
                  pct(report.averageAccuracy),
                  style: text.displaySmall?.copyWith(color: palette.brand),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    l10n.gamesAnalyzedCount(report.gamesAnalyzed),
                    style: text.bodyMedium?.copyWith(color: palette.inkMuted),
                  ),
                ),
              ],
            ),
            if (report.timeline.length >= 2) ...[
              const SizedBox(height: EcSpace.md),
              Text(l10n.accuracyOverTime, style: text.labelLarge),
              const SizedBox(height: EcSpace.sm),
              _Timeline(
                values: [for (final t in report.timeline) t.accuracy],
                color: palette.brand,
                grid: palette.surfaceAlt,
                label: l10n.accuracyOverTime,
              ),
            ],
          ],
        ),
      ),
      if (report.byPhase.isNotEmpty)
        _Section(
          title: l10n.accuracyByPhase,
          icon: Icons.timeline_rounded,
          color: palette.zap,
          child: Column(
            children: [
              for (final p in GamePhase.values)
                if (report.byPhase[p] case final s?)
                  _Bar(
                    label: l10n.phase(p),
                    fraction: s.accuracy / 100,
                    trailing: pct(s.accuracy),
                    color: palette.zap,
                  ),
            ],
          ),
        ),
      if (report.byColor.isNotEmpty)
        _Section(
          title: l10n.whiteVsBlack,
          icon: Icons.contrast_rounded,
          color: palette.sun,
          child: Column(
            children: [
              for (final white in [true, false])
                if (report.byColor[white] case final s?)
                  _Bar(
                    label: white ? l10n.asWhite : l10n.asBlack,
                    sublabel: [
                      l10n.gamesCount(s.games),
                      if (s.score != null)
                        l10n.scorePercent((s.score! * 100).round()),
                    ].join(' · '),
                    fraction: (s.accuracy ?? 0) / 100,
                    trailing: pct(s.accuracy),
                    color: palette.sun,
                  ),
            ],
          ),
        ),
      if (report.bySpeed.length > 1 ||
          (report.bySpeed.isNotEmpty &&
              report.bySpeed.keys.first != GameSpeed.unknown))
        _Section(
          title: l10n.byTimeControl,
          icon: Icons.timer_rounded,
          color: palette.brand,
          child: Column(
            children: [
              for (final e in report.bySpeed.entries)
                _Bar(
                  label: l10n.speed(e.key),
                  sublabel: [
                    l10n.gamesCount(e.value.games),
                    if (e.value.score != null)
                      l10n.scorePercent((e.value.score! * 100).round()),
                  ].join(' · '),
                  fraction: (e.value.accuracy ?? 0) / 100,
                  trailing: pct(e.value.accuracy),
                  color: palette.brand,
                ),
            ],
          ),
        ),
      if (categories.isNotEmpty)
        _Section(
          title: l10n.vulnerabilitiesTitle,
          icon: Icons.warning_amber_rounded,
          color: palette.hot,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in categories)
                _Bar(
                  label: l10n.category(e.key),
                  fraction: e.value / maxCategory,
                  trailing: l10n.mistakesCount(e.value),
                  color: palette.hot,
                  onTap: () => context.push(
                    Routes.puzzleSet(PuzzleFilter(category: e.key).encode()),
                  ),
                ),
              if (report.timeTroubleErrors > 0)
                Padding(
                  padding: const EdgeInsets.only(top: EcSpace.sm),
                  child: Row(
                    children: [
                      Icon(Icons.timer_off_rounded, color: palette.sun),
                      const SizedBox(width: EcSpace.sm),
                      Expanded(
                        child: Text(
                          l10n.timeTroubleStat(report.timeTroubleErrors),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      if (tactics.isNotEmpty)
        _Section(
          title: l10n.tacticsTitle,
          icon: Icons.bolt_rounded,
          color: palette.zap,
          child: Column(
            children: [
              for (final e in tactics)
                _Bar(
                  label: l10n.theme(e.key),
                  sublabel: l10n.foundOfTotal(e.value.found, e.value.total),
                  fraction: e.value.found / e.value.total,
                  trailing: '${(e.value.found / e.value.total * 100).round()}%',
                  color: e.value.found / e.value.total >= 0.6
                      ? palette.zap
                      : palette.hot,
                  onTap: () => context.push(
                    Routes.puzzleSet(PuzzleFilter(theme: e.key).encode()),
                  ),
                ),
            ],
          ),
        ),
      if (report.errorsByPiece.isNotEmpty)
        _Section(
          title: l10n.errorsByPieceTitle,
          icon: Icons.extension_rounded,
          color: palette.sun,
          child: Column(
            children: [
              for (final role in Role.values)
                if (report.errorsByPiece[role] case final n?)
                  _Bar(
                    label: l10n.piece(role),
                    fraction: n / maxPiece,
                    trailing: l10n.mistakesCount(n),
                    color: palette.sun,
                  ),
            ],
          ),
        ),
      if (report.openings.isNotEmpty)
        _Section(
          title: l10n.openingsTitle,
          icon: Icons.menu_book_rounded,
          color: palette.brand,
          child: Column(
            children: [
              for (final o in report.openings)
                _Bar(
                  label: o.name,
                  sublabel: [
                    o.asWhite ? l10n.asWhite : l10n.asBlack,
                    l10n.gamesCount(o.games),
                    if (o.score != null)
                      l10n.scorePercent((o.score! * 100).round()),
                  ].join(' · '),
                  fraction: (o.accuracy ?? 0) / 100,
                  trailing: pct(o.accuracy),
                  color: palette.brand,
                ),
            ],
          ),
        ),
      if (withoutSide > 0)
        Padding(
          padding: const EdgeInsets.all(EcSpace.sm),
          child: Text(
            l10n.reportGamesWithoutSide(withoutSide),
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: palette.inkMuted),
          ),
        ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(EcSpace.md),
      itemCount: sections.length,
      separatorBuilder: (_, _) => const SizedBox(height: EcSpace.md),
      itemBuilder: (context, i) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: sections[i],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EcSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: EcSpace.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: EcSpace.md),
            child,
          ],
        ),
      ),
    );
  }
}

/// A labelled horizontal bar with a value at the end. The number is always
/// shown as text too, so the bar is never the only carrier of the value.
class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.fraction,
    required this.trailing,
    required this.color,
    this.sublabel,
    this.onTap,
  });

  final String label;
  final String? sublabel;
  final double fraction;
  final String trailing;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(trailing, style: text.labelLarge),
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
          if (sublabel != null)
            Text(
              sublabel!,
              style: text.bodySmall?.copyWith(color: context.palette.inkMuted),
            ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(EcRadii.pill),
            child: LinearProgressIndicator(
              value: fraction.clamp(0, 1).toDouble(),
              minHeight: 8,
              color: color,
              backgroundColor: context.palette.surfaceAlt,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(EcRadii.sm),
      child: row,
    );
  }
}

/// Accuracy per game, oldest to newest (always left-to-right).
class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.values,
    required this.color,
    required this.grid,
    required this.label,
  });

  final List<double> values;
  final Color color;
  final Color grid;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: ForceLtr(
        child: SizedBox(
          height: 96,
          width: double.infinity,
          child: CustomPaint(painter: _TimelinePainter(values, color, grid)),
        ),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter(this.values, this.color, this.grid);

  final List<double> values;
  final Color color;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final frac in [0.0, 0.5, 1.0]) {
      final y = size.height * frac;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    // Scale to the data's own range (with some headroom) so trends show.
    final lo = (values.reduce((a, b) => a < b ? a : b) - 5).clamp(0, 100);
    final hi = (values.reduce((a, b) => a > b ? a : b) + 5).clamp(0, 100);
    final span = (hi - lo) == 0 ? 1 : hi - lo;
    Offset at(int i) => Offset(
      values.length == 1 ? 0 : i / (values.length - 1) * size.width,
      size.height * (1 - (values[i] - lo) / span),
    );

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    if (values.length <= 40) {
      for (var i = 0; i < values.length; i++) {
        canvas.drawCircle(at(i), 4, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(_TimelinePainter old) =>
      old.values != values || old.color != color;
}
