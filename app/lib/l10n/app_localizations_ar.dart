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
}
