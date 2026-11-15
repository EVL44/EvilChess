/// Chess.com flavour: `{[%clk ...]}` comments, `1...` black move numbers,
/// `Link` instead of a URL in `Site`, extra headers.
const chessComPgn = '''
[Event "Live Chess"]
[Site "Chess.com"]
[Date "2026.10.01"]
[Round "-"]
[White "Alice"]
[Black "bob"]
[Result "1-0"]
[CurrentPosition "r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4"]
[Timezone "UTC"]
[ECO "C20"]
[ECOUrl "https://www.chess.com/openings/Kings-Pawn-Opening-Wayward-Queen-Attack"]
[UTCDate "2026.10.01"]
[UTCTime "18:22:05"]
[WhiteElo "1500"]
[BlackElo "1480"]
[TimeControl "180+2"]
[Termination "Alice won by checkmate"]
[StartTime "18:22:05"]
[EndDate "2026.10.01"]
[EndTime "18:24:00"]
[Link "https://www.chess.com/game/live/123456"]

1. e4 {[%clk 0:03:01.9]} 1... e5 {[%clk 0:03:01.2]} 2. Qh5 {[%clk 0:03:02.5]} 2... Nc6 {[%clk 0:03:00.1]} 3. Bc4 {[%clk 0:03:03.6]} 3... Nf6 {[%clk 0:02:58.3]} 4. Qxf7# {[%clk 0:03:04.4]} 1-0
''';

/// Lichess flavour: spaced clock comments, URL in `Site`, castling.
const lichessPgn = '''
[Event "Rated Blitz game"]
[Site "https://lichess.org/abcd1234"]
[Date "2026.10.02"]
[White "carol"]
[Black "dave"]
[Result "0-1"]
[UTCDate "2026.10.02"]
[UTCTime "09:00:00"]
[WhiteElo "1700"]
[BlackElo "1720"]
[Variant "Standard"]
[TimeControl "300+0"]
[ECO "C50"]
[Opening "Italian Game"]
[Termination "Normal"]

1. e4 { [%clk 0:05:00] } 1... e5 { [%clk 0:05:00] } 2. Nf3 { [%clk 0:04:58] } 2... Nc6 { [%clk 0:04:57] } 3. Bc4 { [%clk 0:04:55] } 3... Bc5 { [%clk 0:04:54] } 4. O-O { [%clk 0:04:50] } 4... Nf6 { [%clk 0:04:51] } 0-1
''';

/// Custom start position via SetUp/FEN, Black to move first.
const fenPgn = '''
[Event "Endgame drill"]
[White "Me"]
[Black "Engine"]
[Result "*"]
[SetUp "1"]
[FEN "4k3/8/8/8/8/8/4P3/4K3 b - - 0 1"]

1... Kd7 2. e4 Ke6 *
''';

/// Third move is illegal: everything before it is kept.
const illegalPgn = '''
[White "A"]
[Black "B"]
[Result "*"]

1. e4 e5 2. Ke3 Nc6 *
''';
