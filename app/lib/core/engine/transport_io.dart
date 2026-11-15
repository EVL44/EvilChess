import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:multistockfish/multistockfish.dart';
import 'package:path/path.dart' as p;

import 'uci_transport.dart';

/// Picks the engine for native platforms:
/// - Android / iOS: Stockfish compiled into the app (`multistockfish`).
/// - Windows / Linux / macOS: the official Stockfish executable, bundled by
///   the desktop build (see `tool/fetch_stockfish.sh`), or found on PATH.
Future<UciTransport> createPlatformTransport() async {
  if (Platform.isAndroid || Platform.isIOS) {
    return MultistockfishTransport.start();
  }
  final path = await findDesktopStockfish();
  if (path == null) {
    throw const EngineUnavailableException(
      'Stockfish was not found. Run tool/fetch_stockfish.sh before building, '
      'or install Stockfish and put it on your PATH.',
    );
  }
  return ProcessTransport.start(path);
}

/// Which engine build this platform uses (shown in settings/about).
String get platformEngineLabel => Platform.isAndroid || Platform.isIOS
    ? 'Stockfish 19 (light NNUE)'
    : 'Stockfish 19';

/// Default search depth per move for full-game analysis.
int get defaultAnalysisDepth => Platform.isAndroid || Platform.isIOS ? 16 : 18;

/// Looks for a Stockfish binary next to the app, in the macOS bundle, then
/// on PATH.
Future<String?> findDesktopStockfish() async {
  final exeName = Platform.isWindows ? 'stockfish.exe' : 'stockfish';
  final appDir = p.dirname(Platform.resolvedExecutable);
  final candidates = [
    p.join(appDir, 'engines', exeName),
    // macOS: <App>.app/Contents/MacOS/<exe> → Contents/Resources/stockfish
    p.join(appDir, '..', 'Resources', exeName),
  ];
  for (final c in candidates) {
    if (await File(c).exists()) return c;
  }
  final pathVar = Platform.environment['PATH'] ?? '';
  for (final dir in pathVar.split(Platform.isWindows ? ';' : ':')) {
    if (dir.isEmpty) continue;
    final c = p.join(dir, exeName);
    if (await File(c).exists()) return c;
  }
  return null;
}

/// A UCI engine running as a child process (desktop).
class ProcessTransport implements UciTransport {
  ProcessTransport._(this._process) {
    _process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_lines.add, onDone: _lines.close);
    // Drain stderr so the pipe never fills up.
    _process.stderr.drain<void>();
  }

  /// Starts [executable] with no arguments.
  static Future<ProcessTransport> start(
    String executable, {
    List<String> arguments = const [],
  }) async {
    final process = await Process.start(executable, arguments);
    return ProcessTransport._(process);
  }

  final Process _process;
  final _lines = StreamController<String>.broadcast();

  @override
  Stream<String> get lines => _lines.stream;

  @override
  void send(String command) => _process.stdin.writeln(command);

  @override
  Future<void> close() async {
    try {
      _process.stdin.writeln('quit');
      await _process.stdin.flush();
    } on Object {
      // Already gone.
    }
    await _process.exitCode.timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        _process.kill();
        return -1;
      },
    );
  }
}

/// Stockfish linked into the app on Android and iOS.
class MultistockfishTransport implements UciTransport {
  MultistockfishTransport._(this._engine) {
    _engine.stdout.listen(_lines.add);
  }

  static Future<MultistockfishTransport> start() async {
    final engine = await Stockfish.create(flavor: StockfishFlavor.light);
    return MultistockfishTransport._(engine);
  }

  final Stockfish _engine;
  final _lines = StreamController<String>.broadcast();

  @override
  Stream<String> get lines => _lines.stream;

  @override
  void send(String command) => _engine.stdin = command;

  @override
  Future<void> close() async {
    await _engine.dispose();
    await _lines.close();
  }
}
