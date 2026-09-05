// Fails the build when the storage conventions are broken.
//
//   dart run tool/check_data_access.dart
//
// Story 1.4 establishes the conventions every table in every later epic
// inherits: money and quantity column names, one client-minted identity,
// tenancy, append-only financial data, no stored balance. Every one of them is
// invisible in review — a new table with an `amountTaka` column or a missing
// registry line looks perfectly reasonable on its own, and only goes wrong
// three epics later when a figure disagrees with itself. So they are checked
// here, and a violation is a failed build rather than a review comment.
//
// The rules, and the architecture decision each one holds up:
//
//   drift-outside-data   AR-29  no widget touches the database. Drift is
//                               importable from lib/data/ and nowhere else.
//   money-name           AD-1   an integer money column is named `…Paisa`.
//   quantity-name        AD-2   an integer quantity column is named `…Milli`.
//   no-real-column       AD-1   no `double` anywhere near a stored value.
//   balance-column       AD-19  no balance column, on any table, ever.
//   server-id            AD-3   one identity per record, and it is the UUIDv7.
//   unclassified-table   AD-9   every table is financial or reference, once.
//   phantom-table        AD-9   ...and the registry names no table that is gone.
//   missing-primary-key  AD-3   every table applies the HisabRow mixin.
//   missing-business-id  AD-11  every table carries businessId (one exception).
//   append-only-marker   AD-4   AppendOnly mixin iff classified financial.
//   unique-constraint    AD-10  no unique constraint besides the primary key.
//
// This is a plain text scan, not an analyzer plugin, and it is a THIRD file
// beside `check_theme_tokens.dart` and `check_single_formatter.dart` rather
// than a merged "lint everything" tool. Each check states one set of rules a
// contributor can read in a minute and know what will fail before they push.
//
// Known limitation, stated rather than hidden: the money and quantity name
// rules apply to `IntColumn` and `RealColumn` declarations. A money value
// smuggled into a `TextColumn` is not caught here — it is caught by AD-1 in
// review and by `test/data/conventions_test.dart`, which walks the real
// generated schema rather than the source text.

import 'dart:io';

/// Where Drift may be imported. Everything else under `lib/` reaches storage
/// through a repository provider (AR-29).
const List<String> kDataLayerPrefixes = <String>['lib/data/'];

/// Generated code is not hand-written and is not reviewed line by line.
const List<String> kGeneratedSuffixes = <String>[
  '.g.dart',
  '.freezed.dart',
  '.gr.dart',
];

/// The table declarations, and the AD-9 registry that must agree with them.
const String kTablesPath = 'lib/data/db/tables.dart';
const String kClassificationPath = 'lib/data/classification.dart';

/// The one table with no `businessId` column: its own `id` IS the business id,
/// and a second column holding the same value could only disagree with itself.
const String kTenancyRootTable = 'Businesses';

class DataRule {
  const DataRule(this.id, this.what, this.instead);

  /// Stable name, so a test can assert a specific rule fired.
  final String id;

  /// What was found, in the report.
  final String what;

  /// What to write instead. A check that only says "no" costs more time than it
  /// saves, so every rule carries its own fix.
  final String instead;
}

const DataRule kRuleDriftOutsideData = DataRule(
  'drift-outside-data',
  'a database package imported outside lib/data/',
  'no widget touches the database (AR-29). Read what you need through a '
      'repository provider from lib/data/providers.dart; if the repository '
      'does not expose it yet, add the method there',
);

const DataRule kRuleMoneyName = DataRule(
  'money-name',
  'an integer money column not named `…Paisa`',
  'money is an integer count of paisa and its column says so (AD-1): rename '
      'it to end in `Paisa`. The owner never sees a paisa — lib/format/ '
      'renders taka at the display edge',
);

