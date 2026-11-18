import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fake_server.dart';

/// Lichess-format puzzles the fake serves.
const forkPuzzle = {
  'id': 'fork1',
  'fen': 'r3k3/8/8/1N6/8/8/8/4K3 b - - 0 1',
  'moves': ['a8a7', 'b5c7', 'e8d7', 'c7a8'],
  'rating': 1650,
  'themes': ['fork', 'short'],
};

const matePuzzle = {
  'id': 'mate1',
  'fen': '6k1/5ppp/8/8/p7/8/5PPP/2RR2K1 b - - 0 1',
  'moves': ['a4a3', 'c1c8'],
  'rating': 700,
  'themes': ['mateIn1', 'backRankMate'],
};

/// A fake evilchess server: accounts, profile, sync, puzzles and rush.
class FakeApi {
  final sync = FakeSyncServer();
  final users = <String, ({String password, String name})>{};
  String? signedInEmail;
  int rating = 1500;
  final attempts = <String, bool>{};
  final rush = <String, int>{'3min': 0, '5min': 0, 'survival': 0};
  int _token = 0;

  http.Response _json(Object body, [int status = 200]) =>
      http.Response(jsonEncode(body), status);

  http.Response _err(int status, String code) =>
      _json({'code': code, 'message': code}, status);

  Map<String, Object> _tokens() => {
    'accessToken': 'access-${++_token}',
    'refreshToken': 'refresh-$_token',
    'expiresIn': 900,
  };

  Map<String, Object?> _me() {
    final u = users[signedInEmail]!;
    return {
      'id': 'user-$signedInEmail',
      'email': signedInEmail,
      'displayName': u.name,
      'puzzleRating': rating,
      'puzzleRd': 200,
      'provisional': attempts.length < 3,
      'puzzlesPlayed': attempts.length,
    };
  }

  http.Client client() => MockClient((req) async {
    final path = req.url.path;
    final body = req.body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(req.body) as Map<String, dynamic>;
    final authed = req.headers['Authorization']?.startsWith('Bearer ') ?? false;

    switch ((req.method, path)) {
      case ('POST', '/api/v1/auth/register'):
        final email = (body['email'] as String).trim().toLowerCase();
        if (users.containsKey(email)) return _err(409, 'email_taken');
        users[email] = (
          password: body['password'] as String,
          name: (body['displayName'] as String?) ?? email.split('@').first,
        );
        signedInEmail = email;
        return _json(_tokens(), 201);
      case ('POST', '/api/v1/auth/login'):
        final email = (body['email'] as String).trim().toLowerCase();
        if (users[email]?.password != body['password']) {
          return _err(401, 'invalid_credentials');
        }
        signedInEmail = email;
        return _json(_tokens());
      case ('POST', '/api/v1/auth/logout'):
        return http.Response('', 204);
      case ('POST', '/api/v1/auth/refresh'):
        return _json(_tokens());
      case ('GET', '/api/v1/puzzles/daily'):
        return _json(matePuzzle);
      case ('GET', '/api/v1/puzzles/batch'):
        return _json([matePuzzle, forkPuzzle]);
    }
    if (!authed || signedInEmail == null) return _err(401, 'unauthorized');
    switch ((req.method, path)) {
      case ('GET', '/api/v1/me'):
        return _json(_me());
      case ('POST', '/api/v1/sync'):
        return _json(sync.handle(body));
      case ('GET', '/api/v1/puzzles/next'):
        return _json(forkPuzzle);
      case ('GET', '/api/v1/rush'):
        return _json(rush);
      case ('POST', '/api/v1/rush'):
        final mode = body['mode'] as String;
        final score = (body['score'] as num).toInt();
        final newBest = score > rush[mode]!;
        if (newBest) rush[mode] = score;
        return _json({'mode': mode, 'best': rush[mode], 'newBest': newBest});
    }
    final attempt = RegExp(r'^/api/v1/puzzles/(\w+)/attempt$').firstMatch(path);
    if (attempt != null) {
      final id = attempt[1]!;
      if (attempts.containsKey(id)) {
        return _json({
          'rated': false,
          'rating': rating,
          'delta': 0,
          'rd': 200,
          'provisional': true,
        });
      }
      final win = body['win'] as bool;
      attempts[id] = win;
      final delta = win ? 20 : -15;
      rating += delta;
      return _json({
        'rated': true,
        'rating': rating,
        'delta': delta,
        'rd': 200,
        'provisional': true,
      });
    }
    return _err(404, 'not_found');
  });
}
