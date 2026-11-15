import 'package:flutter/foundation.dart';

/// Where a game came from.
enum GameSource { pgn, lichess, chesscom, evilchess }

/// Time-control category, using Lichess's definition (estimated duration =
/// base + 40 × increment).
enum GameSpeed {
  ultraBullet,
  bullet,
  blitz,
  rapid,
  classical,
  correspondence,
  unknown;

  static GameSpeed fromName(String? name) => switch (name) {
    'ultraBullet' => ultraBullet,
    'bullet' => bullet,
    'blitz' => blitz,
    'rapid' => rapid,
    'classical' => classical,
    'correspondence' || 'daily' => correspondence,
    _ => unknown,
  };
}

/// A time control such as `180+2` (seconds + increment seconds).
@immutable
class TimeControl {
  const TimeControl(this.baseSeconds, this.incrementSeconds);

  final int baseSeconds;
  final int incrementSeconds;

  /// Parses PGN `TimeControl` values: `180+2`, `600`, `1/259200` (daily),
  /// `-` (none). Multi-stage controls (`40/7200:3600`) use the first stage.
  static TimeControl? parse(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty || value == '-' || value == '?') return null;
    if (value.contains('/')) return null; // moves/seconds = correspondence
    final stage = value.split(':').first;
    final parts = stage.split('+');
    final base = int.tryParse(parts[0]);
    if (base == null) return null;
    final inc = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeControl(base, inc);
  }

  /// Lichess speed categories.
  GameSpeed get speed {
    final estimate = baseSeconds + 40 * incrementSeconds;
    if (estimate < 30) return GameSpeed.ultraBullet;
    if (estimate < 180) return GameSpeed.bullet;
    if (estimate < 480) return GameSpeed.blitz;
    if (estimate < 1500) return GameSpeed.rapid;
    return GameSpeed.classical;
  }

  @override
  String toString() => '$baseSeconds+$incrementSeconds';

  @override
  bool operator ==(Object other) =>
      other is TimeControl &&
      other.baseSeconds == baseSeconds &&
      other.incrementSeconds == incrementSeconds;

  @override
  int get hashCode => Object.hash(baseSeconds, incrementSeconds);
}

/// One half-move of a game, with the positions around it.
@immutable
class GamePly {
  const GamePly({
    required this.san,
    required this.uci,
    required this.fenBefore,
    required this.fenAfter,
    this.clock,
  });

  final String san;

  /// Standard UCI (castling as `e1g1`).
  final String uci;
  final String fenBefore;
  final String fenAfter;

  /// Mover's remaining clock after this move, when the PGN records it.
  final Duration? clock;

  Map<String, Object?> toJson() => {
    'san': san,
    'uci': uci,
    'b': fenBefore,
    'a': fenAfter,
    if (clock != null) 'clk': clock!.inMilliseconds,
  };

  factory GamePly.fromJson(Map<String, Object?> json) => GamePly(
    san: json['san']! as String,
    uci: json['uci']! as String,
    fenBefore: json['b']! as String,
    fenAfter: json['a']! as String,
    clock: json['clk'] == null
        ? null
        : Duration(milliseconds: (json['clk']! as num).toInt()),
  );
}

/// A finished (or abandoned) game, independent of where it was imported from.
@immutable
class GameRecord {
  const GameRecord({
    required this.id,
    required this.source,
    required this.white,
    required this.black,
    required this.result,
    required this.initialFen,
    required this.plies,
    required this.pgn,
    this.externalId,
    this.url,
    this.whiteElo,
    this.blackElo,
    this.playedAt,
    this.timeControl,
    this.speed = GameSpeed.unknown,
    this.eco,
    this.opening,
    this.event,
  });

  /// Stable id: `<source>:<external id>` for online games, a content hash for
  /// pasted PGNs (so importing the same PGN twice does not duplicate it).
  final String id;
  final GameSource source;
  final String? externalId;
  final String? url;
  final String white;
  final String black;
  final int? whiteElo;
  final int? blackElo;

  /// `1-0`, `0-1`, `1/2-1/2` or `*`.
  final String result;
  final DateTime? playedAt;
  final TimeControl? timeControl;
  final GameSpeed speed;
  final String? eco;
  final String? opening;
  final String? event;
  final String initialFen;
  final List<GamePly> plies;

  /// Original PGN text (kept for export and re-parsing).
  final String pgn;
}
