// Text the owner typed, back to the stored integer.
//
// PARSING IS TOTAL. A parse failure is a normal outcome of a keypad, not an
// exception: nothing in this file throws on user input, so no form can crash on
// a stray keystroke. Every entry point returns a [ParseResult] the caller turns
// into a Bangla message from the error's code (AR-16: SCREAMING_SNAKE codes,
// Bangla text resolved client-side).
//
// The input is deliberately forgiving, because the keypad belongs to the
// device: Bangla digits, Western digits or a mix, in either language mode, with
// or without the currency mark, the group commas and surrounding spaces. What
// it will not do is guess. `10.999` taka is rejected rather than silently
// rounded — the owner sees what they typed, and a figure that quietly changed
// on its way into the database is how a ledger stops adding up.

import 'digits.dart';
import 'money.dart';
import 'quantity.dart';

/// Why a parse failed.
///
/// The `code` is the wire/lookup form (AR-16). The Bangla sentence for each
/// code belongs to the error-message catalogue, not here — this layer knows
/// nothing about strings the owner reads.
enum NumberParseError {
  /// Nothing was typed. Distinct from a typed zero, which is a valid figure.
  empty('NUMBER_EMPTY'),

  /// Something that is not a number: letters, two decimal points, two signs, a
  /// stray symbol.
  notANumber('NUMBER_NOT_A_NUMBER'),

  /// More decimal places than the value is stored to — `10.999` taka, when
  /// money holds two. Rejected rather than rounded.
  tooPrecise('NUMBER_TOO_PRECISE'),

  /// Too many digits to hold in the stored integer.
  tooLarge('NUMBER_TOO_LARGE');

  const NumberParseError(this.code);

  /// SCREAMING_SNAKE, resolved to Bangla by the caller.
  final String code;
}

/// The outcome of a parse: a value or a reason, never an exception.
sealed class ParseResult<T> {
  const ParseResult();

  bool get isSuccess;

  bool get isFailure => !isSuccess;

  /// The parsed value, or null when the parse failed.
  T? get valueOrNull;

  /// The reason, or null when the parse succeeded.
  NumberParseError? get errorOrNull;

  /// The parsed value, or [fallback] when the parse failed.
  T valueOr(T fallback) => valueOrNull ?? fallback;

  /// Collapses both cases into one value — the usual way a form turns this into
  /// either a figure or a message.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(NumberParseError error) onFailure,
  });
}

/// A value came back.
final class ParseSuccess<T> extends ParseResult<T> {
  const ParseSuccess(this.value);

  final T value;

  @override
  bool get isSuccess => true;

  @override
  T? get valueOrNull => value;

  @override
  NumberParseError? get errorOrNull => null;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(NumberParseError error) onFailure,
  }) => onSuccess(value);

  @override
  bool operator ==(Object other) =>
      other is ParseSuccess<T> && other.value == value;

  @override
  int get hashCode => Object.hash(ParseSuccess, value);

  @override
  String toString() => 'ParseSuccess($value)';
}

/// Nothing usable came back, and here is why.
final class ParseFailure<T> extends ParseResult<T> {
  const ParseFailure(this.error);

  final NumberParseError error;

  @override
  bool get isSuccess => false;

  @override
  T? get valueOrNull => null;

  @override
  NumberParseError? get errorOrNull => error;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(NumberParseError error) onFailure,
  }) => onFailure(error);

  @override
  bool operator ==(Object other) =>
      other is ParseFailure<T> && other.error == error;

  @override
  int get hashCode => Object.hash(ParseFailure, error);

  @override
  String toString() => 'ParseFailure(${error.code})';
}

/// Text → stored integer. The only number parser in the product.
abstract final class HisabParse {
  /// Characters that are noise around a figure and are simply dropped: the
  /// group separator, the currency mark, and every kind of space a keyboard or
  /// a copy-paste can introduce.
  static const Set<String> _ignored = <String>{
    kGroupSeparator,
    MoneyFormat.currencyMark,
    ' ',
    '\u00A0', // no-break space
    '\u2009', // thin space
    '\u202F', // narrow no-break space
    '\u200B', // zero-width space
    '\u200C', // zero-width non-joiner — Bangla keyboards emit these
    '\u200D', // zero-width joiner
    '\t',
  };

