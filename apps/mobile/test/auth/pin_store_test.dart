// What is in the keystore after a PIN is set, and what is not.
//
// The acceptance criterion is written from the attacker's side: "given the
// keystore, when it is dumped, then it holds a salt and a hash and nothing from
// which the PIN can be read back". So the tests dump the fake keystore and read
// it the way someone with the phone would.
//
// Most tests run at a low iteration count on purpose — they are asserting the
// shape of the record and the behaviour around it, not the cost of the KDF, and
// a hundred thousand rounds per assertion would turn this file into a minute of
// CI. One test at the shipping cost keeps that number honest.

import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/auth/pin_store.dart';

import 'support/keystore.dart';

/// Cheap enough to run dozens of times, real enough to be the same code path.
const int kTestIterations = 1000;

const String kPin = '482913';
const String kOtherPin = '730264';

PinStore _store(FakeSecureStorage storage) =>
    PinStore(storage, iterations: kTestIterations);

void main() {
  group('what reaches storage', () {
    test('a salt and a digest, and never the PIN', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      await _store(storage).save(kPin);

      expect(
        storage.values.keys,
        containsAll(<String>[PinStore.saltKeyName, PinStore.hashKeyName]),
      );
      expect(
        storage.dump.contains(kPin),
        isFalse,
        reason: 'the PIN itself is in the keystore — the whole story failed',
      );
      // Not the PIN in any encoding a dump would reveal it in, either.
      expect(storage.dump.contains('৪৮২৯১৩'), isFalse);

      final String salt = storage.values[PinStore.saltKeyName]!;
      expect(salt, hasLength(kPinSaltBytes * 2));
      expect(salt, matches(RegExp(r'^[0-9a-f]+$')));

      final String hashEntry = storage.values[PinStore.hashKeyName]!;
      expect(hashEntry, startsWith('$kPinAlgorithm:$kTestIterations:'));
      expect(hashEntry.split(':')[2], hasLength(kPinHashBytes * 2));
    });

    test('the cost travels with the digest, so it can be raised later', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      await PinStore(storage, iterations: 512).save(kPin);

      // A later build with a higher default still verifies an old record.
      final PinStore raised = PinStore(storage, iterations: 250000);
      expect(await raised.verify(kPin), isTrue);
    });
  });

  group('verifying', () {
    test('the same PIN verifies; a different one does not', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final PinStore store = _store(storage);
      await store.save(kPin);

      expect(await store.verify(kPin), isTrue);
      expect(await store.verify(kOtherPin), isFalse);
      expect(await store.verify('482914'), isFalse);
    });

    test('the same PIN typed in Bangla digits verifies', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final PinStore store = _store(storage);
      await store.save(kPin);

      expect(await store.verify('৪৮২৯১৩'), isTrue);
    });

    test('a wrong PIN changes nothing in storage', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final PinStore store = _store(storage);
      await store.save(kPin);
      final Map<String, String> before = storage.values;

      for (int i = 0; i < 20; i++) {
        expect(await store.verify('000001'), isFalse);
      }

      expect(
        storage.values,
        before,
        reason: 'no number of wrong attempts touches the record — never a wipe',
      );
    });

    test('no PIN yet is not the same as a wrong PIN', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final PinStore store = _store(storage);

      expect(await store.isSet(), isFalse);
      await expectLater(
        store.verify(kPin),
        throwsA(isA<PinNotSetException>()),
      );
    });

    test('a half-written record is not a PIN', () async {
      // The salt was written and the phone died before the digest.
      final FakeSecureStorage storage = FakeSecureStorage(<String, String>{
        PinStore.saltKeyName: mintPinSaltHex(),
      });
      expect(await _store(storage).isSet(), isFalse);
    });
  });

  group('two installs of the same PIN', () {
    test('produce different salts and different digests', () async {
      final FakeSecureStorage first = FakeSecureStorage();
      final FakeSecureStorage second = FakeSecureStorage();
      await _store(first).save(kPin);
      await _store(second).save(kPin);

      expect(
        first.values[PinStore.saltKeyName],
        isNot(second.values[PinStore.saltKeyName]),
      );
      expect(
        first.values[PinStore.hashKeyName],
        isNot(second.values[PinStore.hashKeyName]),
        reason:
            'identical digests would tell an attacker with two phones that '
            'both shops chose the same PIN',
      );
    });

    test('a salt is 256 bits and never repeats', () {
      final Set<String> salts = <String>{
        for (int i = 0; i < 32; i++) mintPinSaltHex(),
      };
      expect(salts, hasLength(32));
    });
  });

  group('a keystore that fails', () {
    test('unreachable is an error, never a silent success', () async {
      final FakeSecureStorage storage = FakeSecureStorage()..failing = true;
      await expectLater(
        _store(storage).save(kPin),
        throwsA(isA<PinKeystoreUnavailableException>()),
      );
    });

    test('a write that stores nothing is caught before the owner is let in',
        () async {
      final FakeSecureStorage storage = FakeSecureStorage()..swallowing = true;
      await expectLater(
        _store(storage).save(kPin),
        throwsA(isA<PinKeystoreUnavailableException>()),
        reason:
            'the write reported success and stored nothing; without the '
            'read-back the owner would be told they are protected',
      );
    });

    test('a record this build cannot parse is reported, not replaced', () async {
      final FakeSecureStorage storage = FakeSecureStorage(<String, String>{
        PinStore.saltKeyName: mintPinSaltHex(),
        PinStore.hashKeyName: 'argon2id:3:deadbeef',
      });
      await expectLater(
        _store(storage).isSet(),
        throwsA(isA<MalformedPinRecordException>()),
      );
      expect(storage.writes, 0);
    });
  });

  group('the policy is enforced below the screen too', () {
    test('a weak PIN cannot be stored by skipping the form', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      await expectLater(
        _store(storage).save('111111'),
        throwsA(isA<WeakPinException>()),
      );
      expect(storage.values, isEmpty);
    });
  });

  group('the primitives', () {
    test('PBKDF2 matches RFC 6070 vector 1, transposed to SHA-256', () {
      // RFC 6070 is stated for HMAC-SHA1; the SHA-256 answers for the same
      // inputs are the widely published ones. Pinned here so a rewrite of the
      // loop that still "works" but computes something else fails loudly.
      final List<int> derived = pbkdf2HmacSha256(
        password: 'password'.codeUnits,
        salt: 'salt'.codeUnits,
        iterations: 1,
        length: 32,
      );
      expect(
        derived
            .map((int b) => b.toRadixString(16).padLeft(2, '0'))
            .join(),
        '120fb6cffcf8b32c43e7225256c4f837a86548c9'
            '2ccc35480805987cb70be17b',
      );
    });

    test('PBKDF2 spans more than one block when asked for more bytes', () {
      final List<int> derived = pbkdf2HmacSha256(
        password: 'password'.codeUnits,
        salt: 'salt'.codeUnits,
        iterations: 2,
        length: 64,
      );
      expect(derived, hasLength(64));
      expect(
        derived.sublist(0, 32),
        isNot(derived.sublist(32)),
        reason: 'the second block must use a different block index',
      );
    });

    test('the comparison is length-safe', () {
      expect(constantTimeEquals('abc', 'abc'), isTrue);
      expect(constantTimeEquals('abc', 'abd'), isFalse);
      expect(constantTimeEquals('abc', 'abcd'), isFalse);
      expect(constantTimeEquals('', ''), isTrue);
    });
  });

  group('the shipping cost', () {
    test('a PIN saved at the real iteration count round-trips', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final PinStore store = PinStore(storage);
      expect(store.iterations, kPinIterations);

      await store.save(kPin);
      expect(await store.verify(kPin), isTrue);
      expect(await store.verify(kOtherPin), isFalse);
    });
  });
}
