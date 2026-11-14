import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' show Side;
import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Board colour themes. More (and Pro custom boards) arrive in later phases.
enum BoardTheme {
  grape(EcColors.boardLight, EcColors.boardDark),
  mint(Color(0xFFE8F5E9), Color(0xFF4CAF7D)),
  classic(Color(0xFFF0D9B6), Color(0xFFB58863));

  const BoardTheme(this.lightSquare, this.darkSquare);

  final Color lightSquare;
  final Color darkSquare;

  ChessboardColorScheme get colorScheme => ChessboardColorScheme(
    lightSquare: lightSquare,
    darkSquare: darkSquare,
    background: SolidColorChessboardBackground(
      lightSquare: lightSquare,
      darkSquare: darkSquare,
    ),
    whiteCoordBackground: SolidColorChessboardBackground(
      lightSquare: lightSquare,
      darkSquare: darkSquare,
      coordinates: true,
    ),
    blackCoordBackground: SolidColorChessboardBackground(
      lightSquare: lightSquare,
      darkSquare: darkSquare,
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: const HighlightDetails(solidColor: Color(0x80F59E0B)),
    selected: const HighlightDetails(solidColor: Color(0x60DB2777)),
    validMoves: const Color(0x406D28D9),
    validPremoves: const Color(0x40203085),
  );
}
