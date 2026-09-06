// Every row of the story's weak-PIN case, and the ordinary case that must pass.
//
// The policy is the one part of this story that can be asserted exhaustively
// with no keystore, no clock and no widget — so it is, including the reason the
// owner is shown, because a refusal with no reason is a screen a shop owner
// cannot get past.

import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/auth/pin_policy.dart';

void main() {
  group('length and shape', () {
    test('six is the only length', () {
      expect(PinPolicy.length, 6);
      expect(PinPolicy.inspect('48291'), PinWeakness.wrongLength);
      expect(PinPolicy.inspect('4829137'), PinWeakness.wrongLength);
      expect(PinPolicy.inspect(''), PinWeakness.wrongLength);
    });

    test('anything that is not a digit is refused', () {
      expect(PinPolicy.inspect('4829a7'), PinWeakness.notDigits);
      expect(PinPolicy.inspect('48-291'), PinWeakness.notDigits);
    });

    test('Bangla digits are the same PIN as Western digits', () {
      // UX-DR4: either script, or a mix, in either language mode.
      expect(PinPolicy.normalise('৪৮২৯১৩'), '482913');
      expect(PinPolicy.normalise('৪৮২9১3'), '482913');
      expect(PinPolicy.accepts('৪৮২৯১৩'), isTrue);
      expect(PinPolicy.inspect('১১১১১১'), PinWeakness.sameDigitRepeated);
    });
  });

  group('the weak PINs the story names', () {
    test('one digit six times', () {
      for (final String pin in <String>[
        '111111',
        '000000',
        '999999',
        '777777',
      ]) {
        expect(
          PinPolicy.inspect(pin),
          PinWeakness.sameDigitRepeated,
          reason: '$pin is guessed first, every time',
        );
      }
    });

    test('a run, ascending or descending', () {
      for (final String pin in <String>[
        '123456',
        '654321',
        '456789',
        '987654',
        '012345',
      ]) {
        expect(PinPolicy.inspect(pin), PinWeakness.consecutiveRun, reason: pin);
      }
    });

    test('the common list', () {
      for (final String pin in PinPolicy.commonlyGuessed) {
        expect(
          PinPolicy.accepts(pin),
          isFalse,
          reason: '$pin is on the list of PINs tried first',
        );
      }
      expect(PinPolicy.inspect('123123'), PinWeakness.commonlyGuessed);
      expect(PinPolicy.inspect('786786'), PinWeakness.commonlyGuessed);
    });

    test('the shape rules are not duplicated in the list', () {
      // The list exists for what the rules cannot catch. A run or a repeat in
      // it would be dead weight, and would report the less useful reason.
      for (final String pin in PinPolicy.commonlyGuessed) {
        expect(
          PinPolicy.inspect(pin),
          PinWeakness.commonlyGuessed,
          reason: '$pin is already refused by a shape rule; drop it',
        );
      }
    });
  });

  group('ordinary six digits pass', () {
    test('a PIN a shop owner would actually choose', () {
      for (final String pin in <String>[
        '482913',
        '730264',
        '195028',
        '604817',
        '283746',
        // Two of the same digit, just not all six.
        '448291',
        // Part of a run, but not the whole thing.
        '123479',
      ]) {
        expect(
          PinPolicy.inspect(pin),
          isNull,
          reason: 'refusing $pin would be refusing a reasonable PIN',
        );
        expect(PinPolicy.accepts(pin), isTrue);
      }
    });
  });

  group('every refusal states its reason, in Bangla', () {
    test('no weakness has an empty or Latin-script reason', () {
      for (final PinWeakness weakness in PinWeakness.values) {
        expect(weakness.reason, isNotEmpty);
        expect(
          RegExp(r'[A-Za-z]').hasMatch(weakness.reason),
          isFalse,
          reason: 'an untranslated user-facing string is a defect (NFR-20)',
        );
      }
    });
  });
}
