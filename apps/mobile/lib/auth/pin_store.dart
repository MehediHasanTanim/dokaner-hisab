// The PIN, as it exists in storage: a salt and a digest, and nothing else.
//
// This file is the counterpart of `lib/data/db/encryption.dart` and follows its
// three rules deliberately, because the failure modes are the same shape:
//
//   1. **The PIN is never stored, logged or returned.** Only a 32-byte random
//      salt and a PBKDF2-HMAC-SHA256 digest over it reach the keystore. There
//      is no code path in this file — or anywhere in `lib/auth/` — that can
//      answer the question "what is the PIN".
//   2. **A write is read back and verified before the owner is told they are
//      protected.** A keystore write that silently failed would leave an owner
//      believing their খাতা is locked when it is not. That is the worst
//      outcome this story has, and `save` refuses to return until it has
//      re-read the record and verified the PIN against it.
//   3. **Nothing here deletes anything.** No wipe, no reset, no clearing of the
//      record on failed attempts. Wrong PINs are the lockout's business
//      (`lockout.dart`) and the answer there is a delay, never destruction.
//
// ── The PIN does NOT touch the database key ──────────────────────────────────
// AD-17's SQLCipher key is minted by `mintDatabaseKeyHex` and lives at its own
// keystore entry, untouched by this file. The story's Design Notes argue the
// decision: six digits is a million combinations, so wrapping a 256-bit key
// with it would add nothing an attacker notices while guaranteeing that a
// forgotten PIN destroys the shop's records. The PIN gates the person at the
// counter. It is not, and must not become, an encryption key.
//
// ── Why PBKDF2 and not Argon2 ────────────────────────────────────────────────
// `crypto` is a direct dependency of this app (promoted from transitive for
// this story) and gives HMAC-SHA256; PBKDF2 over it is thirty lines that can be
// read and checked against RFC 8018. Argon2 is the better KDF and needs a
// package that is not in the lockfile — adding one is an "Ask First" in this
// story's boundaries. The iteration count travels *with* each stored digest, so
// raising it later re-hashes on the next successful unlock instead of locking
// anyone out.
//
// UNLIKE `encryption.dart`, this file is NOT Flutter-free: it normalises the
// entered digits through `PinPolicy`, which reaches `lib/format/`, which pulls
// in Riverpod. That is fine here — nothing under `tool/` imports the PIN — but
// it is worth knowing before someone tries to run this from a `dart run`
// harness the way `tool/benchmark_local_write.dart` runs the database key.

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../data/db/encryption.dart' show SecureKeyStorage;
import 'pin_policy.dart';

/// Salt length. 256 bits from the platform CSPRNG, the same width as AD-17's
/// database key, for the same reason: it is the width at which "guess the
/// salt" stops being a strategy.
const int kPinSaltBytes = 32;

/// Digest length: SHA-256's own output width. One PBKDF2 block, no more.
const int kPinHashBytes = 32;

/// PBKDF2 iterations for a PIN chosen today.
///
/// COST, STATED PLAINLY: this runs on the owner's phone, on the UI isolate,
/// once per unlock attempt. It is a deliberate trade — high enough that an
/// offline guess costs something, low enough that a shop owner at a counter
/// does not wait. It is stored with each digest, so it can be raised without
/// invalidating an existing PIN. Measure it on the mid-range 2023 Android
/// device the performance floor names (NFR-1) before changing it, and move the
/// derivation onto a background isolate rather than lowering it.
const int kPinIterations = 100000;

/// The algorithm label written into the stored record.
const String kPinAlgorithm = 'pbkdf2-sha256';

/// Anything that went wrong between the keystore and a usable PIN.
///
/// Sealed, like `DatabaseSecurityException`, because the owner-facing
/// consequence of each is different: "your phone would not keep the PIN" is a
/// screen that must not lie about being protected, while "no PIN is set yet" is
/// the first-run path.
sealed class PinSecurityException implements Exception {
  const PinSecurityException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The platform keystore could not be read or written.
final class PinKeystoreUnavailableException extends PinSecurityException {
  const PinKeystoreUnavailableException(super.message, [this.cause]);

  final Object? cause;
}

/// The keystore holds something that is not a PIN record.
///
/// Reported, never silently replaced: a record this build cannot parse may
/// still be the only thing standing between a borrowed phone and the খাতা.
final class MalformedPinRecordException extends PinSecurityException {
  const MalformedPinRecordException(super.message);
}

/// A PIN the policy refuses. Checked here as well as on the screen, so that no
/// later caller can store a weak PIN by skipping the form.
final class WeakPinException extends PinSecurityException {
  WeakPinException(this.weakness) : super(weakness.reason);