  static const Set<String> _minusSigns = <String>{'-', kMinusSign};

  /// Reads an amount of money and returns it in paisa.
  ///
  ///   `১,০৮,৫০০`     → 10850000
  ///   `108500.50`    → 10850050
  ///   `১08,৫00.5`    → 10850050   (a mixed-script keypad is still a keypad)
  ///   `৳ ১,০৮,৫০০ `  → 10850000
  ///   `10.999`       → failure, NUMBER_TOO_PRECISE
  static ParseResult<int> money(String text) =>
      _scaled(text, MoneyFormat.fractionDigits);

  /// Reads a quantity and returns it in milli-units.
  ///
  ///   `২.৫`   → 2500
  ///   `3`     → 3000
  ///   `0.25`  → 250
  static ParseResult<int> quantity(String text) =>
      _scaled(text, QuantityFormat.fractionDigits);

  /// The shared reader. Money and quantity differ only in how many fraction
  /// digits the stored integer holds.
  static ParseResult<int> _scaled(String text, int fractionDigits) {
    if (text.trim().isEmpty) {
      return const ParseFailure<int>(NumberParseError.empty);
    }

    final String normalised = HisabDigits.toWestern(text);

    final StringBuffer whole = StringBuffer();
    final StringBuffer fraction = StringBuffer();
    bool negative = false;
    bool sawSign = false;
    bool sawPoint = false;
    bool sawDigit = false;

    for (final int unit in normalised.codeUnits) {
      final String character = String.fromCharCode(unit);

      if (_ignored.contains(character)) {
        continue;
      }

      final int? digit = HisabDigits.valueOf(unit);
      if (digit != null) {
        sawDigit = true;
        (sawPoint ? fraction : whole).write(character);
        continue;
      }

      if (character == kDecimalSeparator) {
        // A second point is not a number: `১.২.৩` is a version string or a
        // slip, and either way guessing at it would be worse than refusing.
        if (sawPoint) {
          return const ParseFailure<int>(NumberParseError.notANumber);
        }
        sawPoint = true;
        continue;
      }

      if (_minusSigns.contains(character) || character == kPlusSign) {
        // A sign is only a sign in front of the figure, and only once: `--5`
        // and `5-` are both refused.
        if (sawSign || sawDigit || sawPoint) {
          return const ParseFailure<int>(NumberParseError.notANumber);
        }
        sawSign = true;
        negative = _minusSigns.contains(character);
        continue;
      }

      return const ParseFailure<int>(NumberParseError.notANumber);
    }

    if (!sawDigit) {
      // Something was typed, but no digit was in it: `৳`, `.`, `-`, `abc`.
      return const ParseFailure<int>(NumberParseError.notANumber);
    }

    String fractionDigitsTyped = fraction.toString();
    if (fractionDigitsTyped.length > fractionDigits) {
      final String excess = fractionDigitsTyped.substring(fractionDigits);
      // Extra places are only acceptable when they carry nothing: `10.500`
      // taka is ten fifty exactly, while `10.999` is a third place with a
      // value in it and rounding it away would change what the owner typed.
      if (excess.codeUnits.any((int u) => u != 0x30)) {
        return const ParseFailure<int>(NumberParseError.tooPrecise);
      }
      fractionDigitsTyped = fractionDigitsTyped.substring(0, fractionDigits);
    }

    final String digits =
        _stripLeadingZeros(whole.toString()) +
        fractionDigitsTyped.padRight(fractionDigits, '0');

    // The digits are concatenated rather than multiplied out, so a figure too
    // long to hold is a failed parse and never a silent overflow.
    final int? value = int.tryParse(digits);
    if (value == null) {
      return const ParseFailure<int>(NumberParseError.tooLarge);
    }

    return ParseSuccess<int>(negative ? -value : value);
  }

  static String _stripLeadingZeros(String digits) {
    int i = 0;
    while (i < digits.length && digits.codeUnitAt(i) == 0x30) {
      i++;
    }
    return digits.substring(i);
  }
}
