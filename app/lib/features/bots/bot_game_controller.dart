import 'dart:async';
import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/engine_service.dart';
import '../analysis/data/analysis_runner.dart';
import '../analysis/domain/position_key.dart';
import '../games/data/game_repository.dart';
import '../games/domain/game_record.dart';
import '../games/domain/pgn_import.dart';
import '../games/domain/pgn_writer.dart';
import 'domain/bot.dart';

/// Why a game ended.
enum GameEnd {
  checkmate,
  stalemate,
  insufficientMaterial,
  threefoldRepetition,
  fiftyMoveRule,
  resignation,
}

/// What the player chose before the game.
typedef BotGameSetup = ({String botId, Side userSide, bool takebacks});

@immutable
class BotGameState {
  const BotGameState({
    required this.bot,
    required this.userSide,
    required this.takebacks,
    required this.initialFen,
    this.plies = const [],
    this.thinking = false,
    this.result,
    this.end,
    this.hintUci,
    this.hintLoading = false,
    this.savedGameId,
    this.error,
  });

  final Bot bot;
  final Side userSide;
  final bool takebacks;
  final String initialFen;
  final List<GamePly> plies;

  /// The bot is choosing a move.
  final bool thinking;

  /// `1-0`, `0-1` or `1/2-1/2` once the game is over.
  final String? result;
  final GameEnd? end;

  /// Engine suggestion for the player (shown as an arrow).
  final String? hintUci;
  final bool hintLoading;

  /// Library id once the finished game is saved.
  final String? savedGameId;
  final String? error;

  String get fen => plies.isEmpty ? initialFen : plies.last.fenAfter;
  Position get position => Chess.fromSetup(Setup.parseFen(fen));
  Side get turn => position.turn;
  bool get isOver => result != null;
  bool get userToMove => !isOver && turn == userSide;

  /// Did the player win (null while playing or after a draw).
  bool? get userWon {
    if (result == null || result == '1/2-1/2') return null;
    return (result == '1-0') == (userSide == Side.white);
  }

  /// A takeback is possible when allowed and the player has moved.
  bool get canTakeBack =>
      takebacks &&
      !isOver &&
      !thinking &&
      plies.any((p) => _moverOf(p) == userSide);

  static Side _moverOf(GamePly p) =>
      p.fenBefore.split(' ')[1] == 'w' ? Side.white : Side.black;

  /// A light record for widgets that show a move list.
  GameRecord get record => GameRecord(
    id: 'live',
    source: GameSource.evilchess,
    white: userSide == Side.white ? 'You' : bot.name,
    black: userSide == Side.black ? 'You' : bot.name,
    result: result ?? '*',
    initialFen: initialFen,
    plies: plies,
    pgn: '',
  );

  BotGameState copyWith({
    List<GamePly>? plies,
    bool? thinking,
    String? Function()? result,
    GameEnd? Function()? end,
    String? Function()? hintUci,
    bool? hintLoading,
    String? Function()? savedGameId,
    String? Function()? error,
  }) => BotGameState(
    bot: bot,
    userSide: userSide,
    takebacks: takebacks,
    initialFen: initialFen,
    plies: plies ?? this.plies,
    thinking: thinking ?? this.thinking,
    result: result != null ? result() : this.result,
    end: end != null ? end() : this.end,
    hintUci: hintUci != null ? hintUci() : this.hintUci,
    hintLoading: hintLoading ?? this.hintLoading,
    savedGameId: savedGameId != null ? savedGameId() : this.savedGameId,
    error: error != null ? error() : this.error,
  );
}

/// Checks whether the game is over after the last move in [plies].
({String result, GameEnd end})? gameOver(
  Position pos,
  List<GamePly> plies,
  String initialFen,
) {
  if (pos.isCheckmate) {
    return (
      result: pos.turn == Side.white ? '0-1' : '1-0',
      end: GameEnd.checkmate,
    );
  }
  if (pos.isStalemate) return (result: '1/2-1/2', end: GameEnd.stalemate);
  if (pos.isInsufficientMaterial) {
    return (result: '1/2-1/2', end: GameEnd.insufficientMaterial);
  }
  if (pos.halfmoves >= 100) {
    return (result: '1/2-1/2', end: GameEnd.fiftyMoveRule);
  }
  final now = positionKey(pos);
  var seen = fenKey(initialFen) == now ? 1 : 0;
  for (final p in plies) {
    if (fenKey(p.fenAfter) == now) seen++;
  }
  if (seen >= 3) {
    return (result: '1/2-1/2', end: GameEnd.threefoldRepetition);
  }
  return null;
}

/// Runs one game against a bot.
class BotGameController extends Notifier<BotGameState> {
  BotGameController(this.setup);

  final BotGameSetup setup;

  /// Pause before the bot moves, so it feels like an opponent. Tests set it
  /// to zero.
  static Duration Function(math.Random) thinkTime = (r) =>
      Duration(milliseconds: 450 + r.nextInt(900));

  final _random = math.Random();
  BotMovePicker? _picker;
  int _generation = 0;
  bool _disposed = false;

