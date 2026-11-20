import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// An in-memory stand-in for the evilchess server's sync endpoint, with the
/// same rules: last-write-wins on `updatedAt`, a growing sequence number per
/// stored change, and pages of at most [page] items.
class FakeSyncServer {
  FakeSyncServer({this.page = 500});

  final int page;
  final _items = <String, Map<String, Object?>>{};
  int _seq = 0;
  int requests = 0;

  /// Lets a test add a server-side item (e.g. a server import).
  void put(Map<String, Object?> change) => _store(change);

  void _store(Map<String, Object?> c) {
    final key = '${c['kind']}|${c['key']}';
    final existing = _items[key];
    final at = DateTime.parse(c['updatedAt']! as String);
    if (existing != null &&
        !at.isAfter(DateTime.parse(existing['updatedAt']! as String))) {
      return;
    }
    _items[key] = {
      'kind': c['kind'],
      'key': c['key'],
      'payload': (c['deleted'] as bool? ?? false) ? null : c['payload'],
      'deleted': c['deleted'] ?? false,
      'updatedAt': c['updatedAt'],
      'seq': ++_seq,
    };
  }

  Map<String, Object?> handle(Map<String, dynamic> body) {
    requests++;
    for (final c in (body['changes'] as List).cast<Map<String, dynamic>>()) {
      _store(c);
    }
    final since = (body['since'] as num).toInt();
    final all = _items.values.where((i) => (i['seq']! as int) > since).toList()
      ..sort((a, b) => (a['seq']! as int).compareTo(b['seq']! as int));
    final hasMore = all.length > page;
    final out = all.take(page).toList();
    return {
      'cursor': out.isEmpty ? since : out.last['seq'],
      'hasMore': hasMore,
      'changes': out,
    };
  }

  /// An HTTP client that answers `/api/v1/sync` (any other path is a 404).
  http.Client client() => MockClient((req) async {
    if (req.url.path == '/api/v1/sync') {
      return http.Response(
        jsonEncode(handle(jsonDecode(req.body) as Map<String, dynamic>)),
        200,
      );
    }
    return http.Response('{"code":"not_found","message":"?"}', 404);
  });
}
