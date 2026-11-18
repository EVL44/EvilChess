import 'package:material_ui/material_ui.dart';

import '../domain/bot.dart';

/// Round avatar for a bot: its colour, its icon and a pair of little horns.
class BotAvatar extends StatelessWidget {
  const BotAvatar({super.key, required this.bot, this.size = 56});

  final Bot bot;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: bot.name,
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _HornsPainter(bot.color),
          child: Padding(
            padding: EdgeInsets.all(size * 0.1),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(bot.color, Colors.white, 0.25)!,
                    bot.color,
                  ],
                ),
              ),
              child: Center(
                child: Icon(bot.icon, color: Colors.white, size: size * 0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HornsPainter extends CustomPainter {
  _HornsPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()..color = Color.lerp(color, Colors.black, 0.35)!;
    for (final dir in [-1.0, 1.0]) {
      final cx = s / 2 + dir * s * 0.24;
      final path = Path()
        ..moveTo(cx - dir * s * 0.08, s * 0.2)
        ..quadraticBezierTo(
          cx + dir * s * 0.1,
          s * 0.12,
          cx + dir * s * 0.14,
          0,
        )
        ..quadraticBezierTo(
          cx + dir * s * 0.02,
          s * 0.06,
          cx + dir * s * 0.06,
          s * 0.24,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_HornsPainter old) => old.color != color;
}
