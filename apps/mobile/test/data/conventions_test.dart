// The four architecture decisions, asserted against the REAL schema.
//
// `tool/check_data_access.dart` reads the Dart source. This file reads what
// SQLite actually built, which is the only thing that is true at runtime: a
// mixin that a future Drift version stopped applying, a converter that changed
// the storage type, a primary key that quietly went missing — none of those
// show up in a text scan, and all of them show up here.
//
// The assertions are deliberately written against `sqlite_master` and
// `PRAGMA table_info` rather than Drift's own reflection, so this test keeps
// working across Drift versions and keeps answering the question it is really
// asking: what is on the disk?
//
//   AD-1  every money column is `…_paisa` and an INTEGER
//   AD-2  every quantity column is `…_milli` and an INTEGER
//   AD-3  every primary key is a single TEXT column called `id`, and there is
//         no `server_id` anywhere
//   AD-4  every financial table has BEFORE UPDATE and BEFORE DELETE triggers
//   AD-9  every table is classified, and the registry names nothing else
//   AD-10 no unique index beyond the implicit primary key
//   AD-11 every table carries `business_id` (the Business table IS the id)
//   AD-19 no balance column, on any table

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/data/classification.dart';
import 'package:hisab/data/db/database.dart';
import 'package:hisab/data/ids.dart';

import 'support/database.dart';

/// A column as SQLite reports it.
class SchemaColumn {
  const SchemaColumn(this.name, this.type, this.isPrimaryKey);

  final String name;
  final String type;
  final bool isPrimaryKey;
}

/// Words that would mean money in a column name. Kept in step with the same
/// list in `tool/check_data_access.dart`.
final RegExp moneyWords = RegExp(
  r'amount|price|cost|paid|due|discount|subtotal|total|fee|tax|profit|revenue',
);

final RegExp quantityWords = RegExp(r'quantity|qty');

