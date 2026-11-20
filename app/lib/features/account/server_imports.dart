import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../games/domain/game_record.dart';
import 'account.dart';

/// Lichess / Chess.com imports run by the server for signed-in users; the
/// games then reach every device through sync.
class ServerImports {
  ServerImports(this._api, {this.pollEvery = const Duration(seconds: 2)});

  final ApiClient _api;
  final Duration pollEvery;

  static String provider(GameSource s) =>
      s == GameSource.lichess ? 'lichess' : 'chesscom';

  Future<void> link(GameSource source, String username) =>
      _api.put('/api/v1/imports/${provider(source)}', {'username': username});

  Future<void> unlink(GameSource source) =>
      _api.delete('/api/v1/imports/${provider(source)}');

  /// Starts an import and waits for it, reporting games imported so far.
  /// Throws an [ApiException] with code `import_failed` when the server
  /// reports an error.
  Future<int> run(GameSource source, {void Function(int)? onProgress}) async {
    final p = provider(source);
    final start =
        await _api.post('/api/v1/imports/$p/sync') as Map<String, dynamic>;
    final before = (start['imported'] as num?)?.toInt() ?? 0;
    for (var i = 0; i < 300; i++) {
      await Future<void>.delayed(pollEvery);
      final list = await _api.get('/api/v1/imports') as List;
      final acc = list.cast<Map<String, dynamic>>().firstWhere(
        (a) => a['provider'] == p,
        orElse: () => const {},
      );
      final status = acc['status'] as String? ?? 'idle';
      final imported = ((acc['imported'] as num?)?.toInt() ?? 0) - before;
      onProgress?.call(imported < 0 ? 0 : imported);
      if (status == 'error') {
        throw ApiException(
          502,
          'import_failed',
          acc['lastError'] as String? ?? 'Import failed',
        );
      }
      if (status == 'idle') return imported < 0 ? 0 : imported;
    }
    throw const ApiException(0, 'network', 'Import is taking too long');
  }
}

final serverImportsProvider = Provider<ServerImports>(
  (ref) => ServerImports(ref.watch(apiClientProvider)),
);
