// Quantity, from the stored integer to the string the owner reads.
//
// Quantity crosses this boundary as integer milli-units and nothing else
// (AR-2): 2500 milli is two and a half kilograms, 1000 milli is one piece.
// Three digits of scale exist so that a shopkeeper can sell 250 grams of rice
// without the stock count drifting; they are not there to be displayed.
//
// Quantity is NOT money. It never carries the currency mark, it is not stored
// at the same scale, and a quantity formatted by the money formatter would be
// wrong twice over. The two live in separate files for that reason.

import 'digits.dart';
import 'language.dart';

/// Formats stored milli-units. The only quantity formatter in the product.
abstract final class QuantityFormat {
  /// How many milli-units make one whole unit.
  static const int milliPerUnit = 1000;

  /// The scale quantity is stored at.
  static const int fractionDigits = 3;

  /// Renders [milli] the way [language] reads it, with an optional [unit]
  /// label after a single space.
  ///
  ///   2500, 'কেজি' → ২.৫ কেজি
  ///   3000         → ৩            (a whole quantity, not ৩.০)
  ///   2503         → ২.৫০৩
  ///   250          → ০.২৫
  ///   0            → ০
  ///
  /// Trailing zeros in the fraction are trimmed: five hundred grams is ০.৫, not
  /// ০.৫০০. A quantity is written the way it is spoken.
  static String format(
    int milli, {
    HisabLanguage language = HisabLanguage.fallback,
    String? unit,
  }) {
    final ScaledDigits split = ScaledDigits.of(milli, fractionDigits);

    final StringBuffer out = StringBuffer();
    if (split.isNegative) {
      out.write(kMinusSign);
    }
    out.write(HisabDigits.group(split.whole, language));
    final String fraction = split.trimmedFraction;
    if (fraction.isNotEmpty) {
      out.write(kDecimalSeparator);
      out.write(fraction);
    }

    final String number = HisabDigits.toScript(out.toString(), language);
    if (unit == null || unit.isEmpty) {
      return number;
    }
    // One space, and the unit label as the caller gave it — unit names come
    // from the owner's own product records and are never translated here.
    return '$number $unit';
  }

  /// The machine-readable form: Western digits, no grouping, a `.` decimal and
  /// an ASCII `-` for negatives, with no unit label — `2.5`, `3`, `-0.25`.
  ///
  /// Trailing zeros stay trimmed here too. A quantity column has no fixed
  /// scale to line up (unlike a money column, where every row shows both paisa
  /// digits), and a spreadsheet reads `2.5` and `2.500` as the same number.
  static String export(int milli) {
    final ScaledDigits split = ScaledDigits.of(milli, fractionDigits);
    final String fraction = split.trimmedFraction;
    return '${split.isNegative ? '-' : ''}${split.whole}'
        '${fraction.isEmpty ? '' : '$kDecimalSeparator$fraction'}';
  }
}