const DataRule kRuleQuantityName = DataRule(
  'quantity-name',
  'an integer quantity column not named `…Milli`',
  'quantity is an integer count of thousandths of a unit and its column says '
      'so (AD-2): rename it to end in `Milli`',
);

const DataRule kRuleTypedMoneyColumn = DataRule(
  'money-column-type',
  'a `…Paisa` or `…Milli` column that is not an integer',
  'declare it `IntColumn get x => integer()()`. Money and quantity are '
      'integers in every tier (AD-1, AD-2)',
);

const DataRule kRuleNoRealColumn = DataRule(
  'no-real-column',
  'a floating-point column',
  'no float, no decimal library, no string-encoded money, anywhere, in any '
      'tier (AD-1). Store an integer',
);

const DataRule kRuleBalanceColumn = DataRule(
  'balance-column',
  'a stored balance column',
  'a balance is derived and never stored (AD-19, AD-6): a Money Account '
      "balance is `SUM(money_movements.amount_paisa)`, a party balance is its "
      'ledger entries. A stored balance goes stale the moment a row is '
      'backdated, and AD-4 then forbids fixing it',
);

const DataRule kRuleServerId = DataRule(
  'server-id',
  'a `serverId`',
  'there is exactly one identity per record and the device mints it: a '
      'lowercase UUIDv7 from HisabIds.newId() (AD-3). Every foreign key stores '
      'that same id, on the phone and on the server',
);

const DataRule kRuleUnclassifiedTable = DataRule(
  'unclassified-table',
  'a table with no AD-9 classification',
  'add one line to HisabTables.classification in lib/data/classification.dart '
      'saying whether the table is `financial` (append-only, and both devices\' '
      'rows are kept on sync) or `reference` (mutable, last-writer-wins). The '
      'classification decides how a sync conflict resolves, so a missing one '
      'is how a financial record gets silently overwritten',
);

const DataRule kRulePhantomTable = DataRule(
  'phantom-table',
  'a classification for a table that does not exist',
  'the registry is exhaustive AND exact (AD-9). Remove the line, or restore '
      'the table it names',
);

const DataRule kRuleMissingPrimaryKey = DataRule(
  'missing-primary-key',
  'a table that does not apply the HisabRow mixin',
  'add `with HisabRow` from lib/data/db/columns.dart. It declares the '
      'client-minted UUIDv7 primary key that AD-3 requires of every table',
);

const DataRule kRuleMissingBusinessId = DataRule(
  'missing-business-id',
  'a table with no businessId',
  'add `with BusinessScoped` from lib/data/db/columns.dart. Every row names '
      'the Business it belongs to (AD-11) so that it is self-describing when '
      'it travels in a sync envelope',
);

const DataRule kRuleAppendOnlyMarker = DataRule(
  'append-only-marker',
  'the AppendOnly mixin and the AD-9 registry disagree',
  'a table classified `financial` carries `with AppendOnly`, and a table '
      'carrying `AppendOnly` is classified `financial` — the marker is what a '
      'reader sees on the table and the registry is what installs the UPDATE '
      'and DELETE triggers, so they must say the same thing',
);

const DataRule kRuleUniqueConstraint = DataRule(
  'unique-constraint',
  'a unique constraint besides the primary key',
  "financial tables carry no unique constraint besides the primary key "
      '(AD-10): a violation on any other unique index aborts a whole sync '
      'envelope and the device retries it forever. If a reference table truly '
      'needs one, it needs a decision recorded first',
);

/// Every rule, so the test can prove each one is reachable.
const List<DataRule> kDataRules = <DataRule>[
  kRuleDriftOutsideData,
  kRuleMoneyName,
  kRuleQuantityName,
  kRuleTypedMoneyColumn,
  kRuleNoRealColumn,
  kRuleBalanceColumn,
  kRuleServerId,
  kRuleUnclassifiedTable,
  kRulePhantomTable,
  kRuleMissingPrimaryKey,
  kRuleMissingBusinessId,
  kRuleAppendOnlyMarker,
  kRuleUniqueConstraint,
];

