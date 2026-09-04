// Covers the "Bangla conjuncts" row of the story's edge-case matrix on all
// three surfaces the product renders on: Android, iOS and a generated PDF.
//
// Three kinds of check, deliberately, because no one of them is sufficient:
//
//   1. The FACE. Read the .ttf's own cmap and GSUB tables and assert the
//      codepoints are there and the Bengali shaping features exist. A golden
//      cannot catch a font swapped for one without Bengali coverage — you would
//      simply re-record the golden and ship tofu.
//   2. The SHAPER. Lay ক্ত out through the real engine and assert the conjunct
//      actually formed, by comparing it against the two consonants unjoined.
//   3. The PIXELS. A golden of the conjunct sample in both families, so a
//      regression in weight, metrics or fallback is visible to a human.
//
// Plus the PDF: a receipt is generated from the same bundled TTF, and the test
// asserts the face is embedded in the output rather than substituted.
//
// GOLDENS: the .png under test/theme/goldens/ is generated once with
//     flutter test --update-goldens test/theme/bangla_rendering_test.dart
// and REVIEWED BY EYE before being committed — look for formed conjuncts and
// no dotted circles. A golden accepted without looking at it is worse than no
// golden, because it makes the wrong thing permanent.

import 'dart:convert' show latin1;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/theme/hisab_theme.dart';
import 'package:hisab/theme/tokens.dart';
import 'package:pdf/widgets.dart' as pw;

import 'support/fonts.dart';
import 'support/ttf.dart';

/// The conjuncts that fail first when a face is missing or substituted, plus
/// the two words the product says most often and the currency mark.
const String kConjunctSample = 'ক্ত ঙ্ক ক্ষ ন্ত্র · হিসাব · বাকি · ৳১,০৮,৫০০';

/// Codepoints every bundled face has to cover.
const Map<int, String> kRequiredCodePoints = <int, String>{
  0x0995: 'ক',
  0x0996: 'খ',
  0x0997: 'গ',
  0x0999: 'ঙ',
  0x09A4: 'ত',
  0x09A8: 'ন',
  0x09AC: 'ব',
  0x09B8: 'স',
  0x09B9: 'হ',
  0x09BF: 'ি',
  0x09BE: 'া',
  0x09CD: '্ (হসন্ত)',
  0x09E6: '০',
  0x09EF: '৯',
  0x09F3: '৳',
};

/// The OpenType features a Bengali shaper needs. A face carrying none of these
/// cannot form a conjunct no matter what the renderer does.
const Set<String> kBengaliShapingFeatures = <String>{
  'akhn',
  'rphf',
  'blwf',
  'half',
  'pstf',
  'vatu',
  'cjct',
  'nukt',
};

double _width(String text, TextStyle style) {
  final TextPainter painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final double width = painter.width;
  painter.dispose();
  return width;
}

