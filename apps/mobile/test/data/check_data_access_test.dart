// Asserts that the storage-convention guard actually catches things.
//
// A build check nobody tests is a check that quietly rots into a no-op: a regex
// is loosened to silence a false positive, a path exemption grows, and three
// epics later the check passes over a table with a stored balance on it. So
// this test plants a violation of every rule and asserts each one is reported,
// then runs the real scan over the real tree so the guard's own verdict is part
// of the test suite rather than only part of CI.
//
// The tool is imported by path because it lives in tool/, not lib/ — it is a
// build check, not shipped code, and it has no business being importable by the
// app.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_data_access.dart'
    show
        DataRule,
        DataViolation,
        DeclaredTable,
        declaredClassification,
        declaredTables,
        isDataLayer,
        isGenerated,
        kDataRules,
        kRuleAppendOnlyMarker,
        kRuleBalanceColumn,
        kRuleDriftOutsideData,
        kRuleMissingBusinessId,
        kRuleMissingPrimaryKey,
        kRuleMoneyName,
        kRuleNoRealColumn,
        kRulePhantomTable,
        kRuleQuantityName,
        kRuleServerId,
        kRuleTypedMoneyColumn,
        kRuleUnclassifiedTable,
        kRuleUniqueConstraint,
        scanProject,
        scanSchema,
        scanSource,
        sqlTableName;

/// A path outside the data layer, where Drift is not allowed.
const String kWidgetPath = 'lib/home/home_screen.dart';

/// A path inside the data layer, where table declarations live.
const String kTablePath = 'lib/data/db/tables.dart';

List<String> _ids(List<DataViolation> violations) =>
    violations.map((DataViolation v) => v.rule.id).toList();

List<DataViolation> _scanWidget(String source) =>
    scanSource(path: kWidgetPath, source: source);

List<DataViolation> _scanTable(String source) =>
    scanSource(path: kTablePath, source: source);

/// A minimal registry naming exactly the tables a sample declares.
String _registry(Map<String, String> entries) {
  final StringBuffer out = StringBuffer('const classification = {\n');
  entries.forEach((String table, String kind) {
    out.writeln("  '$table': TableClass.$kind,");
  });
  out.writeln('};');
  return out.toString();
}

List<DataViolation> _scanSchemaSample(
  String tables,
  Map<String, String> registry,
) {
  return scanSchema(
    tablesPath: kTablePath,
    tablesSource: tables,
    classificationPath: 'lib/data/classification.dart',
    classificationSource: _registry(registry),
  );
}

