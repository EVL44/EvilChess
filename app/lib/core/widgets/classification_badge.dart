import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/move_classification.dart';
import '../theme/tokens.dart';

/// Round badge for a [MoveClass]: colour + glyph, with a screen-reader label.
class ClassificationBadge extends StatelessWidget {
  const ClassificationBadge(
    this.moveClass, {
    super.key,
    this.size = 28,
    this.showLabel = false,
  });

  final MoveClass moveClass;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = moveClass.label(l10n);
    final glyph = moveClass.glyph;

    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: moveClass.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size / 14),
      ),
      child: glyph.icon != null
          ? Icon(glyph.icon, size: size * 0.6, color: Colors.white)
          : Text(
              glyph.text!,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.48,
                height: 1,
              ),
            ),
    );

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: showLabel
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                circle,
                const SizedBox(width: EcSpace.sm),
                Text(label, style: Theme.of(context).textTheme.labelLarge),
              ],
            )
          : circle,
    );
  }
}