class DataViolation {
  DataViolation(this.path, this.line, this.column, this.rule, this.source);

  final String path;
  final int line;
  final int column;
  final DataRule rule;
  final String source;

  @override
  String toString() => '$path:$line:$column  ${rule.what}';
}

/// True when [relativePath] is inside the data layer, the one place Drift and
/// the raw SQLite bindings may be imported.
bool isDataLayer(String relativePath) =>
    kDataLayerPrefixes.any(relativePath.startsWith);

/// True when [relativePath] is generated and therefore not scanned.
bool isGenerated(String relativePath) =>
    kGeneratedSuffixes.any(relativePath.endsWith);

/// Matches an import of anything that talks SQL directly.
final RegExp _databaseImport = RegExp(
  r'''import\s+['"]package:(drift|sqlite3|sqlcipher_flutter_libs|sqflite)''',
);

/// A Drift column declaration: `IntColumn get amountPaisa => integer()();`
final RegExp _columnDeclaration = RegExp(
  r'\b(IntColumn|RealColumn|TextColumn|BoolColumn|DateTimeColumn|BlobColumn)'
  r'\s+get\s+(\w+)',
);

/// Words that mean money in a column name. Strong ones only: the rule fires on
/// integer columns, where a money value would actually live.
final RegExp _moneyWords = RegExp(
  r'(?:^|[a-z])(?:[Aa]mount|[Pp]rice|[Cc]ost|[Pp]aid|[Dd]ue|[Dd]iscount|'
  r'[Ss]ubtotal|[Tt]otal|[Ff]ee|[Tt]ax|[Pp]rofit|[Rr]evenue)',
);

/// Words that mean a counted quantity in a column name.
final RegExp _quantityWords = RegExp(r'(?:^|[a-z])(?:[Qq]uantity|[Qq]ty)');

/// Any spelling of a stored balance.
final RegExp _balanceWords = RegExp('[Bb]alance');

/// One identity per record (AD-3).
final RegExp _serverId = RegExp(r'\bserverId\b|\bserver_id\b');

/// A unique index declared on a table.
final RegExp _uniqueConstraint = RegExp(r'\.unique\(\)|get\s+uniqueKeys\b');

/// Scans one file's text for the line-level rules.
///
/// Exposed so `test/data/check_data_access_test.dart` can plant a violation of
/// every rule and assert it is still caught — a guard nobody tests is a guard
/// that quietly rots into a no-op.
List<DataViolation> scanSource({
  required String path,
  required String source,
}) {
  final List<DataViolation> violations = <DataViolation>[];
  if (isGenerated(path)) {
    return violations;
  }

  final bool inDataLayer = isDataLayer(path);
  final List<String> lines = source.split('\n');

  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    // A rule named in a comment is documentation, not a violation.
    if (line.trimLeft().startsWith('//')) {
      continue;
    }

    void report(DataRule rule, int column) {
      violations.add(DataViolation(path, i + 1, column, rule, line.trim()));
    }

    // AR-29 — Drift is importable from lib/data/ and nowhere else.
    if (!inDataLayer) {
      final RegExpMatch? importMatch = _databaseImport.firstMatch(line);
      if (importMatch != null) {
        report(kRuleDriftOutsideData, importMatch.start + 1);
      }
    }

    // AD-3 — there is no serverId, anywhere.
    for (final RegExpMatch match in _serverId.allMatches(line)) {
      report(kRuleServerId, match.start + 1);
    }

    for (final RegExpMatch match in _columnDeclaration.allMatches(line)) {
      final String columnType = match.group(1)!;
      final String name = match.group(2)!;
      final int column = match.start + 1;
      final bool isInteger = columnType == 'IntColumn';

      // AD-19 — no balance column, whatever its type.
      if (_balanceWords.hasMatch(name)) {
        report(kRuleBalanceColumn, column);
        continue;
      }

      // AD-1 — no float near a stored value.
      if (columnType == 'RealColumn') {
        report(kRuleNoRealColumn, column);
        continue;
      }

      // AD-1 / AD-2 — a `…Paisa` or `…Milli` column is an integer.
      if (name.endsWith('Paisa') || name.endsWith('Milli')) {
        if (!isInteger) {
          report(kRuleTypedMoneyColumn, column);
        }
        continue;
      }

      if (isInteger && _moneyWords.hasMatch(name)) {
        report(kRuleMoneyName, column);
      } else if (isInteger && _quantityWords.hasMatch(name)) {
        report(kRuleQuantityName, column);
      }
    }
  }

  return violations;
}

