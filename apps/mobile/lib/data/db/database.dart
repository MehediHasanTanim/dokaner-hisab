// The local database. Drift over SQLCipher, four tables, schema version 1.
//
// This file is the system of record for the whole product. Everything the owner
// records lands here first and syncs later (FR-93), so the phone's copy is not a
// cache — it is the truth, and the cloud is the replica.
//
// Three things happen here and nowhere else:
//
//   1. The schema is declared, from the four table classes.
//   2. The migration strategy is declared: forward-only, per AR-27.
//   3. AD-4 is ENFORCED. Every table classified `financial` in
//      lib/data/classification.dart gets a BEFORE UPDATE and a BEFORE DELETE
//      trigger that aborts the statement. Discipline is what AD-4 asks for; a
//      trigger is what makes it true at three in the morning in Epic 5, in code
//      nobody reviewing this story will ever read.
//
// ─────────────────────────────────────────────────────────────────────────────
// CODE GENERATION IS NOT OPTIONAL. `database.g.dart` does not exist in the
// repository; nothing in lib/data/ compiles until it is written:
//
//     cd apps/mobile && dart run build_runner build --delete-conflicting-outputs
//
// CI runs the same command before `flutter analyze`.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:drift/drift.dart';

import '../classification.dart';
import 'columns.dart';
import 'tables.dart';

part 'database.g.dart';

/// The sentinel in every append-only abort message.
///
/// SQLite raises the trigger's message as a plain string, so this constant is
/// how Dart tells "AD-4 stopped you" apart from "the disk is full". Repositories
/// and tests match on it; see [isAppendOnlyViolation].
const String kAppendOnlyAbort = 'HISAB_APPEND_ONLY';

/// True when [error] is the database refusing to change a financial row.
///
/// The exception type comes from the `sqlite3` package through Drift and
/// differs between a direct executor and one behind an isolate, so this matches
/// on the sentinel rather than on a class.
bool isAppendOnlyViolation(Object error) =>
    error.toString().contains(kAppendOnlyAbort);

@DriftDatabase(tables: <Type>[Users, Businesses, MoneyAccounts, MoneyMovements])
class HisabDatabase extends _$HisabDatabase {
  /// Takes an executor rather than opening one, so that the encrypted opener
  /// (`encryption.dart`), the benchmark harness and the tests all construct the
  /// same database over different files.
  HisabDatabase(super.e);

  /// Schema version 1 — this story creates the schema. It only ever goes up,
  /// and only in a story that ships a tested `onUpgrade` step (AR-27).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },

    // Forward-only (AR-27). There is no downgrade path and there will not be
    // one: a downgrade would have to discard rows the newer schema wrote, and
    // on an append-only store that is data loss dressed as a migration. Every
    // future step appends to this method and is tested against a populated
    // database before it merges.
    onUpgrade: (Migrator m, int from, int to) async {
      if (from > to) {
        throw StateError(
          'Refusing to downgrade the local database from schema $from to $to. '
          'Migrations are forward-only (AR-27).',
        );
      }
      // No steps yet: schema version 1 is the first.
    },

    // Runs on every open, after any create or upgrade. Both statements here
    // are idempotent on purpose, so an existing install picks up a guard that
    // was added after its database was created.
    beforeOpen: (OpeningDetails _) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await installAppendOnlyGuards();
    },
  );

  /// Installs AD-4 as SQLite triggers, one pair per financial table.
  ///
  /// Driven by [HisabTables.financial], so a table added to the registry as
  /// financial is guarded the next time the app opens without anyone
  /// remembering to write a trigger for it. `IF NOT EXISTS` makes it safe to
  /// run on every open.
  ///
  /// Exposed for `test/data/money_movement_test.dart`, which asserts the guard
  /// actually fires.
  Future<void> installAppendOnlyGuards() async {
    for (final String table in HisabTables.financial) {
      await customStatement('''
CREATE TRIGGER IF NOT EXISTS ${table}_append_only_update
BEFORE UPDATE ON $table
BEGIN
  SELECT RAISE(ABORT, '$kAppendOnlyAbort: $table is append-only (AD-4). Write a reversal row plus a new row instead of updating this one.');
END;
''');
      await customStatement('''
CREATE TRIGGER IF NOT EXISTS ${table}_append_only_delete
BEFORE DELETE ON $table
BEGIN
  SELECT RAISE(ABORT, '$kAppendOnlyAbort: $table is append-only (AD-4). A void is a reversal row, never a delete.');
END;
''');
    }
  }

  /// The table names SQLite actually holds, for the conventions test.
  Future<List<String>> userTableNames() async {
    final List<QueryRow> rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' ORDER BY name",
    ).get();
    return rows.map((QueryRow r) => r.read<String>('name')).toList();
  }
}
