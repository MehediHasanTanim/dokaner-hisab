// Every parse row of Story 1.3's edge-case matrix, plus a round trip over a
// spread of stored values.
//
// Two properties matter more than any single case here:
//
//   1. Parsing is TOTAL. Nothing in these tests is wrapped in a try/catch,
//      because nothing the parser is given may throw. A keypad cannot crash a
//      form.
//   2. Round trip. Any stored integer, formatted and read back, returns the
//      identical integer — in either language, with or without a sign, with or
//      without paisa. That property is what lets a figure be shown to the owner
//      and then re-read from the field they edited.

import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/format/format.dart';

/// The parsed paisa, or a failing expectation naming what went wrong instead.
int _paisa(String text) {
  final ParseResult<int> result = HisabParse.money(text);
  expect(
    result.isSuccess,
    isTrue,
    reason: '"$text" failed to parse: ${result.errorOrNull?.code}',
  );
  return result.valueOrNull!;
}

void _fails(String text, NumberParseError expected) {
  final ParseResult<int> result = HisabParse.money(text);
  expect(
    result.isFailure,
    isTrue,
    reason: '"$text" parsed to ${result.valueOrNull} instead of failing',
  );
  expect(result.errorOrNull, expected, reason: 'wrong reason for "$text"');
}

void main() {
  group('digit scripts', () {
    test('the two scripts have ten digits each, in value order', () {
      expect(kBanglaDigits, hasLength(10));
      expect(kWesternDigits, hasLength(10));
      for (int value = 0; value < 10; value++) {
        expect(
          HisabDigits.valueOf(kBanglaDigits.codeUnitAt(value)),
          value,
          reason: 'index is value, so a lookup needs no table',
        );
        expect(HisabDigits.valueOf(kWesternDigits.codeUnitAt(value)), value);
      }
    });

    test('a digit in either script is a digit', () {
      expect(HisabDigits.isDigit('৫'), isTrue);
      expect(HisabDigits.isDigit('5'), isTrue);
      expect(HisabDigits.isDigit('৳'), isFalse);
      expect(HisabDigits.isDigit('٣'), isFalse, reason: 'Arabic-Indic is not '
          'a script this product reads');
      expect(HisabDigits.isDigit('55'), isFalse, reason: 'one character only');
    });

    test('converting a script leaves everything else alone', () {
      expect(HisabDigits.toWestern('৳১,০৮,৫০০.৫০'), '৳108,500.50');
      expect(
        HisabDigits.toScript('৳108,500.50', HisabLanguage.bangla),
        '৳১,০৮,৫০০.৫০',
      );
      expect(
        HisabDigits.toScript('৳108,500.50', HisabLanguage.english),
        '৳108,500.50',
        reason: 'English is already Western digits, so nothing moves',
      );
    });
  });

  group('script', () {
    test('Bangla digits with lakh commas', () {
      expect(_paisa('১,০৮,৫০০'), 10850000);
    });

    test('Western digits with a decimal', () {
      expect(_paisa('108500.50'), 10850050);
    });

    test('a mix of both scripts in one figure', () {
      // The keypad belongs to the device: an owner in Bangla mode may still be
      // holding a Western keyboard, and half a figure may arrive in each.
      expect(_paisa('১08,৫00.5'), 10850050);
    });

    test('Bangla digits in the fraction too', () {
      expect(_paisa('১০৮৫০০.৫০'), 10850050);
    });
  });

  group('decoration', () {
    test('the currency mark, commas and spaces are ignored', () {
      expect(_paisa('৳ ১,০৮,৫০০ '), 10850000);
    });

    test('so are the invisible characters a Bangla keyboard emits', () {
      expect(_paisa('‌১০৮৫০০‍'), 10850000);
      expect(_paisa('১০৮ ৫০০'), 10850000);
    });

    test('an explicit plus is accepted and means positive', () {
      expect(_paisa('+১২,৫০০'), 1250000);
    });

    test('both minus signs are accepted', () {
      expect(_paisa('-108500'), -10850000);
      expect(_paisa('−১,০৮,৫০০'), -10850000);
    });
  });

  group('scale', () {
    test('one decimal place is tenths of a taka', () {
      expect(_paisa('10.5'), 1050);
    });

    test('no decimal place is whole taka', () {
      expect(_paisa('10'), 1000);
    });

    test('a bare fraction is read as a fraction of one taka', () {
      expect(_paisa('.5'), 50);
    });

    test('trailing zeros past the scale carry nothing and are accepted', () {
      // ten fifty, written with a third place that holds nothing.
      expect(_paisa('10.500'), 1050);
    });

    test('quantity reads three places, not two', () {
      expect(HisabParse.quantity('২.৫').valueOrNull, 2500);
      expect(HisabParse.quantity('3').valueOrNull, 3000);
      expect(HisabParse.quantity('0.25').valueOrNull, 250);
      expect(HisabParse.quantity('2.503').valueOrNull, 2503);
    });
  });

  group('failure is a result, never an exception', () {
    test('empty and blank input', () {
      _fails('', NumberParseError.empty);
      _fails('   ', NumberParseError.empty);
    });

    test('letters', () {
      _fails('abc', NumberParseError.notANumber);
      _fails('১০০ টাকা', NumberParseError.notANumber);
    });

    test('two decimal points', () {
      _fails('১.২.৩', NumberParseError.notANumber);
    });

    test('two signs, or a sign in the wrong place', () {
      _fails('--5', NumberParseError.notANumber);
      _fails('+-5', NumberParseError.notANumber);
      _fails('5-', NumberParseError.notANumber);
    });

    test('decoration with no figure in it', () {
      _fails('৳', NumberParseError.notANumber);
      _fails('.', NumberParseError.notANumber);
      _fails('-', NumberParseError.notANumber);
    });

    test('more precision than the value is stored to', () {
      // Rejected rather than silently rounded: the owner sees what they typed.
      _fails('10.999', NumberParseError.tooPrecise);
      expect(
        HisabParse.quantity('2.5001').errorOrNull,
        NumberParseError.tooPrecise,
      );
    });

    test('more digits than the stored integer can hold', () {
      _fails('99999999999999999999999', NumberParseError.tooLarge);
    });

    test('every failure carries a SCREAMING_SNAKE code for a Bangla message', () {
      for (final NumberParseError error in NumberParseError.values) {
        expect(
          error.code,
          matches(RegExp(r'^[A-Z][A-Z_]*[A-Z]$')),
          reason: 'AR-16: the code is what the Bangla text is resolved from',
        );
      }
    });

    test('nothing throws, whatever is typed', () {
      const List<String> rubbish = <String>[
        '',
        ' ',
        'abc',
        '১.২.৩',
        '--5',
        '৳৳৳',
        '...',
        '-.',
        '1e9',
        '٣٤٥', // Arabic-Indic digits: a script this product does not read
        '½',
        '\n',
        '10,,500',
        '0000000000000000000000000000001',
      ];
      for (final String text in rubbish) {
        final ParseResult<int> money = HisabParse.money(text);
        final ParseResult<int> quantity = HisabParse.quantity(text);
        expect(money, isNotNull, reason: 'money("$text") returned nothing');
        expect(
          quantity,
          isNotNull,
          reason: 'quantity("$text") returned nothing',
        );
      }
    });
  });

  group('the result type', () {
    test('folds to one value the caller can render', () {
      expect(
        HisabParse.money('১০০').fold<String>(
          onSuccess: (int paisa) => 'ok $paisa',
          onFailure: (NumberParseError e) => 'no ${e.code}',
        ),
        'ok 10000',
      );
      expect(
        HisabParse.money('abc').fold<String>(
          onSuccess: (int paisa) => 'ok $paisa',
          onFailure: (NumberParseError e) => 'no ${e.code}',
        ),
        'no NUMBER_NOT_A_NUMBER',
      );
    });

    test('valueOr gives a caller its own fallback', () {
      expect(HisabParse.money('abc').valueOr(0), 0);
      expect(HisabParse.money('১').valueOr(0), 100);
    });
  });

  group('round trip', () {
    /// A spread that covers every branch of the formatter: zero, sub-taka,
    /// the one-taka boundary, the first lakh, past a crore, and negatives of
    /// each.
    const List<int> paisaValues = <int>[
      0,
      1,
      5,
      50,
      99,
      100,
      101,
      999,
      100000,
      10000000,
      10850000,
      10850050,
      98765432109,
      999999999999,
    ];

    test('display form → parser → the identical stored integer', () {
      for (final HisabLanguage language in HisabLanguage.values) {
        for (final int paisa in paisaValues) {
          for (final int signed in <int>[paisa, -paisa]) {
            final String shown = MoneyFormat.format(
              signed,
              language: language,
            );
            expect(
              _paisa(shown),
              signed,
              reason: '$signed rendered as "$shown" in ${language.name}',
            );
          }
        }
      }
    });

    test('a signed display form round trips too', () {
      for (final int paisa in paisaValues) {
        final String shown = MoneyFormat.format(paisa, sign: MoneySign.always);
        expect(_paisa(shown), paisa, reason: '"$shown"');
      }
    });

    test('the machine-readable form round trips', () {
      for (final int paisa in paisaValues) {
        for (final int signed in <int>[paisa, -paisa]) {
          expect(_paisa(MoneyFormat.export(signed)), signed);
        }
      }
    });

    test('quantity round trips in both languages', () {
      const List<int> milliValues = <int>[
        0,
        1,
        250,
        999,
        1000,
        2500,
        2503,
        108500000,
        999999999999,
      ];
      for (final HisabLanguage language in HisabLanguage.values) {
        for (final int milli in milliValues) {
          for (final int signed in <int>[milli, -milli]) {
            final String shown = QuantityFormat.format(
              signed,
              language: language,
            );
            expect(
              HisabParse.quantity(shown).valueOrNull,
              signed,
              reason: '$signed rendered as "$shown" in ${language.name}',
            );
          }
        }
      }
    });

    test('a quantity with its unit label attached does not round trip', () {
      // Stated so nobody is surprised: the label is not part of the figure, and
      // the parser refuses text rather than guessing which suffix is a unit.
      expect(
        HisabParse.quantity(QuantityFormat.format(2500, unit: 'কেজি')).isFailure,
        isTrue,
      );
    });
  });
}
