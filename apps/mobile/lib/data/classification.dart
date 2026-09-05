// The AD-9 registry: every table is financial or reference, named once.
//
// AD-9 asks for a classification that is exhaustive and mutually exclusive over
// every table, declared in ONE place, with a build-time check that fails on an
// unclassified table. This is that one place. `tool/check_data_access.dart`
// reads this map and the table declarations in `db/tables.dart` and fails the
// build when the two disagree in either direction — a table with no entry, or
// an entry naming a table that does not exist.
//
// The classification is not documentation. It decides two things:
//
//   1. **How the row is written.** Financial rows are append-only (AD-4): the
//      database installs BEFORE UPDATE and BEFORE DELETE triggers on every
//      table classified financial here, and they abort the statement. A
//      correction is a reversal plus a new row. Reference rows are mutable.
//   2. **How a sync conflict resolves** (AD-9, Story 1.11 onwards). Financial
//      rows never conflict — both devices' rows are kept and the ledger is
//      their sum. Reference rows resolve last-writer-wins by server receipt
//      time.
//
// Getting this wrong on a new table is how a financial record gets silently
// overwritten by another device, which is why an unclassified table is a broken
// build rather than a review comment.
//
// This file deliberately imports nothing. It is read by the build check as
// plain text and by the database as data, and neither should have to resolve
// Drift to answer "is this table financial?".

/// What a table is, for AD-4's append-only rule and AD-9's conflict rule.
enum TableClass {
  /// Append-only. No UPDATE, no DELETE, ever. A correction is a reversal row
  /// plus a new row (AD-4). Enforced by database triggers, not by discipline.
  financial,

  /// Mutable identity and settings. Last-writer-wins on sync.
  reference,
}

/// Every table in the local database, classified exactly once.
///
/// Keys are the SQL table names Drift generates from the table classes in
/// `db/tables.dart` (`MoneyMovements` -> `money_movements`). The build check
/// derives the same names from the class declarations and compares.
///
/// Story 1.4 creates four tables and no more. A later story adding a table adds
/// its line here in the same commit, or CI stops it.
abstract final class HisabTables {
  /// The registry. Exhaustive and mutually exclusive, by construction: a Map
  /// cannot hold a table twice, and the check proves it holds every table once.
  static const Map<String, TableClass> classification = <String, TableClass>{
    // Reference — the owner's identity. Mutable: a name or an email changes.
    // Not a money record, so not financial (this story's decision table).
    'users': TableClass.reference,

    // Reference — the shop. Name, type and address are all editable.
    'businesses': TableClass.reference,

    // Reference — Cash, bKash, Nagad, Rocket, Bank. AD-19 states this
    // explicitly, and it is why a MoneyAccount holds no balance column: the
    // balance is the sum of its movements and nothing else.
    'money_accounts': TableClass.reference,

    // Financial — every taka that enters or leaves an account, including the
    // Opening Balance (AD-19). Append-only.
    'money_movements': TableClass.financial,
  };

  /// The tables that carry money and may never be updated or deleted.
  static Set<String> get financial => classification.entries
      .where((MapEntry<String, TableClass> e) => e.value == TableClass.financial)
      .map((MapEntry<String, TableClass> e) => e.key)
      .toSet();

  /// The mutable tables.
  static Set<String> get reference => classification.entries
      .where((MapEntry<String, TableClass> e) => e.value == TableClass.reference)
      .map((MapEntry<String, TableClass> e) => e.key)
      .toSet();

  /// Every table name known to the registry.
  static Set<String> get all => classification.keys.toSet();

  /// The classification of [tableName], or a throw naming the hole.
  ///
  /// Nothing in the app should reach this and get an exception — the build
  /// check fails first. It throws rather than returning a default because a
  /// default would silently classify a new financial table as reference, which
  /// is the exact failure AD-9 exists to prevent.
  static TableClass classify(String tableName) {
    final TableClass? found = classification[tableName];
    if (found == null) {
      throw UnclassifiedTableException(tableName);
    }
    return found;
  }

  /// True when writes to [tableName] are append-only (AD-4).
  static bool isAppendOnly(String tableName) =>
      classify(tableName) == TableClass.financial;
}

/// A table reached the runtime without an AD-9 classification.
class UnclassifiedTableException implements Exception {
  const UnclassifiedTableException(this.tableName);

  final String tableName;

  @override
  String toString() =>
      'UnclassifiedTableException: "$tableName" is not classified in '
      'lib/data/classification.dart. AD-9 requires every table to be declared '
      'financial or reference exactly once, because the classification decides '
      'whether the row is append-only and how a sync conflict resolves. Add a '
      'line to HisabTables.classification.';
}
