import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/analysis/domain/evaluation.dart';
import '../../features/analysis/domain/game_analysis.dart';
import 'uci_transport.dart';

/// One parsed `info` line that carries a score.
@immutable
class UciInfo {
  const UciInfo({
    required this.depth,
    required this.multiPv,
    required this.pv,
    this.cp,
    this.mate,
    this.bound,
  });

  final int depth;
  final int multiPv;

  /// Score from the side to move's point of view (as UCI reports it).
  final int? cp;
  final int? mate;

  /// `lowerbound` / `upperbound` when the score is not exact.
  final String? bound;
  final List<String> pv;

  /// Parses `info depth 18 ... multipv 1 score cp 34 ... pv e2e4 e7e5`.
  /// Returns null for info lines without a score or pv (e.g. `currmove`).
  static UciInfo? parse(String line) {
    if (!line.startsWith('info ')) return null;
    final t = line.split(RegExp(r'\s+'));
    int? depth, cp, mate;
    var multiPv = 1;
    String? bound;
    List<String>? pv;
    for (var i = 1; i < t.length; i++) {
      switch (t[i]) {
        case 'depth':
          depth = int.tryParse(t[++i]);
        case 'multipv':
          multiPv = int.tryParse(t[++i]) ?? 1;
        case 'score':
          final kind = t[++i];
          final value = int.tryParse(t[++i]);
          if (kind == 'cp') cp = value;
          if (kind == 'mate') mate = value;
          if (i + 1 < t.length &&
              (t[i + 1] == 'lowerbound' || t[i + 1] == 'upperbound')) {
            bound = t[++i];
          }
        case 'pv':
          pv = t.sublist(i + 1);
          i = t.length;
        case 'string':
          return null;
      }
    }
    if (depth == null || pv == null || (cp == null && mate == null)) {
      return null;
    }
    return UciInfo(
      depth: depth,
      multiPv: multiPv,
      cp: cp,
      mate: mate,
      bound: bound,
      pv: pv,
    );
  }

  /// Converts the side-to-move score to a White-POV [Eval].
  Eval toWhiteEval({required bool whiteToMove}) {
    final sign = whiteToMove ? 1 : -1;
    return mate != null ? Eval.mate(mate! * sign) : Eval.cp(cp! * sign);
  }
}

/// One candidate move from a MultiPV search.
@immutable
class EngineLine {
  const EngineLine({required this.uci, required this.eval});

  /// First move of the line, standard UCI.
  final String uci;

  /// Score after this move, from White's point of view.
  final Eval eval;
}

/// Talks UCI to an engine over a [UciTransport]. Searches are serialized:
/// a new [evaluate] call waits for the previous one to finish.
class UciEngine {
  UciEngine(this._transport) {
    _sub = _transport.lines.listen(_onLine);
  }

  final UciTransport _transport;
  late final StreamSubscription<String> _sub;

  final _readyWaiters = <Completer<void>>[];
  Completer<void>? _uciOk;
  _Search? _search;
  Future<void> _queue = Future.value();
  bool _initialized = false;
  int _multiPv = 1;
  String? engineName;

  /// UCI handshake. Safe to call more than once.
  Future<void> init({int threads = 1, int hashMb = 32}) async {
    if (_initialized) return;
    _uciOk = Completer<void>();
    _transport.send('uci');
    await _uciOk!.future.timeout(const Duration(seconds: 20));
    _transport.send('setoption name Threads value $threads');
    _transport.send('setoption name Hash value $hashMb');
    await _isReady();
    _initialized = true;
  }

  Future<void> _isReady() {
    final c = Completer<void>();
    _readyWaiters.add(c);
    _transport.send('isready');
    return c.future.timeout(const Duration(seconds: 20));
  }

  /// Call before analysing a new game so the engine clears its hash.
  Future<void> newGame() => _enqueue(() async {
    _transport.send('ucinewgame');
    await _isReady();
  });

