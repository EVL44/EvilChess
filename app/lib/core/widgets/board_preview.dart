import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' show Side, kInitialBoardFEN;
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/board_themes.dart';
import '../theme/tokens.dart';
import 'force_ltr.dart';

/// A non-interactive board. Always laid out left-to-right, even in Arabic:
/// file a is on White's left no matter the UI language.
class BoardPreview extends StatelessWidget {
  const BoardPreview({
    super.key,
    this.fen = kInitialBoardFEN,
    this.orientation = Side.white,
    this.theme = BoardTheme.grape,
    this.semanticLabel,
  });

  final String fen;
  final Side orientation;
  final BoardTheme theme;

  /// Screen-reader description. Defaults to "Chessboard".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: semanticLabel ?? l10n.boardLabel,
      image: true,
      excludeSemantics: true,
      child: ForceLtr(
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) => StaticChessboard(
              size: constraints.maxWidth,
              orientation: orientation,
              fen: fen,
              settings: StaticChessboardSettings(
                colorScheme: theme.colorScheme,
                enableCoordinates: true,
                borderRadius: BorderRadius.circular(EcRadii.md),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
