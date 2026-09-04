// Fails the build when a widget writes a style literal instead of a token.
//
//   dart run tool/check_theme_tokens.dart
//
// The rule (UX-DR1 / UX-DR2, and the first acceptance criterion of Story 1.2):
// the theme is the ONLY source of colour, type, radius and spacing. A widget
// that writes `Color(0xFF...)` or `fontSize: 14` has forked the design system,
// and the fork is invisible until someone notices two greens on one screen.
//
// `lib/theme/` is the one place those literals are allowed, because that is
// where the tokens are defined. Everywhere else under `lib/` they are an error.
//
// This is a plain text scan, not an analyzer plugin, on purpose: it has no
// dependencies, runs in under a second, and a contributor can read it and know
// exactly what will fail before they push.

import 'dart:io';

/// Where the literals are allowed to live: the token and theme layer itself.
const List<String> kAllowedPrefixes = <String>['lib/theme/'];

/// Generated code is not hand-written and is not reviewed line by line.
const List<String> kGeneratedSuffixes = <String>[
  '.g.dart',
  '.freezed.dart',
  '.gr.dart',
];

class Rule {
  const Rule(this.pattern, this.what, this.instead);

  final RegExp pattern;

  /// What was found, in the report.
  final String what;

  /// What to write instead. A check that only says "no" costs more time than it
  /// saves, so every rule carries its own fix.
  final String instead;
}

final List<Rule> kRules = <Rule>[
  Rule(
    RegExp(r'Color\(0x'),
    'a literal colour',
    'use a token from HisabColors, or Theme.of(context).colorScheme',
  ),
  Rule(
    RegExp(r'\bColors\.'),
    "a colour from Material's palette",
    'use a token from HisabColors — the product has fifteen colours and no more',
  ),
  Rule(
    RegExp(r'\bfontSize\s*:'),
    'a literal font size',
    'use Theme.of(context).textTheme, or a named style from HisabTextStyles',
  ),
  Rule(
    RegExp(r'BorderRadius\.circular\('),
    'a literal radius',
    'use HisabRadii — sm, md, lg, sheet or chip',
  ),
  Rule(
    RegExp(r'\bRadius\.circular\('),
    'a literal radius',
    'use HisabRadii — sm, md, lg, sheet or chip',
  ),
];

class Violation {
  Violation(this.path, this.line, this.column, this.rule, this.source);

  final String path;
  final int line;
  final int column;
  final Rule rule;
  final String source;
}

void main() {
  final Directory root = _appRoot();
  final Directory lib = Directory('${root.path}/lib');

  if (!lib.existsSync()) {
    stderr.writeln('check_theme_tokens: no lib/ directory under ${root.path}');
    exit(2);
  }

  List<Violation> violations = <Violation>[];
  int scanned = 0;

  final List<File> files =
      lib
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));

  for (final File file in files) {
    final String relative = _relative(file.path, root.path);
    if (kAllowedPrefixes.any(relative.startsWith)) {
      continue;
    }
    if (kGeneratedSuffixes.any(relative.endsWith)) {
      continue;
    }
    scanned++;

    final List<String> lines = file.readAsLinesSync();
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      // A rule named in a comment is documentation, not a violation.
      if (line.trimLeft().startsWith('//')) {
        continue;
      }
      for (final Rule rule in kRules) {
        for (final RegExpMatch match in rule.pattern.allMatches(line)) {
          violations.add(
            Violation(relative, i + 1, match.start + 1, rule, line.trim()),
          );
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln(
      'check_theme_tokens: $scanned file(s) scanned, no style literals outside '
      '${kAllowedPrefixes.join(", ")}',
    );
    exit(0);
  }

  stderr.writeln(
    'check_theme_tokens: ${violations.length} style literal(s) outside the '
    'theme layer.\n'
    'The theme is the only source of colour, type, radius and spacing '
    '(UX-DR1).\n',
  );
  for (final Violation v in violations) {
    stderr.writeln('${v.path}:${v.line}:${v.column}  ${v.rule.what}');
    stderr.writeln('    ${v.source}');
    stderr.writeln('    -> ${v.rule.instead}\n');
  }
  exit(1);
}

/// The app root, so the check works from anywhere: `dart run tool/...` inside
/// apps/mobile, or from the repository root in CI.
Directory _appRoot() {
  final Directory fromScript = File.fromUri(
    Platform.script,
  ).parent.parent.absolute;
  if (Directory('${fromScript.path}/lib').existsSync()) {
    return fromScript;
  }
  return Directory.current.absolute;
}

String _relative(String path, String rootPath) {
  final String normalisedRoot = rootPath.endsWith(Platform.pathSeparator)
      ? rootPath
      : '$rootPath${Platform.pathSeparator}';
  final String relative = path.startsWith(normalisedRoot)
      ? path.substring(normalisedRoot.length)
      : path;
  return relative.replaceAll(Platform.pathSeparator, '/');
}