void main() {
  group('the face itself', () {
    test('every bundled face covers the Bangla codepoints', () {
      for (final BundledFont font in kBundledFonts) {
        final TtfFace face = font.face;
        kRequiredCodePoints.forEach((int codePoint, String label) {
          expect(
            face.covers(codePoint),
            isTrue,
            reason:
                '$font cannot draw $label (U+${codePoint.toRadixString(16).toUpperCase()}). '
                'A shop owner would see a tofu box.',
          );
        });
      }
    });

    test('every bundled face carries Bengali conjunct features', () {
      for (final BundledFont font in kBundledFonts) {
        final Set<String> present =
            font.face.gsubFeatureTags.intersection(kBengaliShapingFeatures);
        expect(
          present.length,
          greaterThanOrEqualTo(2),
          reason:
              '$font has no Bengali shaping features (found: $present). '
              'ক + ্ + ত will render as three separate marks, not as ক্ত.',
        );
      }
    });

    test('Western digits are present too', () {
      // English mode renders Western digits from the identical stored value
      // (FR-8), out of the same faces.
      for (final BundledFont font in kBundledFonts) {
        for (int digit = 0x30; digit <= 0x39; digit++) {
          expect(font.face.covers(digit), isTrue, reason: '$font lacks digits');
        }
      }
    });
  });

  group('the shaper', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await loadBundledFonts();
    });

    for (final String family in <String>[HisabFonts.ui, HisabFonts.display]) {
      test('$family forms ক্ত rather than leaving ক ্ ত apart', () {
        final TextStyle style = TextStyle(
          fontFamily: family,
          fontSize: HisabTypeScale.amountLg.size,
        );
        final double joined = _width('ক্ত', style);
        final double apart = _width('কত', style);
        expect(joined, greaterThan(0));
        expect(
          joined,
          lessThan(apart),
          reason:
              'ক্ত is no narrower than কত, so the conjunct did not form: the '
              'hasant is being drawn instead of joining the two consonants.',
        );
      });

      test('$family forms ঙ্ক', () {
        final TextStyle style = TextStyle(
          fontFamily: family,
          fontSize: HisabTypeScale.amountLg.size,
        );
        expect(_width('ঙ্ক', style), lessThan(_width('ঙক', style)));
      });
    }
  });

  group('the pixels', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await loadBundledFonts();
    });

    testWidgets('the conjunct sample in both families', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(560, 260);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HisabTheme.light(),
          debugShowCheckedModeBanner: false,
          home: const Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: ValueKey<String>('bangla-conjuncts'),
                child: _ConjunctSpecimen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(const ValueKey<String>('bangla-conjuncts')),
        matchesGoldenFile('goldens/bangla_conjuncts.png'),
      );
      // Skipped off macOS. Flutter's golden files are pixel comparisons, and
      // text rasterisation differs between macOS and the Linux runner CI uses —
      // a golden recorded on one fails on the other for reasons that have
      // nothing to do with the font. Rather than let that noise train everyone
      // to ignore a red build, the golden runs where it was recorded and the
      // real guarantees run everywhere: the face tests read the font's own
      // tables, and the shaper test proves the conjunct forms. Those two catch
      // a substituted or broken face; this one is for a human's eyes.
    }, skip: !Platform.isMacOS);
  });

  group('the PDF receipt', () {
    late List<int> withBangla;
    late List<int> almostEmpty;

    setUpAll(() async {
      // Receipts are set in Noto Serif Bengali; the amounts on them in Hind
      // Siliguri. Both have to survive the trip into a PDF.
      withBangla = await _buildReceipt(kConjunctSample);
      almostEmpty = await _buildReceipt('.');
    });

    test('a PDF is produced from the bundled face without falling over', () {
      expect(withBangla.length, greaterThan(0));
      expect(
        latin1.decode(withBangla.sublist(0, 5), allowInvalid: true),
        startsWith('%PDF-'),
      );
    });

    test('the bundled TrueType face is embedded in the output', () {
      // FontFile2 is an embedded TrueType program. Its absence would mean the
      // PDF references a base-14 font instead, which has no Bangla at all.
      final String raw = latin1.decode(withBangla, allowInvalid: true);
      expect(
        raw,
        contains('FontFile2'),
        reason: 'no TrueType program embedded — the receipt would show tofu',
      );
      // A composite (Type0) font is what carries a Bangla glyph set.
      expect(raw, contains('Type0'));
    });

    test('the Bangla glyphs are in the output, not just the font reference', () {
      // The pdf package subsets: only glyphs actually used are written. So a
      // document carrying the Bangla sample must be materially larger than the
      // same document carrying one full stop.
      expect(
        withBangla.length,
        greaterThan(almostEmpty.length),
        reason: 'no extra glyph outlines were embedded for the Bangla text',
      );
    });
  });
}

/// A receipt-shaped page: title in the serif, amount in the UI face.
Future<List<int>> _buildReceipt(String text) async {
  final pw.Document document = pw.Document(compress: false);
  final BundledFont serif = kBundledFonts.firstWhere(
    (BundledFont f) => f.fileName == 'NotoSerifBengali-SemiBold.ttf',
  );
  final BundledFont ui = kBundledFonts.firstWhere(
    (BundledFont f) => f.fileName == 'HindSiliguri-SemiBold.ttf',
  );
  final serifBytes = serif.file.readAsBytesSync();
  final uiBytes = ui.file.readAsBytesSync();
  final pw.Font title = pw.Font.ttf(
    serifBytes.buffer.asByteData(
      serifBytes.offsetInBytes,
      serifBytes.lengthInBytes,
    ),
  );
  final pw.Font amount = pw.Font.ttf(
    uiBytes.buffer.asByteData(uiBytes.offsetInBytes, uiBytes.lengthInBytes),
  );

  document.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(text, style: pw.TextStyle(font: title, fontSize: 18)),
          pw.SizedBox(height: 12),
          pw.Text(text, style: pw.TextStyle(font: amount, fontSize: 15)),
        ],
      ),
    ),
  );
  return document.save();
}

class _ConjunctSpecimen extends StatelessWidget {
  const _ConjunctSpecimen();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HisabColors.paper,
      child: Padding(
        padding: const EdgeInsets.all(HisabSpacing.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Noto Serif Bengali', style: HisabTextStyles.label),
            Text(
              kConjunctSample,
              style: HisabTextStyles.title,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: HisabSpacing.s4),
            Text('Hind Siliguri', style: HisabTextStyles.label),
            Text(
              kConjunctSample,
              style: HisabTextStyles.body,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: HisabSpacing.s4),
            Text(
              '৳১,০৮,৫০০',
              style: HisabTextStyles.amountLg,
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}
