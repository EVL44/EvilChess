/// A line-based channel to a UCI chess engine. Each platform provides one:
/// a native library (Android/iOS), a child process (desktop), or a Web Worker
/// (web). Everything above this — the UCI protocol, analysis, caching — is
/// shared and platform-independent.
abstract interface class UciTransport {
  /// Lines printed by the engine.
  Stream<String> get lines;

  /// Sends one command line to the engine.
  void send(String command);

  /// Stops the engine and releases its resources.
  Future<void> close();
}

/// Thrown when no engine can be started on this device.
class EngineUnavailableException implements Exception {
  const EngineUnavailableException(this.message);
  final String message;
  @override
  String toString() => 'EngineUnavailableException: $message';
}
