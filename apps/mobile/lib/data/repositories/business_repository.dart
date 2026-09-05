// The shop. Exactly one per owner (FR-2).
//
// Reference data (AD-9): name, type and address are editable. There is no
// currency column — BDT is displayed and not editable in the MVP, so a column
// would imply a choice the owner does not have.
//
// This table is the tenancy root: its `id` is the `businessId` every other
// table stores (AD-11), which is why `Businesses` is the one table without a
// separate `businessId` column.

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../db/tables.dart';
import '../ids.dart';

class BusinessRepository {
  const BusinessRepository(this._db);

  final HisabDatabase _db;

  Future<Business> create({
    required String name,
    required BusinessType type,
    required String ownerUserId,
    String? address,
    DateTime? at,
  }) async {
    final DateTime instant = (at ?? DateTime.now()).toUtc();
    final String id = HisabIds.newId();
    await _db.into(_db.businesses).insert(
      BusinessesCompanion.insert(
        id: id,
        createdAtUtc: instant,
        updatedAtUtc: instant,
        name: name,
        type: type,
        ownerUserId: ownerUserId,
        address: Value<String?>(address),
      ),
    );
    return byId(id);
  }

  Future<Business> byId(String id) {
    return (_db.select(_db.businesses)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// The Business on this device, or null before setup has run.
  ///
  /// One row is expected. `getSingleOrNull` rather than a `first`, so a second
  /// row — which would mean two shops on one phone, which FR-2 forbids —
  /// surfaces as a failure instead of being silently picked between.
  Future<Business?> current() {
    return _db.select(_db.businesses).getSingleOrNull();
  }

  /// Updates the editable fields. Reference data, so a plain write.
  Future<void> update({
    required String id,
    String? name,
    BusinessType? type,
    String? address,
    DateTime? at,
  }) async {
    await (_db.update(_db.businesses)..where((t) => t.id.equals(id))).write(
      BusinessesCompanion(
        name: name == null ? const Value<String>.absent() : Value<String>(name),
        type: type == null
            ? const Value<BusinessType>.absent()
            : Value<BusinessType>(type),
        address: address == null
            ? const Value<String?>.absent()
            : Value<String?>(address),
        updatedAtUtc: Value<DateTime>((at ?? DateTime.now()).toUtc()),
      ),
    );
  }
}
