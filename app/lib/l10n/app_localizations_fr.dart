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
}
