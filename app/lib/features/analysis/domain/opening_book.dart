/// Named opening for a book position.
typedef OpeningName = ({String eco, String name});

/// Positions from the Lichess opening tables (CC0), keyed by [positionKey].
class OpeningBook {
  OpeningBook._(this._entries);

  /// Parses the `assets/openings/book.tsv` format: `key \t eco \t name`.
  factory OpeningBook.parse(String tsv) {
    final entries = <String, OpeningName?>{};
    for (final line in tsv.split('\n')) {
      if (line.isEmpty) continue;
      final parts = line.split('\t');
      final eco = parts.length > 1 ? parts[1] : '';
      final name = parts.length > 2 ? parts[2].trimRight() : '';
      entries[parts[0]] = eco.isEmpty ? null : (eco: eco, name: name);
    }
    return OpeningBook._(entries);
  }

  /// An empty book (used when the asset is unavailable, e.g. in tests).
  factory OpeningBook.empty() => OpeningBook._(const {});

  static const assetPath = 'assets/openings/book.tsv';

  final Map<String, OpeningName?> _entries;

  int get length => _entries.length;

  bool contains(String key) => _entries.containsKey(key);

  /// The name of the line ending exactly at [key], if any.
  OpeningName? nameAt(String key) => _entries[key];

  /// The deepest named opening along a sequence of position keys, stopping
  /// at the first position that leaves the book.
  OpeningName? identify(Iterable<String> keys) {
    OpeningName? found;
    for (final key in keys) {
      if (!_entries.containsKey(key)) break;
      found = _entries[key] ?? found;
    }
    return found;
  }
}