void main() {
  late HisabDatabase db;
  late List<String> tables;
  late Map<String, List<SchemaColumn>> columns;

  setUpAll(() async {
    db = await openTestDatabase();
    tables = await db.userTableNames();

    columns = <String, List<SchemaColumn>>{};
    for (final String table in tables) {
      final List<QueryRow> rows = await db
          .customSelect("PRAGMA table_info('$table')")
          .get();
      columns[table] = rows
          .map(
            (QueryRow r) => SchemaColumn(
              r.read<String>('name'),
              r.read<String>('type').toUpperCase(),
              r.read<int>('pk') > 0,
            ),
          )
          .toList();
    }
  });

  tearDownAll(() async {
    await db.close();
  });

  group('the schema is the four tables of Epic 1 and no others', () {
    test('exactly four tables exist', () {
      expect(
        tables,
        <String>['businesses', 'money_accounts', 'money_movements', 'users'],
        reason:
            'AR-17: create only the tables this epic needs. A fifth table is '
            'an "ask first" in the story spec',
      );
    });

    test('every table has a row in the AD-9 registry', () {
      for (final String table in tables) {
        expect(
          HisabTables.classification.containsKey(table),
          isTrue,
          reason:
              '"$table" is not classified in lib/data/classification.dart. The '
              'classification decides whether the table is append-only and how '
              'a sync conflict resolves',
        );
      }
    });

    test('the registry names no table that does not exist', () {
      expect(HisabTables.all.difference(tables.toSet()), isEmpty);
    });

    test('the classification is what AD-9 states', () {
      expect(HisabTables.financial, <String>{'money_movements'});
      expect(HisabTables.reference, <String>{
        'businesses',
        'money_accounts',
        'users',
      });
      expect(
        HisabTables.isAppendOnly('money_accounts'),
        isFalse,
        reason: 'AD-19 says MoneyAccount is reference and MoneyMovement is '
            'financial, in as many words',
      );
    });

    test('an unclassified table throws rather than defaulting', () {
      expect(
        () => HisabTables.classify('sales'),
        throwsA(isA<UnclassifiedTableException>()),
        reason:
            'a default would silently classify a new financial table as '
            'reference, which is the failure AD-9 exists to prevent',
      );
    });
  });

  group('AD-3 — one client-minted identity per record', () {
    test('every primary key is a single TEXT column called id', () {
      for (final String table in tables) {
        final List<SchemaColumn> keys = columns[table]!
            .where((SchemaColumn c) => c.isPrimaryKey)
            .toList();
        expect(keys, hasLength(1), reason: '$table has a composite key');
        expect(keys.single.name, 'id', reason: '$table');
        expect(
          keys.single.type,
          'TEXT',
          reason: '$table — a UUIDv7 is text, never an autoincrementing int',
        );
      }
    });

    test('no table has a serverId', () {
      for (final String table in tables) {
        expect(
          columns[table]!.map((SchemaColumn c) => c.name),
          isNot(contains('server_id')),
          reason: 'AD-3 removed serverId: there is exactly one identity',
        );
      }
    });

    test('a minted id is a lowercase UUIDv7', () {
      final String id = HisabIds.newId();
      expect(HisabIds.isValid(id), isTrue, reason: id);
      expect(id, equals(id.toLowerCase()));
      expect(id[14], '7', reason: 'the version nibble');
    });

    test('minted ids sort in the order they were minted', () async {
      final List<String> ids = <String>[];
      for (int i = 0; i < 5; i++) {
        ids.add(HisabIds.newId());
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      final List<String> sorted = List<String>.of(ids)..sort();
      expect(
        sorted,
        ids,
        reason:
            'v7 carries a millisecond timestamp in its leading bytes; that is '
            'what makes (businessDate, id) a stable tiebreak',
      );
    });

    test('the timestamp inside an id is readable and recent', () {
      final DateTime minted = HisabIds.mintedAt(HisabIds.newId());
      expect(minted.isUtc, isTrue);
      expect(
        DateTime.now().toUtc().difference(minted).abs(),
        lessThan(const Duration(minutes: 1)),
      );
    });
  });

  group('AD-1 / AD-2 — money and quantity are named integers', () {
    test('a `_paisa` or `_milli` column is an INTEGER', () {
      for (final String table in tables) {
        for (final SchemaColumn column in columns[table]!) {
          if (column.name.endsWith('_paisa') ||
              column.name.endsWith('_milli')) {
            expect(
              column.type,
              'INTEGER',
              reason: '$table.${column.name}',
            );
          }
        }
      }
    });

    test('an integer money column is named `_paisa`', () {
      for (final String table in tables) {
        for (final SchemaColumn column in columns[table]!) {
          if (column.type == 'INTEGER' && moneyWords.hasMatch(column.name)) {
            expect(
              column.name.endsWith('_paisa'),
              isTrue,
              reason:
                  '$table.${column.name} holds money and must say so (AD-1)',
            );
          }
          if (column.type == 'INTEGER' && quantityWords.hasMatch(column.name)) {
            expect(
              column.name.endsWith('_milli'),
              isTrue,
              reason: '$table.${column.name} (AD-2)',
            );
          }
        }
      }
    });

    test('no column is a float', () {
      for (final String table in tables) {
        for (final SchemaColumn column in columns[table]!) {
          expect(
            column.type,
            isNot(anyOf('REAL', 'DOUBLE', 'FLOAT', 'NUMERIC')),
            reason: '$table.${column.name} — no double near a stored value',
          );
        }
      }
    });
  });

  group('AD-19 — a balance is derived and never stored', () {
    test('no table anywhere has a balance column', () {
      for (final String table in tables) {
        for (final SchemaColumn column in columns[table]!) {
          expect(
            column.name.contains('balance'),
            isFalse,
            reason:
                '$table.${column.name} — a Money Account balance is '
                'SUM(money_movements.amount_paisa) and nothing else',
          );
        }
      }
    });

    test('MoneyAccount holds a type and a name, and no figure', () {
      expect(
        columns['money_accounts']!.map((SchemaColumn c) => c.name).toSet(),
        <String>{
          'id',
          'business_id',
          'created_at_utc',
          'updated_at_utc',
          'type',
          'name',
          'is_archived',
        },
      );
    });
  });

  group('AD-11 / AD-14 — tenancy and time', () {
    test('every table carries business_id, except the Business itself', () {
      for (final String table in tables) {
        final Iterable<String> names = columns[table]!.map(
          (SchemaColumn c) => c.name,
        );
        if (table == 'businesses') {
          expect(
            names,
            isNot(contains('business_id')),
            reason:
                "the Business table's own id IS the business id; a second "
                'column could only disagree with itself',
          );
        } else {
          expect(names, contains('business_id'), reason: table);
        }
      }
    });

    test('every table records the UTC instant it was created', () {
      for (final String table in tables) {
        final SchemaColumn created = columns[table]!.firstWhere(
          (SchemaColumn c) => c.name == 'created_at_utc',
          orElse: () => const SchemaColumn('', '', false),
        );
        expect(created.name, 'created_at_utc', reason: table);
        expect(
          created.type,
          'TEXT',
          reason:
              '$table — stored as ISO-8601 with a Z, so the instant is '
              'unambiguously UTC and sorts chronologically',
        );
      }
    });

    test('a transaction row also stores the business day it belongs to', () {
      for (final String table in HisabTables.financial) {
        final Iterable<String> names = columns[table]!.map(
          (SchemaColumn c) => c.name,
        );
        expect(names, contains('business_date'), reason: table);
      }
    });

    test('a reference row records when it changed; a financial row cannot', () {
      for (final String table in HisabTables.reference) {
        expect(
          columns[table]!.map((SchemaColumn c) => c.name),
          contains('updated_at_utc'),
          reason: table,
        );
      }
      for (final String table in HisabTables.financial) {
        expect(
          columns[table]!.map((SchemaColumn c) => c.name),
          isNot(contains('updated_at_utc')),
          reason:
              '$table is append-only, so an updated_at column could only ever '
              'lie',
        );
      }
    });
  });

  group('AD-4 / AD-10 — append-only, and nothing else that can block a sync',
      () {
    test('every financial table has an UPDATE and a DELETE guard', () async {
      final List<QueryRow> triggers = await db
          .customSelect(
            "SELECT name, tbl_name FROM sqlite_master WHERE type = 'trigger'",
          )
          .get();
      final Set<String> names = triggers
          .map((QueryRow r) => r.read<String>('name'))
          .toSet();

      for (final String table in HisabTables.financial) {
        expect(names, contains('${table}_append_only_update'), reason: table);
        expect(names, contains('${table}_append_only_delete'), reason: table);
      }
      expect(
        names,
        hasLength(HisabTables.financial.length * 2),
        reason: 'a reference table must not be guarded — it is meant to change',
      );
    });

    test('the reversal link points backwards only', () {
      final Iterable<String> names = columns['money_movements']!.map(
        (SchemaColumn c) => c.name,
      );
      expect(names, contains('reverses_id'));
      expect(
        names,
        isNot(contains('reversed_by_id')),
        reason:
            'setting reversedById on the original would be an UPDATE on a '
            'financial row, which AD-4 forbids and the triggers prevent. '
            '"Was this reversed?" is a lookup — see the story spec',
      );
    });

    test('there is no unique index beyond the implicit primary key', () async {
      final List<QueryRow> indexes = await db
          .customSelect(
            "SELECT name, tbl_name FROM sqlite_master WHERE type = 'index'",
          )
          .get();
      final List<String> declared = indexes
          .map((QueryRow r) => r.read<String>('name'))
          .where((String name) => !name.startsWith('sqlite_'))
          .toList();
      expect(
        declared,
        isEmpty,
        reason:
            'AD-10: a violation on any unique index other than the primary key '
            'aborts a whole sync envelope, and the device retries it forever',
      );
    });
  });
}
