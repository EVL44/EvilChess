import 'dart:convert';

import 'package:evilchess/core/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiClient', () {
    test('sends the bearer token and decodes JSON', () async {
      late http.Request seen;
      final api = ApiClient(
        baseUrl: 'http://api',
        httpClient: MockClient((r) async {
          seen = r;
          return http.Response('{"ok":true}', 200);
        }),
        store: MemoryTokenStore()..tokens = const Tokens('A1', 'R1'),
      );
      expect(await api.post('/x', {'a': 1}), {'ok': true});
      expect(seen.headers['Authorization'], 'Bearer A1');
      expect(jsonDecode(seen.body), {'a': 1});
    });

    test('on 401 refreshes once, retries, and stores the new tokens', () async {
      final store = MemoryTokenStore()..tokens = const Tokens('old', 'R1');
      var refreshes = 0;
      final api = ApiClient(
        baseUrl: 'http://api',
        store: store,
        httpClient: MockClient((r) async {
          if (r.url.path == '/api/v1/auth/refresh') {
            refreshes++;
            expect(jsonDecode(r.body), {'refreshToken': 'R1'});
            await Future<void>.delayed(const Duration(milliseconds: 10));
            return http.Response(
              '{"accessToken":"new","refreshToken":"R2","expiresIn":900}',
              200,
            );
          }
          return r.headers['Authorization'] == 'Bearer new'
              ? http.Response('{"me":1}', 200)
              : http.Response('{"code":"unauthorized","message":"x"}', 401);
        }),
      );
      // Three parallel requests share one refresh.
      final results = await Future.wait([
        api.get('/a'),
        api.get('/b'),
        api.get('/c'),
      ]);
      expect(results, everyElement({'me': 1}));
      expect(refreshes, 1);
      expect(store.tokens!.refreshToken, 'R2');
    });

    test('a failed refresh signs out', () async {
      final store = MemoryTokenStore()..tokens = const Tokens('old', 'R1');
      var signedOut = false;
      final api = ApiClient(
        baseUrl: 'http://api',
        store: store,
        onSignedOut: () => signedOut = true,
        httpClient: MockClient(
          (r) async => http.Response(
            '{"code":"refresh_token_reused","message":"x"}',
            401,
          ),
        ),
      );
      await expectLater(
        api.get('/me'),
        throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)),
      );
      expect(signedOut, isTrue);
      expect(store.tokens, isNull);
    });

    test('server errors and network failures become ApiExceptions', () async {
      final api = ApiClient(
        baseUrl: 'http://api',
        store: MemoryTokenStore(),
        httpClient: MockClient((r) async {
          if (r.url.path == '/down') throw Exception('connection refused');
          return http.Response('{"code":"email_taken","message":"Taken"}', 409);
        }),
      );
      await expectLater(
        api.post('/register', {}),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'email_taken')
              .having((e) => e.status, 'status', 409),
        ),
      );
      await expectLater(
        api.get('/down'),
        throwsA(
          isA<ApiException>().having((e) => e.isNetwork, 'network', true),
        ),
      );
    });
  });
}
