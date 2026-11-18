import 'package:dartchess/dartchess.dart' show Role;

import '../../features/analysis/domain/game_analysis.dart';
import '../../features/analysis/domain/material.dart';
import '../../features/analysis/domain/motifs.dart';
import '../../features/bots/bot_game_controller.dart';
import '../../features/bots/domain/bot.dart';
import '../../features/games/domain/game_record.dart';
import '../../features/reports/domain/report.dart';
import '../../l10n/app_localizations.dart';

/// Localized names for domain enums, in one place.
extension DomainLabels on AppLocalizations {
  String phase(GamePhase p) => switch (p) {
    GamePhase.opening => phaseOpening,
    GamePhase.middlegame => phaseMiddlegame,
    GamePhase.endgame => phaseEndgame,
  };

  String category(ErrorCategory c) => switch (c) {
    ErrorCategory.mate => catMate,
    ErrorCategory.hungMaterial => catHungMaterial,
    ErrorCategory.missedTactic => catMissedTactic,
    ErrorCategory.opening => catOpening,
    ErrorCategory.endgame => catEndgame,
    ErrorCategory.positional => catPositional,
  };

  String theme(TacticTheme t) => switch (t) {
    TacticTheme.fork => themeFork,
    TacticTheme.pin => themePin,
    TacticTheme.skewer => themeSkewer,
    TacticTheme.discoveredAttack => themeDiscoveredAttack,
    TacticTheme.mate => themeMate,
    TacticTheme.backRankMate => themeBackRankMate,
  };

  String piece(Role r) => switch (r) {
    Role.pawn => piecePawn,
    Role.knight => pieceKnight,
    Role.bishop => pieceBishop,
    Role.rook => pieceRook,
    Role.queen => pieceQueen,
    Role.king => pieceKing,
  };

  String speed(GameSpeed s) => switch (s) {
    GameSpeed.ultraBullet => speedUltraBullet,
    GameSpeed.bullet => speedBullet,
    GameSpeed.blitz => speedBlitz,
    GameSpeed.rapid => speedRapid,
    GameSpeed.classical => speedClassical,
    GameSpeed.correspondence => speedCorrespondence,
    GameSpeed.unknown => speedOther,
  };

  /// Title of a puzzle set / filter.
  String filterTitle(PuzzleFilter f) {
    if (f.category != null) return category(f.category!);
    if (f.theme != null) return theme(f.theme!);
    if (f.phase != null) return phase(f.phase!);
    if (f.timeTrouble) return timeTroubleLabel;
    return allMistakes;
  }

  /// One sentence for a "thing to work on".
  String focus(FocusItem item) => switch (item.kind) {
    FocusKind.category => focusCategory(
      category(item.filter.category!),
      item.count,
    ),
    FocusKind.tactic => focusTactic(
      theme(item.filter.theme!),
      (item.rate ?? 0).round(),
    ),
    FocusKind.phase => focusPhase(
      phase(item.filter.phase!),
      (item.rate ?? 0).round(),
    ),
    FocusKind.timeTrouble => focusTimeTrouble(item.count),
  };

  /// Plain-words reasons why [move] was an error, most important first.
  /// [hungPiece] names the piece left en prise, when known.
  List<String> explain(MoveAnalysis move, {Role? hungPiece}) {
    final m = move.motifs;
    return [
      if (m.contains(Motif.walkedIntoMate)) explainWalkedIntoMate,
      if (m.contains(Motif.backRankMate)) explainBackRankMate,
      if (m.contains(Motif.missedMate)) explainMissedMate,
      if (m.contains(Motif.hungPiece))
        hungPiece == null
            ? explainHungPieceGeneric
            : explainHungPiece(piece(hungPiece).toLowerCase()),
      if (m.contains(Motif.badTrade)) explainBadTrade,
      if (m.contains(Motif.missedFork)) explainMissedFork,
      if (m.contains(Motif.missedPin)) explainMissedPin,
      if (m.contains(Motif.missedSkewer)) explainMissedSkewer,
      if (m.contains(Motif.missedDiscoveredAttack))
        explainMissedDiscoveredAttack,
      if (m.contains(Motif.timeTrouble)) explainTimeTrouble,
    ];
  }

  String botStyle(BotStyle s) => switch (s) {
    BotStyle.balanced => styleBalanced,
    BotStyle.aggressive => styleAggressive,
    BotStyle.defensive => styleDefensive,
    BotStyle.tricky => styleTricky,
    BotStyle.materialistic => styleMaterialistic,
  };

  String botBio(Bot b) => switch (b.id) {
    'pip' => botBioPip,
    'gremlina' => botBioGremlina,
    'bramble' => botBioBramble,
    'hex' => botBioHex,
    'grimsby' => botBioGrimsby,
    'vexa' => botBioVexa,
    'warlock' => botBioWarlock,
    _ => botBioMalakar,
  };

  String gameEnd(GameEnd e) => switch (e) {
    GameEnd.checkmate => endCheckmate,
    GameEnd.stalemate => endStalemate,
    GameEnd.insufficientMaterial => endInsufficient,
    GameEnd.threefoldRepetition => endThreefold,
    GameEnd.fiftyMoveRule => endFiftyMoves,
    GameEnd.resignation => endResignation,
  };
}
