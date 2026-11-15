import 'package:material_ui/material_ui.dart';

import '../../../core/theme/move_classification.dart';
import '../../../core/widgets/force_ltr.dart';
import '../../../l10n/app_localizations.dart';
import '../../analysis/domain/game_analysis.dart';

/// White's win% over the game. Tap or drag to jump to a move. Mistakes are
/// marked with dots in their classification colour. Always left-to-right
/// (time flows the same way in every language).
class EvalGraph extends StatelessWidget {
  const EvalGraph({
    super.key,
    required this.analysis,
    required this.currentPly,
    required this.onSelect,
    this.height = 72,
  });

  final GameAnalysis analysis;
  final int currentPly;
  final ValueChanged<int> onSelect;
  final double height;

  void _select(Offset local, double width) {
    final n = analysis.whiteEvals.length;
    if (n < 2) return;
    final idx = (local.dx / width * (n - 1)).round().clamp(0, n - 1);
    onSelect(idx - 1); // position idx is after move idx-1
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: AppLocalizations.of(context).evalGraphLabel,
      child: ForceLtr(
        child: SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, c) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _select(d.localPosition, c.maxWidth),
              onHorizontalDragUpdate: (d) =>
                  _select(d.localPosition, c.maxWidth),
              child: CustomPaint(
                size: Size(c.maxWidth, height),
                painter: _GraphPainter(
                  wins: [
                    for (final e in analysis.whiteEvals) e.whiteWinPercent,
                  ],
                  marks: [
                    for (final m in analysis.moves)
                      if (m.isMistakeOrWorse) (m.ply + 1, m.classification),
                  ],
                  current: currentPly + 1,
                  line: scheme.primary,
                  dark: const Color(0xFF2B2140),
                  light: const Color(0xFFF7F3FF),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.wins,
    required this.marks,
    required this.current,
    required this.line,
    required this.dark,
    required this.light,
  });

  final List<double> wins;
  final List<(int, MoveClass)> marks;
  final int current;
  final Color line;
  final Color dark;
  final Color light;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    canvas.clipRRect(r);
    canvas.drawRect(Offset.zero & size, Paint()..color = dark);
    if (wins.length < 2) return;

    double x(int i) => i / (wins.length - 1) * size.width;
    double y(double w) => size.height * (1 - w / 100);

    final area = Path()..moveTo(0, size.height);
    for (var i = 0; i < wins.length; i++) {
      area.lineTo(x(i), y(wins[i]));
    }
    area
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = light);

    // Midline
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()
        ..color = line.withValues(alpha: 0.35)
        ..strokeWidth = 1,
    );

    // Current position
    final cx = x(current.clamp(0, wins.length - 1));
    canvas.drawLine(
      Offset(cx, 0),
      Offset(cx, size.height),
      Paint()
        ..color = line
        ..strokeWidth = 2.5,
    );

    for (final (i, cls) in marks) {
      if (i >= wins.length) continue;
      final p = Offset(x(i), y(wins[i]).clamp(5, size.height - 5));
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.6, Paint()..color = cls.color);
    }
  }

  @override
  bool shouldRepaint(_GraphPainter old) =>
      old.current != current || old.wins != wins || old.line != line;
}
