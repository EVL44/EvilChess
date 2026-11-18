import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/engine/uci_engine.dart';
import '../../analysis/domain/evaluation.dart';
import '../../analysis/domain/material.dart';
import '../../analysis/domain/opening_book.dart';
import '../../analysis/domain/position_key.dart';

/// How a bot likes to play. Applied as a small bonus on top of the engine's
/// score, so the style shows in close choices without ruining the moves.
enum BotStyle { balanced, aggressive, defensive, tricky, materialistic }

/// A bot opponent. Strength comes from three knobs:
/// - [depth]: how far Stockfish looks (low depth misses tactics like a human),
/// - [temperature]: how willing the bot is to pick a worse candidate move
///   (in centipawns; 0 = always the best),
/// - [blunderChance]: how often it plays a random legal move.
@immutable
class Bot {
  const Bot({
    required this.id,
    required this.name,
    required this.rating,
    required this.style,
    required this.depth,
    required this.multiPv,
    required this.temperature,
    required this.blunderChance,
    required this.bookChance,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;

  /// Rough playing strength. Not calibrated against rated players yet.
  final int rating;
  final BotStyle style;
  final int depth;
  final int multiPv;
  final double temperature;
  final double blunderChance;

  /// How often it plays a known opening move when one exists.
  final double bookChance;
  final Color color;
  final IconData icon;
}

/// The cast, weakest first.
const kBots = <Bot>[
  Bot(
    id: 'pip',
    name: 'Pip',
    rating: 400,
    style: BotStyle.materialistic,
    depth: 1,
    multiPv: 8,
    temperature: 320,
    blunderChance: 0.18,
    bookChance: 0,
    color: Color(0xFF65A30D),
    icon: Icons.child_care_rounded,
  ),
  Bot(
    id: 'gremlina',
    name: 'Gremlina',
    rating: 800,
    style: BotStyle.aggressive,
    depth: 2,
    multiPv: 8,
    temperature: 190,
    blunderChance: 0.08,
    bookChance: 0.4,
    color: Color(0xFFDB2777),
    icon: Icons.local_fire_department_rounded,
  ),
  Bot(
    id: 'bramble',
    name: 'Baron Bramble',
    rating: 1100,
    style: BotStyle.defensive,
    depth: 3,
    multiPv: 6,
    temperature: 120,
    blunderChance: 0.04,
    bookChance: 0.6,
    color: Color(0xFF92400E),
    icon: Icons.shield_rounded,
  ),
  Bot(
    id: 'hex',
    name: 'Madame Hex',
    rating: 1400,
    style: BotStyle.tricky,
    depth: 5,
    multiPv: 6,
    temperature: 75,
    blunderChance: 0.02,
    bookChance: 0.8,
    color: Color(0xFF7C3AED),
    icon: Icons.auto_awesome_rounded,
  ),
  Bot(
    id: 'grimsby',
    name: 'Sir Grimsby',
    rating: 1700,
    style: BotStyle.balanced,
    depth: 7,
    multiPv: 5,
    temperature: 42,
    blunderChance: 0.01,
    bookChance: 0.9,
    color: Color(0xFF2563EB),
    icon: Icons.school_rounded,
  ),
  Bot(
    id: 'vexa',
    name: 'Vexa',
    rating: 2000,
    style: BotStyle.aggressive,
    depth: 9,
    multiPv: 4,
    temperature: 22,
    blunderChance: 0,
    bookChance: 0.95,
    color: Color(0xFFEA580C),
    icon: Icons.bolt_rounded,
  ),
  Bot(
    id: 'warlock',
    name: 'The Warlock',
    rating: 2300,
    style: BotStyle.defensive,
    depth: 12,
    multiPv: 3,
    temperature: 9,
    blunderChance: 0,
    bookChance: 1,
    color: Color(0xFF0891B2),
    icon: Icons.psychology_rounded,
  ),
  Bot(
    id: 'malakar',
    name: 'Malakar the Unblinking',
    rating: 2700,
    style: BotStyle.balanced,
    depth: 16,
    multiPv: 1,
    temperature: 0,
    blunderChance: 0,
    bookChance: 1,
    color: Color(0xFFDC2626),
    icon: Icons.visibility_rounded,
  ),
];

Bot botById(String id) =>
    kBots.firstWhere((b) => b.id == id, orElse: () => kBots.first);

/// All legal moves of [pos] in standard UCI (castling as `e1g1`).
List<String> legalUcis(Position pos) => [
  for (final entry in pos.legalMoves.entries)
    for (final to in entry.value.squares)
      ...() {
        final from = entry.key;
        final role = pos.board.roleAt(from);
        final promoting =
            role == Role.pawn &&
            (to.rank == Rank.first || to.rank == Rank.eighth);
        if (!promoting) {
          return [standardUci(pos, NormalMove(from: from, to: to))];
        }
        return [
          for (final r in [Role.queen, Role.knight, Role.rook, Role.bishop])
            NormalMove(from: from, to: to, promotion: r).uci,
        ];
      }(),
];

/// Picks a bot's move from the engine's candidate lines. Pure and seeded,
/// so it can be tested deterministically.
class BotMovePicker {
  BotMovePicker(this.bot, {math.Random? random})
    : _random = random ?? math.Random();

  final Bot bot;
  final math.Random _random;

  /// Mover-POV score used for sampling: centipawns, with mates mapped far
  /// outside the centipawn range (sooner mates score higher).
  static double moverScore(Eval eval, {required bool white}) {
    final sign = white ? 1 : -1;
    if (eval.mate != null) {
      final m = eval.mate! * sign;
      return m > 0 ? 10000 - m * 10.0 : -10000 - m * 10.0;
    }
    return (eval.cp! * sign).toDouble();
  }

  /// Style bonus in centipawns for playing [uci] in [pos].
  double styleBonus(Position pos, String uci) {
    final move = parseEngineUci(pos, uci);
    if (move is! NormalMove) return 0;
    final target = pos.board.pieceAt(move.to);
    final capture = target != null && target.color != pos.turn;
    final check = pos.play(move).isCheck;
    final moved = pos.board.roleAt(move.from);
    final castle =
        moved == Role.king && (move.from.file - move.to.file).abs() >= 2 ||
        (moved == Role.king && target?.color == pos.turn);
    return switch (bot.style) {
      BotStyle.balanced => 0,
      BotStyle.aggressive => (capture ? 30 : 0) + (check ? 55 : 0),
      BotStyle.defensive => (castle ? 70 : 0) + (check ? -10 : 0),
      BotStyle.tricky => (check ? 70 : 0) + (capture ? 15 : 0),
      BotStyle.materialistic => capture ? pieceValue(target.role) * 35.0 : 0,
    };
  }

  /// Chooses the move to play (standard UCI).
  String choose(Position pos, List<EngineLine> lines, {OpeningBook? book}) {
    final legal = legalUcis(pos);
    if (legal.isEmpty) throw StateError('No legal move');

    // 1. Known opening moves, for variety.
    if (book != null && _random.nextDouble() < bot.bookChance) {
      final bookMoves = [
        for (final uci in legal)
          if (book.contains(positionKey(pos.play(parseEngineUci(pos, uci)!))))
            uci,
      ];
      if (bookMoves.isNotEmpty) {
        return bookMoves[_random.nextInt(bookMoves.length)];
      }
    }

    // 2. The occasional plain blunder.
    if (lines.isEmpty || _random.nextDouble() < bot.blunderChance) {
      return legal[_random.nextInt(legal.length)];
    }

    // 3. Sample a candidate: better moves are exponentially more likely.
    final white = pos.turn == Side.white;
    final candidates = [
      for (final l in lines)
        if (legal.contains(l.uci)) l,
    ];
    if (candidates.isEmpty) return legal[_random.nextInt(legal.length)];

    final scores = [
      for (final l in candidates)
        moverScore(l.eval, white: white) +
            // Never let style talk the bot out of a forced mate.
            (l.eval.mate != null ? 0 : styleBonus(pos, l.uci)),
    ];
    final best = scores.reduce(math.max);
    if (bot.temperature <= 0) return candidates[scores.indexOf(best)].uci;

    final weights = [
      for (final s in scores) math.exp((s - best) / bot.temperature),
    ];
    final total = weights.reduce((a, b) => a + b);
    var r = _random.nextDouble() * total;
    for (var i = 0; i < candidates.length; i++) {
      r -= weights[i];
      if (r <= 0) return candidates[i].uci;
    }
    return candidates.last.uci;
  }
}
