import 'package:dartchess/dartchess.dart';
import 'package:drift/native.dart';
import 'package:evilchess/core/db/app_database.dart';
import 'package:evilchess/core/engine/engine_service.dart';
import 'package:evilchess/features/analysis/data/analysis_runner.dart';
import 'package:evilchess/features/analysis/domain/game_analysis.dart';
import 'package:evilchess/features/analysis/domain/motifs.dart';
import 'package:evilchess/features/analysis/domain/opening_book.dart';
import 'package:evilchess/features/analysis/domain/position_key.dart';
import 'package:evilchess/features/games/data/game_repository.dart';
import 'package:evilchess/features/games/domain/game_record.dart';
import 'package:evilchess/features/games/domain/pgn_import.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_engine.dart';
import '../fixtures/pgns.dart';

TacticTheme? tactic(String fen, String uci) {
  final pos = Chess.fromSetup(Setup.parseFen(fen));
  return detectTactic(pos, parseEngineUci(pos, uci)! as NormalMove);
}

/// Analyses [pgn] with a scripted fake engine. [script] maps the number of
/// plies played to the engine's answer for that position.
Future<GameAnalysis> analyse(String pgn, Map<int, FakeLine> script) async {
  final game = parsePgnGames(pgn).single;
  String key(int i) =>
      fenKey(i == 0 ? game.initialFen : game.plies[i - 1].fenAfter);
  final db = AppDatabase(NativeDatabase.memory());
  final repo = GameRepository(db);
  final engine = EngineService(
    () async => FakeUciTransport(
      script: {for (final e in script.entries) key(e.key): e.value},
    ),
  );
  await repo.addGames([game]);
  final analysis = await AnalysisRunner(
    repository: repo,
    engineService: engine,
    book: OpeningBook.empty(),
    depth: 10,
  ).run(game);
  await engine.dispose();
  await db.close();
  return analysis!;
}

void main() {
  group('detectTactic', () {
    test('knight fork of king and rook', () {
      expect(
        tactic('r3k3/8/8/1N6/8/8/8/4K3 w - - 0 1', 'b5c7'),
        TacticTheme.fork,
      );
    });

    test('bishop pins a knight to the king', () {
      expect(
        tactic('4k3/8/2n5/8/8/8/8/4KB2 w - - 0 1', 'f1b5'),
        TacticTheme.pin,
      );
    });

    test('bishop skewers king and queen', () {
      expect(
        tactic('7q/8/8/4k3/8/8/8/2B1K3 w - - 0 1', 'c1b2'),
        TacticTheme.skewer,
      );
    });

    test('knight move uncovers a rook attack on the queen', () {
      expect(
        tactic('6k1/4q3/8/8/4N3/8/8/4R1K1 w - - 0 1', 'e4f6'),
        TacticTheme.discoveredAttack,
      );
    });

    test('back-rank mate', () {
      expect(
        tactic('6k1/5ppp/8/8/8/8/8/R5K1 w - - 0 1', 'a1a8'),
        TacticTheme.backRankMate,
      );
    });

    test('other mates are just "mate"', () {
      expect(
        tactic(
          'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4',
          'h5f7',
        ),
        TacticTheme.mate,
      );
    });

    test('a quiet developing move has no theme', () {
      expect(tactic(Chess.initial.fen, 'g1f3'), isNull);
    });
  });

  group('annotateMotifs', () {
    test('walking into mate', () async {
      final a = await analyse(chessComPgn, {
        5: (cp: -10, mate: null, best: 'g7g6', secondCp: -400),
        6: (cp: null, mate: 1, best: 'h5f7', secondCp: 300),
      });
      final nf6 = a.moves[5];
      expect(nf6.motifs, contains(Motif.walkedIntoMate));
      expect(nf6.category, ErrorCategory.mate);
      // White found the mate: counted as a found "mate" opportunity.
      expect(a.moves[6].opportunity, TacticTheme.mate);
      expect(a.moves[6].motifs, isEmpty);
    });

    test('hanging the queen', () async {
      // 2...Qg5?? 3.Bxg5
      final a = await analyse('1. d4 e5 2. dxe5 Qg5 3. Bxg5 *', {
        3: (cp: -80, mate: null, best: 'b8c6', secondCp: -120),
        4: (cp: 900, mate: null, best: 'c1g5', secondCp: 100),
      });
      final qg5 = a.moves[3];
      expect(qg5.san, 'Qg5');
      expect(qg5.motifs, contains(Motif.hungPiece));
      expect(qg5.category, ErrorCategory.hungMaterial);
      expect(
        hungPieceRole(
          parsePgnGames('1. d4 e5 2. dxe5 Qg5 3. Bxg5 *')
              .single
              .plies[3]
              .fenAfter,
          'c1g5',
        ),
        Role.queen,
      );
    });

    test('a bad trade: bishop for a pawn', () async {
      final a = await analyse(
        '1. e4 e5 2. Nf3 Nc6 3. Bc4 Nf6 4. Bxf7+ Kxf7 *',
        {
          6: (cp: 30, mate: null, best: 'd2d3', secondCp: 10),
          7: (cp: 300, mate: null, best: 'e8f7', secondCp: -200),
        },
      );
      final bxf7 = a.moves[6];
      expect(bxf7.san, 'Bxf7+');
      expect(bxf7.motifs, contains(Motif.badTrade));
      expect(bxf7.motifs, isNot(contains(Motif.hungPiece)));
      expect(bxf7.category, ErrorCategory.hungMaterial);
    });

    test('good moves carry no motifs or category', () async {
      final a = await analyse('1. e4 e5 2. Nf3 Nc6 *', {});
      expect(a.moves.every((m) => m.motifs.isEmpty), isTrue);
      expect(a.moves.every((m) => m.category == null), isTrue);
    });
  });

  test('time-trouble threshold scales with the time control', () {
    expect(timeTroubleThreshold(const TimeControl(60, 0)).inSeconds, 6);
    expect(timeTroubleThreshold(const TimeControl(180, 2)).inSeconds, 18);
    expect(timeTroubleThreshold(const TimeControl(600, 0)).inSeconds, 30);
    expect(timeTroubleThreshold(const TimeControl(15, 0)).inSeconds, 5);
  });
}
