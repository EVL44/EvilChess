import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Where the evilchess server is. Set at build time with
/// `--dart-define=API_URL=https://api.example.com`; otherwise a local
/// development server (the Android emulator reaches the host as 10.0.2.2).
String defaultApiUrl() {
  const fromEnv = String.fromEnvironment('API_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080';
  }
  return 'http://localhost:8080';
}

/// An error answered by the server (`{"code": ..., "message": ...}`) or a
/// network failure (`code == 'network'`).
class ApiException implements Exception {
  const ApiException(this.status, this.code, this.message);

  final int status;
  final String code;
  final String message;

  bool get isNetwork => code == 'network';
  bool get isUnauthorized => status == 401;

  @override
  String toString() => 'ApiException($status, $code): $message';
}

/// Access + refresh token pair from the server.
@immutable
class Tokens {
  const Tokens(this.accessToken, this.refreshToken);

  factory Tokens.fromJson(Map<String, dynamic> json) =>
      Tokens(json['accessToken'] as String, json['refreshToken'] as String);

  final String accessToken;
  final String refreshToken;
}

/// Persists the refresh token (and caches the access token) between runs.
abstract interface class TokenStore {
  Future<Tokens?> read();
  Future<void> write(Tokens tokens);
  Future<void> clear();
}

/// In-memory store, for tests.
class MemoryTokenStore implements TokenStore {
  Tokens? tokens;

  @override
  Future<Tokens?> read() async => tokens;

  @override
  Future<void> write(Tokens t) async => tokens = t;

  @override
  Future<void> clear() async => tokens = null;
}

/// JSON-over-HTTP client for the evilchess API.
///
/// Adds the bearer token, and on a 401 refreshes the tokens once and retries.
/// Concurrent requests share a single refresh. If refreshing fails, the
/// session is cleared and [onSignedOut] is called.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.httpClient,
    required this.store,
    this.onSignedOut,
    this.timeout = const Duration(seconds: 20),
  });

  final String baseUrl;
  final http.Client httpClient;
  final TokenStore store;
  final Duration timeout;
  void Function()? onSignedOut;

  Tokens? _tokens;
  bool _loaded = false;
  Future<Tokens?>? _refreshing;

  Future<Tokens?> _current() async {
    if (!_loaded) {
      _tokens = await store.read();
      _loaded = true;
    }
    return _tokens;
  }

  Future<bool> get hasSession async => (await _current()) != null;

  Future<void> setTokens(Tokens tokens) async {
    _tokens = tokens;
    _loaded = true;
    await store.write(tokens);
  }

  Future<void> clearSession() async {
    _tokens = null;
    _loaded = true;
    await store.clear();
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      send('GET', path, query: query);

  Future<dynamic> post(String path, [Object? body]) =>
      send('POST', path, body: body);

  Future<dynamic> put(String path, [Object? body]) =>
      send('PUT', path, body: body);

  Future<dynamic> patch(String path, [Object? body]) =>
      send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => send('DELETE', path);

  /// Sends a request; [auth] adds the bearer token when signed in.
  Future<dynamic> send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    var tokens = auth ? await _current() : null;
    var res = await _raw(method, path, body, query, tokens?.accessToken);
    if (res.statusCode == 401 && tokens != null) {
      tokens = await _refresh(tokens);
      if (tokens != null) {
        res = await _raw(method, path, body, query, tokens.accessToken);
      }
    }
    return _decode(res);
  }

  Future<http.Response> _raw(
    String method,
    String path,
    Object? body,
    Map<String, String>? query,
    String? accessToken,
  ) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final req = http.Request(method, uri)
      ..headers['Accept'] = 'application/json';
    if (accessToken != null) {
      req.headers['Authorization'] = 'Bearer $accessToken';
    }
    if (body != null) {
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(body);
    }
    try {
      return await http.Response.fromStream(
        await httpClient.send(req).timeout(timeout),
      );
    } on TimeoutException {
      throw const ApiException(0, 'network', 'The server did not answer');
    } on Exception catch (e) {
      throw ApiException(0, 'network', '$e');
    }
  }

  /// One refresh at a time; everyone waiting gets its result.
  Future<Tokens?> _refresh(Tokens stale) {
    return _refreshing ??= () async {
      try {
        // Someone else may have refreshed already.
        if (_tokens != null && _tokens!.accessToken != stale.accessToken) {
          return _tokens;
        }
        final res = await _raw(
          'POST',
          '/api/v1/auth/refresh',
          {'refreshToken': stale.refreshToken},
          null,
          null,
        );
        if (res.statusCode != 200) {
          await clearSession();
          onSignedOut?.call();
          return null;
        }
        final tokens = Tokens.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>,
        );
        await setTokens(tokens);
        return tokens;
      } finally {
        _refreshing = null;
      }
    }();
  }

  static dynamic _decode(http.Response res) {
    final text = utf8.decode(res.bodyBytes);
    final json = text.isEmpty ? null : jsonDecode(text);
    if (res.statusCode >= 200 && res.statusCode < 300) return json;
    if (json is Map<String, dynamic>) {
      throw ApiException(
        res.statusCode,
        json['code'] as String? ?? 'error',
        json['message'] as String? ?? 'Request failed',
      );
    }
    throw ApiException(res.statusCode, 'error', 'HTTP ${res.statusCode}');
  }
}
