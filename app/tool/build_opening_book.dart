// Builds assets/openings/book.tsv from the Lichess chess-openings TSV files
// (https://github.com/lichess-org/chess-openings, CC0).
//
// Usage (from app/): dart run tool/build_opening_book.dart <dir with a.tsv..e.tsv>
//
// Output: one line per book position: `<position key>\t<eco>\t<name>`.
// Every position on the way to a named line is in the book; it carries the
// name of the line that ends exactly there, or is blank.
import 'dart:io' as io;

import 'package:dartchess/dartchess.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';

void main(List<String> args) {
  if (args.length != 1) {
    io.stderr.writeln('usage: dart run tool/build_opening_book.dart <tsv dir>');
    io.exit(64);
  }
  final named = <String, (String eco, String name)>{};
  final all = <String>{};
  var lines = 0;

  for (final letter in ['a', 'b', 'c', 'd', 'e']) {
    final file = io.File('${args.first}/$letter.tsv');
    for (final row in file.readAsLinesSync().skip(1)) {
      if (row.trim().isEmpty) continue;
      final [eco, name, pgn] = row.split('\t');
      Position pos = Chess.initial;
      final game = PgnGame.parsePgn(pgn);
      for (final node in game.moves.mainline()) {
        final move = pos.parseSan(node.san);
        if (move == null) {
          throw StateError('Illegal move ${node.san} in "$name"');
        }
        pos = pos.play(move);
        all.add(positionKey(pos));
      }
      // Keep the first (most general) name if two lines transpose.
      named.putIfAbsent(positionKey(pos), () => (eco, name));
      lines++;
    }
  }

  final out = StringBuffer();
  for (final key in all.toList()..sort()) {
    final (eco, name) = named[key] ?? ('', '');
    out.writeln('$key\t$eco\t$name');
  }
  final dest = io.File('assets/openings/book.tsv')..createSync(recursive: true);
  dest.writeAsStringSync(out.toString());
  io.stdout.writeln(
    'Wrote ${all.length} positions (${named.length} named) from $lines lines '
    'to ${dest.path} (${dest.lengthSync()} bytes).',
  );
}