  /// Searches [fen] to [depth] and returns the result from White's point
  /// of view. With [multiPv] ≥ 2 the second line's score is included.
  Future<PositionEval> evaluate(
    String fen, {
    required int depth,
    int multiPv = 2,
  }) async => (await _run(fen, depth: depth, multiPv: multiPv)).done.future;

  /// Searches [fen] and returns up to [multiPv] candidate moves, best first,
  /// each with its White-POV score. Empty when there is no legal move.
  Future<List<EngineLine>> lines(
    String fen, {
    required int depth,
    required int multiPv,
  }) async {
    final search = await _run(fen, depth: depth, multiPv: multiPv);
    await search.done.future;
    final keys = search.lines.keys.toList()..sort();
    return [
      for (final k in keys)
        if (search.lines[k]!.pv.isNotEmpty)
          EngineLine(
            uci: search.lines[k]!.pv.first,
            eval: search.lines[k]!.toWhiteEval(whiteToMove: search.whiteToMove),
          ),
    ];
  }

  /// Runs one search and returns it once finished.
  Future<_Search> _run(
    String fen, {
    required int depth,
    required int multiPv,
  }) => _enqueue(() async {
    if (!_initialized) await init();
    if (multiPv != _multiPv) {
      _transport.send('setoption name MultiPV value $multiPv');
      _multiPv = multiPv;
      await _isReady();
    }
    final whiteToMove = fen.split(' ').elementAtOrNull(1) != 'b';
    final search = _Search(whiteToMove);
    _search = search;
    _transport.send('position fen $fen');
    _transport.send('go depth $depth');
    try {
      await search.done.future;
      return search;
    } finally {
      _search = null;
    }
  });

  Future<T> _enqueue<T>(Future<T> Function() task) {
    final result = _queue.then((_) => task());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  void _onLine(String raw) {
    final line = raw.trim();
    if (line.isEmpty) return;
    if (line == 'uciok') {
      _uciOk?.complete();
      _uciOk = null;
    } else if (line.startsWith('id name ')) {
      engineName = line.substring(8);
    } else if (line == 'readyok') {
      if (_readyWaiters.isNotEmpty) _readyWaiters.removeAt(0).complete();
    } else if (line.startsWith('info ')) {
      if (line.contains('score mate 0')) _search?.mated = true;
      final info = UciInfo.parse(line);
      if (info != null && info.bound == null) {
        _search?.lines[info.multiPv] = info;
      }
    } else if (line.startsWith('bestmove')) {
      _search?.finish(line.split(' ').elementAtOrNull(1));
    }
  }

  Future<void> dispose() async {
    _search?.done.completeError(StateError('engine disposed'));
    await _sub.cancel();
    await _transport.close();
  }
}

class _Search {
  _Search(this.whiteToMove);
  final bool whiteToMove;
  final lines = <int, UciInfo>{};
  final done = Completer<PositionEval>();

  /// The engine reported `score mate 0`: the side to move is checkmated.
  bool mated = false;

  void finish(String? bestmove) {
    if (done.isCompleted) return;
    final first = lines[1];
    if (first == null) {
      // No legal moves: the engine replies "bestmove (none)" after
      // "score mate 0" (checkmated) or "score cp 0" (stalemate).
      done.complete(
        PositionEval(
          eval: mated ? Eval.mate(whiteToMove ? -1 : 1) : const Eval.cp(0),
          depth: 0,
        ),
      );
      return;
    }
    final second = lines[2];
    done.complete(
      PositionEval(
        eval: first.toWhiteEval(whiteToMove: whiteToMove),
        depth: first.depth,
        bestUci: (bestmove == null || bestmove == '(none)')
            ? first.pv.firstOrNull
            : bestmove,
        pv: first.pv,
        secondEval: second?.toWhiteEval(whiteToMove: whiteToMove),
      ),
    );
  }
}