  final PinWeakness weakness;
}

/// Asked to verify when this device has no PIN yet.
final class PinNotSetException extends PinSecurityException {
  const PinNotSetException(super.message);
}

/// One stored PIN: the salt, the digest, and the parameters that produced it.
class PinRecord {
  const PinRecord({
    required this.saltHex,
    required this.hashHex,
    required this.iterations,
  });

  final String saltHex;
  final String hashHex;
  final int iterations;

  /// The digest entry as it is written: the algorithm and its cost travel with
  /// the digest, so a record produced by an older build still verifies.
  String encodeHash() => '$kPinAlgorithm:$iterations:$hashHex';

  /// Parses the digest entry. Throws rather than guessing.
  static PinRecord decode({required String saltHex, required String hashEntry}) {
    final List<String> parts = hashEntry.split(':');
    if (parts.length != 3 || parts[0] != kPinAlgorithm) {
      throw const MalformedPinRecordException(
        'The platform keystore holds a PIN record this build does not '
        'recognise. It is NOT being replaced.',
      );
    }
    final int? iterations = int.tryParse(parts[1]);
    if (iterations == null || iterations < 1) {
      throw const MalformedPinRecordException(
        'The stored PIN record does not name a usable iteration count.',
      );
    }
    if (!_isHex(saltHex, kPinSaltBytes) || !_isHex(parts[2], kPinHashBytes)) {
      throw const MalformedPinRecordException(
        'The stored PIN salt or digest is not the expected width of hex.',
      );
    }
    return PinRecord(
      saltHex: saltHex,
      hashHex: parts[2],
      iterations: iterations,
    );
  }
}

/// Writes, reads and checks the one PIN that opens this app.
///
/// Two keystore entries, both under the same `SecureKeyStorage` the database
/// key uses (`lib/data/db/encryption.dart`). There is no second storage
/// abstraction in this app and there must not be one: two ways to reach the
/// keystore is two sets of platform options to keep in step.
class PinStore {
  const PinStore(this.storage, {this.iterations = kPinIterations});

  /// The salt. Versioned in its name, so a future change of derivation is a new
  /// entry rather than an ambiguous overwrite.
  static const String saltKeyName = 'hisab.pin.salt.v1';

  /// The digest, with its algorithm and iteration count.
  static const String hashKeyName = 'hisab.pin.hash.v1';

  final SecureKeyStorage storage;

  /// The cost used for a PIN saved from now on. Existing records verify at
  /// whatever cost they were written with.
  final int iterations;

  /// True when this device already has a PIN.
  ///
  /// Both entries must be present and parseable. A half-written record — a
  /// salt with no digest, because the second write failed — is not a PIN, and
  /// treating it as one would lock the owner out of an app they never set up.
  Future<bool> isSet() async => await _read() != null;

  /// Stores [pin] as a salt and a digest, then reads it back and proves it.
  ///
  /// Returns only after the written record has been re-read from the keystore
  /// and [pin] verified against it. The owner is told they are protected on the
  /// strength of that round trip and nothing weaker.
  Future<void> save(String pin) async {
    final PinWeakness? weakness = PinPolicy.inspect(pin);
    if (weakness != null) {
      throw WeakPinException(weakness);
    }

    final String saltHex = mintPinSaltHex();
    final PinRecord record = PinRecord(
      saltHex: saltHex,
      hashHex: derivePinHashHex(
        pin: pin,
        saltHex: saltHex,
        iterations: iterations,
      ),
      iterations: iterations,
    );

    await _write(saltKeyName, record.saltHex);
    await _write(hashKeyName, record.encodeHash());

    final PinRecord? confirmed = await _read();
    if (confirmed == null) {
      throw const PinKeystoreUnavailableException(
        'The PIN was written to the platform keystore but could not be read '
        'back. Telling the owner their খাতা is locked would be a lie.',
      );
    }
    final bool proved = await verify(pin);
    if (!proved) {
      throw const PinKeystoreUnavailableException(
        'The PIN written to the platform keystore does not verify against '
        'what was read back. The app is NOT reporting itself as locked.',
      );
    }
  }

  /// True when [pin] matches the stored record.
  ///
  /// Throws [PinNotSetException] when there is no PIN — "no PIN yet" and "wrong
  /// PIN" must never look the same to a caller, because the first opens the
  /// set-PIN screen and the second counts an attempt.
  Future<bool> verify(String pin) async {
    final PinRecord? record = await _read();
    if (record == null) {
      throw const PinNotSetException(
        'This device has no PIN yet; there is nothing to verify against.',
      );
    }
    final String candidate = derivePinHashHex(
      pin: pin,
      saltHex: record.saltHex,
      iterations: record.iterations,
    );
    return constantTimeEquals(candidate, record.hashHex);
  }

