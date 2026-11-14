import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// The ten move classes shown in game review.
///
/// Every class has its own colour **and** its own glyph so the meaning never
/// depends on colour alone (colour-blind safe). The order is best → worst.
enum MoveClass {
  brilliant,
  great,
  best,
  excellent,
  good,
  book,
  inaccuracy,
  mistake,
  miss,
  blunder;

  /// Badge colour. Chosen to stay distinguishable for the common colour-vision
  /// deficiencies when combined with [glyph]; the glyph carries the meaning.
  Color get color => switch (this) {
    MoveClass.brilliant => const Color(0xFF0891B2), // cyan
    MoveClass.great => const Color(0xFF2563EB), // blue
    MoveClass.best => const Color(0xFF16A34A), // green
    MoveClass.excellent => const Color(0xFF4D7C0F), // olive
    MoveClass.good => const Color(0xFF64748B), // slate
    MoveClass.book => const Color(0xFF92400E), // brown
    MoveClass.inaccuracy => const Color(0xFFA16207), // mustard
    MoveClass.mistake => const Color(0xFFEA580C), // orange
    MoveClass.miss => const Color(0xFFC026D3), // fuchsia
    MoveClass.blunder => const Color(0xFFDC2626), // red
  };

  /// Either a text glyph (chess annotation symbols) or an icon.
  MoveGlyph get glyph => switch (this) {
    MoveClass.brilliant => const MoveGlyph.text('!!'),
    MoveClass.great => const MoveGlyph.text('!'),
    MoveClass.best => const MoveGlyph.icon(Icons.star_rounded),
    MoveClass.excellent => const MoveGlyph.icon(Icons.thumb_up_alt_rounded),
    MoveClass.good => const MoveGlyph.icon(Icons.check_rounded),
    MoveClass.book => const MoveGlyph.icon(Icons.menu_book_rounded),
    MoveClass.inaccuracy => const MoveGlyph.text('?!'),
    MoveClass.mistake => const MoveGlyph.text('?'),
    MoveClass.miss => const MoveGlyph.icon(Icons.close_rounded),
    MoveClass.blunder => const MoveGlyph.text('??'),
  };

  String label(AppLocalizations l10n) => switch (this) {
    MoveClass.brilliant => l10n.classBrilliant,
    MoveClass.great => l10n.classGreat,
    MoveClass.best => l10n.classBest,
    MoveClass.excellent => l10n.classExcellent,
    MoveClass.good => l10n.classGood,
    MoveClass.book => l10n.classBook,
    MoveClass.inaccuracy => l10n.classInaccuracy,
    MoveClass.mistake => l10n.classMistake,
    MoveClass.miss => l10n.classMiss,
    MoveClass.blunder => l10n.classBlunder,
  };
}

/// A badge glyph: either annotation text such as `??` or a Material icon.
class MoveGlyph {
  const MoveGlyph.text(String this.text) : icon = null;
  const MoveGlyph.icon(IconData this.icon) : text = null;

  final String? text;
  final IconData? icon;

  /// Stable identity used to check that every class has a unique glyph.
  String get id => text ?? 'icon:${icon!.codePoint}';
}
