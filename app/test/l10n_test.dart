import 'dart:convert';
import 'dart:io';

import 'package:evilchess/core/theme/move_classification.dart';
import 'package:evilchess/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Set<String> _keys(String locale) {
  final json = jsonDecode(
    File('lib/l10n/app_$locale.arb').readAsStringSync(),
  ) as Map<String, dynamic>;
  return json.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  test('every language has exactly the same strings as English', () {
    final en = _keys('en');
    for (final locale in ['fr', 'ar']) {
      final other = _keys(locale);
      expect(en.difference(other), isEmpty, reason: 'missing in $locale');
      expect(other.difference(en), isEmpty, reason: 'extra keys in $locale');
    }
  });

  test('supported locales are en, fr, ar', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      {'en', 'fr', 'ar'},
    );
  });

  group('MoveClass', () {
    test('every class has a unique glyph and colour (never colour alone)', () {
      final glyphs = MoveClass.values.map((c) => c.glyph.id).toSet();
      final colors = MoveClass.values.map((c) => c.color).toSet();
      expect(glyphs, hasLength(MoveClass.values.length));
      expect(colors, hasLength(MoveClass.values.length));
    });

    test('every class has a distinct label in every language', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        final labels = MoveClass.values.map((c) => c.label(l10n)).toSet();
        expect(
          labels,
          hasLength(MoveClass.values.length),
          reason: 'duplicate label in ${locale.languageCode}',
        );
        expect(labels.every((s) => s.trim().isNotEmpty), isTrue);
      }
    });

    test('white glyphs stay readable on every badge colour', () {
      for (final c in MoveClass.values) {
        final ratio = _contrast(Colors.white, c.color);
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: '${c.name} contrast $ratio',
        );
      }
    });
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
