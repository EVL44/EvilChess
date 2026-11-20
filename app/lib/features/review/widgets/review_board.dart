import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/board_themes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/force_ltr.dart';

/// The board used on the review screen. Shows a position with the last move,
/// optional arrows and a classification glyph on the moved piece. When
/// [interactive] is true (Retry mode) the side to move can play a move.
class ReviewBoard extends StatefulWidget {
  const ReviewBoard({
    super.key,
    required this.fen,
    required this.orientation,
    this.lastMoveUci,
    this.shapes = const {},
    this.annotations = const {},
    this.interactive = false,
    this.onMove,
    this.semanticLabel,
    this.theme = BoardTheme.grape,
    this.revision = 0,
  });

  final String fen;
  final Side orientation;
  final String? lastMoveUci;
  final Set<Shape> shapes;
  final Map<Square, Annotation> annotations;
  final bool interactive;
  final void Function(NormalMove move)? onMove;
  final String? semanticLabel;
  final BoardTheme theme;

  /// Bump to redraw the position even when [fen] is unchanged (e.g. to undo
  /// a rejected move the player dragged on the board).
  final int revision;

  @override
  State<ReviewBoard> createState() => _ReviewBoardState();
}

class _ReviewBoardState extends State<ReviewBoard> {
  late final ChessboardController _controller = ChessboardController(
    game: _gameData(),
  );

  GameData _gameData() {
    final pos = Chess.fromSetup(Setup.parseFen(widget.fen));
    final last = widget.lastMoveUci == null
        ? null
        : Move.parse(widget.lastMoveUci!);
    return GameData(
      fen: widget.fen,
      playerSide: widget.interactive
          ? (pos.turn == Side.white ? PlayerSide.white : PlayerSide.black)
          : PlayerSide.none,
      sideToMove: pos.turn,
      validMoves: widget.interactive ? makeLegalMoves(pos) : const {},
      lastMove: last,
      kingSquareInCheck: pos.isCheck ? pos.board.kingOf(pos.turn) : null,
    );
  }

  @override
  void didUpdateWidget(ReviewBoard old) {
    super.didUpdateWidget(old);
    if (old.fen != widget.fen ||
        old.interactive != widget.interactive ||
        old.lastMoveUci != widget.lastMoveUci ||
        old.revision != widget.revision) {
      _controller.updatePosition(_gameData());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      child: ForceLtr(
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, c) => Chessboard(
              size: c.maxWidth,
              controller: _controller,
              orientation: widget.orientation,
              shapes: widget.shapes,
              annotations: widget.annotations,
              settings: ChessboardSettings(
                colorScheme: widget.theme.colorScheme,
                borderRadius: BorderRadius.circular(EcRadii.md),
                enablePremoves: false,
                animationDuration: const Duration(milliseconds: 180),
              ),
              onMove: (move, {viaDragAndDrop}) {
                if (move is NormalMove) widget.onMove?.call(move);
              },
            ),
          ),
        ),
      ),
    );
  }
}
