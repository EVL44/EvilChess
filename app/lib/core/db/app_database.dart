import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Imported and played games.
@DataClassName('GameRow')
class Games extends Table {
  TextColumn get id => text()();
  TextColumn get source => text()();
  TextColumn get externalId => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get white => text()();
  TextColumn get black => text()();
  IntColumn get whiteElo => integer().nullable()();
  IntColumn get blackElo => integer().nullable()();
  TextColumn get result => text()();
  DateTimeColumn get playedAt => dateTime().nullable()();
  TextColumn get timeControl => text().nullable()();
  TextColumn get speed => text()();
  TextColumn get eco => text().nullable()();
  TextColumn get opening => text().nullable()();
  TextColumn get event => text().nullable()();
  TextColumn get initialFen => text()();

  /// JSON list of plies (san, uci, fens, clock).
  TextColumn get pliesJson => text()();
  TextColumn get pgn => text()();

  /// Which colour the linked account played ('white' / 'black'), if known.
  TextColumn get userSide => text().nullable()();
  DateTimeColumn get importedAt => dateTime()();
  DateTimeColumn get analyzedAt => dateTime().nullable()();
  IntColumn get analysisDepth => integer().nullable()();

  /// Version of the analysis rules the stored rows were produced with
  /// (see `kAnalysisVersion`); older rows are upgraded without the engine.
  IntColumn get analysisVersion => integer().withDefault(const Constant(0))();

  /// Last local change (import, analysis, colour), in milliseconds since
  /// the epoch — drives sync pushes. (Drift dates only keep seconds.)
  IntColumn get updatedAt => integer().named('updated_at_ms').nullable()();
  RealColumn get whiteAccuracy => real().nullable()();
  RealColumn get blackAccuracy => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One row per analysed move — reports are plain SQL over this table.
@DataClassName('MoveAnalysisRow')
class MoveAnalyses extends Table {
  TextColumn get gameId =>
      text().references(Games, #id, onDelete: KeyAction.cascade)();
  IntColumn get ply => integer()();
  BoolColumn get whiteMoved => boolean()();
  TextColumn get san => text()();
  TextColumn get uci => text()();
  TextColumn get classification => text()();
  RealColumn get accuracy => real()();
  RealColumn get winBefore => real()();
  RealColumn get winAfter => real()();

  /// White-POV evals as JSON ({"cp":..} / {"mate":..}).
  TextColumn get evalBefore => text()();
  TextColumn get evalAfter => text()();
  TextColumn get bestUci => text().nullable()();
  TextColumn get bestSan => text().nullable()();

  /// Engine line in SAN, space separated.
  TextColumn get bestLine => text().nullable()();
  TextColumn get phase => text()();
  TextColumn get piece => text()();
  IntColumn get clockMs => integer().nullable()();

  /// Position before the move (puzzles start from here).
  TextColumn get fenBefore => text().nullable()();

  /// Comma-separated `Motif` names explaining an error.
  TextColumn get motifs => text().nullable()();

  /// `TacticTheme` of the best move when it was found or clearly missed.
  TextColumn get opportunity => text().nullable()();

  /// `ErrorCategory` for inaccuracies and worse.
  TextColumn get category => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {gameId, ply};
}

/// Progress on puzzles made from the player's own mistakes.
@DataClassName('PuzzleAttemptRow')
class PuzzleAttempts extends Table {
  TextColumn get gameId =>
      text().references(Games, #id, onDelete: KeyAction.cascade)();
  IntColumn get ply => integer()();
  BoolColumn get solved => boolean()();
  IntColumn get attempts => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastAttemptAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {gameId, ply};
}

/// Engine results by position — shared between games, so a position that
/// was already searched at the same or greater depth is never recomputed.
@DataClassName('PositionEvalRow')
class PositionEvals extends Table {
  /// First four FEN fields (see `positionKey`).
  TextColumn get fenKey => text()();
  IntColumn get multiPv => integer()();
  IntColumn get depth => integer()();

  /// JSON of `PositionEval` (scores are White-POV).
  TextColumn get json => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {fenKey, multiPv};
}

/// Lichess / Chess.com usernames linked for importing.
@DataClassName('LinkedAccountRow')
class LinkedAccounts extends Table {
  TextColumn get provider => text()();
  TextColumn get username => text()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Newest game time seen, used for incremental sync.
  DateTimeColumn get newestGameAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {provider};
}

/// Games deleted on this device, so the deletion reaches other devices.
@DataClassName('DeletedGameRow')
class DeletedGames extends Table {
  TextColumn get id => text()();

  /// Milliseconds since the epoch.
  IntColumn get deletedAt => integer().named('deleted_at_ms')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Lichess puzzles kept on the device for offline Puzzle Rush.
@DataClassName('CachedPuzzleRow')
class CachedPuzzles extends Table {
  TextColumn get id => text()();
  TextColumn get fen => text()();

  /// UCI moves, space separated; the first is the opponent's.
  TextColumn get moves => text()();
  IntColumn get rating => integer()();
  TextColumn get themes => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Games,
    MoveAnalyses,
    PositionEvals,
    LinkedAccounts,
    PuzzleAttempts,
    DeletedGames,
    CachedPuzzles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(games, games.analysisVersion);
        await m.addColumn(moveAnalyses, moveAnalyses.fenBefore);
        await m.addColumn(moveAnalyses, moveAnalyses.motifs);
        await m.addColumn(moveAnalyses, moveAnalyses.opportunity);
        await m.addColumn(moveAnalyses, moveAnalyses.category);
        await m.createTable(puzzleAttempts);
      }
      if (from < 3) {
        await m.addColumn(games, games.updatedAt);
        await m.createTable(deletedGames);
        await m.createTable(cachedPuzzles);
      }
    },
    onCreate: (m) async {
      await m.createAll();
      await m.createIndex(
        Index(
          'games_played_at',
          'CREATE INDEX games_played_at ON games (played_at DESC)',
        ),
      );
    },
  );

  static QueryExecutor _openConnection() => driftDatabase(
    name: 'evilchess',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
