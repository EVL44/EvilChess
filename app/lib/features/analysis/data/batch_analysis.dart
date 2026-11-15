import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../games/data/game_repository.dart';
import 'analysis_runner.dart';

@immutable
class BatchState {
  const BatchState({
    this.running = false,
    this.done = 0,
    this.total = 0,
    this.error,
  });

  final bool running;

  /// Games finished so far / games queued in this run.
  final int done;
  final int total;
  final String? error;
}

/// Analyses every not-yet-analysed game, one after another. Keeps running
/// while the user moves around the app; [stop] ends it after the current
/// position.
class BatchAnalysisController extends Notifier<BatchState> {
  bool _stop = false;

  @override
  BatchState build() => const BatchState();

  Future<void> start() async {
    if (state.running) return;
    _stop = false;
    final repo = ref.read(gameRepositoryProvider);
    final ids = await repo.unanalyzedGameIds();
    if (ids.isEmpty) return;
    state = BatchState(running: true, total: ids.length);
    try {
      final runner = await ref.read(analysisRunnerProvider.future);
      for (final id in ids) {
        if (_stop) break;
        final game = await repo.getGame(id);
        if (game != null) {
          await runner.run(game, isCancelled: () => _stop);
        }
        if (_stop) break;
        state = BatchState(
          running: true,
          done: state.done + 1,
          total: ids.length,
        );
      }
      state = BatchState(done: state.done, total: ids.length);
    } catch (e) {
      state = BatchState(done: state.done, total: ids.length, error: '$e');
    }
  }

  void stop() => _stop = true;
}

final batchAnalysisProvider =
    NotifierProvider<BatchAnalysisController, BatchState>(
      BatchAnalysisController.new,
    );
