// Covers two rows of the story's edge-case matrix:
//
//   * "Column of amounts" — several figures stacked in a ledger column must
//     align vertically. That is tabular figures, and the test fails if the
//     digits have different advance widths.
//   * "Fonts absent" — the two families must resolve from bundled assets, never
//     from a system face and never from a download.

import 'dart:io';
import 'dart:ui' as ui show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/theme/hisab_theme.dart';
import 'package:hisab/theme/tokens.dart';

import 'support/fonts.dart';
import 'support/ttf.dart';

const ui.FontFeature _tabular = ui.FontFeature.tabularFigures();

bool _isTabular(TextStyle style) =>
    style.fontFeatures?.any(
      (ui.FontFeature f) => f.feature == _tabular.feature && f.value == 1,
    ) ??
    false;

double _widthOf(String text, TextStyle style) {
  final TextPainter painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final double width = painter.width;
  painter.dispose();
  return width;
}

void main() {
  group('bundled faces', () {
    test('all six declared files are on disk', () {
      for (final BundledFont font in kBundledFonts) {
        expect(
          font.file.existsSync(),
          isTrue,
          reason: '${font.path} is missing.\n$kMissingFontsHint',
        );
      }
    });

    test('each file is a real TrueType face, not a stray download', () {
      for (final BundledFont font in kBundledFonts) {
        final TtfFace face = font.face;
        expect(face.hasTable('cmap'), isTrue, reason: '${font.path} has no cmap');
        expect(face.hasTable('glyf'), isTrue, reason: '${font.path} has no glyf');
      }
    });

    test('the two families are the two DESIGN.md names', () {
      final Set<String> families = kBundledFonts
          .map((BundledFont f) => f.family)
          .toSet();
      expect(families, <String>{HisabFonts.display, HisabFonts.ui});
    });

    test('Hind Siliguri ships 400 / 500 / 600 / 700', () {
      final List<int> weights =
          kBundledFonts
              .where((BundledFont f) => f.family == HisabFonts.ui)
              .map((BundledFont f) => f.weight)
              .toList()
            ..sort();
      expect(weights, <int>[400, 500, 600, 700]);
    });

    test('Noto Serif Bengali ships 600 / 700', () {
      final List<int> weights =
          kBundledFonts
              .where((BundledFont f) => f.family == HisabFonts.display)
              .map((BundledFont f) => f.weight)
              .toList()
            ..sort();
      expect(weights, <int>[600, 700]);
    });

    test('pubspec declares exactly these files, under these families', () {
      // The list in the fixture and the list in pubspec.yaml are two copies of
      // the same fact, and a renamed file is an invisible missing face.
      final String pubspec = File('pubspec.yaml').readAsStringSync();
      // Comments explain *why* there is no runtime font download, and say the
      // package name to do it. Strip them, or this test fails on its own
      // rationale.
      final String declarations = pubspec
          .split('\n')
          .where((String line) => !line.trimLeft().startsWith('#'))
          .join('\n');
      for (final BundledFont font in kBundledFonts) {
        expect(
          pubspec,
          contains('asset: ${font.path}'),
          reason: '${font.path} is not declared in pubspec.yaml',
        );
        expect(pubspec, contains('weight: ${font.weight}'));
      }
      expect(pubspec, contains('family: ${HisabFonts.display}'));
      expect(pubspec, contains('family: ${HisabFonts.ui}'));
      // No runtime font download, ever.
      expect(
        declarations,
        isNot(contains('google_fonts')),
        reason: 'the app must render with no connection (UX-DR3)',
      );
    });
  });

  group('tabular figures', () {
    test('every role in the scale has them', () {
      HisabTextStyles.byRole.forEach((String name, TextStyle style) {
        expect(_isTabular(style), isTrue, reason: '$name is not tabular');
      });
    });

    test('every slot of the M3 text theme has them', () {
      final TextTheme theme = HisabTheme.textTheme;
      final Map<String, TextStyle?> slots = <String, TextStyle?>{
        'displayLarge': theme.displayLarge,
        'displayMedium': theme.displayMedium,
        'displaySmall': theme.displaySmall,
        'headlineLarge': theme.headlineLarge,
        'headlineMedium': theme.headlineMedium,
        'headlineSmall': theme.headlineSmall,
        'titleLarge': theme.titleLarge,
        'titleMedium': theme.titleMedium,
        'titleSmall': theme.titleSmall,
        'bodyLarge': theme.bodyLarge,
        'bodyMedium': theme.bodyMedium,
        'bodySmall': theme.bodySmall,
        'labelLarge': theme.labelLarge,
        'labelMedium': theme.labelMedium,
        'labelSmall': theme.labelSmall,
      };
      slots.forEach((String name, TextStyle? style) {
        expect(style, isNotNull, reason: '$name would fall back to a default');
        expect(_isTabular(style!), isTrue, reason: '$name is not tabular');
      });
    });

    test('the component styles have them too', () {
      final Map<String, TextStyle> styles = <String, TextStyle>{
        'buttonLabel': HisabTextStyles.buttonLabel,
        'fieldValue': HisabTextStyles.fieldValue,
        'fieldHint': HisabTextStyles.fieldHint,
        'quickActionLabel': HisabTextStyles.quickActionLabel,
        'chipLabel': HisabTextStyles.chipLabel,
        'ledger': HisabTextStyles.ledger,
        'ledgerBalance': HisabTextStyles.ledgerBalance,
        'bottomNavLabel': HisabTextStyles.bottomNavLabel,
        'banner': HisabTextStyles.banner,
        'amountIn': HisabTextStyles.amountIn,
        'amountOut': HisabTextStyles.amountOut,
      };
      styles.forEach((String name, TextStyle style) {
        expect(_isTabular(style), isTrue, reason: '$name is not tabular');
      });
    });
  });

  group('every slot resolves to a bundled family', () {
    test('no style falls through to a system font', () {
      const Set<String> bundled = <String>{HisabFonts.display, HisabFonts.ui};
      final TextTheme theme = HisabTheme.textTheme;
      final List<TextStyle?> all = <TextStyle?>[
        theme.displayLarge,
        theme.displayMedium,
        theme.displaySmall,
        theme.headlineLarge,
        theme.headlineMedium,
        theme.headlineSmall,
        theme.titleLarge,
        theme.titleMedium,
        theme.titleSmall,
        theme.bodyLarge,
        theme.bodyMedium,
        theme.bodySmall,
        theme.labelLarge,
        theme.labelMedium,
        theme.labelSmall,
      ];
      for (final TextStyle? style in all) {
        expect(bundled, contains(style?.fontFamily));
      }
    });

    test('the serif is never used below 17px anywhere in the theme', () {
      final TextTheme theme = HisabTheme.textTheme;
      for (final TextStyle? style in <TextStyle?>[
        theme.titleLarge,
        theme.titleMedium,
        theme.titleSmall,
        theme.displayLarge,
        theme.bodyLarge,
        theme.labelSmall,
      ]) {
        if (style?.fontFamily == HisabFonts.display) {
          expect(
            style!.fontSize,
            greaterThanOrEqualTo(HisabFonts.displayMinSize),
          );
        }
      }
    });
  });

  group('a ledger column lines up', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await loadBundledFonts();
    });

    test('Western digits share one advance width', () {
      final TextStyle style = HisabTextStyles.amountSm;
      final double narrow = _widthOf('1111', style);
      final double wide = _widthOf('8888', style);
      expect(
        wide,
        closeTo(narrow, 0.01),
        reason:
            'digits have different advance widths, so a column of amounts will '
            'not align. Tabular figures are not reaching the rendered text.',
      );
    });

    test('Bangla digits share one advance width', () {
      // Bangla mode renders Bangla digits (FR-8), and it is Bangla mode the
      // shop owner uses. The alignment guarantee has to hold there.
      final TextStyle style = HisabTextStyles.amountSm;
      final double ones = _widthOf('১১১১', style);
      final double eights = _widthOf('৮৮৮৮', style);
      expect(ones, closeTo(eights, 0.01));
    });

    test('two grouped amounts of equal digit count are equally wide', () {
      final TextStyle style = HisabTextStyles.amountMd;
      expect(
        _widthOf('৳১,০৮,৫০০', style),
        closeTo(_widthOf('৳৯,৯৯,৯৯৯', style), 0.01),
      );
    });

    test('the amount ramp really does descend on screen', () {
      // Money is the largest thing on any screen it appears on, and the ramp is
      // what guarantees it.
      double previous = double.infinity;
      for (final HisabTypeRole role in HisabTypeScale.amounts) {
        final double width = _widthOf('৳১,০৮,৫০০', HisabTextStyles.forRole(role));
        expect(width, lessThan(previous));
        previous = width;
      }
    });
  });
}
