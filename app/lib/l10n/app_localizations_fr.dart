// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'evilchess';

  @override
  String get navHome => 'Accueil';

  @override
  String get navAnalyze => 'Analyser';

  @override
  String get navPuzzles => 'Problèmes';

  @override
  String get navPlay => 'Jouer';

  @override
  String get navProfile => 'Profil';

  @override
  String get homeGreeting => 'Prêt à être diabolique ?';

  @override
  String get homeTagline =>
      'Analyses complètes, rapports et problèmes illimités. Gratuit. Pour toujours.';

  @override
  String get homeAnalyzeTitle => 'Analyser une partie';

  @override
  String get homeAnalyzeBody =>
      'Importez depuis Lichess ou Chess.com, ou collez un PGN.';

  @override
  String get homePuzzlesTitle => 'Résoudre des problèmes';

  @override
  String get homePuzzlesBody =>
      'Des problèmes illimités, y compris tirés de vos propres erreurs.';

  @override
  String get homePlayTitle => 'Jouer';

  @override
  String get homePlayBody =>
      'Des bots avec une vraie personnalité, ou des joueurs du monde entier.';

  @override
  String get comingSoonTitle => 'Bientôt disponible';

  @override
  String get comingSoonBody =>
      'Cette partie d\'evilchess est encore en construction.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get designSystemTitle => 'Système de design';

  @override
  String get licensesTitle => 'Licences open source';

  @override
  String get boardLabel => 'Échiquier';

  @override
  String get startPositionLabel => 'Position de départ';

  @override
  String get classBrilliant => 'Brillant';

  @override
  String get classGreat => 'Excellent coup';

  @override
  String get classBest => 'Meilleur';

  @override
  String get classExcellent => 'Très bon';

  @override
  String get classGood => 'Bon';

  @override
  String get classBook => 'Théorie';

  @override
  String get classInaccuracy => 'Imprécision';

  @override
  String get classMistake => 'Erreur';

  @override
  String get classMiss => 'Occasion manquée';

  @override
  String get classBlunder => 'Gaffe';

  @override
  String get buttonPrimary => 'C\'est parti';

  @override
  String get buttonSecondary => 'Plus tard';

  @override
  String get importGames => 'Importer des parties';

  @override
  String get importPasteTab => 'Coller un PGN';

  @override
  String get importPasteHint => 'Collez une ou plusieurs parties au format PGN';

  @override
  String get importFromFile => 'Ouvrir un fichier .pgn';

  @override
  String get importButton => 'Importer';

  @override
  String get importOnlineTab => 'Comptes en ligne';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get linkAndSync => 'Lier et importer';

  @override
  String get syncNow => 'Synchroniser';

  @override
  String get unlinkAccount => 'Délier';

  @override
  String lastSynced(String when) {
    return 'Dernière synchro $when';
  }

  @override
  String get neverSynced => 'Pas encore synchronisé';

  @override
  String importingCount(int count) {
    return 'Import… $count parties';
  }

  @override
  String get noGamesTitle => 'Aucune partie';

  @override
  String get noGamesBody =>
      'Importez vos parties depuis Lichess ou Chess.com, ou collez un PGN, et obtenez une analyse complète gratuite.';

  @override
  String importFailed(String message) {
    return 'Échec de l\'import : $message';
  }

  @override
  String get pgnNoGames => 'Aucune partie jouable trouvée dans ce PGN.';

  @override
  String get notAnalyzed => 'Non analysée';

  @override
  String get accuracyShort => 'Précision';

  @override
  String get deleteGame => 'Supprimer la partie';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get gameReviewTitle => 'Analyse de partie';

  @override
  String get gameNotFound => 'Cette partie n\'existe plus.';

  @override
  String get analyzingTitle => 'Analyse de votre partie…';

  @override
  String analyzingBody(int percent) {
    return 'Stockfish vérifie chaque coup sur votre appareil. $percent %';
  }

  @override
  String analysisFailed(String message) {
    return 'L\'analyse a échoué : $message';
  }

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get reanalyze => 'Réanalyser';

  @override
  String get flipBoard => 'Retourner l\'échiquier';

  @override
  String get firstMove => 'Premier coup';

  @override
  String get previousMove => 'Coup précédent';

  @override
  String get nextMove => 'Coup suivant';

  @override
  String get lastMove => 'Dernier coup';

  @override
  String get nextMistake => 'Erreur suivante';

  @override
  String get noMoreMistakes => 'Plus d\'erreurs après ce coup.';

  @override
  String moveIsClass(String move, String classification) {
    return '$move : $classification';
  }

  @override
  String bestWas(String move) {
    return 'Le meilleur coup était $move';
  }

  @override
  String get engineLine => 'Ligne du moteur';

  @override
  String get retryPosition => 'Rejouer cette position';

  @override
  String retryPrompt(String side) {
    return 'Trouvez un meilleur coup pour les $side';
  }

  @override
  String get retryCorrect => 'Bravo ! C\'est le meilleur coup.';

  @override
  String get retryGood => 'Pas mal — cela garde l\'avantage.';

  @override
  String get retryWrong => 'Pas tout à fait. Réessayez !';

  @override
  String get retryShowAnswer => 'Voir la solution';

  @override
  String get retryBack => 'Retour à l\'analyse';

  @override
  String get white => 'Blancs';

  @override
  String get black => 'Noirs';

  @override
  String get startOfGame => 'Début de la partie';

  @override
  String moveSemantics(
    int number,
    String side,
    String san,
    String classification,
  ) {
    return 'Coup $number $side : $san, $classification';
  }

  @override
  String evalBarLabel(String eval) {
    return 'Évaluation $eval';
  }

  @override
  String get evalGraphLabel =>
      'Graphique d\'évaluation. Touchez pour aller à un coup.';

  @override
  String get engineMissing =>
      'Aucun moteur d\'échecs disponible sur cet appareil.';

  @override
  String get openingLabel => 'Ouverture';

  @override
  String importResult(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added nouvelles parties importées',
      one: '1 nouvelle partie importée',
      zero: 'Aucune nouvelle partie',
    );
    return '$_temp0';
  }

  @override
  String analyzeAll(int count) {
    return 'Tout analyser ($count)';
  }

  @override
  String analyzingGames(int done, int total) {
    return 'Analyse de la partie $done sur $total…';
  }

  @override
  String get stop => 'Arrêter';

  @override
  String get iPlayedWhite => 'J\'avais les Blancs';

  @override
  String get iPlayedBlack => 'J\'avais les Noirs';

  @override
  String get myReport => 'Mon rapport';

  @override
  String get myReportBody =>
      'Vos forces, vos faiblesses et quoi travailler ensuite.';

  @override
  String get reportEmptyTitle => 'Pas encore de rapport';

  @override
  String get reportEmptyBody =>
      'Analysez quelques parties et indiquez à evilchess quel joueur vous êtes : liez votre compte Lichess ou Chess.com, ou choisissez votre couleur dans une partie.';

  @override
  String reportGamesWithoutSide(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count parties analysées n\'ont pas votre couleur définie et ne sont pas comptées.',
      one: '1 partie analysée n\'a pas votre couleur définie et n\'est pas comptée.',
    );
    return '$_temp0';
  }

  @override
  String gamesAnalyzedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties analysées',
      one: '1 partie analysée',
    );
    return '$_temp0';
  }

  @override
  String get averageAccuracy => 'Précision moyenne';

  @override
  String get accuracyOverTime => 'Précision au fil du temps';

  @override
  String get accuracyByPhase => 'Précision par phase';

  @override
  String get phaseOpening => 'Ouverture';

  @override
  String get phaseMiddlegame => 'Milieu de partie';

  @override
  String get phaseEndgame => 'Finale';

  @override
  String get whiteVsBlack => 'Blancs et Noirs';

  @override
  String get asWhite => 'Avec les Blancs';

  @override
  String get asBlack => 'Avec les Noirs';

  @override
  String scorePercent(int percent) {
    return 'Score $percent %';
  }

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '1 partie',
    );
    return '$_temp0';
  }

  @override
  String get byTimeControl => 'Par cadence';

  @override
  String get speedUltraBullet => 'UltraBullet';

  @override
  String get speedBullet => 'Bullet';

  @override
  String get speedBlitz => 'Blitz';

  @override
  String get speedRapid => 'Rapide';

  @override
  String get speedClassical => 'Classique';

  @override
  String get speedCorrespondence => 'Différé';

  @override
  String get speedOther => 'Autre';

  @override
  String get vulnerabilitiesTitle => 'D\'où viennent vos erreurs';

  @override
  String get catMate => 'Mats encaissés';

  @override
  String get catHungMaterial => 'Matériel en prise';

  @override
  String get catMissedTactic => 'Tactiques manquées';

  @override
  String get catOpening => 'Erreurs d\'ouverture';

  @override
  String get catEndgame => 'Technique de finale';

  @override
  String get catPositional => 'Fautes positionnelles';

  @override
  String mistakesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count erreurs',
      one: '1 erreur',
    );
    return '$_temp0';
  }

  @override
  String timeTroubleStat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de vos erreurs ont eu lieu en zeitnot.',
      one: '1 de vos erreurs a eu lieu en zeitnot.',
    );
    return '$_temp0';
  }

  @override
  String get tacticsTitle => 'Tactiques trouvées et manquées';

  @override
  String get themeFork => 'Fourchettes';

  @override
  String get themePin => 'Clouages';

  @override
  String get themeSkewer => 'Enfilades';

  @override
  String get themeDiscoveredAttack => 'Attaques à la découverte';

  @override
  String get themeMate => 'Mats';

  @override
  String get themeBackRankMate => 'Mats du couloir';

  @override
  String foundOfTotal(int found, int total) {
    return '$found sur $total trouvées';
  }

  @override
  String get errorsByPieceTitle => 'Erreurs par pièce';

  @override
  String get piecePawn => 'Pion';

  @override
  String get pieceKnight => 'Cavalier';

  @override
  String get pieceBishop => 'Fou';

  @override
  String get pieceRook => 'Tour';

  @override
  String get pieceQueen => 'Dame';

  @override
  String get pieceKing => 'Roi';

  @override
  String get openingsTitle => 'Vos ouvertures';

  @override
  String get focusTitle => '3 choses à travailler cette semaine';

  @override
  String focusCategory(String category, int count) {
    return '$category : $count sur la période';
  }

  @override
  String focusTactic(String theme, int percent) {
    return '$theme : vous n\'en trouvez que $percent %';
  }

  @override
  String focusPhase(String phase, int percent) {
    return '$phase : votre phase la plus faible ($percent % de précision)';
  }

  @override
  String focusTimeTrouble(int count) {
    return 'Zeitnot : $count erreurs avec peu de temps';
  }

  @override
  String get practice => 'S\'entraîner';

  @override
  String explainHungPiece(String piece) {
    return 'Ce coup laisse votre $piece en prise : il suffit de la capturer.';
  }

  @override
  String get explainHungPieceGeneric => 'Ce coup laisse une pièce en prise.';

  @override
  String get explainBadTrade => 'Cet échange perd du matériel.';

  @override
  String get explainMissedFork =>
      'Vous avez manqué une fourchette : un coup qui attaque deux cibles à la fois.';

  @override
  String get explainMissedPin =>
      'Vous avez manqué un clouage : une pièce qui ne peut pas bouger sans perdre plus gros.';

  @override
  String get explainMissedSkewer =>
      'Vous avez manqué une enfilade : attaquer la grosse pièce pour gagner celle derrière.';

  @override
  String get explainMissedDiscoveredAttack =>
      'Vous avez manqué une attaque à la découverte : déplacer une pièce ouvre la ligne d\'une autre.';

  @override
  String get explainMissedMate => 'Vous avez manqué un mat forcé.';

  @override
  String get explainWalkedIntoMate => 'Ce coup permet un mat forcé.';

  @override
  String get explainBackRankMate =>
      'Attention à la dernière rangée : le roi n\'a pas de case de fuite.';

  @override
  String get explainTimeTrouble => 'Vous manquiez de temps ici.';

  @override
  String get puzzlesFromMistakes => 'Mes erreurs';

  @override
  String get puzzlesFromMistakesBody =>
      'Des positions de vos propres parties où vous vous êtes trompé. Trouvez le meilleur coup.';

  @override
  String puzzleProgress(int solved, int total) {
    return '$solved sur $total résolus';
  }

  @override
  String get startPuzzles => 'Commencer';

  @override
  String get puzzlesEmptyTitle => 'Pas encore de problèmes';

  @override
  String get puzzlesEmptyBody =>
      'Analysez d\'abord quelques parties : chaque erreur devient un problème.';

  @override
  String puzzleFindBetter(String move, String side) {
    return 'Vous avez joué $move. Trouvez un meilleur coup pour les $side.';
  }

  @override
  String get puzzleSolved => 'Résolu !';

  @override
  String get puzzleNext => 'Problème suivant';

  @override
  String get puzzleOpenGame => 'Ouvrir la partie';

  @override
  String puzzleStreak(int count) {
    return 'Série : $count';
  }

  @override
  String get puzzleAllDone => 'C\'est tout pour le moment. Bravo !';

  @override
  String get puzzleThemesTitle => 'Travailler une faiblesse';

  @override
  String puzzleCounter(int index, int total) {
    return '$index / $total';
  }

  @override
  String get otherModesSoon =>
      'Les problèmes classés, le Puzzle Rush et le problème du jour arrivent avec les comptes.';

  @override
  String get allMistakes => 'Toutes mes erreurs';

  @override
  String get timeTroubleLabel => 'Zeitnot';
}