void main() {
  group('the check catches a planted violation', () {
    test('drift imported by a widget', () {
      final List<DataViolation> found = _scanWidget(
        "import 'package:drift/drift.dart';",
      );
      expect(_ids(found), <String>[kRuleDriftOutsideData.id]);
      expect(found.single.line, 1);
      expect(found.single.rule.instead, contains('repository provider'));
    });

    test('the raw sqlite bindings imported by a widget', () {
      expect(
        _ids(_scanWidget("import 'package:sqlite3/sqlite3.dart';")),
        <String>[kRuleDriftOutsideData.id],
      );
    });

    test('an integer money column not named `…Paisa`', () {
      expect(
        _ids(_scanTable('IntColumn get totalAmount => integer()();')),
        <String>[kRuleMoneyName.id],
      );
      expect(
        _ids(_scanTable('IntColumn get unitPrice => integer()();')),
        <String>[kRuleMoneyName.id],
      );
    });

    test('an integer quantity column not named `…Milli`', () {
      expect(
        _ids(_scanTable('IntColumn get quantity => integer()();')),
        <String>[kRuleQuantityName.id],
      );
    });

    test('a `…Paisa` column that is not an integer', () {
      expect(
        _ids(_scanTable('TextColumn get amountPaisa => text()();')),
        <String>[kRuleTypedMoneyColumn.id],
      );
      expect(
        _ids(_scanTable('TextColumn get weightMilli => text()();')),
        <String>[kRuleTypedMoneyColumn.id],
      );
    });

    test('a floating-point column', () {
      expect(
        _ids(_scanTable('RealColumn get ratio => real()();')),
        <String>[kRuleNoRealColumn.id],
      );
    });

    test('a stored balance, whatever it is called or typed', () {
      expect(
        _ids(_scanTable('IntColumn get balancePaisa => integer()();')),
        <String>[kRuleBalanceColumn.id],
      );
      expect(
        _ids(_scanTable('IntColumn get openingBalancePaisa => integer()();')),
        <String>[kRuleBalanceColumn.id],
      );
      expect(
        _ids(_scanTable('TextColumn get runningBalance => text()();')),
        <String>[kRuleBalanceColumn.id],
      );
    });

    test('a serverId, anywhere', () {
      expect(_ids(_scanTable('TextColumn get serverId => text()();')), <String>[
        kRuleServerId.id,
      ]);
      expect(
        _ids(_scanWidget('final id = record.serverId;')),
        <String>[kRuleServerId.id],
      );
    });

    test('a table with no AD-9 classification', () {
      final List<DataViolation> found = _scanSchemaSample(
        'class Sales extends Table with HisabRow, BusinessScoped, AppendOnly {}',
        <String, String>{},
      );
      expect(_ids(found), contains(kRuleUnclassifiedTable.id));
      expect(found.first.source, contains('sales'));
    });

    test('a classification for a table that does not exist', () {
      final List<DataViolation> found = _scanSchemaSample(
        'class Users extends Table with HisabRow, BusinessScoped {}',
        <String, String>{'users': 'reference', 'sales': 'financial'},
      );
      expect(_ids(found), <String>[kRulePhantomTable.id]);
    });

    test('a table that does not apply HisabRow', () {
      final List<DataViolation> found = _scanSchemaSample(
        'class Users extends Table with BusinessScoped {}',
        <String, String>{'users': 'reference'},
      );
      expect(_ids(found), contains(kRuleMissingPrimaryKey.id));
    });

    test('a table with no businessId', () {
      final List<DataViolation> found = _scanSchemaSample(
        'class Users extends Table with HisabRow {}',
        <String, String>{'users': 'reference'},
      );
      expect(_ids(found), contains(kRuleMissingBusinessId.id));
    });

    test('a financial table without the AppendOnly marker', () {
      final List<DataViolation> found = _scanSchemaSample(
        'class Sales extends Table with HisabRow, BusinessScoped {}',
        <String, String>{'sales': 'financial'},
      );
      expect(_ids(found), <String>[kRuleAppendOnlyMarker.id]);
    });

    test('an AppendOnly table classified as reference', () {
      final List<DataViolation> found = _scanSchemaSample(
        'class Sales extends Table with HisabRow, BusinessScoped, AppendOnly {}',
        <String, String>{'sales': 'reference'},
      );
      expect(_ids(found), <String>[kRuleAppendOnlyMarker.id]);
    });

    test('a unique constraint besides the primary key', () {
      final List<DataViolation> found = _scanSchemaSample(
        'class Users extends Table with HisabRow, BusinessScoped {\n'
        '  TextColumn get phone => text().unique()();\n'
        '}',
        <String, String>{'users': 'reference'},
      );
      expect(_ids(found), <String>[kRuleUniqueConstraint.id]);
    });

    test('every rule in the list is reachable', () {
      // If a rule can never fire, it is decoration.
      final Set<String> fired = <String>{
        ..._ids(_scanWidget("import 'package:drift/drift.dart';")),
        ..._ids(_scanTable('IntColumn get totalAmount => integer()();')),
        ..._ids(_scanTable('IntColumn get quantity => integer()();')),
        ..._ids(_scanTable('TextColumn get amountPaisa => text()();')),
        ..._ids(_scanTable('RealColumn get ratio => real()();')),
        ..._ids(_scanTable('IntColumn get balancePaisa => integer()();')),
        ..._ids(_scanTable('TextColumn get serverId => text()();')),
        ..._ids(
          _scanSchemaSample(
            'class Sales extends Table {}',
            <String, String>{'ghosts': 'reference'},
          ),
        ),
        ..._ids(
          _scanSchemaSample(
            'class Sales extends Table with HisabRow, BusinessScoped {}',
            <String, String>{'sales': 'financial'},
          ),
        ),
        ..._ids(
          _scanSchemaSample(
            'class Users extends Table with HisabRow, BusinessScoped {\n'
            '  TextColumn get phone => text().unique()();\n'
            '}',
            <String, String>{'users': 'reference'},
          ),
        ),
      };

      for (final DataRule rule in kDataRules) {
        expect(
          fired,
          contains(rule.id),
          reason:
              'rule "${rule.id}" was not triggered by any sample in this test '
              '— add one, or delete the rule',
        );
        expect(rule.instead, isNotEmpty, reason: 'every rule carries its fix');
      }
    });

    test('the report names the file, the line and the column', () {
      final List<DataViolation> found = scanSource(
        path: kTablePath,
        source: 'line one\nline two\n  IntColumn get totalAmount => '
            'integer()();\n',
      );
      expect(found, hasLength(1));
      final DataViolation v = found.single;
      expect(v.path, kTablePath);
      expect(v.line, 3, reason: 'lines are 1-indexed');
      expect(v.column, greaterThan(1));
      expect(v.source, startsWith('IntColumn get totalAmount'));
    });
  });

  group('the check does not cry wolf', () {
    test('the data layer may import drift', () {
      expect(
        scanSource(
          path: 'lib/data/db/database.dart',
          source: "import 'package:drift/drift.dart';",
        ),
        isEmpty,
      );
      expect(isDataLayer('lib/data/providers.dart'), isTrue);
      expect(isDataLayer('lib/theme/tokens.dart'), isFalse);
    });

    test('generated code is exempt', () {
      expect(isGenerated('lib/data/db/database.g.dart'), isTrue);
      expect(
        scanSource(
          path: 'lib/data/db/database.g.dart',
          source: 'IntColumn get totalAmount => integer()();',
        ),
        isEmpty,
      );
    });

    test('a rule named in a comment is documentation, not a violation', () {
      expect(_scanTable('// never add a serverId — AD-3 removed it'), isEmpty);
      expect(
        _scanTable('/// No balance column: a balance is a sum (AD-19).'),
        isEmpty,
      );
    });

    test('the conventions themselves are not flagged', () {
      expect(
        _scanTable(
          'IntColumn get amountPaisa => integer()();\n'
          'IntColumn get quantityMilli => integer()();\n'
          'TextColumn get businessId => text()();\n'
          'BoolColumn get isArchived => boolean()();\n'
          'TextColumn get businessDate => text()();',
        ),
        isEmpty,
      );
    });

    test('the Business table is the one table with no businessId column', () {
      expect(
        _scanSchemaSample(
          'class Businesses extends Table with HisabRow {}',
          <String, String>{'businesses': 'reference'},
        ),
        isEmpty,
        reason: "its own id IS the business id",
      );
    });

    test('a businessId declared by hand counts, not only the mixin', () {
      expect(
        _scanSchemaSample(
          'class Users extends Table with HisabRow {\n'
          '  TextColumn get businessId => text().nullable()();\n'
          '}',
          <String, String>{'users': 'reference'},
        ),
        isEmpty,
        reason:
            'Users declares it nullable by hand, because an owner exists '
            'before their Business does',
      );
    });
  });

  group('the parsing the rules rest on', () {
    test('a class name becomes the SQL table name Drift generates', () {
      expect(sqlTableName('Users'), 'users');
      expect(sqlTableName('MoneyAccounts'), 'money_accounts');
      expect(sqlTableName('MoneyMovements'), 'money_movements');
    });

    test('a table declared across several lines is still found', () {
      final List<DeclaredTable> found = declaredTables(
        'class MoneyMovements extends Table\n'
        '    with HisabRow, BusinessScoped, AppendOnly {\n'
        '}',
      );
      expect(found.map((DeclaredTable t) => t.sqlName), <String>[
        'money_movements',
      ]);
      expect(found.single.isAppendOnly, isTrue);
      expect(found.single.hasPrimaryKey, isTrue);
      expect(found.single.isBusinessScoped, isTrue);
    });

    test('the registry is read out of the real file', () {
      final String source = File(
        'lib/data/classification.dart',
      ).readAsStringSync();
      expect(declaredClassification(source), <String, String>{
        'users': 'reference',
        'businesses': 'reference',
        'money_accounts': 'reference',
        'money_movements': 'financial',
      });
    });
  });

  group('the real source tree passes', () {
    test('every storage convention holds', () {
      // `flutter test` runs from the package root, so lib/ and tool/ are right
      // here. This is the same verdict CI gets from
      // `dart run tool/check_data_access.dart`, asserted where a developer sees
      // it before pushing.
      expect(
        Directory('lib/data').existsSync(),
        isTrue,
        reason: 'expected to run from apps/mobile',
      );

      final List<DataViolation> violations = scanProject(Directory.current);
      expect(
        violations.map((DataViolation v) => v.toString()).toList(),
        isEmpty,
      );
    });
  });
}
