import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/game_record.dart';
import '../domain/pgn_import.dart';

/// Identifies us to Lichess / Chess.com, as both APIs ask. Browsers ignore
/// this header (they send their own User-Agent), which both APIs accept.
const kApiUserAgent = 'evilchess/0.1 (+https://github.com/evilchess)';

class ImportException implements Exception {
  const ImportException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'ImportException($statusCode): $message';
}

/// Progress of an import, for the UI.
@immutable
class ImportProgress {
  const ImportProgress(this.fetched, {this.label});
  final int fetched;
  final String? label;
}

Map<String, String> get _headers => {if (!kIsWeb) 'User-Agent': kApiUserAgent};

/// Lichess: `GET /api/games/user/{name}` as NDJSON (one game per line).
///
/// Uses `since` for incremental sync. Lichess allows one request at a time
/// per client and asks clients to wait a full minute after HTTP 429.
class LichessImporter {
  LichessImporter(this._client, {this.baseUrl = 'https://lichess.org'});

  final http.Client _client;
  final String baseUrl;

  Stream<GameRecord> fetchGames(
    String username, {
    DateTime? since,
    int? max,
  }) async* {
    final uri = Uri.parse('$baseUrl/api/games/user/$username').replace(
      queryParameters: {
        'pgnInJson': 'true',
        'clocks': 'true',
        'opening': 'true',
        'evals': 'false',
        'perfType': 'ultraBullet,bullet,blitz,rapid,classical,correspondence',
        if (since != null) 'since': '${since.millisecondsSinceEpoch + 1}',
        if (max != null) 'max': '$max',
      },
    );
    final request = http.Request('GET', uri)
      ..headers.addAll({..._headers, 'Accept': 'application/x-ndjson'});
    final response = await _client.send(request);
    if (response.statusCode == 404) {
      throw ImportException(
        'Lichess user "$username" not found',
        statusCode: 404,
      );
    }
    if (response.statusCode == 429) {
      throw const ImportException(
        'Lichess rate limit reached — wait a minute and try again.',
        statusCode: 429,
      );
    }
    if (response.statusCode != 200) {
      throw ImportException('Lichess error', statusCode: response.statusCode);
    }
    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final json = jsonDecode(line) as Map<String, dynamic>;
      final game = parseLichessGame(json);
      if (game != null) yield game;
    }
  }
}

/// Converts one Lichess game JSON object (with `pgnInJson`) to a record.
@visibleForTesting
GameRecord? parseLichessGame(Map<String, dynamic> json) {
  final variant = json['variant'] as String? ?? 'standard';
  if (variant != 'standard' &&
      variant != 'fromPosition' &&
      variant != 'chess960') {
    return null;
  }
  final pgn = json['pgn'] as String?;
  final id = json['id'] as String?;
  if (pgn == null || id == null) return null;
  final parsed = parseSinglePgn(
    pgn,
    source: GameSource.lichess,
    externalId: id,
    url: 'https://lichess.org/$id',
  );
  if (parsed == null) return null;
  final created = json['createdAt'] as int?;
  final speed = GameSpeed.fromName(json['speed'] as String?);
  return GameRecord(
    id: parsed.id,
    source: parsed.source,
    externalId: id,
    url: parsed.url,
    white: parsed.white,
    black: parsed.black,
    whiteElo: parsed.whiteElo,
    blackElo: parsed.blackElo,
    result: parsed.result,
    playedAt: created != null
        ? DateTime.fromMillisecondsSinceEpoch(created, isUtc: true)
        : parsed.playedAt,
    timeControl: parsed.timeControl,
    speed: speed == GameSpeed.unknown ? parsed.speed : speed,
    eco: parsed.eco,
    opening: parsed.opening,
    event: parsed.event,
    initialFen: parsed.initialFen,
    plies: parsed.plies,
    pgn: parsed.pgn,
  );
}

