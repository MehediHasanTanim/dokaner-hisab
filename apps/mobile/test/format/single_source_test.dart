// Asserts that the "no second formatter" guard actually catches things.
//
// A build check nobody tests is a check that quietly rots into a no-op: a
// regex is loosened to silence a false positive, or a path exemption grows,
// and six months later the check passes on a file full of hand-written ৳. So
// this test plants a violation of every rule and asserts each one is reported,
// and then runs the real scan over the real lib/ so the guard's own verdict is
// part of the test suite rather than only part of CI.
//
// The tool is imported by path because it lives in tool/, not lib/ — it is a
// build check, not shipped code, and it has no business being importable by the
// app.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_single_formatter.dart'
    show
        FormatterRule,
        FormatterViolation,
        isExempt,
        kFormatterRules,
        scanDirectory,
        scanSource;

/// A path outside the format layer, so nothing is exempt.
const String kWidgetPath = 'lib/home/home_screen.dart';

List<FormatterViolation> _scan(String source) =>
    scanSource(path: kWidgetPath, source: source);

void main() {
  group('the check catches a planted violation', () {
    test("intl's NumberFormat", () {
      final List<FormatterViolation> found = _scan(
        "final f = NumberFormat.decimalPattern('bn');",
      );
      expect(found, hasLength(1));
      expect(found.single.line, 1);
      expect(found.single.rule.instead, contains('MoneyFormat'));
    });

    test('toStringAsFixed on a double', () {
      expect(_scan('final s = (paisa / 100).toStringAsFixed(2);'), hasLength(1));
    });

    test('toStringAsPrecision and toStringAsExponential', () {
      expect(_scan('final s = x.toStringAsPrecision(3);'), hasLength(1));
      expect(_scan('final s = x.toStringAsExponential(3);'), hasLength(1));
    });

    test('a hand-written currency mark', () {
      final List<FormatterViolation> found = _scan(
        r"Text('৳' + amount.toString());",
      );
      expect(found, isNotEmpty);
      expect(
        found.first.rule.what,
        contains('currency mark'),
        reason: 'the report has to say what was found',
      );
    });

    test('every rule in the list is reachable', () {
      // If a rule can never fire, it is decoration. Each one is given a line
      // that should trip it.
      const Map<String, String> samples = <String, String>{
        "intl's number formatter": 'final f = NumberFormat();',
        'a number rendered by rounding a double':
            'final s = v.toStringAsFixed(2);',
        'a number rendered at a chosen precision':
            'final s = v.toStringAsPrecision(2);',
        'a number in scientific notation':
            'final s = v.toStringAsExponential(2);',
        'a hand-written currency mark': "const mark = '৳';",
        'an intl number API': 'final s = compactSimpleCurrency();',
      };
      for (final FormatterRule rule in kFormatterRules) {
        final String? sample = samples[rule.what];
        expect(
          sample,
          isNotNull,
          reason: 'rule "${rule.what}" has no sample in this test — add one',
        );
        expect(
          rule.pattern.hasMatch(sample!),
          isTrue,
          reason: 'rule "${rule.what}" did not match its own sample',
        );
      }
    });

    test('the report names the file, the line and the column', () {
      final List<FormatterViolation> found = scanSource(
        path: kWidgetPath,
        source: 'line one\nline two\n  final s = x.toStringAsFixed(2);\n',
      );
      expect(found, hasLength(1));
      final FormatterViolation v = found.single;
      expect(v.path, kWidgetPath);
      expect(v.line, 3, reason: 'lines are 1-indexed');
      expect(v.column, greaterThan(1));
      expect(v.source, 'final s = x.toStringAsFixed(2);');
      expect(v.rule.instead, isNotEmpty, reason: 'every rule carries its fix');
    });
  });

  group('the check does not cry wolf', () {
    test('the format layer itself is exempt', () {
      expect(
        scanSource(
          path: 'lib/format/money.dart',
          source: "static const String currencyMark = '৳';",
        ),
        isEmpty,
        reason: 'lib/format/ is where the one implementation lives',
      );
      expect(isExempt('lib/format/parse.dart'), isTrue);
      expect(isExempt('lib/theme/theme_preview.dart'), isFalse);
    });

    test('generated code is exempt', () {
      expect(isExempt('lib/data/models.g.dart'), isTrue);
      expect(isExempt('lib/data/models.freezed.dart'), isTrue);
    });

    test('a rule named in a comment is documentation, not a violation', () {
      expect(
        _scan('// never write ৳ by hand — use MoneyFormat.format'),
        isEmpty,
      );
      expect(_scan('/// toStringAsFixed(2) is not how money is rendered'), isEmpty);
    });

    test('ordinary code is not flagged', () {
      expect(
        _scan(
          'Text(MoneyFormat.format(paisa, language: language));\n'
          'final int total = a + b;\n'
          "const String unit = 'কেজি';",
        ),
        isEmpty,
      );
    });
  });

  group('the real source tree passes', () {
    test('no number is formatted outside lib/format/', () {
      // `flutter test` runs from the package root, so lib/ is right here. This
      // is the same verdict CI gets from `dart run tool/check_single_formatter.dart`,
      // asserted where a developer sees it before pushing.
      final Directory lib = Directory('lib');
      expect(
        lib.existsSync(),
        isTrue,
        reason: 'expected to run from apps/mobile',
      );

      final List<FormatterViolation> violations = scanDirectory(
        lib,
        rootPath: Directory.current.path,
      );
      expect(
        violations.map((FormatterViolation v) => v.toString()).toList(),
        isEmpty,
        reason:
            'every surface renders the identical stored value through '
            'lib/format/ (UX-DR4)',
      );
    });

    test('the format layer is where the currency mark lives', () {
      // The other half of the same rule: the mark has to exist somewhere, and
      // that somewhere is lib/format/money.dart.
      final String money = File('lib/format/money.dart').readAsStringSync();
      expect(money.contains('৳'), isTrue);
    });
  });
}
