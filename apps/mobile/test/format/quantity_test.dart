// Quantity: trimming, whole values, and the rule that a quantity is not money.
//
// Quantity is stored as integer milli-units (AR-2) so that 250 grams of rice
// can be sold without the stock count drifting. Three digits of scale exist for
// the arithmetic, not for the owner: nobody writes ২.৫০০ কেজি in a khata.

import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/format/format.dart';

void main() {
  group('trailing zeros', () {
    test('are trimmed', () {
      expect(
        QuantityFormat.format(2500, unit: 'কেজি'),
        '২.৫ কেজি',
        reason: 'never ২.৫০০ কেজি — a quantity is written the way it is spoken',
      );
    });

    test('are trimmed one place at a time', () {
      expect(QuantityFormat.format(2530), '২.৫৩');
      expect(QuantityFormat.format(2503), '২.৫০৩');
    });

    test('leave nothing behind when the whole fraction is zero', () {
      expect(
        QuantityFormat.format(3000),
        '৩',
        reason: 'a whole quantity is ৩, not ৩.০',
      );
      expect(QuantityFormat.format(3000).contains('.'), isFalse);
    });
  });

  group('values', () {
    test('below one unit keep a zero whole part', () {
      expect(QuantityFormat.format(250), '০.২৫');
      expect(QuantityFormat.format(1), '০.০০১');
    });

    test('zero is a figure, never a blank', () {
      expect(QuantityFormat.format(0), '০');
      expect(QuantityFormat.format(0, language: HisabLanguage.english), '0');
    });

    test('negative uses the same U+2212 as money', () {
      expect(QuantityFormat.format(-2500), '−২.৫');
      expect(QuantityFormat.format(-2500).codeUnitAt(0), 0x2212);
    });

    test('large quantities group the way the language reads them', () {
      // 108500 pieces.
      expect(
        QuantityFormat.format(108500000, language: HisabLanguage.bangla),
        '১,০৮,৫০০',
      );
      expect(
        QuantityFormat.format(108500000, language: HisabLanguage.english),
        '108,500',
      );
    });
  });

  group('language', () {
    test('English renders the identical stored value in Western digits', () {
      expect(
        QuantityFormat.format(2500, language: HisabLanguage.english, unit: 'kg'),
        '2.5 kg',
      );
    });

    test('Bangla is the default', () {
      expect(QuantityFormat.format(2500), '২.৫');
    });
  });

  group('quantity is not money', () {
    test('it never carries the currency mark', () {
      for (final int milli in <int>[0, 1, 250, 2500, 3000, 108500000, -2500]) {
        for (final HisabLanguage language in HisabLanguage.values) {
          expect(
            QuantityFormat.format(milli, language: language, unit: 'কেজি'),
            isNot(contains('৳')),
            reason: '$milli milli in ${language.name} carried a ৳',
          );
          expect(
            QuantityFormat.export(milli),
            isNot(contains('৳')),
            reason: '$milli milli carried a ৳ into an export',
          );
        }
      }
    });

    test('the same integer means different things to the two formatters', () {
      // 2500 is ২৫.০০ taka and ২.৫ kilograms. Nothing about the number says
      // which, which is exactly why they are separate calls.
      expect(MoneyFormat.format(2500), '৳২৫');
      expect(QuantityFormat.format(2500), '২.৫');
    });
  });

  group('the unit label', () {
    test('follows the figure after one space', () {
      expect(QuantityFormat.format(1000, unit: 'পিস'), '১ পিস');
    });

    test('is left off when there is none', () {
      expect(QuantityFormat.format(1000), '১');
      expect(QuantityFormat.format(1000, unit: ''), '১');
    });

    test('is passed through exactly as given', () {
      // Unit names come from the owner's own product records. This layer does
      // not translate them and does not pluralise them.
      expect(QuantityFormat.format(2000, unit: 'হালি'), '২ হালি');
    });
  });

  group('the machine-readable form', () {
    test('is Western digits, ungrouped, with a . decimal', () {
      expect(QuantityFormat.export(2500), '2.5');
      expect(QuantityFormat.export(3000), '3');
      expect(QuantityFormat.export(108500000), '108500');
      expect(QuantityFormat.export(-250), '-0.25');
    });

    test('carries no unit label', () {
      expect(QuantityFormat.export(2500), isNot(contains(' ')));
    });
  });
}
