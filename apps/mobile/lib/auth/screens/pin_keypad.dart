// The keypad, and the six dots above it. Shared by both PIN screens.
//
// One keypad, not two: the digits an owner taps to choose a PIN and the digits
// they tap to unlock have to feel identical, and two copies of a keypad drift
// the way two copies of anything drift.
//
// The app draws its own keypad rather than raising the system keyboard for
// three reasons: the keys can be made big enough to hit one-handed at a counter
// (`HisabMetrics.buttonHeight`, above the 48dp floor of UX-DR21), the digits on
// them are Bangla because the owner reads Bangla (UX-DR4), and a system
// keyboard's own suggestion strip has no business near a PIN.
//
// The label on a key is Bangla; the value behind it is Western. That conversion
// happens through `lib/format/` and nowhere else — there is one digit script
// rule in this product and it lives there.

import 'package:flutter/material.dart';

import '../../format/format.dart';
import '../../theme/hisab_theme.dart';
import '../../theme/tokens.dart';
import '../pin_policy.dart';

/// The rows of the keypad. The empty string is the blank key beside zero.
const List<List<String>> kKeypadRows = <List<String>>[
  <String>['1', '2', '3'],
  <String>['4', '5', '6'],
  <String>['7', '8', '9'],
  <String>['', '0', kBackspaceKey],
];

/// The key that removes the last digit.
const String kBackspaceKey = 'backspace';

/// How far the entry has got: one dot per digit, filled left to right.
///
/// Dots, not the digits themselves: someone standing beside the owner at a
/// counter can read six large digits from a metre away.
class PinDots extends StatelessWidget {
  const PinDots({
    required this.filled,
    required this.language,
    this.length = kPinLength,
    super.key,
  });

  final int filled;

  /// The script the spoken count is read in. Even a count only a screen reader
  /// hears goes through `lib/format/` — there is no second digit rule.
  final HisabLanguage language;

  final int length;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // The count is spoken, because the dots themselves say nothing to a
      // screen reader (UX-DR23).
      label:
          'পিনের ${HisabDigits.toScript(filled.toString(), language)} সংখ্যা '
          'দেওয়া হয়েছে',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (int i = 0; i < length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HisabSpacing.s2,
              ),
              child: _Dot(filled: i < filled),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled});

  final bool filled;

  /// A dot is a small thing; these two numbers are its only geometry and they
  /// are not part of any token group in DESIGN.md.
  static const double _size = HisabSpacing.s3;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? HisabColors.ink : HisabColors.paperSunk,
        border: Border.all(
          color: filled ? HisabColors.ink : HisabColors.rule,
          width: HisabMetrics.ruleWidth,
        ),
      ),
    );
  }
}

/// The ten digits and a backspace.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    required this.language,
    required this.onDigit,
    required this.onBackspace,
    this.enabled = true,
    super.key,
  });

  /// The script the key labels are drawn in. The value passed to [onDigit] is
  /// always a Western digit, whatever the label says.
  final HisabLanguage language;

  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;

  /// False while a wait is running. The keys grey out rather than disappearing,
  /// so the keypad does not move under the owner's thumb.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final List<String> row in kKeypadRows)
          Padding(
            padding: const EdgeInsets.only(bottom: HisabSpacing.s2),
            child: Row(
              children: <Widget>[
                for (final String key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: HisabSpacing.s1,
                      ),
                      child: _Key(
                        value: key,
                        language: language,
                        enabled: enabled,
                        onDigit: onDigit,
                        onBackspace: onBackspace,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.value,
    required this.language,
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
  });

  final String value;
  final HisabLanguage language;
  final bool enabled;
  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      // The blank beside zero. It keeps the grid square without being a target.
      return const SizedBox(height: HisabMetrics.buttonHeight);
    }

    if (value == kBackspaceKey) {
      return Semantics(
        button: true,
        label: 'শেষ সংখ্যাটি মুছুন',
        child: TextButton(
          onPressed: enabled ? onBackspace : null,
          child: const Icon(Icons.backspace_outlined),
        ),
      );
    }

    return TextButton(
      onPressed: enabled ? () => onDigit(value) : null,
      child: Text(
        HisabDigits.toScript(value, language),
        style: HisabTextStyles.amountMd,
      ),
    );
  }
}
