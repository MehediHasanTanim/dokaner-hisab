// Identity, minted on the device, in one place.
//
// AD-3: a client-minted UUIDv7 is the ONLY identity a record ever has. It is
// the primary key on this phone, it is the primary key on the server, and it is
// what every foreign key stores. There is no `serverId` anywhere in this
// product — `tool/check_data_access.dart` fails the build when one appears.
//
// Why v7 and not v4. A v7 identifier carries a 48-bit big-endian millisecond
// timestamp in its leading bytes, so lexicographic order is creation order.
// AD-7's FIFO consumption order and this story's `(businessDate, id)` movement
// order both lean on that: when two rows share a business date, the id breaks
// the tie the way the owner entered them. A v4 id would make that tiebreak
// random, and the ledger would reorder itself between two devices.
//
// One function mints ids so the version is auditable in one grep rather than
// wherever someone happened to type `Uuid()`.

import 'package:uuid/uuid.dart';

/// The one place a record's identity is created.
abstract final class HisabIds {
  /// The generator. `uuid` is resolved and locked in `pubspec.lock`; the
  /// version nibble is asserted by [isValid] and by the conventions test, so a
  /// package upgrade that quietly changed the version would fail the build.
  static const Uuid _uuid = Uuid();

  /// Mints a new lowercase, hyphenated UUIDv7.
  ///
  /// Every row in every table gets its id from here and from nowhere else.
  static String newId() => _uuid.v7();

  /// A lowercase hyphenated UUID whose version nibble is 7 and whose variant
  /// bits are RFC 4122. Anything else is not an identity this product minted.
  static final RegExp pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  /// True when [id] is a well-formed UUIDv7 in the canonical lowercase form.
  static bool isValid(String id) => pattern.hasMatch(id);

  /// The creation instant encoded in a v7 id, in UTC.
  ///
  /// This is a diagnostic — a way to read when a row was minted without
  /// joining anything. It is NEVER the business date: AD-14 derives that once
  /// at creation and stores it, precisely so that a later reading of the clock
  /// cannot re-bucket a historical figure. See `business_date.dart`.
  static DateTime mintedAt(String id) {
    if (!isValid(id)) {
      throw ArgumentError.value(id, 'id', 'not a UUIDv7');
    }
    final String hex = id.substring(0, 8) + id.substring(9, 13);
    return DateTime.fromMillisecondsSinceEpoch(
      int.parse(hex, radix: 16),
      isUtc: true,
    );
  }
}
