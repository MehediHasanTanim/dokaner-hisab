// What six digits are, and which six digits are refused.
//
// The rule lives here rather than inside a form validator for three reasons:
// it is the same rule on the set-PIN screen and on any later change-PIN
// screen; it is the one part of this story that can be exhaustively tested
// without a keystore, a widget or a clock; and the *reason* a PIN is refused
// has to reach the owner in Bangla, so the reason is part of the rule rather
// than something the screen invents.
//
// This file holds no secret and touches no storage. It never sees a stored
// PIN — only the digits an owner just typed, which are already in memory.
//
// Digits arrive normalised through `lib/format/`: the keypad in this app emits
// Western digits, but a device keyboard in Bangla mode emits ০-৯, and UX-DR4
// is explicit that either script — or a mix — is accepted anywhere a number is
// typed. Normalising here means the stored hash is over one canonical form, so
// the same PIN typed on two keyboards is the same PIN.

import '../format/format.dart';

/// Six. Stated once; every other file asks for it here.
const int kPinLength = 6;

/// Why a PIN was refused.
///
/// An enum rather than a string so the rule is testable by identity and the
/// wording can change without touching a test. Each carries the sentence the
/// owner reads — there is no English-only surface in this product, and a
/// refusal with no stated reason is the most frustrating screen a shop owner
/// can meet on their first minute in the app.
enum PinWeakness {
  /// Not six digits.
  wrongLength,

  /// Something that is not a digit in either script.
  notDigits,

  /// 111111, 000000 — one digit repeated.
  sameDigitRepeated,

  /// 123456, 654321 — a run of consecutive digits, in either direction.
  consecutiveRun,

  /// On the short list of PINs an attacker tries first.
  commonlyGuessed;

  /// The reason, in the owner's words.
  String get reason => switch (this) {
    PinWeakness.wrongLength => 'পিন ছয় সংখ্যার হতে হবে।',
    PinWeakness.notDigits => 'পিনে শুধু সংখ্যা থাকবে।',
    PinWeakness.sameDigitRepeated =>
      'একই সংখ্যা ছয়বার — এটা অন্য কেউ প্রথম চেষ্টাতেই ধরে ফেলবে।',
    PinWeakness.consecutiveRun =>
      'পরপর সাজানো সংখ্যা সহজেই ধরা যায়। এলোমেলো ছয়টি সংখ্যা দিন।',
    PinWeakness.commonlyGuessed =>
      'এই পিনটি খুব পরিচিত — অন্য কেউ প্রথমেই এটা চেষ্টা করবে।',
  };
}

/// The six-digit rule.
abstract final class PinPolicy {
  /// The only length this product accepts.
  static const int length = kPinLength;

  /// PINs that the shape rules above do not catch but that appear at the top
  /// of every published leak of six-digit PINs: repeated pairs, repeated
  /// triples, keypad columns and rows, and mirrored runs.
  ///
  /// Deliberately short. A long blocklist starts refusing PINs an owner chose
  /// for a reason they can remember, and the honest defence against guessing
  /// is the growing delay in `lockout.dart`, not a bigger list here. Runs and
  /// repeated single digits are absent from this set because the shape rules
  /// already refuse them, with a more useful reason.
  static const Set<String> commonlyGuessed = <String>{
    '123123',
    '121212',
    '112233',
    '123321',
    '789456',
    '159753',
    '147258',
    '258369',
    '102030',
    '101010',
    '131313',
    '212121',
    '696969',
    '007007',
    '123654',
    '456123',
    '110110',
    '100100',
    '111222',
    '123000',
    '786786',
    '142536',
  };

  /// The canonical form of what the owner typed: Western digits, no spaces.
  ///
  /// Everything downstream — the weakness check, the hash, the comparison —
  /// works on this form and nothing else.
  static String normalise(String entered) =>
      HisabDigits.toWestern(entered).replaceAll(RegExp(r'\s'), '');

  /// Why [entered] is refused, or null when it is acceptable.
  static PinWeakness? inspect(String entered) {
    final String pin = normalise(entered);

    if (pin.length != length) {
      return PinWeakness.wrongLength;
    }
    for (final int unit in pin.codeUnits) {
      if (unit < 0x30 || unit > 0x39) {
        return PinWeakness.notDigits;
      }
    }

    if (_isOneDigitRepeated(pin)) {
      return PinWeakness.sameDigitRepeated;
    }
    if (_isConsecutiveRun(pin)) {
      return PinWeakness.consecutiveRun;
    }
    if (commonlyGuessed.contains(pin)) {
      return PinWeakness.commonlyGuessed;
    }
    return null;
  }

  /// True when [entered] may be used as a PIN.
  static bool accepts(String entered) => inspect(entered) == null;

  static bool _isOneDigitRepeated(String pin) {
    for (int i = 1; i < pin.length; i++) {
      if (pin.codeUnitAt(i) != pin.codeUnitAt(0)) {
        return false;
      }
    }
    return true;
  }

  /// Ascending or descending by one, the whole way: 123456, 654321, 456789.
  static bool _isConsecutiveRun(String pin) {
    bool ascending = true;
    bool descending = true;
    for (int i = 1; i < pin.length; i++) {
      final int step = pin.codeUnitAt(i) - pin.codeUnitAt(i - 1);
      if (step != 1) {
        ascending = false;
      }
      if (step != -1) {
        descending = false;
      }
    }
    return ascending || descending;
  }
}
