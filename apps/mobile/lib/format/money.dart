// Money, from the stored integer to the string the owner reads.
//
// Money crosses this boundary as integer paisa and nothing else (AR-1). There
// is no `double` anywhere in this file: not as a parameter, not as an
// intermediate, not as a return. Every figure is produced by slicing the digits
// of the stored integer, so a column of amounts on a screen and the total under
// it are arithmetic on the same integers and cannot disagree by a rounding step.
//
// THE ONE DEFECT THIS PRODUCT CANNOT SHIP is a column that does not sum to its
// total. That is why nothing here rounds a displayed figure — paisa are either
// hidden (because they are exactly zero) or shown in full.

import 'digits.dart';
import 'language.dart';

/// Whether a figure states its direction with a sign.
enum MoneySign {
  /// A minus on negatives, nothing on zero or a positive. The default: a
  /// balance is just a number.
  negativeOnly,

  /// A plus on positives and a minus on negatives — for surfaces where the
  /// figure has a direction, like a movement in a ledger. Zero takes no sign,
  /// because zero has no direction.
  always,

  /// No sign at all, for a figure whose direction is carried by its column, its
  /// colour or the word beside it. The magnitude only.
  never,
}

/// Formats stored paisa. The only money formatter in the product.
abstract final class MoneyFormat {
  /// The currency mark, U+09F3 BENGALI RUPEE SIGN. Currency is ৳ BDT and is not
  /// editable in the MVP, so it is a constant rather than a setting.
  static const String currencyMark = '৳';

  /// How many paisa make one taka.
  static const int paisaPerTaka = 100;

  /// The scale money is stored at.
  static const int fractionDigits = 2;

  /// Renders [paisa] the way [language] reads it.
  ///
  ///   10850000, Bangla  → ৳১,০৮,৫০০
  ///   10850000, English → ৳108,500
  ///   10850050, Bangla  → ৳১,০৮,৫০০.৫০
  ///   50,       Bangla  → ৳০.৫০
  ///   0,        Bangla  → ৳০          (never blank — a deliberate zero is not
  ///                                    an unanswered field)
  ///   -10850000         → −৳১,০৮,৫০০  (U+2212, sign before the currency mark)
  ///
  /// Paisa are hidden when they are zero and shown as exactly two digits when
  /// they are not. That rule lives here and nowhere else.
  static String format(
    int paisa, {
    HisabLanguage language = HisabLanguage.fallback,
    MoneySign sign = MoneySign.negativeOnly,
    bool withCurrency = true,
  }) {
    final ScaledDigits split = ScaledDigits.of(paisa, fractionDigits);

    final StringBuffer out = StringBuffer();
    out.write(_signPrefix(split.isNegative, paisa, sign));
    if (withCurrency) {
      out.write(currencyMark);
    }
    out.write(HisabDigits.group(split.whole, language));
    if (split.hasFraction) {
      out.write(kDecimalSeparator);
      out.write(split.fraction);
    }

    return HisabDigits.toScript(out.toString(), language);
  }

  /// The magnitude with its direction stripped, for a surface that carries the
  /// direction some other way — a column heading, or the word জমা or খরচ beside
  /// it. Colour is never the only carrier of meaning, and neither is a sign.
  static String formatAbsolute(
    int paisa, {
    HisabLanguage language = HisabLanguage.fallback,
    bool withCurrency = true,
  }) => format(
    paisa,
    language: language,
    sign: MoneySign.never,
    withCurrency: withCurrency,
  );

  /// The machine-readable form: Western digits, no grouping, a `.` decimal and
  /// an ASCII `-` for negatives — `108500.50`, `-108500.50` — in every language.
  ///
  /// This is what goes into a CSV export, a request body, a log line, or
  /// anything else read by software rather than by the owner. A CSV carrying
  /// Bangla digits and lakh commas is unopenable in the spreadsheet the owner's
  /// accountant uses, and U+2212 is not a minus sign to a spreadsheet either.
  ///
  /// Unlike the display form this always writes both paisa digits, so every row
  /// of an exported column has the same shape.
  static String export(int paisa) {
    final ScaledDigits split = ScaledDigits.of(paisa, fractionDigits);
    return '${split.isNegative ? '-' : ''}'
        '${split.whole}$kDecimalSeparator${split.fraction}';
  }

  static String _signPrefix(bool isNegative, int paisa, MoneySign sign) =>
      switch (sign) {
        MoneySign.never => '',
        MoneySign.negativeOnly => isNegative ? kMinusSign : '',
        MoneySign.always => isNegative
            ? kMinusSign
            : (paisa > 0 ? kPlusSign : ''),
      };
}