  Future<PinRecord?> _read() async {
    final String? saltHex = await _readEntry(saltKeyName);
    final String? hashEntry = await _readEntry(hashKeyName);
    if (saltHex == null || hashEntry == null) {
      return null;
    }
    return PinRecord.decode(saltHex: saltHex, hashEntry: hashEntry);
  }

  Future<String?> _readEntry(String name) async {
    try {
      return await storage.read(name);
    } on Object catch (error) {
      throw PinKeystoreUnavailableException(
        'Could not read the PIN record from the platform keystore.',
        error,
      );
    }
  }

  Future<void> _write(String name, String value) async {
    try {
      await storage.write(name, value);
    } on Object catch (error) {
      throw PinKeystoreUnavailableException(
        'Could not write the PIN to the platform keystore. The owner is not '
        'being told they are protected.',
        error,
      );
    }
  }
}

/// 256 bits of salt from the platform CSPRNG, lowercase hex.
///
/// `Random.secure()` — the same generator, and the same reasoning, as
/// `mintDatabaseKeyHex`: a salt from a seeded generator is a salt an attacker
/// can regenerate, which is the whole point of having one.
String mintPinSaltHex() {
  final Random random = Random.secure();
  final StringBuffer hex = StringBuffer();
  for (int i = 0; i < kPinSaltBytes; i++) {
    hex.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return hex.toString();
}

/// PBKDF2-HMAC-SHA256 over the normalised PIN, as lowercase hex.
///
/// The PIN is normalised through [PinPolicy.normalise] first, so that the same
/// six digits typed on a Bangla keypad and on a Western one produce the same
/// digest. Without that, an owner who switched keyboards would be locked out by
/// a PIN they typed correctly.
String derivePinHashHex({
  required String pin,
  required String saltHex,
  required int iterations,
}) {
  final List<int> derived = pbkdf2HmacSha256(
    password: utf8.encode(PinPolicy.normalise(pin)),
    salt: _hexToBytes(saltHex),
    iterations: iterations,
    length: kPinHashBytes,
  );
  return _bytesToHex(derived);
}

/// PBKDF2 as RFC 8018 states it, with HMAC-SHA256 as the PRF.
///
/// Written out rather than pulled from a package: `crypto` gives the HMAC and
/// nothing above it, and the alternative is a second cryptography dependency
/// for thirty lines that can be read and checked by eye.
List<int> pbkdf2HmacSha256({
  required List<int> password,
  required List<int> salt,
  required int iterations,
  required int length,
}) {
  if (iterations < 1) {
    throw ArgumentError.value(iterations, 'iterations', 'must be at least 1');
  }
  final Hmac prf = Hmac(sha256, password);
  final List<int> output = <int>[];

  for (int block = 1; output.length < length; block++) {
    final List<int> seed = <int>[
      ...salt,
      (block >> 24) & 0xff,
      (block >> 16) & 0xff,
      (block >> 8) & 0xff,
      block & 0xff,
    ];
    List<int> u = prf.convert(seed).bytes;
    final List<int> accumulated = List<int>.of(u);
    for (int i = 1; i < iterations; i++) {
      u = prf.convert(u).bytes;
      for (int j = 0; j < accumulated.length; j++) {
        accumulated[j] ^= u[j];
      }
    }
    output.addAll(accumulated);
  }

  return output.sublist(0, length);
}

/// Compares two hex digests without leaking where they first differ.
///
/// A `==` on two strings returns as soon as it finds a difference, and the time
/// it took says how much of the digest matched. That matters less for a local
/// PIN than for a network credential, but a comparison that is constant-time
/// costs nothing to write and one that is not is a habit that travels.
bool constantTimeEquals(String a, String b) {
  int difference = a.length ^ b.length;
  final int shortest = a.length < b.length ? a.length : b.length;
  for (int i = 0; i < shortest; i++) {
    difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return difference == 0;
}

bool _isHex(String value, int bytes) =>
    RegExp('^[0-9a-f]{${bytes * 2}}\$').hasMatch(value);

List<int> _hexToBytes(String hex) => <int>[
  for (int i = 0; i + 1 < hex.length; i += 2)
    int.parse(hex.substring(i, i + 2), radix: 16),
];

String _bytesToHex(List<int> bytes) {
  final StringBuffer hex = StringBuffer();
  for (final int byte in bytes) {
    hex.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return hex.toString();
}