  @override
  BotGameState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final bot = botById(setup.botId);
    _picker = BotMovePicker(bot, random: _random);
    final initial = BotGameState(
      bot: bot,
      userSide: setup.userSide,
      takebacks: setup.takebacks,
      initialFen: Chess.initial.fen,
    );
    if (setup.userSide == Side.black) {
      scheduleMicrotask(_botTurn);
    }
    return initial;
  }

  GamePly _ply(Position pos, Move move) {
    final (after, san) = pos.makeSan(move);
    return GamePly(
      san: san,
      uci: standardUci(pos, move),
      fenBefore: pos.fen,
      fenAfter: after.fen,
    );
  }

  /// Plays [move] and, if the game goes on, lets the bot answer.
  void userMove(Move move) {
    if (!state.userToMove || state.thinking) return;
    final pos = state.position;
    if (!pos.isLegal(move)) return;
    _apply(_ply(pos, move));
    if (!state.isOver) unawaited(_botTurn());
  }

  void _apply(GamePly ply) {
    final plies = [...state.plies, ply];
    final after = Chess.fromSetup(Setup.parseFen(ply.fenAfter));
    final over = gameOver(after, plies, state.initialFen);
    state = state.copyWith(
      plies: plies,
      hintUci: () => null,
      result: () => over?.result,
      end: () => over?.end,
    );
    if (over != null) unawaited(_save());
  }

  Future<void> _botTurn() async {
    if (_disposed || state.isOver || state.userToMove) return;
    final generation = ++_generation;
    state = state.copyWith(thinking: true, error: () => null);
    try {
      final pos = state.position;
      final bot = state.bot;
      final started = DateTime.now();
      final engine = await ref.read(engineServiceProvider).engine;
      final lines = await engine.lines(
        pos.fen,
        depth: bot.depth,
        multiPv: bot.multiPv,
      );
      final book = await ref.read(openingBookProvider.future);
      final uci = _picker!.choose(pos, lines, book: book);

      final wait = thinkTime(_random) - DateTime.now().difference(started);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
      // A takeback or rematch while thinking makes this answer stale.
      if (_disposed || generation != _generation) return;

      final move = parseEngineUci(pos, uci)!;
      state = state.copyWith(thinking: false);
      _apply(_ply(pos, move));
    } catch (e) {
      if (_disposed || generation != _generation) return;
      state = state.copyWith(thinking: false, error: () => '$e');
    }
  }

  /// Retries the bot's move after an engine error.
  void retryBot() => unawaited(_botTurn());

  /// Shows the engine's best move for the player.
  Future<void> hint() async {
    if (!state.userToMove || state.hintLoading) return;
    final fen = state.fen;
    state = state.copyWith(hintLoading: true);
    try {
      final engine = await ref.read(engineServiceProvider).engine;
      final r = await engine.evaluate(fen, depth: 14, multiPv: 1);
      if (_disposed || state.fen != fen) return;
      state = state.copyWith(hintLoading: false, hintUci: () => r.bestUci);
    } catch (_) {
      if (!_disposed) state = state.copyWith(hintLoading: false);
    }
  }

  /// Undoes the player's last move (and the bot's reply to it).
  void takeBack() {
    if (!state.canTakeBack) return;
    _generation++; // drop a reply that is still being computed
    final plies = [...state.plies];
    while (plies.isNotEmpty) {
      final last = plies.removeLast();
      if (BotGameState._moverOf(last) == state.userSide) break;
    }
    state = state.copyWith(plies: plies, thinking: false, hintUci: () => null);
  }

  void resign() {
    if (state.isOver) return;
    _generation++;
    state = state.copyWith(
      thinking: false,
      result: () => state.userSide == Side.white ? '0-1' : '1-0',
      end: () => GameEnd.resignation,
    );
    unawaited(_save());
  }

  /// Starts a new game against the same bot with colours swapped.
  void rematch() {
    _generation++;
    final side = state.userSide.opposite;
    state = BotGameState(
      bot: state.bot,
      userSide: side,
      takebacks: state.takebacks,
      initialFen: Chess.initial.fen,
    );
    if (side == Side.black) unawaited(_botTurn());
  }

  /// Stores the finished game in the library (with the player's colour set,
  /// so it counts in the report and its mistakes become puzzles).
  Future<void> _save() async {
    final s = state;
    if (s.plies.isEmpty || s.result == null) return;
    final now = DateTime.now().toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    final botName = '${s.bot.name} (bot)';
    final pgn = writePgn(
      headers: {
        'Event': 'evilchess bot game',
        'Site': 'evilchess',
        'Date': '${now.year}.${two(now.month)}.${two(now.day)}',
        'UTCDate': '${now.year}.${two(now.month)}.${two(now.day)}',
        'UTCTime': '${two(now.hour)}:${two(now.minute)}:${two(now.second)}',
        'White': s.userSide == Side.white ? 'You' : botName,
        'Black': s.userSide == Side.black ? 'You' : botName,
        if (s.userSide == Side.white) 'BlackElo': '${s.bot.rating}',
        if (s.userSide == Side.black) 'WhiteElo': '${s.bot.rating}',
        'Termination': s.end?.name ?? '',
      },
      sans: [for (final p in s.plies) p.san],
      result: s.result!,
      initialFen: s.initialFen,
    );
    final record = parseSinglePgn(
      pgn,
      source: GameSource.evilchess,
      externalId: '${s.bot.id}-${now.microsecondsSinceEpoch}',
    );
    if (record == null) return;
    final repo = ref.read(gameRepositoryProvider);
    await repo.addGames([record]);
    await repo.setUserSide(
      record.id,
      s.userSide == Side.white ? 'white' : 'black',
    );
    if (!_disposed) state = state.copyWith(savedGameId: () => record.id);
  }
}

final botGameProvider = NotifierProvider.autoDispose
    .family<BotGameController, BotGameState, BotGameSetup>(
      BotGameController.new,
    );
