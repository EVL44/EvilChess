import 'dart:convert';

import 'package:evilchess/features/games/data/online_import.dart';
import 'package:evilchess/features/games/domain/game_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../fixtures/pgns.dart';

Map<String, Object?> lichessJson(String id, int createdAt) => {
  'id': id,
  'rated': true,
  'variant': 'standard',
  'speed': 'blitz',
  'createdAt': createdAt,
  'players': {
    'white': {
      'user': {'name': 'carol'},
      'rating': 1700,
    },
    'black': {
      'user': {'name': 'dave'},
      'rating': 1720,
    },
  },
  'pgn': lichessPgn,
};

void main() {
  group('Lichess', () {
    test('streams NDJSON games and sends the right query', () async {
      late Uri seen;
      late Map<String, String> headers;
      final client = MockClient.streaming((req, _) async {
        seen = req.url;
        headers = req.headers;
        final body = [
          jsonEncode(lichessJson('g1', 1760000000000)),
          '',
          jsonEncode(lichessJson('g2', 1760000100000)),
        ].join('\n');
        return http.StreamedResponse(Stream.value(utf8.encode(body)), 200);
      });

      final since = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      final games = await LichessImporter(client)
          .fetchGames('carol', since: since)
          .toList();

      expect(games.map((g) => g.id), ['lichess:g1', 'lichess:g2']);
      expect(games.first.url, 'https://lichess.org/g1');
      expect(games.first.speed, GameSpeed.blitz);
      expect(
        games.first.playedAt,
        DateTime.fromMillisecondsSinceEpoch(1760000000000, isUtc: true),
      );
      expect(seen.path, '/api/games/user/carol');
      expect(seen.queryParameters['since'], '1700000000001');
      expect(seen.queryParameters['pgnInJson'], 'true');
      expect(seen.queryParameters['clocks'], 'true');
      expect(headers['Accept'], 'application/x-ndjson');
      expect(headers['User-Agent'], kApiUserAgent);
    });

    test('skips variants', () {
      final json = lichessJson('x', 1)..['variant'] = 'crazyhouse';
      expect(parseLichessGame(json.cast()), isNull);
    });

    test('404 and 429 become ImportExceptions', () async {
      for (final code in [404, 429]) {
        final client = MockClient((_) async => http.Response('', code));
        expect(
          LichessImporter(client).fetchGames('nobody').toList(),
          throwsA(
            isA<ImportException>().having((e) => e.statusCode, 'code', code),
          ),
        );
      }
    });
  });

  group('Chess.com', () {
    Map<String, Object?> game(
      String uuid,
      int endTime, {
      String rules = 'chess',
    }) => {
      'url': 'https://www.chess.com/game/live/$uuid',
      'uuid': uuid,
      'pgn': chessComPgn,
      'time_control': '180+2',
      'end_time': endTime,
      'rated': true,
      'time_class': 'blitz',
      'rules': rules,
      'white': {'username': 'Alice', 'rating': 1500, 'result': 'win'},
      'black': {'username': 'bob', 'rating': 1480, 'result': 'checkmated'},
    };

    test(
      'reads archives month by month, incremental from the last game',
      () async {
        final requested = <String>[];
        final client = MockClient((req) async {
          requested.add(req.url.path);
          if (req.url.path.endsWith('/archives')) {
            return http.Response(
              jsonEncode({
                'archives': [
                  'https://api.chess.com/pub/player/alice/games/2026/08',
                  'https://api.chess.com/pub/player/alice/games/2026/09',
                  'https://api.chess.com/pub/player/alice/games/2026/10',
                ],
              }),
              200,
            );
          }
          if (req.url.path.endsWith('2026/09')) {
            return http.Response(
              jsonEncode({
                'games': [
                  game(
                    'old',
                    DateTime.utc(2026, 9, 10).millisecondsSinceEpoch ~/ 1000,
                  ),
                  game(
                    'new',
                    DateTime.utc(2026, 9, 20).millisecondsSinceEpoch ~/ 1000,
                  ),
                ],
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'games': [
                game(
                  'oct',
                  DateTime.utc(2026, 10, 2).millisecondsSinceEpoch ~/ 1000,
                ),
                game(
                  '960',
                  DateTime.utc(2026, 10, 3).millisecondsSinceEpoch ~/ 1000,
                  rules: 'chess960',
                ),
              ],
            }),
            200,
          );
        });

        final games = await ChessComImporter(client)
            .fetchGames('Alice', since: DateTime.utc(2026, 9, 15))
            .toList();

        // August skipped entirely; "old" filtered; chess960 skipped.
        expect(games.map((g) => g.externalId), ['new', 'oct']);
        expect(requested, isNot(contains('/pub/player/alice/games/2026/08')));
        expect(requested.first, '/pub/player/alice/games/archives');
        expect(games.first.id, 'chesscom:new');
        expect(games.first.whiteElo, 1500);
        expect(games.first.speed, GameSpeed.blitz);
      },
    );

    test('unknown user', () {
      final client = MockClient((_) async => http.Response('{}', 404));
      expect(
        ChessComImporter(client).fetchGames('ghost').toList(),
        throwsA(isA<ImportException>()),
      );
    });
  });
}
