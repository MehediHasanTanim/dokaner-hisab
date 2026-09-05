// The key, the keystore, and the encrypted open. AD-17 lives here.
//
// The threat is stated plainly in AD-17: a phone left on a counter is borrowed
// or stolen, and the file on it holds the shop's full financial history and its
// customers' phone numbers. So the database is SQLCipher, the key is 256 bits
// from the platform CSPRNG, and it is written once into the platform keystore.
//
// Three rules govern everything below, and each one has a test:
//
//   1. **There is no unencrypted fallback.** If SQLCipher is not the SQLite
//      build we are running against, or the keystore cannot be reached, this
//      code THROWS. It never opens the file anyway. A silent plaintext fallback
//      is the worst possible outcome of this story: the app would work
//      perfectly and the promise would be broken.
//   2. **A key is never regenerated over existing data.** A stored key that
//      fails to open the file is reported as itself. Minting a fresh one would
//      turn "I cannot read your ledger" into "your ledger is gone".
//   3. **The key never appears in the bundle, in a preference file, or in a
//      log.** It is minted on the device on first run and read back from the
//      keystore afterwards. Nothing in this file prints it.
//
// ── This file imports no Flutter ─────────────────────────────────────────────
// The platform half — the keystore plugin and the documents directory — lives
// in `platform_keystore.dart`. The split is not tidiness: `tool/` harnesses run
// under `dart run`, with no Flutter engine and therefore no `dart:ui`, and a
// single `package:flutter` import anywhere in the transitive graph would make
// the benchmark in `tool/benchmark_local_write.dart` impossible to run at all.
// Everything here is pure Dart over `sqlite3` and `drift`.
//
// ── Why flutter_secure_storage ───────────────────────────────────────────────
// AD-17 says "platform keystore ... never in shared preferences". On Android,
// flutter_secure_storage does not put the value in plaintext preferences: it
// encrypts it with a key held in the Android Keystore and stores the resulting
// blob. That is exactly the arrangement AD-17 is asking for — the prohibition
// is on plaintext preferences, not on the package. On iOS it is the Keychain
// directly. The package is already resolved and locked in pubspec.lock.
//
// ── What this file deliberately does NOT configure ───────────────────────────
// No AndroidOptions/IOSOptions are passed. The defaults are the platform-backed
// ones, and the option classes have been reshaped between major versions of the
// package; pinning an option here that a future upgrade renames would fail the
// build in a way that is easy to "fix" by dropping the option, which is how a
// security setting quietly disappears. If this project later needs a specific
// accessibility class (for example, "first unlock, this device only"), add it
// deliberately, in its own commit, with a test.

import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// How many bytes of key material AD-17 asks for: 256 bits.
const int kDatabaseKeyBytes = 32;

/// The database file's name inside the app's documents directory.
const String kDatabaseFileName = 'hisab.sqlite';

/// Anything that went wrong between the keystore and an open database.
///
/// Every failure below is one of these: the caller distinguishes "your phone's
/// keystore is unavailable" from "this key does not open this file", because
/// the owner-facing consequence of the two is completely different.
sealed class DatabaseSecurityException implements Exception {
  const DatabaseSecurityException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The platform keystore could not be read or written.
final class KeystoreUnavailableException extends DatabaseSecurityException {
  const KeystoreUnavailableException(super.message, [this.cause]);

  final Object? cause;
}

/// The keystore held something that is not a 256-bit hex key.
///
/// Reported, never overwritten: whatever is there was put there by a previous
/// install, and replacing it makes the existing database unreadable forever.
final class MalformedDatabaseKeyException extends DatabaseSecurityException {
  const MalformedDatabaseKeyException(super.message);
}

/// The SQLite build we are running against is not SQLCipher.
///
/// This is the check that stops the silent plaintext fallback. A plain SQLite
/// build ignores `PRAGMA key` without complaint and writes a perfectly readable
/// file, so the absence of `PRAGMA cipher_version` is the only honest signal.
final class DatabaseNotEncryptedException extends DatabaseSecurityException {
  const DatabaseNotEncryptedException(super.message);
}

/// The key did not open the file.
///
/// Either the wrong key, or a corrupted file. Never answered by minting a new
/// key over the data.
final class DatabaseKeyRejectedException extends DatabaseSecurityException {
  const DatabaseKeyRejectedException(super.message, [this.cause]);

  final Object? cause;
}

/// The narrow slice of secure storage this story needs.
///
/// An interface rather than a direct dependency so the key lifecycle is
/// testable: `flutter_secure_storage` is a plugin and needs a platform channel,
/// which a `flutter test` unit test does not have. The production
/// implementation is [FlutterSecureKeyStorage]; the tests pass a fake.
abstract interface class SecureKeyStorage {
  Future<String?> read(String key);

  Future<void> write(String key, String value);
}

/// Mints, stores and reads the one key that opens the local database.
class DatabaseKeyStore {
  const DatabaseKeyStore(this.storage);

  /// The keystore entry. Versioned in its name so that a future change of key
  /// derivation is a new entry rather than an ambiguous overwrite.
  static const String keyName = 'hisab.database.key.v1';

  final SecureKeyStorage storage;

  /// The key for this device, minted on first call and reused forever after.
  ///
  /// Never returns a key it did not read back out of the keystore: a write that
  /// silently failed would otherwise produce a database nobody can ever open
  /// again, and it would look like a successful first run.
  Future<String> readOrMint() async {
    final String? existing = await read();
    if (existing != null) {
      return existing;
    }

    final String minted = mintDatabaseKeyHex();
    try {
      await storage.write(keyName, minted);
    } on Object catch (error) {
      throw KeystoreUnavailableException(
        'Could not write the database key to the platform keystore. The '
        'database is not opened without it — there is no unencrypted '
        'fallback (AD-17).',
        error,
      );
    }

    final String? confirmed = await read();
    if (confirmed == null) {
      throw const KeystoreUnavailableException(
        'The database key was written to the platform keystore but could not '
        'be read back. Opening the database now would create a file that no '
        'later run can decrypt.',
      );
    }
    if (confirmed != minted) {
      throw const MalformedDatabaseKeyException(
        'The platform keystore returned a different key from the one just '
        'written. Refusing to open the database.',
      );
    }
    return confirmed;
  }

