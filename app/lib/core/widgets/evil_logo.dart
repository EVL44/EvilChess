import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// The evilchess mark: a pawn with little devil horns on a purple tile.
/// Drawn in code so it scales crisply everywhere; store icons come later.
class EvilLogo extends StatelessWidget {
  const EvilLogo({super.key, this.size = 44, this.semanticLabel});

  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: true,
      child: CustomPaint(size: Size.square(size), painter: _EvilLogoPainter()),
    );
  }
}

class _EvilLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final tile = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(s * 0.28),
    );
    canvas.drawRRect(
      tile,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [EcColors.purple, EcColors.magenta],
        ).createShader(Offset.zero & size),
    );

    final ink = Paint()..color = Colors.white;
    final horn = Paint()..color = EcColors.limeLight;

    // Horns
    for (final dir in [-1.0, 1.0]) {
      final cx = s * 0.5 + dir * s * 0.1;
      final path = Path()
        ..moveTo(cx - dir * s * 0.02, s * 0.30)
        ..quadraticBezierTo(
          cx + dir * s * 0.14,
          s * 0.22,
          cx + dir * s * 0.13,
          s * 0.10,
        )
        ..quadraticBezierTo(
          cx + dir * s * 0.06,
          s * 0.22,
          cx + dir * s * 0.08,
          s * 0.33,
        )
        ..close();
      canvas.drawPath(path, horn);
    }

    // Pawn: head, neck collar, body, base
    canvas.drawCircle(Offset(s * 0.5, s * 0.36), s * 0.11, ink);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(s * 0.5, s * 0.5),
          width: s * 0.28,
          height: s * 0.06,
        ),
        Radius.circular(s * 0.03),
      ),
      ink,
    );
    final body = Path()
      ..moveTo(s * 0.42, s * 0.52)
      ..lineTo(s * 0.58, s * 0.52)
      ..quadraticBezierTo(s * 0.60, s * 0.66, s * 0.68, s * 0.74)
      ..lineTo(s * 0.32, s * 0.74)
      ..quadraticBezierTo(s * 0.40, s * 0.66, s * 0.42, s * 0.52)
      ..close();
    canvas.drawPath(body, ink);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.27, s * 0.73, s * 0.46, s * 0.09),
        Radius.circular(s * 0.04),
      ),
      ink,
    );

    // Eyes
    final eye = Paint()..color = EcColors.purpleDeep;
    canvas.drawCircle(Offset(s * 0.46, s * 0.36), s * 0.018, eye);
    canvas.drawCircle(Offset(s * 0.54, s * 0.36), s * 0.018, eye);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
