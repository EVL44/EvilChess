import 'package:dartchess/dartchess.dart';

/// Writes a PGN for a game played in the app.
///
/// [sans] are the moves from [initialFen] (standard start if null). A
/// custom start position adds the `SetUp`/`FEN` headers.
String writePgn({
  required Map<String, String> headers,
  required List<String> sans,
  required String result,
  String? initialFen,
}) {
  final start = initialFen ?? Chess.initial.fen;
  final custom = start != Chess.initial.fen;
  final all = {
    ...headers,
    'Result': result,
    if (custom) 'SetUp': '1',
    if (custom) 'FEN': start,
  };

  final out = StringBuffer();
  all.forEach((k, v) => out.writeln('[$k "${v.replaceAll('"', "'")}"]'));
  out.writeln();

  final parts = start.split(' ');
  final blackFirst = parts.elementAtOrNull(1) == 'b';
  var number = int.tryParse(parts.lastOrNull ?? '') ?? 1;
  final moves = <String>[];
  for (var i = 0; i < sans.length; i++) {
    final white = i.isEven != blackFirst;
    if (white) {
      moves.add('$number. ${sans[i]}');
    } else {
      moves.add(i == 0 ? '$number... ${sans[i]}' : sans[i]);
      number++;
    }
  }
  moves.add(result);
  out.writeln(moves.join(' '));
  return out.toString();
}
