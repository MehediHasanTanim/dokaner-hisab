// Digit scripts and group widths. The two lowest-level decisions in the whole
// number layer, made here once so that money and quantity cannot disagree.
//
// Nothing in this file knows about taka, paisa, kilograms or milli-units. It
// takes a run of digit characters and returns a run of digit characters.
//
// WHY THIS IS HAND-WRITTEN. `intl` can produce Indian grouping from locale
// data, and it is already in the lockfile for dates. It is deliberately not
// used here: the acceptance criterion names the exact output — ৳১,০৮,৫০০, never
// ৳১০৮,৫০০ — and locale data is a moving target between package versions. A
// twenty-line rule that is asserted directly is worth more than a dependency
// whose behaviour can change under a `pub upgrade`.

import 'language.dart';

/// The ten Bangla digits, in value order, so that index == value.
const String kBanglaDigits = '০১২৩৪৫৬৭৮৯';

/// The ten Western digits, in value order.
const String kWesternDigits = '0123456789';

/// The group separator, in both languages.
///
/// Only the digits and the group *widths* change between languages; the comma
/// and the decimal point are the same characters the owner already writes in a
/// khata and the same ones a keypad produces.
const String kGroupSeparator = ',';

/// The decimal separator, in both languages.
const String kDecimalSeparator = '.';

/// The minus sign for a displayed figure: U+2212 MINUS SIGN, not the ASCII
/// hyphen. It is the width of a digit in a tabular face, so a column of figures
/// with negatives in it still lines up.
const String kMinusSign = '−';

/// The plus sign, for the surfaces that state a direction explicitly.
const String kPlusSign = '+';

/// Code unit of Bangla ০ (U+09E6). The ten digits are contiguous from here.
const int _banglaZero = 0x09E6;

/// Code unit of Western 0.
const int _westernZero = 0x0030;

/// Bangla and Western digit scripts, and the rules that separate them.
abstract final class HisabDigits {
  /// Rewrites every Western digit in [text] into the script of [language].
  /// Every other character — comma, point, sign, currency mark, unit label —
  /// is passed through untouched.
  static String toScript(String text, HisabLanguage language) {
    if (language.isEnglish) {
      return text;
    }
    final StringBuffer out = StringBuffer();
    for (final int unit in text.codeUnits) {
      final int value = unit - _westernZero;
      out.writeCharCode(
        value >= 0 && value <= 9 ? _banglaZero + value : unit,
      );
    }
    return out.toString();
  }

  /// Rewrites every Bangla digit in [text] into Western digits, leaving
  /// everything else alone. This is the normalisation the parser runs first:
  /// the keypad belongs to the device, so either script — or a mix — arrives.
  static String toWestern(String text) {
    final StringBuffer out = StringBuffer();
    for (final int unit in text.codeUnits) {
      final int value = unit - _banglaZero;
      out.writeCharCode(
        value >= 0 && value <= 9 ? _westernZero + value : unit,
      );
    }
    return out.toString();
  }

  /// The numeric value of a single digit character in either script, or null if
  /// [codeUnit] is not a digit.
  static int? valueOf(int codeUnit) {
    final int western = codeUnit - _westernZero;
    if (western >= 0 && western <= 9) {
      return western;
    }
    final int bangla = codeUnit - _banglaZero;
    if (bangla >= 0 && bangla <= 9) {
      return bangla;
    }
    return null;
  }

  /// True when [character] is a digit in either script.
  static bool isDigit(String character) =>
      character.length == 1 && valueOf(character.codeUnitAt(0)) != null;

  /// Groups a run of Western digits the way [language] reads them.
  ///
  /// Bangla: lakh grouping. Take the digits right to left; the first group is
  /// three, every group after it is two. 108500 → `1,08,500`.
  ///
  /// English: threes all the way. 108500 → `108,500`.
  ///
  /// [digits] must already be plain Western digits with no sign, separator or
  /// decimal part — callers split those off first.
  static String group(String digits, HisabLanguage language) =>
      language.isBangla ? groupLakh(digits) : groupWestern(digits);

  /// Lakh grouping: last three, then twos. This is the rule the acceptance
  /// criterion names, stated once, in one place.
  static String groupLakh(String digits) {
    if (digits.length <= 3) {
      return digits;
    }
    final String tail = digits.substring(digits.length - 3);
    final String head = digits.substring(0, digits.length - 3);

    final List<String> groups = <String>[];
    int end = head.length;
    while (end > 2) {
      groups.insert(0, head.substring(end - 2, end));
      end -= 2;
    }
    // What is left is one or two digits — the leading group.
    groups.insert(0, head.substring(0, end));

    return '${groups.join(kGroupSeparator)}$kGroupSeparator$tail';
  }

  /// Western grouping: threes from the right. 999999999 → `999,999,999`.
  static String groupWestern(String digits) {
    if (digits.length <= 3) {
      return digits;
    }
    final List<String> groups = <String>[];
    int end = digits.length;
    while (end > 3) {
      groups.insert(0, digits.substring(end - 3, end));
      end -= 3;
    }
    groups.insert(0, digits.substring(0, end));
    return groups.join(kGroupSeparator);
  }
}

/// A stored integer split into a whole part and a fraction, as digit strings.
///
/// Money is paisa (two fraction digits) and quantity is milli-units (three), so
/// both arrive here as an integer plus the scale it is stored at.
///
/// The split is done on the *decimal text* of the integer rather than with `~/`
/// and `%` on its absolute value. That is not fussiness: `abs()` on the most
/// negative int is still negative on a 64-bit VM, and a digit slice has no such
/// edge. It also keeps the largest values exact — 999999999999 paisa groups
/// past a crore with no overflow and no scientific notation, because no
/// arithmetic happens at all.
class ScaledDigits {
  const ScaledDigits._(this.isNegative, this.whole, this.fraction);

  /// Splits [value], stored with [fractionDigits] digits of scale.
  factory ScaledDigits.of(int value, int fractionDigits) {
    final String raw = value.toString();
    final bool isNegative = raw.startsWith('-');
    // Pad so there is always a whole digit left after the fraction is taken:
    // 50 paisa → "050" → 0 taka and 50 paisa.
    final String digits = (isNegative ? raw.substring(1) : raw).padLeft(
      fractionDigits + 1,
      '0',
    );
    final int cut = digits.length - fractionDigits;
    return ScaledDigits._(
      isNegative,
      _stripLeadingZeros(digits.substring(0, cut)),
      digits.substring(cut),
    );
  }

  final bool isNegative;

  /// Western digits, ungrouped, never empty — `0` for a value below one unit.
  final String whole;

  /// Exactly `fractionDigits` Western digits, leading zeros intact.
  final String fraction;

  /// True when every fraction digit is zero, which is what decides whether the
  /// fraction is shown at all.
  bool get hasFraction => fraction.codeUnits.any((int u) => u != 0x30);

  /// The fraction with trailing zeros removed — `500` → `5`, `530` → `53`.
  /// Empty when there is no fraction to show.
  String get trimmedFraction {
    int end = fraction.length;
    while (end > 0 && fraction.codeUnitAt(end - 1) == 0x30) {
      end--;
    }
    return fraction.substring(0, end);
  }

  static String _stripLeadingZeros(String digits) {
    int i = 0;
    while (i < digits.length - 1 && digits.codeUnitAt(i) == 0x30) {
      i++;
    }
    return digits.substring(i);
  }
}
