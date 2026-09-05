// Money accounts — the five places the shop's money sits.
//
// Reference data (AD-9), so unlike a movement an account CAN be renamed or
// archived. What it cannot do is hold a balance: there is no balance column to
// write, and the figure comes from `MoneyMovementRepository.balancePaisa`
// (AD-19). That separation is the whole point of the table.
//
// Nothing in Story 1.4 creates a row. The five accounts are seeded by the story
// that creates a Business, and their opening balances by FR-4's screen.

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../db/tables.dart';
import '../ids.dart';

class MoneyAccountRepository {
  const MoneyAccountRepository(this._db);

  final HisabDatabase _db;

  /// Creates one account for a Business.
  Future<MoneyAccount> create({
    required String businessId,
    required MoneyAccountType type,
    required String name,
    DateTime? at,
  }) async {
    final DateTime instant = (at ?? DateTime.now()).toUtc();
    final String id = HisabIds.newId();
    await _db.into(_db.moneyAccounts).insert(
      MoneyAccountsCompanion.insert(
        id: id,
        businessId: businessId,
        createdAtUtc: instant,
        updatedAtUtc: instant,
        type: type,
        name: name,
      ),
    );
    return byId(id);
  }

  /// Every account of one Business, archived ones included, in creation order.
  Future<List<MoneyAccount>> forBusiness(String businessId) {
    return (_db.select(_db.moneyAccounts)
          ..where((t) => t.businessId.equals(businessId))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
  }

  /// The accounts an entry screen offers.
  Future<List<MoneyAccount>> activeForBusiness(String businessId) {
    return (_db.select(_db.moneyAccounts)
          ..where(
            (t) => t.businessId.equals(businessId) & t.isArchived.equals(false),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
  }

  Future<MoneyAccount> byId(String id) {
    return (_db.select(_db.moneyAccounts)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// Renames an account. Permitted: this is reference data.
  ///
  /// The account's movements are untouched, because they are the money and this
  /// is only the label on it.
  Future<void> rename({
    required String id,
    required String name,
    DateTime? at,
  }) async {
    await (_db.update(_db.moneyAccounts)..where((t) => t.id.equals(id))).write(
      MoneyAccountsCompanion(
        name: Value<String>(name),
        updatedAtUtc: Value<DateTime>((at ?? DateTime.now()).toUtc()),
      ),
    );
  }

  /// Hides an account the owner has stopped using.
  ///
  /// Archived, never deleted: its movements are financial rows that may not be
  /// removed (AD-4), and an account row that vanished from under them would
  /// leave the history unreadable.
  Future<void> setArchived({
    required String id,
    required bool isArchived,
    DateTime? at,
  }) async {
    await (_db.update(_db.moneyAccounts)..where((t) => t.id.equals(id))).write(
      MoneyAccountsCompanion(
        isArchived: Value<bool>(isArchived),
        updatedAtUtc: Value<DateTime>((at ?? DateTime.now()).toUtc()),
      ),
    );
  }
}
