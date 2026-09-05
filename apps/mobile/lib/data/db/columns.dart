// The storage conventions, written once, as Drift mixins.
//
// Epic 1 establishes the column conventions every table in every later epic
// inherits. A convention that has to be retyped per table is a convention that
// will be forgotten by Epic 4, so each one is a mixin here: a new table applies
// the mixins and gets the convention, and `tool/check_data_access.dart` fails
// the build on a table that skipped one.
//
// The conventions, and the decision each encodes:
//
//   HisabRow       AD-3  the primary key is a client-minted UUIDv7, stored as
//                        text. There is no `serverId` and no autoincrement.
//   BusinessScoped AD-11 every row names the Business it belongs to.
//   Timestamped    AD-14 every row records the UTC instant it was created.
//   Mutable              a reference row records when it last changed. A
//                        FINANCIAL row must not have this column: nothing
//                        updates it, so an `updatedAtUtc` on it would be a
//                        column that can only ever lie.
//   BusinessDated  AD-14 a transaction row stores the business day it belongs
//                        to, derived once at creation against Asia/Dhaka.
//   AppendOnly     AD-4  the marker. A table carrying it must be classified
//                        `financial` in lib/data/classification.dart, and the
//                        database installs UPDATE and DELETE triggers on it.
//
// What is NOT here, deliberately: any money or quantity column. Those are named
// per table (`amountPaisa`), because AD-1 and AD-2 are about the NAME and the
// TYPE of the column, and a mixin called `HasAmount` would let two tables mean
// different things by the same word.

import 'package:drift/drift.dart';

/// Stores a UTC instant as ISO-8601 text, always with the `Z`.
///
/// Text rather than a Drift `dateTime()` column on purpose. Drift's integer
/// datetime mode stores whole seconds and hands back a DateTime flagged local,
/// and AD-14's whole point is that the stored instant is unambiguously UTC and
/// that nothing re-derives a day from a local reading. ISO-8601 with `Z` is
/// unambiguous on the wire too (the architecture's Cross-Cutting table names
/// exactly this shape), and it sorts lexicographically in the order it sorts
/// chronologically, so `ORDER BY created_at_utc` needs no conversion.
class UtcInstantConverter extends TypeConverter<DateTime, String> {
  const UtcInstantConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb).toUtc();

  @override
  String toSql(DateTime value) => value.toUtc().toIso8601String();
}

/// AD-3 — the primary key is a client-minted lowercase UUIDv7.
///
/// The value comes from `HisabIds.newId()` in the repository, never from a
/// column default: minting in one visible place is what makes "is this really
/// v7?" answerable by reading one function instead of trusting generated code.
///
/// `test/data/conventions_test.dart` asserts, against the real generated
/// schema, that every table's primary key is exactly this single text column —
/// so if a Drift version ever stopped reading a `primaryKey` override out of a
/// mixin, the suite fails rather than shipping a table with no key.
mixin HisabRow on Table {
  /// The record's only identity, on this phone and on the server, forever.
  TextColumn get id => text().withLength(min: 36, max: 36)();

  @override
  Set<Column> get primaryKey => <Column>{id};
}

/// AD-11 — every row names the Business it belongs to.
///
/// On the device this is what scopes a query to the shop; on the server the
/// value in a request body is ignored and re-derived from the authenticated
/// principal. The column exists on both tiers so the row is self-describing
/// when it travels in a sync envelope (AD-22).
///
/// `Businesses` does not use this mixin, and that is the one documented
/// exception: its own `id` IS the business id, and a second column holding the
/// same value would be a column that can disagree with itself.
mixin BusinessScoped on Table {
  TextColumn get businessId => text().withLength(min: 36, max: 36)();
}

/// AD-14 — the UTC instant the row was created.
///
/// Stored UTC, always. What day it belongs to is a separate stored column on
/// transaction rows; see [BusinessDated].
mixin Timestamped on Table {
  TextColumn get createdAtUtc => text().map(const UtcInstantConverter())();
}

/// A reference row (AD-9) records when it last changed.
///
/// Only reference tables may use this. A financial table is append-only, so an
/// `updatedAtUtc` there would be a column nothing can ever write.
mixin Mutable on Table {
  TextColumn get updatedAtUtc => text().map(const UtcInstantConverter())();
}

/// AD-14 — the business day this row belongs to, `YYYY-MM-DD`.
///
/// Derived ONCE at creation by `BusinessDate.of()` against Asia/Dhaka and
/// stored, so that a device that travels, a corrected clock or a future change
/// of timezone rules cannot re-bucket a historical figure. It is the first key
/// of the `(businessDate, id)` ordering that AD-7 and this story both use.
mixin BusinessDated on Table {
  TextColumn get businessDate => text().withLength(min: 10, max: 10)();
}

/// AD-4 — the marker for an append-only table.
///
/// It declares no column; it is a claim the build check verifies. A table
/// carrying this mixin must be classified `financial` in
/// `lib/data/classification.dart`, and a table classified financial must carry
/// this mixin — `tool/check_data_access.dart` fails on either half being
/// missing. The database then installs BEFORE UPDATE and BEFORE DELETE triggers
/// on it, so the rule is enforced by SQLite rather than by memory.
mixin AppendOnly on Table {}
