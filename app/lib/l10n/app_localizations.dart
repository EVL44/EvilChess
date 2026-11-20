import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'evilchess'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get navAnalyze;

  /// No description provided for @navPuzzles.
  ///
  /// In en, this message translates to:
  /// **'Puzzles'**
  String get navPuzzles;

  /// No description provided for @navPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get navPlay;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Ready to be evil?'**
  String get homeGreeting;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Full game reviews, reports and unlimited puzzles. Free. Forever.'**
  String get homeTagline;

  /// No description provided for @homeAnalyzeTitle.
  ///
  /// In en, this message translates to:
  /// **'Review a game'**
  String get homeAnalyzeTitle;

  /// No description provided for @homeAnalyzeBody.
  ///
  /// In en, this message translates to:
  /// **'Import from Lichess or Chess.com, or paste a PGN.'**
  String get homeAnalyzeBody;

  /// No description provided for @homePuzzlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Solve puzzles'**
  String get homePuzzlesTitle;

  /// No description provided for @homePuzzlesBody.
  ///
  /// In en, this message translates to:
  /// **'Unlimited puzzles, including ones built from your own mistakes.'**
  String get homePuzzlesBody;

  /// No description provided for @homePlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get homePlayTitle;

  /// No description provided for @homePlayBody.
  ///
  /// In en, this message translates to:
  /// **'Bots with real personalities, or players from around the world.'**
  String get homePlayBody;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This part of evilchess is still being built.'**
  String get comingSoonBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @designSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Design system'**
  String get designSystemTitle;

  /// No description provided for @licensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get licensesTitle;

  /// No description provided for @boardLabel.
  ///
  /// In en, this message translates to:
  /// **'Chessboard'**
  String get boardLabel;

  /// No description provided for @startPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting position'**
  String get startPositionLabel;

  /// No description provided for @classBrilliant.
  ///
  /// In en, this message translates to:
  /// **'Brilliant'**
  String get classBrilliant;

  /// No description provided for @classGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get classGreat;

  /// No description provided for @classBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get classBest;

  /// No description provided for @classExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get classExcellent;

  /// No description provided for @classGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get classGood;

  /// No description provided for @classBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get classBook;

  /// No description provided for @classInaccuracy.
  ///
  /// In en, this message translates to:
  /// **'Inaccuracy'**
  String get classInaccuracy;

  /// No description provided for @classMistake.
  ///
  /// In en, this message translates to:
  /// **'Mistake'**
  String get classMistake;

  /// No description provided for @classMiss.
  ///
  /// In en, this message translates to:
  /// **'Miss'**
  String get classMiss;

  /// No description provided for @classBlunder.
  ///
  /// In en, this message translates to:
  /// **'Blunder'**
  String get classBlunder;

  /// No description provided for @buttonPrimary.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get buttonPrimary;

  /// No description provided for @buttonSecondary.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get buttonSecondary;

  /// No description provided for @importGames.
  ///
  /// In en, this message translates to:
  /// **'Import games'**
  String get importGames;

  /// No description provided for @importPasteTab.
  ///
  /// In en, this message translates to:
  /// **'Paste PGN'**
  String get importPasteTab;

  /// No description provided for @importPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste one or more games in PGN format'**
  String get importPasteHint;

  /// No description provided for @importFromFile.
  ///
  /// In en, this message translates to:
  /// **'Open a .pgn file'**
  String get importFromFile;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @importOnlineTab.
  ///
  /// In en, this message translates to:
  /// **'Online accounts'**
  String get importOnlineTab;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @linkAndSync.
  ///
  /// In en, this message translates to:
  /// **'Link & import'**
  String get linkAndSync;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncNow;

  /// No description provided for @unlinkAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlinkAccount;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {when}'**
  String lastSynced(String when);

  /// No description provided for @neverSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get neverSynced;

  /// No description provided for @importingCount.
  ///
  /// In en, this message translates to:
  /// **'Importing… {count} games'**
  String importingCount(int count);

  /// No description provided for @noGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'No games yet'**
  String get noGamesTitle;

  /// No description provided for @noGamesBody.
  ///
  /// In en, this message translates to:
  /// **'Import your games from Lichess or Chess.com, or paste a PGN, and get a full free review.'**
  String get noGamesBody;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {message}'**
  String importFailed(String message);

  /// No description provided for @pgnNoGames.
  ///
  /// In en, this message translates to:
  /// **'No playable game found in this PGN.'**
  String get pgnNoGames;

  /// No description provided for @notAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Not analyzed'**
  String get notAnalyzed;

  /// No description provided for @accuracyShort.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracyShort;

  /// No description provided for @deleteGame.
  ///
  /// In en, this message translates to:
  /// **'Delete game'**
  String get deleteGame;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @gameReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Game review'**
  String get gameReviewTitle;

  /// No description provided for @gameNotFound.
  ///
  /// In en, this message translates to:
  /// **'This game no longer exists.'**
  String get gameNotFound;

  /// No description provided for @analyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your game…'**
  String get analyzingTitle;

  /// No description provided for @analyzingBody.
  ///
  /// In en, this message translates to:
  /// **'Stockfish is checking every move on your device. {percent}%'**
  String analyzingBody(int percent);

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed: {message}'**
  String analysisFailed(String message);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @reanalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze again'**
  String get reanalyze;

  /// No description provided for @flipBoard.
  ///
  /// In en, this message translates to:
  /// **'Flip board'**
  String get flipBoard;

  /// No description provided for @firstMove.
  ///
  /// In en, this message translates to:
  /// **'First move'**
  String get firstMove;

  /// No description provided for @previousMove.
  ///
  /// In en, this message translates to:
  /// **'Previous move'**
  String get previousMove;

  /// No description provided for @nextMove.
  ///
  /// In en, this message translates to:
  /// **'Next move'**
  String get nextMove;

  /// No description provided for @lastMove.
  ///
  /// In en, this message translates to:
  /// **'Last move'**
  String get lastMove;

  /// No description provided for @nextMistake.
  ///
  /// In en, this message translates to:
  /// **'Next mistake'**
  String get nextMistake;

  /// No description provided for @noMoreMistakes.
  ///
  /// In en, this message translates to:
  /// **'No more mistakes after this move.'**
  String get noMoreMistakes;

  /// No description provided for @moveIsClass.
  ///
  /// In en, this message translates to:
  /// **'{move} is {classification}'**
  String moveIsClass(String move, String classification);

  /// No description provided for @bestWas.
  ///
  /// In en, this message translates to:
  /// **'Best was {move}'**
  String bestWas(String move);

  /// No description provided for @engineLine.
  ///
  /// In en, this message translates to:
  /// **'Engine line'**
  String get engineLine;

  /// No description provided for @retryPosition.
  ///
  /// In en, this message translates to:
  /// **'Retry this position'**
  String get retryPosition;

  /// No description provided for @retryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Find a better move for {side}'**
  String retryPrompt(String side);

  /// No description provided for @retryCorrect.
  ///
  /// In en, this message translates to:
  /// **'Nice! That\'s the best move.'**
  String get retryCorrect;

  /// No description provided for @retryGood.
  ///
  /// In en, this message translates to:
  /// **'Good enough — that keeps the advantage.'**
  String get retryGood;

  /// No description provided for @retryWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Try again!'**
  String get retryWrong;

  /// No description provided for @retryShowAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get retryShowAnswer;

  /// No description provided for @retryBack.
  ///
  /// In en, this message translates to:
  /// **'Back to review'**
  String get retryBack;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @startOfGame.
  ///
  /// In en, this message translates to:
  /// **'Start of the game'**
  String get startOfGame;

  /// No description provided for @moveSemantics.
  ///
  /// In en, this message translates to:
  /// **'Move {number} {side}: {san}, {classification}'**
  String moveSemantics(
    int number,
    String side,
    String san,
    String classification,
  );

  /// No description provided for @evalBarLabel.
  ///
  /// In en, this message translates to:
  /// **'Evaluation {eval}'**
  String evalBarLabel(String eval);

  /// No description provided for @evalGraphLabel.
  ///
  /// In en, this message translates to:
  /// **'Evaluation graph. Tap to jump to a move.'**
  String get evalGraphLabel;

  /// No description provided for @engineMissing.
  ///
  /// In en, this message translates to:
  /// **'No chess engine available on this device.'**
  String get engineMissing;

  /// No description provided for @openingLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get openingLabel;

  /// No description provided for @importResult.
  ///
  /// In en, this message translates to:
  /// **'{added, plural, =0{No new games} =1{1 new game imported} other{{added} new games imported}}'**
  String importResult(int added);

  /// No description provided for @analyzeAll.
  ///
  /// In en, this message translates to:
  /// **'Analyze all ({count})'**
  String analyzeAll(int count);

  /// No description provided for @analyzingGames.
  ///
  /// In en, this message translates to:
  /// **'Analyzing game {done} of {total}…'**
  String analyzingGames(int done, int total);

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @iPlayedWhite.
  ///
  /// In en, this message translates to:
  /// **'I played White'**
  String get iPlayedWhite;

  /// No description provided for @iPlayedBlack.
  ///
  /// In en, this message translates to:
  /// **'I played Black'**
  String get iPlayedBlack;

  /// No description provided for @myReport.
  ///
  /// In en, this message translates to:
  /// **'My report'**
  String get myReport;

  /// No description provided for @myReportBody.
  ///
  /// In en, this message translates to:
  /// **'Your strengths, your weaknesses and what to train next.'**
  String get myReportBody;

  /// No description provided for @reportEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No report yet'**
  String get reportEmptyTitle;

  /// No description provided for @reportEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Analyze a few of your games and tell evilchess which player you are: link your Lichess or Chess.com account, or pick your colour inside a game.'**
  String get reportEmptyBody;

  /// No description provided for @reportGamesWithoutSide.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 analyzed game has no colour set for you and is not counted.} other{{count} analyzed games have no colour set for you and are not counted.}}'**
  String reportGamesWithoutSide(int count);

  /// No description provided for @gamesAnalyzedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 game analyzed} other{{count} games analyzed}}'**
  String gamesAnalyzedCount(int count);

  /// No description provided for @averageAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Average accuracy'**
  String get averageAccuracy;

  /// No description provided for @accuracyOverTime.
  ///
  /// In en, this message translates to:
  /// **'Accuracy over time'**
  String get accuracyOverTime;

  /// No description provided for @accuracyByPhase.
  ///
  /// In en, this message translates to:
  /// **'Accuracy by phase'**
  String get accuracyByPhase;

  /// No description provided for @phaseOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get phaseOpening;

  /// No description provided for @phaseMiddlegame.
  ///
  /// In en, this message translates to:
  /// **'Middlegame'**
  String get phaseMiddlegame;

  /// No description provided for @phaseEndgame.
  ///
  /// In en, this message translates to:
  /// **'Endgame'**
  String get phaseEndgame;

  /// No description provided for @whiteVsBlack.
  ///
  /// In en, this message translates to:
  /// **'White vs Black'**
  String get whiteVsBlack;

  /// No description provided for @asWhite.
  ///
  /// In en, this message translates to:
  /// **'As White'**
  String get asWhite;

  /// No description provided for @asBlack.
  ///
  /// In en, this message translates to:
  /// **'As Black'**
  String get asBlack;

  /// No description provided for @scorePercent.
  ///
  /// In en, this message translates to:
  /// **'Score {percent}%'**
  String scorePercent(int percent);

  /// No description provided for @gamesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 game} other{{count} games}}'**
  String gamesCount(int count);

  /// No description provided for @byTimeControl.
  ///
  /// In en, this message translates to:
  /// **'By time control'**
  String get byTimeControl;

  /// No description provided for @speedUltraBullet.
  ///
  /// In en, this message translates to:
  /// **'UltraBullet'**
  String get speedUltraBullet;

  /// No description provided for @speedBullet.
  ///
  /// In en, this message translates to:
  /// **'Bullet'**
  String get speedBullet;

  /// No description provided for @speedBlitz.
  ///
  /// In en, this message translates to:
  /// **'Blitz'**
  String get speedBlitz;

  /// No description provided for @speedRapid.
  ///
  /// In en, this message translates to:
  /// **'Rapid'**
  String get speedRapid;

  /// No description provided for @speedClassical.
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get speedClassical;

  /// No description provided for @speedCorrespondence.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get speedCorrespondence;

  /// No description provided for @speedOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get speedOther;

  /// No description provided for @vulnerabilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Where your mistakes come from'**
  String get vulnerabilitiesTitle;

  /// No description provided for @catMate.
  ///
  /// In en, this message translates to:
  /// **'Walking into mate'**
  String get catMate;

  /// No description provided for @catHungMaterial.
  ///
  /// In en, this message translates to:
  /// **'Hanging material'**
  String get catHungMaterial;

  /// No description provided for @catMissedTactic.
  ///
  /// In en, this message translates to:
  /// **'Missed tactics'**
  String get catMissedTactic;

  /// No description provided for @catOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening errors'**
  String get catOpening;

  /// No description provided for @catEndgame.
  ///
  /// In en, this message translates to:
  /// **'Endgame technique'**
  String get catEndgame;

  /// No description provided for @catPositional.
  ///
  /// In en, this message translates to:
  /// **'Positional slips'**
  String get catPositional;

  /// No description provided for @mistakesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mistake} other{{count} mistakes}}'**
  String mistakesCount(int count);

  /// No description provided for @timeTroubleStat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 of your mistakes happened in time trouble.} other{{count} of your mistakes happened in time trouble.}}'**
  String timeTroubleStat(int count);

  /// No description provided for @tacticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tactics you find and miss'**
  String get tacticsTitle;

  /// No description provided for @themeFork.
  ///
  /// In en, this message translates to:
  /// **'Forks'**
  String get themeFork;

  /// No description provided for @themePin.
  ///
  /// In en, this message translates to:
  /// **'Pins'**
  String get themePin;

  /// No description provided for @themeSkewer.
  ///
  /// In en, this message translates to:
  /// **'Skewers'**
  String get themeSkewer;

  /// No description provided for @themeDiscoveredAttack.
  ///
  /// In en, this message translates to:
  /// **'Discovered attacks'**
  String get themeDiscoveredAttack;

  /// No description provided for @themeMate.
  ///
  /// In en, this message translates to:
  /// **'Checkmates'**
  String get themeMate;

  /// No description provided for @themeBackRankMate.
  ///
  /// In en, this message translates to:
  /// **'Back-rank mates'**
  String get themeBackRankMate;

  /// No description provided for @foundOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{found} of {total} found'**
  String foundOfTotal(int found, int total);

  /// No description provided for @errorsByPieceTitle.
  ///
  /// In en, this message translates to:
  /// **'Mistakes by piece'**
  String get errorsByPieceTitle;

  /// No description provided for @piecePawn.
  ///
  /// In en, this message translates to:
  /// **'Pawn'**
  String get piecePawn;

  /// No description provided for @pieceKnight.
  ///
  /// In en, this message translates to:
  /// **'Knight'**
  String get pieceKnight;

  /// No description provided for @pieceBishop.
  ///
  /// In en, this message translates to:
  /// **'Bishop'**
  String get pieceBishop;

  /// No description provided for @pieceRook.
  ///
  /// In en, this message translates to:
  /// **'Rook'**
  String get pieceRook;

  /// No description provided for @pieceQueen.
  ///
  /// In en, this message translates to:
  /// **'Queen'**
  String get pieceQueen;

  /// No description provided for @pieceKing.
  ///
  /// In en, this message translates to:
  /// **'King'**
  String get pieceKing;

  /// No description provided for @openingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your openings'**
  String get openingsTitle;

  /// No description provided for @focusTitle.
  ///
  /// In en, this message translates to:
  /// **'3 things to work on this week'**
  String get focusTitle;

  /// No description provided for @focusCategory.
  ///
  /// In en, this message translates to:
  /// **'{category}: {count} this period'**
  String focusCategory(String category, int count);

  /// No description provided for @focusTactic.
  ///
  /// In en, this message translates to:
  /// **'{theme}: you find only {percent}% of them'**
  String focusTactic(String theme, int percent);

  /// No description provided for @focusPhase.
  ///
  /// In en, this message translates to:
  /// **'{phase} is your weakest phase ({percent}% accuracy)'**
  String focusPhase(String phase, int percent);

  /// No description provided for @focusTimeTrouble.
  ///
  /// In en, this message translates to:
  /// **'Time trouble: {count} mistakes on a low clock'**
  String focusTimeTrouble(int count);

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// No description provided for @explainHungPiece.
  ///
  /// In en, this message translates to:
  /// **'This leaves your {piece} hanging — it can simply be taken.'**
  String explainHungPiece(String piece);

  /// No description provided for @explainHungPieceGeneric.
  ///
  /// In en, this message translates to:
  /// **'This leaves a piece hanging — it can simply be taken.'**
  String get explainHungPieceGeneric;

  /// No description provided for @explainBadTrade.
  ///
  /// In en, this message translates to:
  /// **'This exchange loses material.'**
  String get explainBadTrade;

  /// No description provided for @explainMissedFork.
  ///
  /// In en, this message translates to:
  /// **'You missed a fork: one move attacking two things at once.'**
  String get explainMissedFork;

  /// No description provided for @explainMissedPin.
  ///
  /// In en, this message translates to:
  /// **'You missed a pin: a piece that could not move without losing something bigger.'**
  String get explainMissedPin;

  /// No description provided for @explainMissedSkewer.
  ///
  /// In en, this message translates to:
  /// **'You missed a skewer: attack the big piece and win the one behind it.'**
  String get explainMissedSkewer;

  /// No description provided for @explainMissedDiscoveredAttack.
  ///
  /// In en, this message translates to:
  /// **'You missed a discovered attack: moving one piece opens fire from another.'**
  String get explainMissedDiscoveredAttack;

  /// No description provided for @explainMissedMate.
  ///
  /// In en, this message translates to:
  /// **'You missed a forced checkmate.'**
  String get explainMissedMate;

  /// No description provided for @explainWalkedIntoMate.
  ///
  /// In en, this message translates to:
  /// **'This allows a forced checkmate.'**
  String get explainWalkedIntoMate;

  /// No description provided for @explainBackRankMate.
  ///
  /// In en, this message translates to:
  /// **'Watch the back rank: the king has no escape square.'**
  String get explainBackRankMate;

  /// No description provided for @explainTimeTrouble.
  ///
  /// In en, this message translates to:
  /// **'You were low on time here.'**
  String get explainTimeTrouble;

  /// No description provided for @puzzlesFromMistakes.
  ///
  /// In en, this message translates to:
  /// **'From my mistakes'**
  String get puzzlesFromMistakes;

  /// No description provided for @puzzlesFromMistakesBody.
  ///
  /// In en, this message translates to:
  /// **'Positions from your own games where you went wrong. Find the better move.'**
  String get puzzlesFromMistakesBody;

  /// No description provided for @puzzleProgress.
  ///
  /// In en, this message translates to:
  /// **'{solved} of {total} solved'**
  String puzzleProgress(int solved, int total);

  /// No description provided for @startPuzzles.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startPuzzles;

  /// No description provided for @puzzlesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No puzzles yet'**
  String get puzzlesEmptyTitle;

  /// No description provided for @puzzlesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Analyze some games first — every mistake becomes a puzzle.'**
  String get puzzlesEmptyBody;

  /// No description provided for @puzzleFindBetter.
  ///
  /// In en, this message translates to:
  /// **'You played {move}. Find a better move for {side}.'**
  String puzzleFindBetter(String move, String side);

  /// No description provided for @puzzleSolved.
  ///
  /// In en, this message translates to:
  /// **'Solved!'**
  String get puzzleSolved;

  /// No description provided for @puzzleNext.
  ///
  /// In en, this message translates to:
  /// **'Next puzzle'**
  String get puzzleNext;

  /// No description provided for @puzzleOpenGame.
  ///
  /// In en, this message translates to:
  /// **'Open the game'**
  String get puzzleOpenGame;

  /// No description provided for @puzzleStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak: {count}'**
  String puzzleStreak(int count);

  /// No description provided for @puzzleAllDone.
  ///
  /// In en, this message translates to:
  /// **'That\'s all of them for now. Nice work!'**
  String get puzzleAllDone;

  /// No description provided for @puzzleThemesTitle.
  ///
  /// In en, this message translates to:
  /// **'Train a weakness'**
  String get puzzleThemesTitle;

  /// No description provided for @puzzleCounter.
  ///
  /// In en, this message translates to:
  /// **'{index} / {total}'**
  String puzzleCounter(int index, int total);

  /// No description provided for @otherModesSoon.
  ///
  /// In en, this message translates to:
  /// **'Rated puzzles, Puzzle Rush and the daily puzzle arrive with accounts.'**
  String get otherModesSoon;

  /// No description provided for @allMistakes.
  ///
  /// In en, this message translates to:
  /// **'All my mistakes'**
  String get allMistakes;

  /// No description provided for @timeTroubleLabel.
  ///
  /// In en, this message translates to:
  /// **'Time trouble'**
  String get timeTroubleLabel;

  /// No description provided for @chooseOpponent.
  ///
  /// In en, this message translates to:
  /// **'Choose your opponent'**
  String get chooseOpponent;

  /// No description provided for @botsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bots with personalities, from total beginner to merciless.'**
  String get botsSubtitle;

  /// No description provided for @botRating.
  ///
  /// In en, this message translates to:
  /// **'~{rating}'**
  String botRating(int rating);

  /// No description provided for @botRatingNote.
  ///
  /// In en, this message translates to:
  /// **'Bot ratings are rough estimates.'**
  String get botRatingNote;

  /// No description provided for @styleBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get styleBalanced;

  /// No description provided for @styleAggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get styleAggressive;

  /// No description provided for @styleDefensive.
  ///
  /// In en, this message translates to:
  /// **'Defensive'**
  String get styleDefensive;

  /// No description provided for @styleTricky.
  ///
  /// In en, this message translates to:
  /// **'Tricky'**
  String get styleTricky;

  /// No description provided for @styleMaterialistic.
  ///
  /// In en, this message translates to:
  /// **'Greedy'**
  String get styleMaterialistic;

  /// No description provided for @botBioPip.
  ///
  /// In en, this message translates to:
  /// **'Just learned how the horsey moves. Grabs anything that isn\'t nailed down.'**
  String get botBioPip;

  /// No description provided for @botBioGremlina.
  ///
  /// In en, this message translates to:
  /// **'Loves a check, any check. Attacks first, thinks later.'**
  String get botBioGremlina;

  /// No description provided for @botBioBramble.
  ///
  /// In en, this message translates to:
  /// **'Castles early, hides behind his pawns and waits for you to overreach.'**
  String get botBioBramble;

  /// No description provided for @botBioHex.
  ///
  /// In en, this message translates to:
  /// **'Sets little traps everywhere. Look twice before you take that pawn.'**
  String get botBioHex;

  /// No description provided for @botBioGrimsby.
  ///
  /// In en, this message translates to:
  /// **'A club player of the old school: sound openings, solid moves, few gifts.'**
  String get botBioGrimsby;

  /// No description provided for @botBioVexa.
  ///
  /// In en, this message translates to:
  /// **'Sharp, fast and fearless. She will sacrifice to get at your king.'**
  String get botBioVexa;

  /// No description provided for @botBioWarlock.
  ///
  /// In en, this message translates to:
  /// **'Sees deep, gives nothing away and squeezes you slowly.'**
  String get botBioWarlock;

  /// No description provided for @botBioMalakar.
  ///
  /// In en, this message translates to:
  /// **'Full-strength Stockfish. It does not blink. Good luck.'**
  String get botBioMalakar;

  /// No description provided for @playAs.
  ///
  /// In en, this message translates to:
  /// **'Play as'**
  String get playAs;

  /// No description provided for @randomSide.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get randomSide;

  /// No description provided for @allowTakebacks.
  ///
  /// In en, this message translates to:
  /// **'Allow takebacks'**
  String get allowTakebacks;

  /// No description provided for @playButton.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playButton;

  /// No description provided for @botThinking.
  ///
  /// In en, this message translates to:
  /// **'{name} is thinking…'**
  String botThinking(String name);

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your move'**
  String get yourTurn;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @takeBack.
  ///
  /// In en, this message translates to:
  /// **'Take back'**
  String get takeBack;

  /// No description provided for @resign.
  ///
  /// In en, this message translates to:
  /// **'Resign'**
  String get resign;

  /// No description provided for @resignConfirm.
  ///
  /// In en, this message translates to:
  /// **'Resign this game?'**
  String get resignConfirm;

  /// No description provided for @youWon.
  ///
  /// In en, this message translates to:
  /// **'You won!'**
  String get youWon;

  /// No description provided for @youLost.
  ///
  /// In en, this message translates to:
  /// **'You lost'**
  String get youLost;

  /// No description provided for @gameDrawn.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get gameDrawn;

  /// No description provided for @endCheckmate.
  ///
  /// In en, this message translates to:
  /// **'by checkmate'**
  String get endCheckmate;

  /// No description provided for @endStalemate.
  ///
  /// In en, this message translates to:
  /// **'by stalemate'**
  String get endStalemate;

  /// No description provided for @endInsufficient.
  ///
  /// In en, this message translates to:
  /// **'insufficient material'**
  String get endInsufficient;

  /// No description provided for @endThreefold.
  ///
  /// In en, this message translates to:
  /// **'threefold repetition'**
  String get endThreefold;

  /// No description provided for @endFiftyMoves.
  ///
  /// In en, this message translates to:
  /// **'fifty-move rule'**
  String get endFiftyMoves;

  /// No description provided for @endResignation.
  ///
  /// In en, this message translates to:
  /// **'by resignation'**
  String get endResignation;

  /// No description provided for @reviewGame.
  ///
  /// In en, this message translates to:
  /// **'Review game'**
  String get reviewGame;

  /// No description provided for @rematch.
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get rematch;

  /// No description provided for @newOpponent.
  ///
  /// In en, this message translates to:
  /// **'New opponent'**
  String get newOpponent;

  /// No description provided for @botError.
  ///
  /// In en, this message translates to:
  /// **'The bot could not move: {message}'**
  String botError(String message);

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync your games, reports and puzzle rating across devices.'**
  String get signInSubtitle;

  /// No description provided for @guestNote.
  ///
  /// In en, this message translates to:
  /// **'You\'re playing as a guest. Everything stays on this device until you sign in.'**
  String get guestNote;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHint;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name (optional)'**
  String get displayNameLabel;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountButton;

  /// No description provided for @switchToRegister.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get switchToRegister;

  /// No description provided for @switchToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToSignIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @socialSoon.
  ///
  /// In en, this message translates to:
  /// **'Google and Apple sign-in will be switched on once the app is registered with them.'**
  String get socialSoon;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @puzzleRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Puzzle rating'**
  String get puzzleRatingLabel;

  /// No description provided for @puzzlesPlayedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rated puzzle} other{{count} rated puzzles}}'**
  String puzzlesPlayedCount(int count);

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncTitle;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @syncDone.
  ///
  /// In en, this message translates to:
  /// **'Synced: {sent} sent, {received} received'**
  String syncDone(int sent, int received);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {message}'**
  String syncFailed(String message);

  /// No description provided for @serverOffline.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Your data is safe on this device.'**
  String get serverOffline;

  /// No description provided for @errEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get errEmailTaken;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errInvalidCredentials;

  /// No description provided for @errRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Wait a minute and try again.'**
  String get errRateLimited;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {message}'**
  String errGeneric(String message);

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Change name'**
  String get editName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @importingOnServer.
  ///
  /// In en, this message translates to:
  /// **'Importing on the server… {count} games so far'**
  String importingOnServer(int count);

  /// No description provided for @dailyPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Daily puzzle'**
  String get dailyPuzzle;

  /// No description provided for @dailyPuzzleBody.
  ///
  /// In en, this message translates to:
  /// **'The same puzzle for everyone, every day.'**
  String get dailyPuzzleBody;

  /// No description provided for @ratedPuzzles.
  ///
  /// In en, this message translates to:
  /// **'Rated puzzles'**
  String get ratedPuzzles;

  /// No description provided for @ratedPuzzlesBody.
  ///
  /// In en, this message translates to:
  /// **'Millions of puzzles from the Lichess database, matched to your rating.'**
  String get ratedPuzzlesBody;

  /// No description provided for @signInForRated.
  ///
  /// In en, this message translates to:
  /// **'Sign in to play rated puzzles and keep a puzzle rating.'**
  String get signInForRated;

  /// No description provided for @puzzleRush.
  ///
  /// In en, this message translates to:
  /// **'Puzzle Rush'**
  String get puzzleRush;

  /// No description provided for @puzzleRushBody.
  ///
  /// In en, this message translates to:
  /// **'Solve as many as you can. Three mistakes and you are out.'**
  String get puzzleRushBody;

  /// No description provided for @rush3min.
  ///
  /// In en, this message translates to:
  /// **'3 min'**
  String get rush3min;

  /// No description provided for @rush5min.
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get rush5min;

  /// No description provided for @rushSurvival.
  ///
  /// In en, this message translates to:
  /// **'Survival'**
  String get rushSurvival;

  /// No description provided for @rushScore.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String rushScore(int score);

  /// No description provided for @rushBest.
  ///
  /// In en, this message translates to:
  /// **'Best {best}'**
  String rushBest(int best);

  /// No description provided for @rushNewBest.
  ///
  /// In en, this message translates to:
  /// **'New best!'**
  String get rushNewBest;

  /// No description provided for @rushTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get rushTimeUp;

  /// No description provided for @rushStruckOut.
  ///
  /// In en, this message translates to:
  /// **'Three strikes!'**
  String get rushStruckOut;

  /// No description provided for @rushPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get rushPlayAgain;

  /// No description provided for @findBestMove.
  ///
  /// In en, this message translates to:
  /// **'Find the best move for {side}'**
  String findBestMove(String side);

  /// No description provided for @puzzleCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get puzzleCorrect;

  /// No description provided for @ratingChange.
  ///
  /// In en, this message translates to:
  /// **'Rating {rating} ({delta})'**
  String ratingChange(int rating, String delta);

  /// No description provided for @puzzleNotRated.
  ///
  /// In en, this message translates to:
  /// **'Already played: not rated again.'**
  String get puzzleNotRated;

  /// No description provided for @offlinePack.
  ///
  /// In en, this message translates to:
  /// **'Offline pack'**
  String get offlinePack;

  /// No description provided for @offlinePackBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No puzzles saved yet. Download some to play Puzzle Rush without internet.} =1{1 puzzle saved on this device.} other{{count} puzzles saved on this device.}}'**
  String offlinePackBody(int count);

  /// No description provided for @downloadPack.
  ///
  /// In en, this message translates to:
  /// **'Download 100 puzzles'**
  String get downloadPack;

  /// No description provided for @playingOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline: playing puzzles saved on this device.'**
  String get playingOffline;

  /// No description provided for @puzzlesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load puzzles from the server.'**
  String get puzzlesUnavailable;

  /// No description provided for @nextPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Next puzzle'**
  String get nextPuzzle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
