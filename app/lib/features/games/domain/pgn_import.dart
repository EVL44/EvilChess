import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dartchess/dartchess.dart';

import '../../analysis/domain/position_key.dart';
import 'game_record.dart';

/// Thrown when a PGN contains no playable game.
class PgnImportException implements Exception {
  const PgnImportException(this.message);
  final String message;
  @override
  String toString() => 'PgnImportException: $message';
}

/// Parses one or more games from PGN text.
///
/// Handles Lichess and Chess.com flavours: `{[%clk 0:02:59.9]}` comments,
/// `1...` black move numbers, `[SetUp]`/`[FEN]` starting positions and
/// Windows line endings. Moves after the first illegal one are dropped (the
/// game keeps everything before it). Games with no legal moves are skipped.
List<GameRecord> parsePgnGames(
  String text, {
  GameSource source = GameSource.pgn,
}) {
  final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final chunks = _splitGames(normalized);
  final games = <GameRecord>[];
  for (final chunk in chunks) {
    final game = parseSinglePgn(chunk, source: source);
    if (game != null) games.add(game);
  }
  return games;
}

/// Parses one game. Returns `null` when it has no legal moves.
GameRecord? parseSinglePgn(
  String pgn, {
  GameSource source = GameSource.pgn,
  String? externalId,
  String? url,
}) {
  final parsed = PgnGame.parsePgn(pgn);
  final headers = parsed.headers;

  Position pos;
  try {
    pos = PgnGame.startingPosition(headers);
  } on PositionSetupException {
    return null;
  } on FenException {
    return null;
  }
  // Only standard chess (including from a custom position / Chess960).
  if (pos.rule != Rule.chess) return null;
  final initialFen = pos.fen;

  final plies = <GamePly>[];
  for (final node in parsed.moves.mainline()) {
    final move = pos.parseSan(node.san);
    if (move == null) break;
    final (after, san) = pos.makeSan(move);
    Duration? clock;
    for (final raw in node.comments ?? const <String>[]) {
      clock ??= PgnComment.fromPgn(raw).clock;
    }
    plies.add(
      GamePly(
        san: san,
        uci: standardUci(pos, move),
        fenBefore: pos.fen,
        fenAfter: after.fen,
        clock: clock,
      ),
    );
    pos = after;
  }
  if (plies.isEmpty) return null;

  String? header(String key) {
    final v = headers[key]?.trim();
    return (v == null || v.isEmpty || v == '?' || v == '-') ? null : v;
  }

  final timeControl = TimeControl.parse(headers['TimeControl']);
  final tcRaw = headers['TimeControl'] ?? '';
  final speed = tcRaw.contains('/')
      ? GameSpeed.correspondence
      : timeControl?.speed ?? GameSpeed.unknown;

  final id = switch ((source, externalId)) {
    (GameSource.pgn, _) ||
    (_, null) => 'pgn:${_contentHash(initialFen, plies, headers)}',
    (final s, final ext?) => '${s.name}:$ext',
  };

  return GameRecord(
    id: id,
    source: source,
    externalId: externalId,
    url: url ?? _siteUrl(header('Link')) ?? _siteUrl(header('Site')),
    white: header('White') ?? 'White',
    black: header('Black') ?? 'Black',
    whiteElo: int.tryParse(headers['WhiteElo'] ?? ''),
    blackElo: int.tryParse(headers['BlackElo'] ?? ''),
    result: _result(headers['Result']),
    playedAt: _playedAt(headers),
    timeControl: timeControl,
    speed: speed,
    eco: header('ECO'),
    opening: header('Opening'),
    event: header('Event'),
    initialFen: initialFen,
    plies: plies,
    pgn: pgn.trim(),
  );
}

/// Splits a multi-game PGN into one chunk per game. A new game starts at a
/// header line that follows movetext (or a blank line).
List<String> _splitGames(String text) {
  final games = <String>[];
  final current = StringBuffer();
  var inMoves = false;
  for (final line in const LineSplitter().convert(text)) {
    final trimmed = line.trimLeft();
    final isHeader =
        trimmed.startsWith('[') && trimmed.trimRight().endsWith(']');
    if (isHeader && inMoves) {
      games.add(current.toString());
      current.clear();
      inMoves = false;
    }
    if (!isHeader && trimmed.isNotEmpty) inMoves = true;
    current.writeln(line);
  }
  if (current.toString().trim().isNotEmpty) games.add(current.toString());
  return games;
}

String _result(String? raw) => switch (raw?.trim()) {
  '1-0' => '1-0',
  '0-1' => '0-1',
  '1/2-1/2' || '½-½' => '1/2-1/2',
  _ => '*',
};

String? _siteUrl(String? site) =>
    site != null && site.startsWith('http') ? site : null;

/// Combines `UTCDate`+`UTCTime` (Lichess, Chess.com) or `Date` (+ `StartTime`).
DateTime? _playedAt(Map<String, String> h) {
  final date = h['UTCDate'] ?? h['Date'];
  if (date == null) return null;
  final d = RegExp(r'^(\d{4})\.(\d{2})\.(\d{2})$').firstMatch(date.trim());
  if (d == null) return null;
  final time = h['UTCTime'] ?? h['StartTime'] ?? '00:00:00';
  final t = RegExp(r'^(\d{2}):(\d{2}):(\d{2})').firstMatch(time.trim());
  return DateTime.utc(
    int.parse(d[1]!),
    int.parse(d[2]!),
    int.parse(d[3]!),
    t == null ? 0 : int.parse(t[1]!),
    t == null ? 0 : int.parse(t[2]!),
    t == null ? 0 : int.parse(t[3]!),
  );
}

String _contentHash(
  String initialFen,
  List<GamePly> plies,
  Map<String, String> headers,
) {
  final key = [
    initialFen,
    headers['White'] ?? '',
    headers['Black'] ?? '',
    headers['Date'] ?? headers['UTCDate'] ?? '',
    ...plies.map((p) => p.uci),
  ].join('|');
  return sha1.convert(utf8.encode(key)).toString().substring(0, 20);
}
