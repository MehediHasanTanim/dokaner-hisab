// The owner. Reference data (AD-9) — mutable identity, not a money record.
//
// One row per signed-in owner on this device. The phone number comes from the
// authenticated session and is not re-entered (FR-3).
//
// `businessId` is nullable here and only here: Story 1.5 signs the owner in
// before Story 1.7 creates the Business, so a User row exists for a few screens
// with no Business to point at. [attachToBusiness] sets it once.

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../ids.dart';

class UserRepository {
  const UserRepository(this._db);

  final HisabDatabase _db;

  Future<User> create({
    required String phone,
    required String name,
    String? email,
    String? businessId,
    DateTime? at,
  }) async {
    final DateTime instant = (at ?? DateTime.now()).toUtc();
    final String id = HisabIds.newId();
    await _db.into(_db.users).insert(
      UsersCompanion.insert(
        id: id,
        createdAtUtc: instant,
        updatedAtUtc: instant,
        phone: phone,
        name: name,
        email: Value<String?>(email),
        businessId: Value<String?>(businessId),
      ),
    );
    return byId(id);
  }

  Future<User> byId(String id) {
    return (_db.select(_db.users)..where((t) => t.id.equals(id))).getSingle();
  }

  /// The signed-in owner on this device, or null before first sign-in.
  Future<User?> current() => _db.select(_db.users).getSingleOrNull();

  /// Sets the Business this owner belongs to. Called once, by the story that
  /// creates the Business.
  Future<void> attachToBusiness({
    required String userId,
    required String businessId,
    DateTime? at,
  }) async {
    await (_db.update(_db.users)..where((t) => t.id.equals(userId))).write(
      UsersCompanion(
        businessId: Value<String?>(businessId),
        updatedAtUtc: Value<DateTime>((at ?? DateTime.now()).toUtc()),
      ),
    );
  }

  /// Updates the owner's own details (FR-3).
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? email,
    DateTime? at,
  }) async {
    await (_db.update(_db.users)..where((t) => t.id.equals(userId))).write(
      UsersCompanion(
        name: name == null ? const Value<String>.absent() : Value<String>(name),
        email: email == null
            ? const Value<String?>.absent()
            : Value<String?>(email),
        updatedAtUtc: Value<DateTime>((at ?? DateTime.now()).toUtc()),
      ),
    );
  }
}
