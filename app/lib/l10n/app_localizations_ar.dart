// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'evilchess';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navAnalyze => 'تحليل';

  @override
  String get navPuzzles => 'ألغاز';

  @override
  String get navPlay => 'العب';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get homeGreeting => 'مستعد لتكون شريرًا؟';

  @override
  String get homeTagline =>
      'مراجعات كاملة للمباريات وتقارير وألغاز غير محدودة. مجانًا وللأبد.';

  @override
  String get homeAnalyzeTitle => 'راجع مباراة';

  @override
  String get homeAnalyzeBody => 'استورد من Lichess أو Chess.com، أو الصق PGN.';

  @override
  String get homePuzzlesTitle => 'حلّ الألغاز';

  @override
  String get homePuzzlesBody =>
      'ألغاز غير محدودة، بما فيها ألغاز مبنية على أخطائك.';

  @override
  String get homePlayTitle => 'العب';

  @override
  String get homePlayBody => 'روبوتات بشخصيات حقيقية، أو لاعبون من حول العالم.';

  @override
  String get comingSoonTitle => 'قريبًا';

  @override
  String get comingSoonBody => 'هذا الجزء من evilchess ما زال قيد الإنشاء.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get settingsAbout => 'حول';

  @override
  String get designSystemTitle => 'نظام التصميم';

  @override
  String get licensesTitle => 'تراخيص المصادر المفتوحة';

  @override
  String get boardLabel => 'رقعة الشطرنج';

  @override
  String get startPositionLabel => 'وضعية البداية';

  @override
  String get classBrilliant => 'رائعة';

  @override
  String get classGreat => 'عظيمة';

  @override
  String get classBest => 'الأفضل';

  @override
  String get classExcellent => 'ممتازة';

  @override
  String get classGood => 'جيدة';

  @override
  String get classBook => 'نظرية';

  @override
  String get classInaccuracy => 'عدم دقة';

  @override
  String get classMistake => 'خطأ';

  @override
  String get classMiss => 'فرصة ضائعة';

  @override
  String get classBlunder => 'خطأ فادح';

  @override
  String get buttonPrimary => 'هيا بنا';

  @override
  String get buttonSecondary => 'لاحقًا';

  @override
  String get importGames => 'استيراد مباريات';

  @override
  String get importPasteTab => 'لصق PGN';

  @override
  String get importPasteHint => 'الصق مباراة أو أكثر بصيغة PGN';

  @override
  String get importFromFile => 'فتح ملف ‎.pgn';

  @override
  String get importButton => 'استيراد';

  @override
  String get importOnlineTab => 'الحسابات على الإنترنت';

  @override
  String get usernameLabel => 'اسم المستخدم';

  @override
  String get linkAndSync => 'ربط واستيراد';

  @override
  String get syncNow => 'مزامنة';

  @override
  String get unlinkAccount => 'إلغاء الربط';

  @override
  String lastSynced(String when) {
    return 'آخر مزامنة $when';
  }

  @override
  String get neverSynced => 'لم تتم المزامنة بعد';

  @override
  String importingCount(int count) {
    return 'جارٍ الاستيراد… $count مباراة';
  }

  @override
  String get noGamesTitle => 'لا توجد مباريات بعد';

  @override
  String get noGamesBody =>
      'استورد مبارياتك من Lichess أو Chess.com أو الصق PGN واحصل على مراجعة كاملة مجانًا.';

  @override
  String importFailed(String message) {
    return 'فشل الاستيراد: $message';
  }

  @override
  String get pgnNoGames => 'لم يتم العثور على مباراة صالحة في ملف PGN هذا.';

  @override
  String get notAnalyzed => 'غير محلّلة';

  @override
  String get accuracyShort => 'الدقة';

  @override
  String get deleteGame => 'حذف المباراة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get gameReviewTitle => 'مراجعة المباراة';

  @override
  String get gameNotFound => 'هذه المباراة لم تعد موجودة.';

  @override
  String get analyzingTitle => 'جارٍ تحليل مباراتك…';

  @override
  String analyzingBody(int percent) {
    return 'يفحص Stockfish كل نقلة على جهازك. $percent٪';
  }

  @override
  String analysisFailed(String message) {
    return 'فشل التحليل: $message';
  }

  @override
  String get tryAgain => 'حاول مجددًا';

  @override
  String get reanalyze => 'إعادة التحليل';

  @override
  String get flipBoard => 'قلب الرقعة';

  @override
  String get firstMove => 'النقلة الأولى';

  @override
  String get previousMove => 'النقلة السابقة';

  @override
  String get nextMove => 'النقلة التالية';

  @override
  String get lastMove => 'النقلة الأخيرة';

  @override
  String get nextMistake => 'الخطأ التالي';

  @override
  String get noMoreMistakes => 'لا توجد أخطاء أخرى بعد هذه النقلة.';

  @override
  String moveIsClass(String move, String classification) {
    return '$move: $classification';
  }

  @override
  String bestWas(String move) {
    return 'الأفضل كان $move';
  }

  @override
  String get engineLine => 'خط المحرك';

  @override
  String get retryPosition => 'أعد المحاولة من هذه الوضعية';

  @override
  String retryPrompt(String side) {
    return 'ابحث عن نقلة أفضل لصالح $side';
  }

  @override
  String get retryCorrect => 'رائع! هذه أفضل نقلة.';

  @override
  String get retryGood => 'جيد — هذه النقلة تحافظ على الأفضلية.';

  @override
  String get retryWrong => 'ليس تمامًا. حاول مجددًا!';

  @override
  String get retryShowAnswer => 'أظهر الحل';

  @override
  String get retryBack => 'العودة إلى المراجعة';

  @override
  String get white => 'الأبيض';

  @override
  String get black => 'الأسود';

  @override
  String get startOfGame => 'بداية المباراة';

  @override
  String moveSemantics(
    int number,
    String side,
    String san,
    String classification,
  ) {
    return 'النقلة $number $side: $san، $classification';
  }

  @override
  String evalBarLabel(String eval) {
    return 'التقييم $eval';
  }

  @override
  String get evalGraphLabel => 'مخطط التقييم. انقر للانتقال إلى نقلة.';

  @override
  String get engineMissing => 'لا يوجد محرك شطرنج متاح على هذا الجهاز.';

  @override
  String get openingLabel => 'الافتتاح';

  @override
  String importResult(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'تم استيراد $added مباراة جديدة',
      many: 'تم استيراد $added مباراة جديدة',
      few: 'تم استيراد $added مباريات جديدة',
      two: 'تم استيراد مباراتين جديدتين',
      one: 'تم استيراد مباراة جديدة',
      zero: 'لا توجد مباريات جديدة',
    );
    return '$_temp0';
  }

  @override
  String analyzeAll(int count) {
    return 'تحليل الكل ($count)';
  }

  @override
  String analyzingGames(int done, int total) {
    return 'جارٍ تحليل المباراة $done من $total…';
  }

  @override
  String get stop => 'إيقاف';

  @override
  String get iPlayedWhite => 'لعبتُ بالأبيض';

  @override
  String get iPlayedBlack => 'لعبتُ بالأسود';

  @override
  String get myReport => 'تقريري';

  @override
  String get myReportBody => 'نقاط قوتك وضعفك وما عليك تدريبه لاحقًا.';

  @override
  String get reportEmptyTitle => 'لا يوجد تقرير بعد';

  @override
  String get reportEmptyBody =>
      'حلّل بعض مبارياتك وأخبر evilchess أيّ لاعب أنت: اربط حسابك على Lichess أو Chess.com، أو اختر لونك داخل المباراة.';

  @override
  String reportGamesWithoutSide(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مباراة محلّلة لم يُحدَّد لونك فيها ولا تُحتسب.',
      many: '$count مباراة محلّلة لم يُحدَّد لونك فيها ولا تُحتسب.',
      few: '$count مباريات محلّلة لم يُحدَّد لونك فيها ولا تُحتسب.',
      two: 'مباراتان محلّلتان لم يُحدَّد لونك فيهما ولا تُحتسبان.',
      one: 'مباراة محلّلة واحدة لم يُحدَّد لونك فيها ولا تُحتسب.',
    );
    return '$_temp0';
  }

  @override
  String gamesAnalyzedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مباراة محلّلة',
      many: '$count مباراة محلّلة',
      few: '$count مباريات محلّلة',
      two: 'مباراتان محلّلتان',
      one: 'مباراة محلّلة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get averageAccuracy => 'متوسط الدقة';

  @override
  String get accuracyOverTime => 'الدقة عبر الزمن';

  @override
  String get accuracyByPhase => 'الدقة حسب المرحلة';

  @override
  String get phaseOpening => 'الافتتاح';

  @override
  String get phaseMiddlegame => 'وسط المباراة';

  @override
  String get phaseEndgame => 'نهاية المباراة';

  @override
  String get whiteVsBlack => 'الأبيض والأسود';

  @override
  String get asWhite => 'بالأبيض';

  @override
  String get asBlack => 'بالأسود';

  @override
  String scorePercent(int percent) {
    return 'النتيجة $percent٪';
  }

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مباراة',
      many: '$count مباراة',
      few: '$count مباريات',
      two: 'مباراتان',
      one: 'مباراة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get byTimeControl => 'حسب التوقيت';

  @override
  String get speedUltraBullet => 'ألترا بوليت';

  @override
  String get speedBullet => 'بوليت';

  @override
  String get speedBlitz => 'بليتز';

  @override
  String get speedRapid => 'سريع';

  @override
  String get speedClassical => 'كلاسيكي';

  @override
  String get speedCorrespondence => 'يومي';

  @override
  String get speedOther => 'أخرى';

  @override
  String get vulnerabilitiesTitle => 'من أين تأتي أخطاؤك';

  @override
  String get catMate => 'الوقوع في كش مات';

  @override
  String get catHungMaterial => 'ترك القطع بلا حماية';

  @override
  String get catMissedTactic => 'تكتيكات ضائعة';

  @override
  String get catOpening => 'أخطاء الافتتاح';

  @override
  String get catEndgame => 'تقنية النهايات';

  @override
  String get catPositional => 'هفوات تموضعية';

  @override
  String mistakesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطأ',
      many: '$count خطأً',
      few: '$count أخطاء',
      two: 'خطآن',
      one: 'خطأ واحد',
    );
    return '$_temp0';
  }

  @override
  String timeTroubleStat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count من أخطائك وقعت تحت ضغط الوقت.',
      many: '$count من أخطائك وقعت تحت ضغط الوقت.',
      few: '$count من أخطائك وقعت تحت ضغط الوقت.',
      two: 'خطآن من أخطائك وقعا تحت ضغط الوقت.',
      one: 'خطأ واحد من أخطائك وقع تحت ضغط الوقت.',
    );
    return '$_temp0';
  }

  @override
  String get tacticsTitle => 'التكتيكات التي تجدها والتي تفوتك';

  @override
  String get themeFork => 'الشوكات';

  @override
  String get themePin => 'التسميرات';

  @override
  String get themeSkewer => 'الأسياخ';

  @override
  String get themeDiscoveredAttack => 'الهجمات المكشوفة';

  @override
  String get themeMate => 'كش مات';

  @override
  String get themeBackRankMate => 'مات الصف الأخير';

  @override
  String foundOfTotal(int found, int total) {
    return 'وُجد $found من $total';
  }

  @override
  String get errorsByPieceTitle => 'الأخطاء حسب القطعة';

  @override
  String get piecePawn => 'بيدق';

  @override
  String get pieceKnight => 'حصان';

  @override
  String get pieceBishop => 'فيل';

  @override
  String get pieceRook => 'رخ';

  @override
  String get pieceQueen => 'وزير';

  @override
  String get pieceKing => 'ملك';

  @override
  String get openingsTitle => 'افتتاحاتك';

  @override
  String get focusTitle => '3 أشياء تعمل عليها هذا الأسبوع';

  @override
  String focusCategory(String category, int count) {
    return '$category: $count في هذه الفترة';
  }

  @override
  String focusTactic(String theme, int percent) {
    return '$theme: تجد $percent٪ منها فقط';
  }

  @override
  String focusPhase(String phase, int percent) {
    return '$phase هي أضعف مراحلك (دقة $percent٪)';
  }

  @override
  String focusTimeTrouble(int count) {
    return 'ضغط الوقت: $count أخطاء والوقت قليل';
  }

  @override
  String get practice => 'تدرّب';

  @override
  String explainHungPiece(String piece) {
    return 'هذه النقلة تترك $piece بلا حماية ويمكن أخذه ببساطة.';
  }

  @override
  String get explainHungPieceGeneric => 'هذه النقلة تترك قطعة بلا حماية.';

  @override
  String get explainBadTrade => 'هذا التبادل يخسر مادة.';

  @override
  String get explainMissedFork => 'فاتتك شوكة: نقلة تهاجم هدفين في آن واحد.';

  @override
  String get explainMissedPin =>
      'فاتك تسمير: قطعة لا تستطيع التحرك دون خسارة ما هو أثمن.';

  @override
  String get explainMissedSkewer =>
      'فاتك سيخ: هاجم القطعة الكبيرة واربح التي خلفها.';

  @override
  String get explainMissedDiscoveredAttack =>
      'فاتك هجوم مكشوف: تحريك قطعة يفتح خط الهجوم لأخرى.';

  @override
  String get explainMissedMate => 'فاتك كش مات إجباري.';

  @override
  String get explainWalkedIntoMate => 'هذه النقلة تسمح بكش مات إجباري.';

  @override
  String get explainBackRankMate => 'انتبه للصف الأخير: الملك بلا مربع هروب.';

  @override
  String get explainTimeTrouble => 'كان وقتك قليلًا هنا.';

  @override
  String get puzzlesFromMistakes => 'من أخطائي';

  @override
  String get puzzlesFromMistakesBody =>
      'وضعيات من مبارياتك أخطأت فيها. ابحث عن النقلة الأفضل.';

  @override
  String puzzleProgress(int solved, int total) {
    return 'حُلّ $solved من $total';
  }

  @override
  String get startPuzzles => 'ابدأ';

  @override
  String get puzzlesEmptyTitle => 'لا توجد ألغاز بعد';

  @override
  String get puzzlesEmptyBody => 'حلّل بعض المباريات أولًا: كل خطأ يصبح لغزًا.';

  @override
  String puzzleFindBetter(String move, String side) {
    return 'لعبتَ $move. ابحث عن نقلة أفضل لصالح $side.';
  }

  @override
  String get puzzleSolved => 'تم الحل!';

  @override
  String get puzzleNext => 'اللغز التالي';

  @override
  String get puzzleOpenGame => 'افتح المباراة';

  @override
  String puzzleStreak(int count) {
    return 'السلسلة: $count';
  }

  @override
  String get puzzleAllDone => 'هذا كل شيء الآن. أحسنت!';

  @override
  String get puzzleThemesTitle => 'درّب نقطة ضعف';

  @override
  String puzzleCounter(int index, int total) {
    return '$index / $total';
  }

  @override
  String get otherModesSoon =>
      'الألغاز المصنّفة وPuzzle Rush واللغز اليومي ستأتي مع الحسابات.';

  @override
  String get allMistakes => 'كل أخطائي';

  @override
  String get timeTroubleLabel => 'ضغط الوقت';

  @override
  String get chooseOpponent => 'اختر خصمك';

  @override
  String get botsSubtitle =>
      'روبوتات بشخصيات مختلفة، من المبتدئ تمامًا إلى الذي لا يرحم.';

  @override
  String botRating(int rating) {
    return '~$rating';
  }

  @override
  String get botRatingNote => 'تصنيفات الروبوتات تقديرية.';

  @override
  String get styleBalanced => 'متوازن';

  @override
  String get styleAggressive => 'هجومي';

  @override
  String get styleDefensive => 'دفاعي';

  @override
  String get styleTricky => 'مخادع';

  @override
  String get styleMaterialistic => 'طمّاع';

  @override
  String get botBioPip => 'تعلّم للتو كيف يتحرك الحصان. يلتقط أي قطعة متروكة.';

  @override
  String get botBioGremlina => 'تعشق الكش، أيّ كش. تهاجم أولًا وتفكّر لاحقًا.';

  @override
  String get botBioBramble =>
      'يُبيّت مبكرًا ويختبئ خلف بيادقه وينتظر أن تتسرّع.';

  @override
  String get botBioHex =>
      'تنصب الفخاخ في كل مكان. فكّر مرتين قبل أن تأخذ ذلك البيدق.';

  @override
  String get botBioGrimsby =>
      'لاعب نادٍ من الطراز القديم: افتتاحات سليمة ونقلات متينة وقليل من الهدايا.';

  @override
  String get botBioVexa => 'حادّة وسريعة وجريئة. ستضحّي لتصل إلى ملكك.';

  @override
  String get botBioWarlock => 'يرى بعيدًا ولا يفرّط في شيء ويخنقك ببطء.';

  @override
  String get botBioMalakar =>
      'Stockfish بكامل قوته. لا يرمش أبدًا. حظًا موفقًا.';

  @override
  String get playAs => 'العب بـ';

  @override
  String get randomSide => 'عشوائي';

  @override
  String get allowTakebacks => 'السماح بالتراجع';

  @override
  String get playButton => 'العب';

  @override
  String botThinking(String name) {
    return '$name يفكّر…';
  }

  @override
  String get yourTurn => 'دورك';

  @override
  String get you => 'أنت';

  @override
  String get hint => 'تلميح';

  @override
  String get takeBack => 'تراجع';

  @override
  String get resign => 'استسلام';

  @override
  String get resignConfirm => 'هل تستسلم في هذه المباراة؟';

  @override
  String get youWon => 'لقد فزت!';

  @override
  String get youLost => 'لقد خسرت';

  @override
  String get gameDrawn => 'تعادل';

  @override
  String get endCheckmate => 'بكش مات';

  @override
  String get endStalemate => 'بالجمود';

  @override
  String get endInsufficient => 'مادة غير كافية';

  @override
  String get endThreefold => 'تكرار ثلاثي';

  @override
  String get endFiftyMoves => 'قاعدة الخمسين نقلة';

  @override
  String get endResignation => 'بالاستسلام';

  @override
  String get reviewGame => 'راجع المباراة';

  @override
  String get rematch => 'إعادة المباراة';

  @override
  String get newOpponent => 'خصم جديد';

  @override
  String botError(String message) {
    return 'تعذّر على الروبوت اللعب: $message';
  }
}
