import 'package:material_ui/material_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../../analysis/domain/evaluation.dart';

/// Vertical bar showing White's winning chances; White's share grows from
/// the side White sits on. Animates between positions.
class EvalBar extends StatelessWidget {
  const EvalBar({
    super.key,
    required this.eval,
    this.whiteAtBottom = true,
    this.width = 18,
  });

  final Eval? eval;
  final bool whiteAtBottom;
  final double width;

  @override
  Widget build(BuildContext context) {
    final white = (eval?.whiteWinPercent ?? 50) / 100;
    final label = eval?.label ?? '';
    final whiteLeads = (eval?.whiteWinPercent ?? 50) >= 50;
    final text = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w900,
      color: whiteLeads ? const Color(0xFF1E1530) : Colors.white,
    );

    return Semantics(
      label: AppLocalizations.of(context).evalBarLabel(label),
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width / 2),
        child: SizedBox(
          width: width,
          child: LayoutBuilder(
            builder: (context, c) {
              return Stack(
                children: [
                  Container(color: const Color(0xFF2B2140)),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left: 0,
                    right: 0,
                    top: whiteAtBottom ? c.maxHeight * (1 - white) : 0,
                    bottom: whiteAtBottom ? 0 : c.maxHeight * (1 - white),
                    child: Container(color: const Color(0xFFF7F3FF)),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: whiteLeads == whiteAtBottom ? null : 4,
                    bottom: whiteLeads == whiteAtBottom ? 4 : null,
                    child: Text(
                      label.replaceAll('+', '').replaceAll('-', ''),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: text,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
