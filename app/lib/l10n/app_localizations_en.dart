// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'evilchess';

  @override
  String get navHome => 'Home';

  @override
  String get navAnalyze => 'Analyze';

  @override
  String get navPuzzles => 'Puzzles';

  @override
  String get navPlay => 'Play';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreeting => 'Ready to be evil?';

  @override
  String get homeTagline =>
      'Full game reviews, reports and unlimited puzzles. Free. Forever.';

  @override
  String get homeAnalyzeTitle => 'Review a game';

  @override
  String get homeAnalyzeBody =>
      'Import from Lichess or Chess.com, or paste a PGN.';

  @override
  String get homePuzzlesTitle => 'Solve puzzles';

  @override
  String get homePuzzlesBody =>
      'Unlimited puzzles, including ones built from your own mistakes.';

  @override
  String get homePlayTitle => 'Play';

  @override
  String get homePlayBody =>
      'Bots with real personalities, or players from around the world.';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody => 'This part of evilchess is still being built.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get settingsAbout => 'About';

  @override
  String get designSystemTitle => 'Design system';

  @override
  String get licensesTitle => 'Open-source licences';

  @override
  String get boardLabel => 'Chessboard';

  @override
  String get startPositionLabel => 'Starting position';

  @override
  String get classBrilliant => 'Brilliant';

  @override
  String get classGreat => 'Great';

  @override
  String get classBest => 'Best';

  @override
  String get classExcellent => 'Excellent';

  @override
  String get classGood => 'Good';

  @override
  String get classBook => 'Book';

  @override
  String get classInaccuracy => 'Inaccuracy';

  @override
  String get classMistake => 'Mistake';

  @override
  String get classMiss => 'Miss';

  @override
  String get classBlunder => 'Blunder';

  @override
  String get buttonPrimary => 'Let\'s go';

  @override
  String get buttonSecondary => 'Maybe later';

  @override
  String get importGames => 'Import games';

  @override
  String get importPasteTab => 'Paste PGN';

  @override
  String get importPasteHint => 'Paste one or more games in PGN format';

  @override
  String get importFromFile => 'Open a .pgn file';

  @override
  String get importButton => 'Import';

  @override
  String get importOnlineTab => 'Online accounts';

  @override
  String get usernameLabel => 'Username';

  @override
  String get linkAndSync => 'Link & import';

  @override
  String get syncNow => 'Sync';

  @override
  String get unlinkAccount => 'Unlink';

  @override
  String lastSynced(String when) {
    return 'Last synced $when';
  }

  @override
  String get neverSynced => 'Not synced yet';

  @override
  String importingCount(int count) {
    return 'Importing… $count games';
  }

  @override
  String get noGamesTitle => 'No games yet';

  @override
  String get noGamesBody =>
      'Import your games from Lichess or Chess.com, or paste a PGN, and get a full free review.';

  @override
  String importFailed(String message) {
    return 'Import failed: $message';
  }

  @override
  String get pgnNoGames => 'No playable game found in this PGN.';

  @override
  String get notAnalyzed => 'Not analyzed';

  @override
  String get accuracyShort => 'Accuracy';

  @override
  String get deleteGame => 'Delete game';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get gameReviewTitle => 'Game review';

  @override
  String get gameNotFound => 'This game no longer exists.';

  @override
  String get analyzingTitle => 'Analyzing your game…';

  @override
  String analyzingBody(int percent) {
    return 'Stockfish is checking every move on your device. $percent%';
  }

  @override
  String analysisFailed(String message) {
    return 'Analysis failed: $message';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get reanalyze => 'Analyze again';

  @override
  String get flipBoard => 'Flip board';

  @override
  String get firstMove => 'First move';

  @override
  String get previousMove => 'Previous move';

  @override
  String get nextMove => 'Next move';

  @override
  String get lastMove => 'Last move';

  @override
  String get nextMistake => 'Next mistake';

  @override
  String get noMoreMistakes => 'No more mistakes after this move.';

  @override
  String moveIsClass(String move, String classification) {
    return '$move is $classification';
  }

  @override
  String bestWas(String move) {
    return 'Best was $move';
  }

  @override
  String get engineLine => 'Engine line';

  @override
  String get retryPosition => 'Retry this position';

  @override
  String retryPrompt(String side) {
    return 'Find a better move for $side';
  }

  @override
  String get retryCorrect => 'Nice! That\'s the best move.';

  @override
  String get retryGood => 'Good enough — that keeps the advantage.';

  @override
  String get retryWrong => 'Not quite. Try again!';

  @override
  String get retryShowAnswer => 'Show answer';

  @override
  String get retryBack => 'Back to review';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get startOfGame => 'Start of the game';

  @override
  String moveSemantics(
    int number,
    String side,
    String san,
    String classification,
  ) {
    return 'Move $number $side: $san, $classification';
  }

  @override
  String evalBarLabel(String eval) {
    return 'Evaluation $eval';
  }

  @override
  String get evalGraphLabel => 'Evaluation graph. Tap to jump to a move.';

  @override
  String get engineMissing => 'No chess engine available on this device.';

  @override
  String get openingLabel => 'Opening';

  @override
  String importResult(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added new games imported',
      one: '1 new game imported',
      zero: 'No new games',
    );
    return '$_temp0';
  }

  @override
  String analyzeAll(int count) {
    return 'Analyze all ($count)';
  }

  @override
  String analyzingGames(int done, int total) {
    return 'Analyzing game $done of $total…';
  }

  @override
  String get stop => 'Stop';

  @override
  String get iPlayedWhite => 'I played White';

  @override
  String get iPlayedBlack => 'I played Black';

  @override
  String get myReport => 'My report';

  @override
  String get myReportBody =>
      'Your strengths, your weaknesses and what to train next.';

  @override
  String get reportEmptyTitle => 'No report yet';

  @override
  String get reportEmptyBody =>
      'Analyze a few of your games and tell evilchess which player you are: link your Lichess or Chess.com account, or pick your colour inside a game.';

  @override
  String reportGamesWithoutSide(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count analyzed games have no colour set for you and are not counted.',
      one: '1 analyzed game has no colour set for you and is not counted.',
    );
    return '$_temp0';
  }

  @override
  String gamesAnalyzedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games analyzed',
      one: '1 game analyzed',
    );
    return '$_temp0';
  }

  @override
  String get averageAccuracy => 'Average accuracy';

  @override
  String get accuracyOverTime => 'Accuracy over time';

  @override
  String get accuracyByPhase => 'Accuracy by phase';

  @override
  String get phaseOpening => 'Opening';

  @override
  String get phaseMiddlegame => 'Middlegame';

  @override
  String get phaseEndgame => 'Endgame';

  @override
  String get whiteVsBlack => 'White vs Black';

  @override
  String get asWhite => 'As White';

  @override
  String get asBlack => 'As Black';

  @override
  String scorePercent(int percent) {
    return 'Score $percent%';
  }

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
    );
    return '$_temp0';
  }

  @override
  String get byTimeControl => 'By time control';

  @override
  String get speedUltraBullet => 'UltraBullet';

  @override
  String get speedBullet => 'Bullet';

  @override
  String get speedBlitz => 'Blitz';

  @override
  String get speedRapid => 'Rapid';

  @override
  String get speedClassical => 'Classical';

  @override
  String get speedCorrespondence => 'Daily';

  @override
  String get speedOther => 'Other';

  @override
  String get vulnerabilitiesTitle => 'Where your mistakes come from';

  @override
  String get catMate => 'Walking into mate';

  @override
  String get catHungMaterial => 'Hanging material';

  @override
  String get catMissedTactic => 'Missed tactics';

  @override
  String get catOpening => 'Opening errors';

  @override
  String get catEndgame => 'Endgame technique';

  @override
  String get catPositional => 'Positional slips';

  @override
  String mistakesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mistakes',
      one: '1 mistake',
    );
    return '$_temp0';
  }

  @override
  String timeTroubleStat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of your mistakes happened in time trouble.',
      one: '1 of your mistakes happened in time trouble.',
    );
    return '$_temp0';
  }

  @override
  String get tacticsTitle => 'Tactics you find and miss';

  @override
  String get themeFork => 'Forks';

  @override
  String get themePin => 'Pins';

  @override
  String get themeSkewer => 'Skewers';

  @override
  String get themeDiscoveredAttack => 'Discovered attacks';

  @override
  String get themeMate => 'Checkmates';

  @override
  String get themeBackRankMate => 'Back-rank mates';

  @override
  String foundOfTotal(int found, int total) {
    return '$found of $total found';
  }

  @override
  String get errorsByPieceTitle => 'Mistakes by piece';

  @override
  String get piecePawn => 'Pawn';

  @override
  String get pieceKnight => 'Knight';

  @override
  String get pieceBishop => 'Bishop';

  @override
  String get pieceRook => 'Rook';

  @override
  String get pieceQueen => 'Queen';

  @override
  String get pieceKing => 'King';

  @override
  String get openingsTitle => 'Your openings';

  @override
  String get focusTitle => '3 things to work on this week';

  @override
  String focusCategory(String category, int count) {
    return '$category: $count this period';
  }

  @override
  String focusTactic(String theme, int percent) {
    return '$theme: you find only $percent% of them';
  }

  @override
  String focusPhase(String phase, int percent) {
    return '$phase is your weakest phase ($percent% accuracy)';
  }

  @override
  String focusTimeTrouble(int count) {
    return 'Time trouble: $count mistakes on a low clock';
  }

  @override
  String get practice => 'Practice';

  @override
  String explainHungPiece(String piece) {
    return 'This leaves your $piece hanging — it can simply be taken.';
  }

  @override
  String get explainHungPieceGeneric =>
      'This leaves a piece hanging — it can simply be taken.';

  @override
  String get explainBadTrade => 'This exchange loses material.';

  @override
  String get explainMissedFork =>
      'You missed a fork: one move attacking two things at once.';

  @override
  String get explainMissedPin =>
      'You missed a pin: a piece that could not move without losing something bigger.';

  @override
  String get explainMissedSkewer =>
      'You missed a skewer: attack the big piece and win the one behind it.';

  @override
  String get explainMissedDiscoveredAttack =>
      'You missed a discovered attack: moving one piece opens fire from another.';

  @override
  String get explainMissedMate => 'You missed a forced checkmate.';

  @override
  String get explainWalkedIntoMate => 'This allows a forced checkmate.';

  @override
  String get explainBackRankMate =>
      'Watch the back rank: the king has no escape square.';

  @override
  String get explainTimeTrouble => 'You were low on time here.';

  @override
  String get puzzlesFromMistakes => 'From my mistakes';

  @override
  String get puzzlesFromMistakesBody =>
      'Positions from your own games where you went wrong. Find the better move.';

  @override
  String puzzleProgress(int solved, int total) {
    return '$solved of $total solved';
  }

  @override
  String get startPuzzles => 'Start';

  @override
  String get puzzlesEmptyTitle => 'No puzzles yet';

  @override
  String get puzzlesEmptyBody =>
      'Analyze some games first — every mistake becomes a puzzle.';

  @override
  String puzzleFindBetter(String move, String side) {
    return 'You played $move. Find a better move for $side.';
  }

  @override
  String get puzzleSolved => 'Solved!';

  @override
  String get puzzleNext => 'Next puzzle';

  @override
  String get puzzleOpenGame => 'Open the game';

  @override
  String puzzleStreak(int count) {
    return 'Streak: $count';
  }

  @override
  String get puzzleAllDone => 'That\'s all of them for now. Nice work!';

  @override
  String get puzzleThemesTitle => 'Train a weakness';

  @override
  String puzzleCounter(int index, int total) {
    return '$index / $total';
  }

  @override
  String get otherModesSoon =>
      'Rated puzzles, Puzzle Rush and the daily puzzle arrive with accounts.';

  @override
  String get allMistakes => 'All my mistakes';

  @override
  String get timeTroubleLabel => 'Time trouble';

  @override
  String get chooseOpponent => 'Choose your opponent';

  @override
  String get botsSubtitle =>
      'Bots with personalities, from total beginner to merciless.';

  @override
  String botRating(int rating) {
    return '~$rating';
  }

  @override
  String get botRatingNote => 'Bot ratings are rough estimates.';

  @override
  String get styleBalanced => 'Balanced';

  @override
  String get styleAggressive => 'Aggressive';

  @override
  String get styleDefensive => 'Defensive';

  @override
  String get styleTricky => 'Tricky';

  @override
  String get styleMaterialistic => 'Greedy';

  @override
  String get botBioPip =>
      'Just learned how the horsey moves. Grabs anything that isn\'t nailed down.';

  @override
  String get botBioGremlina =>
      'Loves a check, any check. Attacks first, thinks later.';

  @override
  String get botBioBramble =>
      'Castles early, hides behind his pawns and waits for you to overreach.';

  @override
  String get botBioHex =>
      'Sets little traps everywhere. Look twice before you take that pawn.';

  @override
  String get botBioGrimsby =>
      'A club player of the old school: sound openings, solid moves, few gifts.';

  @override
  String get botBioVexa =>
      'Sharp, fast and fearless. She will sacrifice to get at your king.';

  @override
  String get botBioWarlock =>
      'Sees deep, gives nothing away and squeezes you slowly.';

  @override
  String get botBioMalakar =>
      'Full-strength Stockfish. It does not blink. Good luck.';

  @override
  String get playAs => 'Play as';

  @override
  String get randomSide => 'Random';

  @override
  String get allowTakebacks => 'Allow takebacks';

  @override
  String get playButton => 'Play';

  @override
  String botThinking(String name) {
    return '$name is thinking…';
  }

  @override
  String get yourTurn => 'Your move';

  @override
  String get you => 'You';

  @override
  String get hint => 'Hint';

  @override
  String get takeBack => 'Take back';

  @override
  String get resign => 'Resign';

  @override
  String get resignConfirm => 'Resign this game?';

  @override
  String get youWon => 'You won!';

  @override
  String get youLost => 'You lost';

  @override
  String get gameDrawn => 'Draw';

  @override
  String get endCheckmate => 'by checkmate';

  @override
  String get endStalemate => 'by stalemate';

  @override
  String get endInsufficient => 'insufficient material';

  @override
  String get endThreefold => 'threefold repetition';

  @override
  String get endFiftyMoves => 'fifty-move rule';

  @override
  String get endResignation => 'by resignation';

  @override
  String get reviewGame => 'Review game';

  @override
  String get rematch => 'Rematch';

  @override
  String get newOpponent => 'New opponent';

  @override
  String botError(String message) {
    return 'The bot could not move: $message';
  }
}
