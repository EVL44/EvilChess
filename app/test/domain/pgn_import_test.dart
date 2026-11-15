import 'package:evilchess/features/games/domain/game_record.dart';
import 'package:evilchess/features/games/domain/pgn_import.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/pgns.dart';

void main() {
  group('Chess.com PGN', () {
    final game = parsePgnGames(chessComPgn).single;

    test('reads headers', () {
      expect(game.white, 'Alice');
      expect(game.black, 'bob');
      expect(game.whiteElo, 1500);
      expect(game.result, '1-0');
      expect(game.eco, 'C20');
      expect(game.url, 'https://www.chess.com/game/live/123456');
      expect(game.playedAt, DateTime.utc(2026, 10, 1, 18, 22, 5));
      expect(game.timeControl, const TimeControl(180, 2));
      expect(game.speed, GameSpeed.blitz);
    });

    test('handles "1..." move numbers and reaches mate', () {
      expect(game.plies.map((p) => p.san), [
        'e4', 'e5', 'Qh5', 'Nc6', 'Bc4', 'Nf6', 'Qxf7#', //
      ]);
      expect(game.plies.last.uci, 'h5f7');
    });

    test('reads [%clk] comments including tenths of a second', () {
      expect(
        game.plies[0].clock,
        const Duration(minutes: 3, seconds: 1, milliseconds: 900),
      );
      expect(
        game.plies[5].clock,
        const Duration(minutes: 2, seconds: 58, milliseconds: 300),
      );
    });

    test('pasting the same PGN twice gives the same id', () {
      expect(parsePgnGames(chessComPgn).single.id, game.id);
      expect(game.id, startsWith('pgn:'));
    });
  });

  group('Lichess PGN', () {
    final game = parsePgnGames(lichessPgn).single;

    test('reads URL from Site and opening name', () {
      expect(game.url, 'https://lichess.org/abcd1234');
      expect(game.opening, 'Italian Game');
      expect(game.speed, GameSpeed.blitz);
    });

    test('castling is stored as king destination UCI', () {
      final castle = game.plies.firstWhere((p) => p.san == 'O-O');
      expect(castle.uci, 'e1g1');
    });

    test('spaced clock comments', () {
      expect(game.plies[2].clock, const Duration(minutes: 4, seconds: 58));
    });
  });

  test('custom FEN with Black to move', () {
    final game = parsePgnGames(fenPgn).single;
    expect(game.initialFen, startsWith('4k3/8/8/8/8/8/4P3/4K3 b'));
    expect(game.plies.map((p) => p.san), ['Kd7', 'e4', 'Ke6']);
    expect(game.plies.first.fenBefore, game.initialFen);
  });

  test('stops at the first illegal move', () {
    final game = parsePgnGames(illegalPgn).single;
    expect(game.plies.map((p) => p.san), ['e4', 'e5']);
  });

  test('multi-game files, Windows line endings, junk is skipped', () {
    final text = [
      chessComPgn,
      lichessPgn,
      '[White "x"]\n[Black "y"]\n\n*\n', // no moves
    ].join('\n').replaceAll('\n', '\r\n');
    final games = parsePgnGames(text);
    expect(games.map((g) => g.white), ['Alice', 'carol']);
  });

  test('a game with headers directly after the previous movetext', () {
    final text = '${chessComPgn.trim()}\n${lichessPgn.trim()}';
    expect(parsePgnGames(text), hasLength(2));
  });

  test('plain movetext without headers', () {
    final games = parsePgnGames('1. d4 d5 2. c4 e6');
    expect(games.single.plies, hasLength(4));
    expect(games.single.white, 'White');
  });

  group('TimeControl', () {
    test('parses and classifies', () {
      expect(TimeControl.parse('60')!.speed, GameSpeed.bullet);
      expect(TimeControl.parse('120+1')!.speed, GameSpeed.bullet);
      expect(TimeControl.parse('180+2')!.speed, GameSpeed.blitz);
      expect(TimeControl.parse('600')!.speed, GameSpeed.rapid);
      expect(TimeControl.parse('900+10')!.speed, GameSpeed.rapid);
      expect(TimeControl.parse('1800')!.speed, GameSpeed.classical);
      expect(TimeControl.parse('15')!.speed, GameSpeed.ultraBullet);
    });

    test('daily and missing controls', () {
      expect(TimeControl.parse('1/259200'), isNull);
      expect(TimeControl.parse('-'), isNull);
      expect(TimeControl.parse(null), isNull);
    });

    test('daily PGN is correspondence', () {
      final g = parsePgnGames('[TimeControl "1/259200"]\n\n1. e4 e5 *').single;
      expect(g.speed, GameSpeed.correspondence);
    });
  });

  test('ply JSON round-trips', () {
    final ply = parsePgnGames(chessComPgn).single.plies.first;
    final copy = GamePly.fromJson(ply.toJson());
    expect(copy.san, ply.san);
    expect(copy.uci, ply.uci);
    expect(copy.fenAfter, ply.fenAfter);
    expect(copy.clock, ply.clock);
  });
}