/// A table class as declared in `tables.dart`.
class DeclaredTable {
  const DeclaredTable({
    required this.className,
    required this.mixins,
    required this.line,
    required this.column,
  });

  final String className;
  final List<String> mixins;
  final int line;
  final int column;

  /// The SQL name Drift derives from the class name: `MoneyMovements` becomes
  /// `money_movements`. The registry is keyed on this.
  String get sqlName => sqlTableName(className);

  bool get hasPrimaryKey => mixins.contains('HisabRow');

  bool get isAppendOnly => mixins.contains('AppendOnly');

  bool get isBusinessScoped => mixins.contains('BusinessScoped');
}

/// Drift's table-name rule: the class name, lower-snake-cased.
String sqlTableName(String className) {
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < className.length; i++) {
    final String character = className[i];
    final String lower = character.toLowerCase();
    if (character != lower && i > 0) {
      out.write('_');
    }
    out.write(lower);
  }
  return out.toString();
}

final RegExp _tableDeclaration = RegExp(
  r'class\s+(\w+)\s+extends\s+Table\b([^{]*)\{',
);

final RegExp _classificationEntry = RegExp(
  r"'(\w+)'\s*:\s*TableClass\.(financial|reference)",
);

int _lineOf(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;

/// Every table class declared in [source].
List<DeclaredTable> declaredTables(String source) {
  return _tableDeclaration.allMatches(source).map((RegExpMatch match) {
    final String withClause = match.group(2) ?? '';
    return DeclaredTable(
      className: match.group(1)!,
      mixins: RegExp(
        r'\w+',
      ).allMatches(withClause).map((RegExpMatch m) => m.group(0)!).toList(),
      line: _lineOf(source, match.start),
      column: 1,
    );
  }).toList();
}

/// The AD-9 registry, as declared in [source].
Map<String, String> declaredClassification(String source) {
  return <String, String>{
    for (final RegExpMatch match in _classificationEntry.allMatches(source))
      match.group(1)!: match.group(2)!,
  };
}

/// The rules that need both files at once: the registry against the tables.
List<DataViolation> scanSchema({
  required String tablesPath,
  required String tablesSource,
  required String classificationPath,
  required String classificationSource,
}) {
  final List<DataViolation> violations = <DataViolation>[];
  final List<DeclaredTable> tables = declaredTables(tablesSource);
  final Map<String, String> registry = declaredClassification(
    classificationSource,
  );

  for (final DeclaredTable table in tables) {
    final String declaration = 'class ${table.className} extends Table';

    if (!table.hasPrimaryKey) {
      violations.add(
        DataViolation(
          tablesPath,
          table.line,
          table.column,
          kRuleMissingPrimaryKey,
          declaration,
        ),
      );
    }

    if (!table.isBusinessScoped &&
        table.className != kTenancyRootTable &&
        !RegExp(
          'get\\s+businessId',
        ).hasMatch(_bodyOf(tablesSource, table.className))) {
      violations.add(
        DataViolation(
          tablesPath,
          table.line,
          table.column,
          kRuleMissingBusinessId,
          declaration,
        ),
      );
    }

    final String? classification = registry[table.sqlName];
    if (classification == null) {
      violations.add(
        DataViolation(
          tablesPath,
          table.line,
          table.column,
          kRuleUnclassifiedTable,
          '$declaration  (expected registry key "${table.sqlName}")',
        ),
      );
    } else if ((classification == 'financial') != table.isAppendOnly) {
      violations.add(
        DataViolation(
          tablesPath,
          table.line,
          table.column,
          kRuleAppendOnlyMarker,
          '$declaration  (registry says $classification, '
              'mixin says ${table.isAppendOnly ? "AppendOnly" : "mutable"})',
        ),
      );
    }
  }

  final Set<String> declared = tables
      .map((DeclaredTable t) => t.sqlName)
      .toSet();
  for (final String name in registry.keys) {
    if (!declared.contains(name)) {
      violations.add(
        DataViolation(
          classificationPath,
          _lineOf(
            classificationSource,
            classificationSource.indexOf("'$name'"),
          ),
          1,
          kRulePhantomTable,
          "'$name'",
        ),
      );
    }
  }

  // AD-10 — no unique constraint besides the primary key.
  final List<String> lines = tablesSource.split('\n');
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trimLeft().startsWith('//')) {
      continue;
    }
    final RegExpMatch? match = _uniqueConstraint.firstMatch(lines[i]);
    if (match != null) {
      violations.add(
        DataViolation(
          tablesPath,
          i + 1,
          match.start + 1,
          kRuleUniqueConstraint,
          lines[i].trim(),
        ),
      );
    }
  }

  return violations;
}

