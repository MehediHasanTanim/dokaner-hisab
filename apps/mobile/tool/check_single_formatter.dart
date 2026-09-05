// Fails the build when a second number formatter appears.
//
//   dart run tool/check_single_formatter.dart
//
// The rule (UX-DR4, and the second acceptance criterion of Story 1.3): every
// surface that shows or reads a figure calls `lib/format/`. Screens, receipts,
// reports, CSV export, notifications and the AI draft parser all render the
// identical stored integer, and the moment a second implementation appears the
// two drift and a receipt disagrees with a screen. That drift is invisible in
// review — both call sites look reasonable on their own — so it is caught here.
//
// `lib/format/` is the one place these constructs are allowed, because that is
// where the formatter and the parser are. Everywhere else under `lib/` they are
// an error.
//
// This is a plain text scan, not an analyzer plugin, on purpose, and it is a
// separate file from `tool/check_theme_tokens.dart` rather than a merged
// "lint everything" tool: each check states one rule, and a contributor can
// read either one in a minute and know exactly what will fail before they push.

import 'dart:io';

/// Where the number layer lives — the one place a formatter may be written.
const List<String> kFormatAllowedPrefixes = <String>['lib/format/'];

/// Generated code is not hand-written and is not reviewed line by line.
const List<String> kGeneratedSuffixes = <String>[
  '.g.dart',
  '.freezed.dart',
  '.gr.dart',
];

class FormatterRule {
  const FormatterRule(this.pattern, this.what, this.instead);

  final RegExp pattern;

  /// What was found, in the report.
  final String what;

  /// What to write instead. A check that only says "no" costs more time than it
  /// saves, so every rule carries its own fix.
  final String instead;
}

final List<FormatterRule> kFormatterRules = <FormatterRule>[
  FormatterRule(
    RegExp(r'\bNumberFormat\b'),
    "intl's number formatter",
    'use MoneyFormat.format / QuantityFormat.format — the grouping rule is '
        'hand-written in lib/format/digits.dart because the acceptance '
        'criterion names the exact output, and locale data is a moving target. '
        'intl stays in the project for dates only',
  ),
  FormatterRule(
    RegExp(r'\btoStringAsFixed\('),
    'a number rendered by rounding a double',
    'money is integer paisa and quantity is integer milli-units — pass the '
        'stored integer to MoneyFormat.format or QuantityFormat.format, which '
        'never round a displayed figure',
  ),
  FormatterRule(
    RegExp(r'\btoStringAsPrecision\('),
    'a number rendered at a chosen precision',
    'pass the stored integer to MoneyFormat.format or QuantityFormat.format',
  ),
  FormatterRule(
    RegExp(r'\btoStringAsExponential\('),
    'a number in scientific notation',
    'a figure the owner reads is never in scientific notation — use '
        'MoneyFormat.format or QuantityFormat.format',
  ),
  FormatterRule(
    RegExp('৳'),
    'a hand-written currency mark',
    'use MoneyFormat.format, which puts the mark, the grouping, the digits '
        'and the sign in the one order every surface agrees on',
  ),
  FormatterRule(
    RegExp(r'\bintl\.DecimalFormat\b|\bcompactSimpleCurrency\b|'
        r'\bsimpleCurrencySymbol\b'),
    "an intl number API",
    'use MoneyFormat / QuantityFormat',
  ),
];

class FormatterViolation {
  FormatterViolation(this.path, this.line, this.column, this.rule, this.source);

  final String path;
  final int line;
  final int column;
  final FormatterRule rule;
  final String source;

  @override
  String toString() => '$path:$line:$column  ${rule.what}';
}

/// True when [relativePath] is exempt: it is the number layer itself, or it is
/// generated.
bool isExempt(String relativePath) =>
    kFormatAllowedPrefixes.any(relativePath.startsWith) ||
    kGeneratedSuffixes.any(relativePath.endsWith);

/// Scans one file's text. Exposed so that `test/format/single_source_test.dart`
/// can plant a violation and assert the check still catches it — a guard nobody
/// tests is a guard that quietly rots into a no-op.
List<FormatterViolation> scanSource({
  required String path,
  required String source,
}) {
  final List<FormatterViolation> violations = <FormatterViolation>[];
  if (isExempt(path)) {
    return violations;
  }
  final List<String> lines = source.split('\n');
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    // A rule named in a comment is documentation, not a violation.
    if (line.trimLeft().startsWith('//')) {
      continue;
    }
    for (final FormatterRule rule in kFormatterRules) {
      for (final RegExpMatch match in rule.pattern.allMatches(line)) {
        violations.add(
          FormatterViolation(path, i + 1, match.start + 1, rule, line.trim()),
        );
      }
    }
  }
  return violations;
}

/// Scans every `.dart` file under [directory], reporting paths relative to
/// [rootPath].
List<FormatterViolation> scanDirectory(
  Directory directory, {
  required String rootPath,
}) {
  final List<File> files =
      directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));

  final List<FormatterViolation> violations = <FormatterViolation>[];
  for (final File file in files) {
    violations.addAll(
      scanSource(
        path: relativePath(file.path, rootPath),
        source: file.readAsStringSync(),
      ),
    );
  }
  return violations;
}

void main() {
  final Directory root = appRoot();
  final Directory lib = Directory('${root.path}/lib');

  if (!lib.existsSync()) {
    stderr.writeln(
      'check_single_formatter: no lib/ directory under ${root.path}',
    );
    exit(2);
  }

  final int scanned = lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .where((File f) => !isExempt(relativePath(f.path, root.path)))
      .length;

  final List<FormatterViolation> violations = scanDirectory(
    lib,
    rootPath: root.path,
  );

  if (violations.isEmpty) {
    stdout.writeln(
      'check_single_formatter: $scanned file(s) scanned, one formatter and one '
      'parser, both in ${kFormatAllowedPrefixes.join(", ")}',
    );
    exit(0);
  }

  stderr.writeln(
    'check_single_formatter: ${violations.length} number(s) formatted outside '
    'the format layer.\n'
    'Every surface renders the identical stored value through lib/format/ '
    '(UX-DR4); a second implementation is how a receipt comes to disagree with '
    'a screen.\n',
  );
  for (final FormatterViolation v in violations) {
    stderr.writeln('${v.path}:${v.line}:${v.column}  ${v.rule.what}');
    stderr.writeln('    ${v.source}');
    stderr.writeln('    -> ${v.rule.instead}\n');
  }
  exit(1);
}

/// The app root, so the check works from anywhere: `dart run tool/...` inside
/// apps/mobile, or from the repository root in CI.
Directory appRoot() {
  final Directory fromScript = File.fromUri(
    Platform.script,
  ).parent.parent.absolute;
  if (Directory('${fromScript.path}/lib').existsSync()) {
    return fromScript;
  }
  return Directory.current.absolute;
}

String relativePath(String path, String rootPath) {
  final String normalisedRoot = rootPath.endsWith(Platform.pathSeparator)
      ? rootPath
      : '$rootPath${Platform.pathSeparator}';
  final String relative = path.startsWith(normalisedRoot)
      ? path.substring(normalisedRoot.length)
      : path;
  return relative.replaceAll(Platform.pathSeparator, '/');
}
