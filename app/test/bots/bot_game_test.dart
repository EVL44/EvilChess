import 'package:dartchess/dartchess.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/core/db/database_provider.dart';
import 'package:evilchess/core/engine/engine_service.dart';
import 'package:evilchess/features/analysis/data/analysis_runner.dart';
import 'package:evilchess/features/analysis/domain/opening_book.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';
import 'package:evilchess/features/bots/bot_game_controller.dart';
import 'package:evilchess/features/games/data/game_repository.dart';
import 'package:evilchess/features/games/domain/game_record.dart';
import 'package:evilchess/features/games/domain/pgn_import.dart';
import 'package:evilchess/features/games/domain/pgn_writer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_engine.dart';

Position fen(String f) => Chess.fromSetup(Setup.parseFen(f));

/// Plays [sans] from the start and returns the plies.
List<GamePly> line(List<String> sans) {
  Position pos = Chess.initial;
  return [
    for (final san in sans)
      () {
        final move = pos.parseSan(san)!;
        final (after, s) = pos.makeSan(move);
        final ply = GamePly(
          san: s,
          uci: standardUci(pos, move),
          fenBefore: pos.fen,
          fenAfter: after.fen,
        );
        pos = after;
        return ply;
      }(),
  ];
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('gameOver', () {
    test('checkmate, stalemate, insufficient material, 50 moves', () {
      expect(
        gameOver(
          fen('rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3'),
          const [],
          Chess.initial.fen,
        ),
        (result: '0-1', end: GameEnd.checkmate),
      );
      expect(gameOver(fen('7k/5Q2/6K1/8/8/8/8/8 b - - 0 1'), const [], ''), (
        result: '1/2-1/2',
        end: GameEnd.stalemate,
      ));
      expect(gameOver(fen('8/8/4k3/8/8/3NK3/8/8 w - - 0 1'), const [], ''), (
        result: '1/2-1/2',
        end: GameEnd.insufficientMaterial,
      ));
      expect(gameOver(fen('8/8/4k3/8/8/3RK3/8/8 w - - 100 80'), const [], ''), (
        result: '1/2-1/2',
        end: GameEnd.fiftyMoveRule,
      ));
      expect(gameOver(Chess.initial, const [], Chess.initial.fen), isNull);
    });

    test('threefold repetition counts the start position', () {
      final shuffle = line([
        'Nf3', 'Nf6', 'Ng1', 'Ng8', //
        'Nf3', 'Nf6', 'Ng1', 'Ng8',
      ]);
      final last = fen(shuffle.last.fenAfter);
      expect(gameOver(last, shuffle, Chess.initial.fen), (
        result: '1/2-1/2',
        end: GameEnd.threefoldRepetition,
      ));
      // Only twice after the first cycle.
      final half = shuffle.sublist(0, 4);
      expect(
        gameOver(fen(half.last.fenAfter), half, Chess.initial.fen),
        isNull,
      );
    });
  });

  test('writePgn round-trips through the importer', () {
    final sans = ['e4', 'e5', 'Qh5', 'Nc6', 'Bc4', 'Nf6', 'Qxf7#'];
    final pgn = writePgn(
      headers: {'White': 'You', 'Black': 'Pip (bot)'},
      sans: sans,
      result: '1-0',
    );
    final game = parsePgnGames(pgn).single;
    expect(game.plies.map((p) => p.san), sans);
    expect(game.result, '1-0');
    expect(game.black, 'Pip (bot)');

    // From a position with Black to move.
    const start = '4k3/8/8/8/8/8/4P3/4K3 b - - 0 1';
    final custom = writePgn(
      headers: const {},
      sans: ['Kd7', 'e4'],
      result: '*',
      initialFen: start,
    );
    expect(custom, contains('1... Kd7 2. e4 *'));
    expect(parsePgnGames(custom).single.initialFen, start);
  });

  group('BotGameController', () {
    late AppDatabase db;
    late ProviderContainer container;
    late FakeUciTransport engine;

    // Black's scripted replies to the scholar's mate.
    String after(List<String> sans) => fenKey(line(sans).last.fenAfter);

    setUp(() {
      BotGameController.thinkTime = (_) => Duration.zero;
      db = AppDatabase(NativeDatabase.memory());
      engine = FakeUciTransport(
        script: {
          after(['e4']): (cp: -30, mate: null, best: 'e7e5', secondCp: null),
          after(['e4', 'e5', 'Qh5']): (
            cp: -20,
            mate: null,
            best: 'b8c6',
            secondCp: null,
          ),
          after(['e4', 'e5', 'Qh5', 'Nc6', 'Bc4']): (
            cp: 0,
            mate: null,
            best: 'g8f6',
            secondCp: null,
          ),
        },
      );
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          engineTransportFactoryProvider.overrideWithValue(() async => engine),
          openingBookProvider.overrideWith((ref) async => OpeningBook.empty()),
        ],
      );
    });
    tearDown(() async {
      container.dispose();
      await db.close();
    });

    Future<void> settle(bool Function() done) async {
      for (var i = 0; i < 200 && !done(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    }

    BotGameSetup setup({Side side = Side.white, bool takebacks = true}) =>
        (botId: 'malakar', userSide: side, takebacks: takebacks);

    void play(BotGameController c, Position pos, String san) =>
        c.userMove(pos.parseSan(san)!);

    test('a full game to checkmate is saved as the player\'s win', () async {
      final s = setup();
      final sub = container.listen(botGameProvider(s), (_, _) {});
      addTearDown(sub.close);
      final c = container.read(botGameProvider(s).notifier);
      BotGameState state() => container.read(botGameProvider(s));

      for (final san in ['e4', 'Qh5', 'Bc4', 'Qxf7#']) {
        final before = state().plies.length;
        play(c, state().position, san);
        await settle(
          () => state().isOver || state().plies.length == before + 2,
        );
      }

      expect(state().plies.map((p) => p.san), [
        'e4', 'e5', 'Qh5', 'Nc6', 'Bc4', 'Nf6', 'Qxf7#', //
      ]);
      expect(state().result, '1-0');
      expect(state().end, GameEnd.checkmate);
      expect(state().userWon, isTrue);

      await settle(() => state().savedGameId != null);
      final repo = GameRepository(db);
      final saved = (await repo.getGame(state().savedGameId!))!;
      expect(saved.source, GameSource.evilchess);
      expect(saved.white, 'You');
      expect(saved.black, 'Malakar the Unblinking (bot)');
      expect(saved.blackElo, 2700);
      expect(saved.plies, hasLength(7));
      expect(await repo.userSide(saved.id), 'white');
    });

    test('takeback undoes the player\'s move and the reply', () async {
      final s = setup();
      final sub = container.listen(botGameProvider(s), (_, _) {});
      addTearDown(sub.close);
      final c = container.read(botGameProvider(s).notifier);
      BotGameState state() => container.read(botGameProvider(s));

      play(c, state().position, 'e4');
      await settle(() => state().plies.length == 2);
      expect(state().canTakeBack, isTrue);
      c.takeBack();
      expect(state().plies, isEmpty);
      expect(state().userToMove, isTrue);
    });

    test('takebacks can be turned off', () async {
      final s = setup(takebacks: false);
      final sub = container.listen(botGameProvider(s), (_, _) {});
      addTearDown(sub.close);
      final c = container.read(botGameProvider(s).notifier);
      BotGameState state() => container.read(botGameProvider(s));

      play(c, state().position, 'e4');
      await settle(() => state().plies.length == 2);
      expect(state().canTakeBack, isFalse);
      c.takeBack();
      expect(state().plies, hasLength(2));
    });

    test('playing Black: the bot opens; resign saves a loss', () async {
      final s = setup(side: Side.black);
      final sub = container.listen(botGameProvider(s), (_, _) {});
      addTearDown(sub.close);
      final c = container.read(botGameProvider(s).notifier);
      BotGameState state() => container.read(botGameProvider(s));

      await settle(() => state().plies.length == 1);
      expect(state().plies, hasLength(1));
      expect(state().userToMove, isTrue);

      c.resign();
      expect(state().result, '1-0');
      expect(state().end, GameEnd.resignation);
      expect(state().userWon, isFalse);
      await settle(() => state().savedGameId != null);
      expect(await GameRepository(db).userSide(state().savedGameId!), 'black');
    });

    test('rematch swaps colours', () async {
      final s = setup();
      final sub = container.listen(botGameProvider(s), (_, _) {});
      addTearDown(sub.close);
      final c = container.read(botGameProvider(s).notifier);
      BotGameState state() => container.read(botGameProvider(s));

      c.resign();
      c.rematch();
      expect(state().userSide, Side.black);
      expect(state().isOver, isFalse);
      await settle(() => state().plies.length == 1);
      expect(state().plies, hasLength(1), reason: 'bot plays White');
    });

    test('hint suggests the engine move', () async {
      final s = setup();
      final sub = container.listen(botGameProvider(s), (_, _) {});
      addTearDown(sub.close);
      final c = container.read(botGameProvider(s).notifier);
      BotGameState state() => container.read(botGameProvider(s));

      await c.hint();
      expect(state().hintUci, isNotNull);
      expect(legalMove(state().position, state().hintUci!), isTrue);
      // Moving clears the hint.
      play(c, state().position, 'd4');
      expect(state().hintUci, isNull);
    });
  });
}

bool legalMove(Position pos, String uci) => parseEngineUci(pos, uci) != null;
