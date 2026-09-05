// AD-17, asserted against the bytes on disk.
//
// The acceptance criterion is written from the owner's side: "given a phone
// that is stolen, when the database file is read off the device, then it is not
// a readable SQLite file". So this test does exactly that — it opens the
// database, writes the owner's name into it, closes it, and then reads the raw
// file the way anyone holding the phone would.
//
// An unencrypted file here is a FAILING TEST, not a warning. If SQLCipher is
// not the SQLite build the tests are running against, `configureEncryptedDatabase`
// throws `DatabaseNotEncryptedException` and every test in this file fails —
// which is the correct outcome, because shipping a plaintext ledger is worse
// than shipping nothing.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/data/db/database.dart';
import 'package:hisab/data/db/encryption.dart';
import 'package:hisab/data/repositories/user_repository.dart';

import 'support/database.dart';

/// A string that would be plainly visible in an unencrypted database file.
const String kOwnerName = 'Rahman-Grocery-Owner-Canary';

void main() {
  late Directory workspace;
  late File databaseFile;

  setUp(() {
    workspace = Directory.systemTemp.createTempSync('hisab_encryption_test');
    databaseFile = File('${workspace.path}/hisab.sqlite');
  });

  tearDown(() {
    if (workspace.existsSync()) {
      workspace.deleteSync(recursive: true);
    }
  });

  group('the key itself', () {
    test('is 256 bits of lowercase hex', () {
      final String key = mintDatabaseKeyHex();
      expect(key, hasLength(kDatabaseKeyBytes * 2));
      expect(key, matches(RegExp(r'^[0-9a-f]+$')));
      expect(isDatabaseKeyHex(key), isTrue);
    });

    test('is different every time', () {
      final Set<String> keys = <String>{
        for (int i = 0; i < 32; i++) mintDatabaseKeyHex(),
      };
      expect(
        keys,
        hasLength(32),
        reason: 'Random.secure(), not a seeded generator — AD-17 forbids a key '
            'derived from anything guessable',
      );
    });

    test('anything that is not 256 bits of hex is rejected', () {
      expect(isDatabaseKeyHex(''), isFalse);
      expect(isDatabaseKeyHex('abc'), isFalse);
      expect(isDatabaseKeyHex('A' * 64), isFalse, reason: 'lowercase only');
      expect(isDatabaseKeyHex('0' * 63), isFalse);
      expect(isDatabaseKeyHex('0' * 65), isFalse);
    });
  });

  group('the keystore', () {
    test('mints once and reuses forever after', () async {
      final FakeKeyStorage storage = FakeKeyStorage();
      final DatabaseKeyStore keys = DatabaseKeyStore(storage);

      final String first = await keys.readOrMint();
      final String second = await keys.readOrMint();

      expect(second, first);
      expect(storage.writes, 1, reason: 'a second mint would orphan the data');
      expect(storage.values.keys, <String>[DatabaseKeyStore.keyName]);
    });

    test('an unreachable keystore is an error, never a plaintext fallback',
        () async {
      final FakeKeyStorage storage = FakeKeyStorage()..failing = true;
      await expectLater(
        DatabaseKeyStore(storage).readOrMint(),
        throwsA(isA<KeystoreUnavailableException>()),
      );
    });

    test('a malformed stored key is reported and NOT replaced', () async {
      final FakeKeyStorage storage = FakeKeyStorage(<String, String>{
        DatabaseKeyStore.keyName: 'not-a-key',
      });

      await expectLater(
        DatabaseKeyStore(storage).readOrMint(),
        throwsA(isA<MalformedDatabaseKeyException>()),
      );
      expect(
        storage.values[DatabaseKeyStore.keyName],
        'not-a-key',
        reason:
            'whatever wrote it may be the only thing that can open the '
            'existing database; overwriting it would destroy the records',
      );
      expect(storage.writes, 0);
    });

    test('a key that will not open the file is never regenerated over it',
        () async {
      final String key = mintDatabaseKeyHex();
      await _writeOwner(databaseFile, key);

      final String wrongKey = mintDatabaseKeyHex();
      final HisabDatabase reopened = openEncryptedTestFile(
        file: databaseFile,
        keyHex: wrongKey,
      );

      await expectLater(
        reopened.customSelect('SELECT count(*) FROM users').get(),
        throwsA(
          predicate<Object>(
            (Object e) =>
                e is DatabaseKeyRejectedException ||
                e.toString().contains('DatabaseKeyRejectedException'),
            'is DatabaseKeyRejectedException',
          ),
        ),
      );

      // The file is still there, still the same size, still holding the data
      // that the right key opens.
      expect(databaseFile.existsSync(), isTrue);
      final HisabDatabase withRightKey = openEncryptedTestFile(
        file: databaseFile,
        keyHex: key,
      );
      expect((await UserRepository(withRightKey).current())!.name, kOwnerName);
      await withRightKey.close();
    });
  });

  group('the file on disk', () {
    test('is not a readable SQLite database', () async {
      await _writeOwner(databaseFile, mintDatabaseKeyHex());

      final List<int> bytes = databaseFile.readAsBytesSync();
      expect(bytes, isNotEmpty);

      final String header = String.fromCharCodes(
        bytes.take(kPlainSqliteHeader.length),
      );
      expect(
        header,
        isNot(kPlainSqliteHeader),
        reason:
            'the first page of a SQLCipher database is ciphertext, header '
            'included. Finding "$kPlainSqliteHeader" here means the shop\'s '
            'ledger is readable by anyone holding the phone (AD-17)',
      );
    });

    test('does not contain the owner\'s name in the clear', () async {
      await _writeOwner(databaseFile, mintDatabaseKeyHex());

      final String raw = String.fromCharCodes(databaseFile.readAsBytesSync());
      expect(
        raw.contains(kOwnerName),
        isFalse,
        reason:
            'AD-17 is about the phone numbers and the names as much as the '
            'figures',
      );
    });
  });

  group('across runs', () {
    test('the same stored key opens the same database', () async {
      final FakeKeyStorage storage = FakeKeyStorage();

      final HisabDatabase firstRun = HisabDatabase(
        encryptedExecutorWith(
          storage: storage,
          resolveFile: () async => databaseFile,
        ),
      );
      await UserRepository(firstRun).create(
        phone: '+8801712345678',
        name: kOwnerName,
      );
      await firstRun.close();
      expect(storage.writes, 1);

      final HisabDatabase secondRun = HisabDatabase(
        encryptedExecutorWith(
          storage: storage,
          resolveFile: () async => databaseFile,
        ),
      );
      final User? owner = await UserRepository(secondRun).current();
      expect(owner, isNotNull);
      expect(owner!.name, kOwnerName);
      await secondRun.close();

      expect(
        storage.writes,
        1,
        reason: 'the second run read the key it already had',
      );
    });
  });
}

/// Opens an encrypted database at [file], writes one owner row, closes it.
Future<void> _writeOwner(File file, String keyHex) async {
  final HisabDatabase database = openEncryptedTestFile(
    file: file,
    keyHex: keyHex,
  );
  await UserRepository(database).create(
    phone: '+8801712345678',
    name: kOwnerName,
  );
  await database.close();
}
