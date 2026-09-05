// Every money row of Story 1.3's edge-case matrix, asserted against the exact
// strings the acceptance criterion names.
//
// The expected values below are literals on purpose. This is the one place in
// the product where a hand-written ৳ and hand-written Bangla digits are the
// point: if the formatter and the test both derived the string from the same
// grouping code, the test would only prove the code agrees with itself.

import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/format/format.dart';

void main() {
  group('lakh grouping', () {
    test('Bangla renders Bangla digits grouped last-three-then-twos', () {
      expect(
        MoneyFormat.format(10850000, language: HisabLanguage.bangla),
        '৳১,০৮,৫০০',
        reason: 'DESIGN.md names this exact output: ৳১,০৮,৫০০, never ৳১০৮,৫০০',
      );
    });

    test('English renders the identical stored value in threes', () {
      expect(
        MoneyFormat.format(10850000, language: HisabLanguage.english),
        '৳108,500',
        reason: 'only the digits and the grouping differ — never the value',
      );
    });

    test('Bangla is the default when no language is passed', () {
      expect(
        MoneyFormat.format(10850000),
        MoneyFormat.format(10850000, language: HisabLanguage.bangla),
        reason: 'Bangla by default regardless of device locale (FR-8)',
      );
    });

    test('the two languages differ only in script and grouping', () {
      const int paisa = 987654321;
      final String bangla = MoneyFormat.format(
        paisa,
        language: HisabLanguage.bangla,
      );
      final String english = MoneyFormat.format(
        paisa,
        language: HisabLanguage.english,
      );
      expect(
        HisabDigits.toWestern(bangla).replaceAll(',', ''),
        english.replaceAll(',', ''),
        reason: 'strip the script and the commas and the same figure is left',
      );
    });

    test('grouping only starts above a thousand', () {
      expect(MoneyFormat.format(99900, language: HisabLanguage.bangla), '৳৯৯৯');
      expect(
        MoneyFormat.format(100000, language: HisabLanguage.bangla),
        '৳১,০০০',
      );
      expect(
        MoneyFormat.format(100000, language: HisabLanguage.english),
        '৳1,000',
      );
    });

    test('the first lakh group is two digits, not three', () {
      // 1,00,000 — the boundary the lakh rule exists for. Western grouping of
      // the same figure is 100,000, and getting this wrong is the whole defect
      // the acceptance criterion names.
      expect(
        MoneyFormat.format(10000000, language: HisabLanguage.bangla),
        '৳১,০০,০০০',
      );
      expect(
        MoneyFormat.format(10000000, language: HisabLanguage.english),
        '৳100,000',
      );
    });
  });

  group('paisa', () {
    test('are hidden when they are zero', () {
      expect(MoneyFormat.format(10850000), '৳১,০৮,৫০০');
    });

    test('are shown as two digits when they are not', () {
      expect(MoneyFormat.format(10850050), '৳১,০৮,৫০০.৫০');
    });

    test('keep their leading zero', () {
      expect(MoneyFormat.format(10850005), '৳১,০৮,৫০০.০৫');
    });

    test('are never rounded away', () {
      // A column that does not sum to its total is the one defect this product
      // cannot ship, so a displayed figure is never rounded.
      expect(MoneyFormat.format(1, language: HisabLanguage.english), '৳0.01');
      expect(MoneyFormat.format(99, language: HisabLanguage.english), '৳0.99');
    });
  });

  group('the boundary at one taka', () {
    test('below one taka keeps a zero whole part', () {
      expect(MoneyFormat.format(50), '৳০.৫০');
      expect(MoneyFormat.format(50, language: HisabLanguage.english), '৳0.50');
    });

    test('exactly one taka shows no paisa', () {
      expect(MoneyFormat.format(100), '৳১');
    });

    test('just over one taka shows both', () {
      expect(MoneyFormat.format(101), '৳১.০১');
    });
  });

  group('zero', () {
    test('is a figure, never a blank', () {
      // A deliberate zero differs from an unanswered field, and the difference
      // has to survive rendering (FR-4).
      expect(MoneyFormat.format(0, language: HisabLanguage.bangla), '৳০');
      expect(MoneyFormat.format(0, language: HisabLanguage.english), '৳0');
    });

    test('carries no sign, even when signs are asked for', () {
      expect(
        MoneyFormat.format(0, sign: MoneySign.always),
        '৳০',
        reason: 'zero has no direction',
      );
    });
  });

  group('sign', () {
    test('a negative uses U+2212 before the currency mark', () {
      expect(MoneyFormat.format(-10850000), '−৳১,০৮,৫০০');
      expect(
        MoneyFormat.format(-10850000).codeUnitAt(0),
        0x2212,
        reason: 'U+2212 MINUS SIGN, not the ASCII hyphen: it is digit-width in '
            'a tabular face, so a column with negatives in it still lines up',
      );
      expect(
        MoneyFormat.format(-10850000).contains('-'),
        isFalse,
        reason: 'the ASCII hyphen never appears in a displayed figure',
      );
    });

    test('a negative below one taka still signs the whole figure', () {
      expect(MoneyFormat.format(-50), '−৳০.৫০');
    });

    test('MoneySign.always states the direction of a positive', () {
      expect(
        MoneyFormat.format(1250000, sign: MoneySign.always),
        '+৳১২,৫০০',
        reason: 'colour is never the only carrier of meaning — the sign is '
            'there too',
      );
    });

    test('MoneySign.never gives the magnitude only', () {
      expect(MoneyFormat.format(-10850000, sign: MoneySign.never), '৳১,০৮,৫০০');
      expect(MoneyFormat.formatAbsolute(-10850000), '৳১,০৮,৫০০');
    });
  });

  group('large values', () {
    test('group correctly past a crore, with no overflow', () {
      // 999999999999 paisa = 9,99,99,99,999.99 taka.
      expect(
        MoneyFormat.format(999999999999, language: HisabLanguage.bangla),
        '৳৯,৯৯,৯৯,৯৯,৯৯৯.৯৯',
      );
      expect(
        MoneyFormat.format(999999999999, language: HisabLanguage.english),
        '৳9,999,999,999.99',
      );
    });

    test('never fall back to scientific notation', () {
      for (final int paisa in <int>[
        1000000000,
        100000000000,
        9007199254740993,
        9223372036854775807,
      ]) {
        final String rendered = MoneyFormat.format(
          paisa,
          language: HisabLanguage.english,
        );
        expect(
          rendered.contains('e'),
          isFalse,
          reason: '$paisa rendered as $rendered',
        );
      }
    });

    test('the most negative int is formatted, not crashed on', () {
      // abs() on this value is still negative on a 64-bit VM. The formatter
      // slices digits instead of doing arithmetic, so it has no such edge.
      // Written as an expression rather than as the literal
      // -9223372036854775808, which is legal Dart but reads like a typo.
      const int mostNegative = -9223372036854775807 - 1;
      final String rendered = MoneyFormat.format(
        mostNegative,
        language: HisabLanguage.english,
      );
      expect(rendered.startsWith('−৳'), isTrue);
      expect(rendered.contains('92,233,720,368,547,758.08'), isTrue);
    });
  });

  group('the currency mark', () {
    test('is the Bengali rupee sign, in both languages', () {
      expect(MoneyFormat.currencyMark.codeUnitAt(0), 0x09F3);
      expect(
        MoneyFormat.format(100, language: HisabLanguage.english).startsWith('৳'),
        isTrue,
        reason: 'currency is ৳ BDT and is not editable in the MVP',
      );
    });

    test('can be left off for a figure whose column already says taka', () {
      expect(MoneyFormat.format(10850000, withCurrency: false), '১,০৮,৫০০');
      expect(
        MoneyFormat.format(-50, withCurrency: false).contains('৳'),
        isFalse,
      );
    });
  });

  group('the machine-readable form', () {
    test('is Western digits, ungrouped, with a . decimal', () {
      expect(MoneyFormat.export(10850050), '108500.50');
    });

    test('is identical whatever the language is', () {
      // The export form takes no language: a CSV carrying Bangla digits and
      // lakh commas is unopenable in the spreadsheet the owner's accountant
      // uses.
      expect(MoneyFormat.export(10850050), isNot(contains(',')));
      expect(MoneyFormat.export(10850050), isNot(contains('৳')));
      expect(MoneyFormat.export(10850050), isNot(contains('০')));
    });

    test('always writes both paisa digits, so a column has one shape', () {
      expect(MoneyFormat.export(10850000), '108500.00');
      expect(MoneyFormat.export(0), '0.00');
      expect(MoneyFormat.export(5), '0.05');
    });

    test('uses an ASCII hyphen for a negative, not U+2212', () {
      expect(MoneyFormat.export(-10850050), '-108500.50');
      expect(
        MoneyFormat.export(-10850050).contains('−'),
        isFalse,
        reason: 'U+2212 is not a minus sign to a spreadsheet',
      );
    });
  });
}
