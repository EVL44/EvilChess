import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Brand colours that Material's [ColorScheme] has no slot for.
@immutable
class EcPalette extends ThemeExtension<EcPalette> {
  const EcPalette({
    required this.brand,
    required this.hot,
    required this.zap,
    required this.sun,
    required this.surfaceAlt,
    required this.inkMuted,
    required this.boardLight,
    required this.boardDark,
  });

  final Color brand;
  final Color hot;
  final Color zap;
  final Color sun;
  final Color surfaceAlt;
  final Color inkMuted;
  final Color boardLight;
  final Color boardDark;

  static const light = EcPalette(
    brand: EcColors.purple,
    hot: EcColors.magenta,
    zap: EcColors.lime,
    sun: EcColors.sun,
    surfaceAlt: EcColors.lightSurfaceAlt,
    inkMuted: EcColors.lightInkMuted,
    boardLight: EcColors.boardLight,
    boardDark: EcColors.boardDark,
  );

  static const dark = EcPalette(
    brand: EcColors.purpleLight,
    hot: EcColors.magentaLight,
    zap: EcColors.limeLight,
    sun: EcColors.sunLight,
    surfaceAlt: EcColors.darkSurfaceAlt,
    inkMuted: EcColors.darkInkMuted,
    boardLight: EcColors.boardLight,
    boardDark: EcColors.boardDark,
  );

  @override
  EcPalette copyWith({
    Color? brand,
    Color? hot,
    Color? zap,
    Color? sun,
    Color? surfaceAlt,
    Color? inkMuted,
    Color? boardLight,
    Color? boardDark,
  }) => EcPalette(
    brand: brand ?? this.brand,
    hot: hot ?? this.hot,
    zap: zap ?? this.zap,
    sun: sun ?? this.sun,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    inkMuted: inkMuted ?? this.inkMuted,
    boardLight: boardLight ?? this.boardLight,
    boardDark: boardDark ?? this.boardDark,
  );

  @override
  EcPalette lerp(EcPalette? other, double t) {
    if (other == null) return this;
    return EcPalette(
      brand: Color.lerp(brand, other.brand, t)!,
      hot: Color.lerp(hot, other.hot, t)!,
      zap: Color.lerp(zap, other.zap, t)!,
      sun: Color.lerp(sun, other.sun, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      boardLight: Color.lerp(boardLight, other.boardLight, t)!,
      boardDark: Color.lerp(boardDark, other.boardDark, t)!,
    );
  }
}

extension EcThemeContext on BuildContext {
  EcPalette get palette => Theme.of(this).extension<EcPalette>()!;
}

/// Font families bundled in `assets/fonts` (both SIL OFL).
abstract final class EcFonts {
  static const latin = 'Nunito';
  static const arabic = 'Cairo';
}

abstract final class AppTheme {
  static ThemeData light({bool arabic = false}) => _build(
    brightness: Brightness.light,
    palette: EcPalette.light,
    background: EcColors.lightBackground,
    surface: EcColors.lightSurface,
    ink: EcColors.lightInk,
    arabic: arabic,
  );

  static ThemeData dark({bool arabic = false}) => _build(
    brightness: Brightness.dark,
    palette: EcPalette.dark,
    background: EcColors.darkBackground,
    surface: EcColors.darkSurface,
    ink: EcColors.darkInk,
    arabic: arabic,
  );

  static ThemeData _build({
    required Brightness brightness,
    required EcPalette palette,
    required Color background,
    required Color surface,
    required Color ink,
    required bool arabic,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: EcColors.purple,
          brightness: brightness,
        ).copyWith(
          primary: palette.brand,
          onPrimary: isDark ? EcColors.purpleDeep : Colors.white,
          secondary: palette.hot,
          onSecondary: Colors.white,
          tertiary: palette.zap,
          surface: surface,
          onSurface: ink,
          surfaceContainerHighest: palette.surfaceAlt,
        );

    final family = arabic ? EcFonts.arabic : EcFonts.latin;
    // The bundled fonts are variable fonts: map each weight onto the `wght` axis.
    final base = Typography.material2021(platform: TargetPlatform.android)
        .englishLike
        .merge(
          isDark ? Typography.whiteMountainView : Typography.blackMountainView,
        );
    final textTheme = _withVariableWeights(
      base,
      family,
    ).apply(bodyColor: ink, displayColor: ink);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(EcRadii.md),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: family,
      // Mixed-script text (e.g. an Arabic UI showing Latin player names) falls
      // back to the other bundled font.
      fontFamilyFallback: [arabic ? EcFonts.latin : EcFonts.arabic],
      textTheme: textTheme,
      extensions: [palette],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EcRadii.lg),
          side: BorderSide(color: palette.surfaceAlt, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(kMinTapTarget, kMinTapTarget),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(kMinTapTarget, kMinTapTarget),
          shape: buttonShape,
          side: BorderSide(color: palette.brand, width: 2),
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: palette.brand.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: palette.brand.withValues(alpha: 0.18),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(kMinTapTarget, kMinTapTarget),
          selectedBackgroundColor: palette.brand,
          selectedForegroundColor: scheme.onPrimary,
        ),
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
    );
  }

  static TextTheme _withVariableWeights(TextTheme t, String family) {
    final fallback = [family == EcFonts.latin ? EcFonts.arabic : EcFonts.latin];
    TextStyle? v(TextStyle? s, FontWeight w) => s?.copyWith(
      fontFamily: family,
      fontFamilyFallback: fallback,
      fontWeight: w,
      fontVariations: [FontVariation('wght', w.value.toDouble())],
    );
    return t.copyWith(
      displayLarge: v(t.displayLarge, FontWeight.w900),
      displayMedium: v(t.displayMedium, FontWeight.w900),
      displaySmall: v(t.displaySmall, FontWeight.w800),
      headlineLarge: v(t.headlineLarge, FontWeight.w800),
      headlineMedium: v(t.headlineMedium, FontWeight.w800),
      headlineSmall: v(t.headlineSmall, FontWeight.w800),
      titleLarge: v(t.titleLarge, FontWeight.w800),
      titleMedium: v(t.titleMedium, FontWeight.w700),
      titleSmall: v(t.titleSmall, FontWeight.w700),
      bodyLarge: v(t.bodyLarge, FontWeight.w500),
      bodyMedium: v(t.bodyMedium, FontWeight.w500),
      bodySmall: v(t.bodySmall, FontWeight.w500),
      labelLarge: v(t.labelLarge, FontWeight.w800),
      labelMedium: v(t.labelMedium, FontWeight.w700),
      labelSmall: v(t.labelSmall, FontWeight.w700),
    );
  }
}
