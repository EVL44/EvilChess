import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'transport_io.dart'
    if (dart.library.js_interop) 'transport_web.dart'
    as platform;
import 'uci_engine.dart';
import 'uci_transport.dart';

export 'uci_engine.dart';
export 'uci_transport.dart';

/// The single analysis engine for the app.
///
/// Platform differences live entirely in the [UciTransport]; the rest of the
/// app only sees [UciEngine]. Tests override [engineTransportFactoryProvider]
/// with a fake engine.
class EngineService {
  EngineService(this._createTransport);

  final Future<UciTransport> Function() _createTransport;
  Future<UciEngine>? _engine;

  /// Starts the engine on first use; later calls share the same instance.
  Future<UciEngine> get engine => _engine ??= _start();

  Future<UciEngine> _start() async {
    try {
      final transport = await _createTransport();
      final engine = UciEngine(transport);
      await engine.init();
      return engine;
    } catch (_) {
      _engine = null; // allow a retry
      rethrow;
    }
  }

  Future<void> dispose() async {
    final e = _engine;
    _engine = null;
    if (e != null) await (await e).dispose();
  }
}

/// Builds the platform transport. Overridden in tests.
final engineTransportFactoryProvider =
    Provider<Future<UciTransport> Function()>(
      (ref) => platform.createPlatformTransport,
    );

final engineServiceProvider = Provider<EngineService>((ref) {
  final service = EngineService(ref.watch(engineTransportFactoryProvider));
  ref.onDispose(service.dispose);
  return service;
});

/// Default per-position depth for full-game analysis on this platform.
final analysisDepthProvider = Provider<int>(
  (ref) => platform.defaultAnalysisDepth,
);

/// Human-readable engine name for this platform.
String get platformEngineLabel => platform.platformEngineLabel;