/// Chess.com public API: monthly archives of finished games.
///
/// Incremental sync re-reads only the months at or after the newest game we
/// already have (the current month is still growing). Requests are made one
/// at a time, as the API asks.
class ChessComImporter {
  ChessComImporter(this._client, {this.baseUrl = 'https://api.chess.com'});

  final http.Client _client;
  final String baseUrl;

  Stream<GameRecord> fetchGames(String username, {DateTime? since}) async* {
    final name = username.toLowerCase();
    final archives = await _getJson(
      '$baseUrl/pub/player/$name/games/archives',
      notFound: 'Chess.com user "$username" not found',
    );
    final urls = (archives['archives'] as List).cast<String>();
    final fromMonth = since == null
        ? null
        : DateTime.utc(since.toUtc().year, since.toUtc().month);

    for (final url in urls) {
      final month = _monthOf(url);
      if (fromMonth != null && month != null && month.isBefore(fromMonth)) {
        continue;
      }
      final data = await _getJson(url);
      for (final g in (data['games'] as List? ?? const [])) {
        final game = parseChessComGame((g as Map).cast<String, dynamic>());
        if (game == null) continue;
        if (since != null &&
            game.playedAt != null &&
            !game.playedAt!.isAfter(since)) {
          continue;
        }
        yield game;
      }
    }
  }

  Future<Map<String, dynamic>> _getJson(String url, {String? notFound}) async {
    final res = await _client.get(Uri.parse(url), headers: _headers);
    if (res.statusCode == 404) {
      throw ImportException(notFound ?? 'Not found: $url', statusCode: 404);
    }
    if (res.statusCode == 429) {
      throw const ImportException(
        'Chess.com rate limit reached — try again shortly.',
        statusCode: 429,
      );
    }
    if (res.statusCode != 200) {
      throw ImportException('Chess.com error', statusCode: res.statusCode);
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static DateTime? _monthOf(String archiveUrl) {
    final m = RegExp(r'/(\d{4})/(\d{2})$').firstMatch(archiveUrl);
    if (m == null) return null;
    return DateTime.utc(int.parse(m[1]!), int.parse(m[2]!));
  }
}

/// Converts one game from a Chess.com monthly archive.
@visibleForTesting
GameRecord? parseChessComGame(Map<String, dynamic> json) {
  if ((json['rules'] as String? ?? 'chess') != 'chess') return null;
  final pgn = json['pgn'] as String?;
  if (pgn == null) return null;
  final url = json['url'] as String?;
  final externalId =
      json['uuid'] as String? ??
      url?.split('/').where((s) => s.isNotEmpty).last;
  final parsed = parseSinglePgn(
    pgn,
    source: GameSource.chesscom,
    externalId: externalId,
    url: url,
  );
  if (parsed == null) return null;
  final end = json['end_time'] as int?;
  final timeClass = json['time_class'] as String?;
  final speed = switch (timeClass) {
    'bullet' => GameSpeed.bullet,
    'blitz' => GameSpeed.blitz,
    'rapid' => GameSpeed.rapid,
    'daily' => GameSpeed.correspondence,
    _ => parsed.speed,
  };
  final white = (json['white'] as Map?)?.cast<String, dynamic>();
  final black = (json['black'] as Map?)?.cast<String, dynamic>();
  return GameRecord(
    id: parsed.id,
    source: GameSource.chesscom,
    externalId: externalId,
    url: url,
    white: white?['username'] as String? ?? parsed.white,
    black: black?['username'] as String? ?? parsed.black,
    whiteElo: white?['rating'] as int? ?? parsed.whiteElo,
    blackElo: black?['rating'] as int? ?? parsed.blackElo,
    result: parsed.result,
    playedAt: end != null
        ? DateTime.fromMillisecondsSinceEpoch(end * 1000, isUtc: true)
        : parsed.playedAt,
    timeControl: parsed.timeControl,
    speed: speed,
    eco: parsed.eco,
    opening: parsed.opening,
    event: parsed.event,
    initialFen: parsed.initialFen,
    plies: parsed.plies,
    pgn: parsed.pgn,
  );
}
