import 'package:material_ui/material_ui.dart';

/// Raw design tokens. Widgets should read colours through [EcPalette]
/// (`context.palette`) so light/dark themes stay consistent; these constants
/// exist so the palette is defined in exactly one place.
abstract final class EcColors {
  // Brand — "evil" purple, hot magenta, lime and sun yellow.
  static const purple = Color(0xFF6D28D9);
  static const purpleLight = Color(0xFFA78BFA);
  static const purpleDeep = Color(0xFF4C1D95);
  static const magenta = Color(0xFFDB2777);
  static const magentaLight = Color(0xFFF472B6);
  static const lime = Color(0xFF65A30D);
  static const limeLight = Color(0xFFA3E635);
  static const sun = Color(0xFFF59E0B);
  static const sunLight = Color(0xFFFBBF24);

  // Neutrals
  static const lightBackground = Color(0xFFFBF7FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF1E9FF);
  static const lightInk = Color(0xFF1E1530);
  static const lightInkMuted = Color(0xFF5F5475);

  static const darkBackground = Color(0xFF15101F);
  static const darkSurface = Color(0xFF211934);
  static const darkSurfaceAlt = Color(0xFF2E2447);
  static const darkInk = Color(0xFFF5F0FF);
  static const darkInkMuted = Color(0xFFB8AED0);

  // Default board theme ("Grape").
  static const boardLight = Color(0xFFEFE3FF);
  static const boardDark = Color(0xFF8B6CC7);
}

abstract final class EcRadii {
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

abstract final class EcSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Minimum interactive size (Material and Apple both recommend >= 48/44).
const double kMinTapTarget = 48;

/// Layout breakpoint between phone (bottom bar) and wide (side rail) layouts.
const double kWideLayoutBreakpoint = 720;
