import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'uci_transport.dart';

/// Path (relative to the web root) of the Stockfish WebAssembly engine:
/// the single-threaded "lite" build of stockfish.js (GPL-3.0), which needs
/// no cross-origin-isolation headers.
const _engineScript = 'engine/stockfish-19-lite-single.js';

/// Web: Stockfish compiled to WebAssembly, running in a Web Worker.
Future<UciTransport> createPlatformTransport() async =>
    WorkerTransport.start(_engineScript);

String get platformEngineLabel => 'Stockfish 19 lite (WebAssembly)';

/// The single-threaded lite engine is slower; keep full-game analysis snappy.
int get defaultAnalysisDepth => 14;

class WorkerTransport implements UciTransport {
  WorkerTransport._(this._worker) {
    _worker.onmessage = ((web.MessageEvent e) {
      final data = e.data;
      if (data.isA<JSString>()) {
        for (final line in (data as JSString).toDart.split('\n')) {
          _lines.add(line);
        }
      }
    }).toJS;
    _worker.onerror = ((web.Event e) {
      _lines.addError(const EngineUnavailableException('Engine worker failed'));
    }).toJS;
  }

  static WorkerTransport start(String scriptUrl) =>
      WorkerTransport._(web.Worker(scriptUrl.toJS));

  final web.Worker _worker;
  final _lines = StreamController<String>.broadcast();

  @override
  Stream<String> get lines => _lines.stream;

  @override
  void send(String command) => _worker.postMessage(command.toJS);

  @override
  Future<void> close() async {
    _worker.terminate();
    await _lines.close();
  }
}
