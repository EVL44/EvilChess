import 'dart:io' as io;
import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';
import 'package:evilchess/core/engine/uci_engine.dart';
import 'package:evilchess/features/analysis/domain/evaluation.dart';
import 'package:evilchess/features/analysis/domain/opening_book.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';
import 'package:evilchess/features/bots/domain/bot.dart';
import 'package:flutter_test/flutter_test.dart';

Position fen(String f) => Chess.fromSetup(Setup.parseFen(f));

/// Counts how often [bot] picks each move over [n] seeded tries.
Map<String, int> sample(
  Bot bot,
  Position pos,
  List<EngineLine> lines, {
  int n = 400,
  OpeningBook? book,
}) {
  final counts = <String, int>{};
  final picker = BotMovePicker(bot, random: math.Random(7));
  for (var i = 0; i < n; i++) {
    final m = picker.choose(pos, lines, book: book);
    counts[m] = (counts[m] ?? 0) + 1;
  }
  return counts;
}

Bot tweak(
  Bot b, {
  double? temperature,
  double? blunderChance,
  double? bookChance,
  BotStyle? style,
}) => Bot(
  id: b.id,
  name: b.name,
  rating: b.rating,
  style: style ?? b.style,
  depth: b.depth,
  multiPv: b.multiPv,
  temperature: temperature ?? b.temperature,
  blunderChance: blunderChance ?? b.blunderChance,
  bookChance: bookChance ?? b.bookChance,
  color: b.color,
  icon: b.icon,
);

void main() {
  // Start position, White to move; scores are White-POV.
  final start = Chess.initial;
  const lines = [
    EngineLine(uci: 'e2e4', eval: Eval.cp(35)),
    EngineLine(uci: 'd2d4', eval: Eval.cp(30)),
    EngineLine(uci: 'g1f3', eval: Eval.cp(25)),
    EngineLine(uci: 'a2a3', eval: Eval.cp(-60)),
  ];

  test('the cast: at least 8 bots from 400 to 2500+, weakest first', () {
    expect(kBots.length, greaterThanOrEqualTo(8));
    expect(kBots.first.rating, lessThanOrEqualTo(400));
    expect(kBots.last.rating, greaterThanOrEqualTo(2500));
    for (var i = 1; i < kBots.length; i++) {
      final a = kBots[i - 1];
      final b = kBots[i];
      expect(b.rating, greaterThan(a.rating));
      expect(b.depth, greaterThanOrEqualTo(a.depth));
      expect(b.temperature, lessThanOrEqualTo(a.temperature));
      expect(b.blunderChance, lessThanOrEqualTo(a.blunderChance));
    }
    expect(kBots.map((b) => b.id).toSet(), hasLength(kBots.length));
    expect(botById('vexa').name, 'Vexa');
    expect(botById('nope'), kBots.first);
  });

  test('the strongest bot always plays the best move', () {
    final counts = sample(kBots.last, start, lines);
    expect(counts, {'e2e4': 400});
  });

  test('a weak bot spreads its choices but still prefers good moves', () {
    final pip = tweak(kBots.first, blunderChance: 0);
    final counts = sample(pip, start, lines);
    expect(counts.keys.length, greaterThanOrEqualTo(3));
    expect(counts['e2e4']!, greaterThan(counts['a2a3'] ?? 0));
  });

  test('blunders are random legal moves', () {
    final always = tweak(kBots.first, blunderChance: 1);
    final counts = sample(always, start, lines);
    final legal = legalUcis(start).toSet();
    expect(legal, hasLength(20));
    expect(counts.keys.every(legal.contains), isTrue);
    expect(counts.keys.length, greaterThan(10));
  });

  test('scores are read from the side to move', () {
    // Black to move: a lower White-POV score is better for Black.
    final pos = fen(
      'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
    );
    final best = tweak(kBots.last, temperature: 0);
    final counts = sample(best, pos, const [
      EngineLine(uci: 'a7a6', eval: Eval.cp(80)),
      EngineLine(uci: 'e7e5', eval: Eval.cp(20)),
    ], n: 20);
    expect(counts, {'e7e5': 20});
  });

  test('style tips close choices', () {
    // Qxf7+ (capture with check) vs a quiet move rated slightly higher.
    final pos = fen(
      'r1bqkbnr/pppp1ppp/2n5/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 2 4',
    );
    const close = [
      EngineLine(uci: 'd2d3', eval: Eval.cp(60)),
      EngineLine(uci: 'h5f7', eval: Eval.cp(50)),
    ];
    final calm = tweak(kBots[4], temperature: 1, style: BotStyle.balanced);
    final wild = tweak(kBots[4], temperature: 1, style: BotStyle.aggressive);
    expect(sample(calm, pos, close, n: 50)['d2d3'], 50);
    expect(sample(wild, pos, close, n: 50)['h5f7'], 50);
  });

  test('style never talks a bot out of a forced mate', () {
    final pos = fen(
      'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4',
    );
    final greedy = tweak(
      kBots.first,
      temperature: 1,
      blunderChance: 0,
      style: BotStyle.materialistic,
    );
    final counts = sample(greedy, pos, const [
      EngineLine(uci: 'h5f7', eval: Eval.mate(1)),
      EngineLine(uci: 'h5e5', eval: Eval.cp(150)),
    ], n: 50);
    expect(counts, {'h5f7': 50});
  });

  test('bots play known opening moves when they have a book', () {
    final book = OpeningBook.parse(
      io.File('assets/openings/book.tsv').readAsStringSync(),
    );
    final booky = tweak(kBots[4], bookChance: 1);
    final counts = sample(booky, start, const [
      EngineLine(uci: 'a2a3', eval: Eval.cp(500)),
    ], book: book);
    expect(counts.keys.length, greaterThan(3), reason: 'varied openings');
    for (final uci in counts.keys) {
      final after = start.play(parseEngineUci(start, uci)!);
      expect(book.contains(positionKey(after)), isTrue, reason: uci);
    }
  });

  test('legal moves include castling and every promotion', () {
    final castle = fen('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1');
    expect(legalUcis(castle), containsAll(['e1g1', 'e1c1']));
    final promo = fen('8/P6k/8/8/8/8/8/K7 w - - 0 1');
    expect(legalUcis(promo), containsAll(['a7a8q', 'a7a8n', 'a7a8r', 'a7a8b']));
  });

  test('mate scores rank above any centipawn score', () {
    expect(
      BotMovePicker.moverScore(const Eval.mate(3), white: true),
      greaterThan(BotMovePicker.moverScore(const Eval.cp(2000), white: true)),
    );
    expect(
      BotMovePicker.moverScore(const Eval.mate(1), white: true),
      greaterThan(BotMovePicker.moverScore(const Eval.mate(5), white: true)),
    );
    expect(
      BotMovePicker.moverScore(const Eval.mate(2), white: false),
      lessThan(BotMovePicker.moverScore(const Eval.cp(-2000), white: false)),
    );
  });
}
