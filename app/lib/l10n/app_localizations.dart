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
