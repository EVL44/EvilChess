import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:evilchess/core/engine/uci_transport.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';

/// Scripted answer for one position: side-to-move score, best move (UCI) and
/// optionally a second line's score.
typedef FakeLine = ({int? cp, int? mate, String? best, int? secondCp});

/// A tiny UCI "engine" for tests. It answers the handshake and, for each
/// `go`, prints the scripted result for the current position or, if none,
/// `cp 0` with the first legal move.
class FakeUciTransport implements UciTransport {
  FakeUciTransport({Map<String, FakeLine>? script}) : script = script ?? {};

  /// Keyed by `positionKey` (first four FEN fields).
  final Map<String, FakeLine> script;
  final _out = StreamController<String>.broadcast();
  final sent = <String>[];
  int searches = 0;
  int multiPv = 1;
  String _fen = Chess.initial.fen;
  bool closed = false;

  @override
  Stream<String> get lines => _out.stream;

  @override
  void send(String command) {
    sent.add(command);
    scheduleMicrotask(() => _handle(command));
  }

  void _emit(String line) {
    if (!_out.isClosed) _out.add(line);
  }

  void _handle(String cmd) {
    if (cmd == 'uci') {
      _emit('id name FakeFish 1');
      _emit('uciok');
    } else if (cmd == 'isready') {
      _emit('readyok');
    } else if (cmd.startsWith('setoption name MultiPV value ')) {
      multiPv = int.parse(cmd.split(' ').last);
    } else if (cmd.startsWith('position fen ')) {
      _fen = cmd.substring('position fen '.length);
    } else if (cmd.startsWith('go')) {
      searches++;
      final depth = int.tryParse(cmd.split(' ').last) ?? 10;
      final pos = Chess.fromSetup(Setup.parseFen(_fen));
      if (pos.isCheckmate) {
        _emit('info depth 0 score mate 0');
        _emit('bestmove (none)');
        return;
      }
      if (pos.isStalemate) {
        _emit('info depth 0 score cp 0');
        _emit('bestmove (none)');
        return;
      }
      final line = script[positionKey(pos)];
      final legal = <String>[];
      for (final entry in pos.legalMoves.entries) {
        for (final to in entry.value.squares) {
          legal.add(standardUci(pos, NormalMove(from: entry.key, to: to)));
        }
      }
      final best = line?.best ?? legal.first;
      final score = line?.mate != null
          ? 'mate ${line!.mate}'
          : 'cp ${line?.cp ?? 0}';
      // A shallower line first, like a real engine.
      _emit('info depth 1 multipv 1 score cp 1 pv $best');
      _emit(
        'info depth $depth seldepth ${depth + 2} multipv 1 score $score '
        'nodes 1000 nps 100000 pv $best',
      );
      if (multiPv > 1 && legal.length > 1) {
        final other = legal.firstWhere((m) => m != best);
        final second = line?.secondCp ?? (line?.cp ?? 0) - 30;
        _emit('info depth $depth multipv 2 score cp $second pv $other');
      }
      _emit('bestmove $best');
    } else if (cmd == 'quit') {
      unawaited(close());
    }
  }

  @override
  Future<void> close() async {
    closed = true;
    await _out.close();
  }
}