/// The source between one table declaration and the next, for the rules that
/// need to look inside a single class body.
String _bodyOf(String source, String className) {
  final int start = source.indexOf('class $className extends Table');
  if (start < 0) {
    return '';
  }
  final Iterable<RegExpMatch> after = _tableDeclaration
      .allMatches(source)
      .where((RegExpMatch m) => m.start > start);
  final int end = after.isEmpty ? source.length : after.first.start;
  return source.substring(start, end);
}

/// Scans every `.dart` file under [directory], reporting paths relative to
/// [rootPath].
List<DataViolation> scanDirectory(
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

  final List<DataViolation> violations = <DataViolation>[];
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

/// The whole verdict: every file, plus the registry cross-check.
List<DataViolation> scanProject(Directory root) {
  final List<DataViolation> violations = scanDirectory(
    Directory('${root.path}/lib'),
    rootPath: root.path,
  );

  final File tables = File('${root.path}/$kTablesPath');
  final File classification = File('${root.path}/$kClassificationPath');
  if (tables.existsSync() && classification.existsSync()) {
    violations.addAll(
      scanSchema(
        tablesPath: kTablesPath,
        tablesSource: tables.readAsStringSync(),
        classificationPath: kClassificationPath,
        classificationSource: classification.readAsStringSync(),
      ),
    );
  }
  return violations;
}

void main() {
  final Directory root = appRoot();
  final Directory lib = Directory('${root.path}/lib');

  if (!lib.existsSync()) {
    stderr.writeln('check_data_access: no lib/ directory under ${root.path}');
    exit(2);
  }

  final int scanned = lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .where((File f) => !isGenerated(relativePath(f.path, root.path)))
      .length;

  final List<DataViolation> violations = scanProject(root);

  if (violations.isEmpty) {
    stdout.writeln(
      'check_data_access: $scanned file(s) scanned, ${kDataRules.length} rules, '
      'storage conventions hold',
    );
    exit(0);
  }

  stderr.writeln(
    'check_data_access: ${violations.length} storage-convention violation(s).\n'
    'These are the conventions every later table inherits (AD-1, AD-2, AD-3, '
    'AD-4, AD-9, AD-10, AD-11, AD-19); a deviation here is inherited, not '
    'contained.\n',
  );
  for (final DataViolation v in violations) {
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
