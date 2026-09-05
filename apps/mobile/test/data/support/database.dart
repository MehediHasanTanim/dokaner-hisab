// Test fixtures for the data layer.
//
// Two openers, and the difference between them matters:
//
//   [openTestDatabase]      in memory, no key. For the schema and behaviour
//                           tests, which are about the conventions and not
//                           about the cipher.
//   [openEncryptedTestFile] a real file with a real key, so that
//                           `encryption_test.dart` can read the bytes off disk
//                           and prove they are not readable.
//
// Both go through the real `HisabDatabase`, so the migration strategy — and
// therefore the append-only triggers — runs exactly as it does on a phone.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hisab/data/db/database.dart';
import 'package:hisab/data/db/encryption.dart';

/// An in-memory database with the real schema and the real triggers.
Future<HisabDatabase> openTestDatabase() async {
  final HisabDatabase database = HisabDatabase(NativeDatabase.memory());
  // Force the connection open now, so `beforeOpen` — which installs the
  // append-only guards — has run before the first assertion.
  await database.customSelect('SELECT 1').get();
  return database;
}

/// A database over a real encrypted file, for the tests that inspect the file.
HisabDatabase openEncryptedTestFile({
  required File file,
  required String keyHex,
}) {
  return HisabDatabase(encryptedExecutor(file: file, keyHex: keyHex));
}

/// A [SecureKeyStorage] that lives in a map.
///
/// `flutter_secure_storage` is a plugin and needs a platform channel, which a
/// `flutter test` unit test does not have. The production path is one class —
/// `FlutterSecureKeyStorage` — and everything else about the key lifecycle is
/// exercised here.
class FakeKeyStorage implements SecureKeyStorage {
  FakeKeyStorage([Map<String, String>? initial])
    : _values = <String, String>{...?initial};

  final Map<String, String> _values;

  /// Set to make every read and write fail, the way an unavailable keystore
  /// does. There must be no unencrypted fallback when it does.
  bool failing = false;

  int writes = 0;

  Map<String, String> get values => Map<String, String>.unmodifiable(_values);

  @override
  Future<String?> read(String key) async {
    if (failing) {
      throw const FileSystemException('keystore unavailable');
    }
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failing) {
      throw const FileSystemException('keystore unavailable');
    }
    writes++;
    _values[key] = value;
  }
}