  /// The stored key, or null when this device has never had one.
  ///
  /// Throws rather than returning null when the keystore is unreachable or
  /// holds something malformed — "no key yet" and "I cannot tell" must not look
  /// the same to the caller, because the first one mints and the second one
  /// must not.
  Future<String?> read() async {
    final String? raw;
    try {
      raw = await storage.read(keyName);
    } on Object catch (error) {
      throw KeystoreUnavailableException(
        'Could not read the database key from the platform keystore.',
        error,
      );
    }
    if (raw == null) {
      return null;
    }
    if (!isDatabaseKeyHex(raw)) {
      throw const MalformedDatabaseKeyException(
        'The platform keystore holds a value that is not a 256-bit hex key. '
        'It is NOT being replaced: whatever wrote it may be the only thing '
        'that can open the existing database. Investigate before clearing it.',
      );
    }
    return raw;
  }
}

/// 256 bits from the platform CSPRNG, lowercase hex.
///
/// `Random.secure()` is the platform's cryptographic generator — `/dev/urandom`
/// on Android, `SecRandomCopyBytes` on iOS. Not `Random()`, which is seeded
/// pseudo-randomness and would make the key guessable from the launch time,
/// which is precisely what AD-17 forbids.
String mintDatabaseKeyHex() {
  final Random random = Random.secure();
  final StringBuffer hex = StringBuffer();
  for (int i = 0; i < kDatabaseKeyBytes; i++) {
    hex.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return hex.toString();
}

/// Exactly [kDatabaseKeyBytes] bytes, lowercase hex, nothing else.
bool isDatabaseKeyHex(String value) =>
    RegExp('^[0-9a-f]{${kDatabaseKeyBytes * 2}}\$').hasMatch(value);

/// Keys the raw SQLite handle and proves the result is really encrypted.
///
/// Runs inside Drift's `setup` callback, before the first statement, which is
/// the only point at which SQLCipher accepts a key.
///
/// The order matters:
///   1. Ask for `cipher_version` FIRST. A plain SQLite build answers with no
///      rows, and we stop there — otherwise a plain build would swallow
///      `PRAGMA key`, open the file in the clear and report success.
///   2. Set the raw key. `x'...'` is SQLCipher's raw-key form: the 32 bytes are
///      used as the key directly, with no PBKDF2 pass over a passphrase, which
///      is right because this key is already full-entropy random.
///   3. Touch the schema. SQLCipher only decrypts on first read, so a wrong key
///      surfaces here and not at open time.
void configureEncryptedDatabase(sqlite.Database db, String keyHex) {
  if (!isDatabaseKeyHex(keyHex)) {
    throw const MalformedDatabaseKeyException(
      'Refusing to open the database with a key that is not 256 bits of hex.',
    );
  }

  final sqlite.ResultSet cipher = db.select('PRAGMA cipher_version;');
  if (cipher.isEmpty) {
    throw const DatabaseNotEncryptedException(
      'This build of SQLite is not SQLCipher, so the local database would be '
      'written in the clear. Refusing to open it (AD-17). Check the '
      "`hooks: user_defines: sqlite3: source: sqlcipher` block in pubspec.yaml "
      '— it is what selects the SQLCipher build, and it is load-bearing.',
    );
  }

  db.execute('PRAGMA key = "x\'$keyHex\'";');

  try {
    db.select('SELECT count(*) FROM sqlite_master;');
  } on Object catch (error) {
    throw DatabaseKeyRejectedException(
      'The stored key did not open the local database file. The file is NOT '
      'being replaced and a new key is NOT being minted — that would destroy '
      "the shop's records. The cloud replica is the restore path (AD-17).",
      error,
    );
  }
}

/// A Drift executor over an encrypted file.
///
/// Lazy, so the keystore read and the first decryption happen on the first
/// query rather than during `main()`.
QueryExecutor encryptedExecutor({
  required File file,
  required String keyHex,
  bool logStatements = false,
}) {
  return NativeDatabase(
    file,
    logStatements: logStatements,
    setup: (sqlite.Database db) => configureEncryptedDatabase(db, keyHex),
  );
}

/// The executor the app uses, given a way to reach the keystore and a file.
///
/// Lazy: the keystore read and the first decryption happen on the first query
/// rather than during `main()`. [resolveFile] is a callback rather than a
/// `File` so that the app can supply the documents directory (an async,
/// Flutter-only lookup) without this file importing Flutter.
QueryExecutor encryptedExecutorWith({
  required SecureKeyStorage storage,
  required Future<File> Function() resolveFile,
  bool logStatements = false,
}) {
  return LazyDatabase(() async {
    final String keyHex = await DatabaseKeyStore(storage).readOrMint();
    final File target = await resolveFile();
    await target.parent.create(recursive: true);
    return encryptedExecutor(
      file: target,
      keyHex: keyHex,
      logStatements: logStatements,
    );
  });
}

/// The magic string at the head of an UNENCRYPTED SQLite file.
///
/// `test/data/encryption_test.dart` reads the first bytes off disk and asserts
/// they are not this. An encrypted file's first page is ciphertext, including
/// the header, so finding this string means the database is readable by anyone
/// holding the phone.
const String kPlainSqliteHeader = 'SQLite format 3';
