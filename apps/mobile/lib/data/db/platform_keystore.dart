// The platform half of AD-17: the real keystore, and the real file path.
//
// Everything about the key that can be reasoned about without a phone lives in
// `encryption.dart`, which imports no Flutter. This file holds the two things
// that genuinely need the platform:
//
//   * `flutter_secure_storage` — the Android Keystore / iOS Keychain binding.
//   * `path_provider` — the app's documents directory.
//
// The split keeps `tool/benchmark_local_write.dart` runnable under `dart run`,
// which has no Flutter engine: a single `package:flutter` import in the
// transitive graph of `encryption.dart` would make the harness impossible to
// run, and an unrunnable benchmark is not a measurement.
//
// No AndroidOptions or IOSOptions are passed. The defaults are the
// platform-backed ones, and the option classes have been reshaped between major
// versions of the package; pinning an option here that a later upgrade renames
// fails the build in a way that is easy to "fix" by deleting the option, which
// is how a security setting quietly disappears. Adding a specific keychain
// accessibility class is a deliberate change, in its own commit, with a test.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'encryption.dart';

/// The platform keystore: an Android Keystore-encrypted blob on Android, the
/// Keychain on iOS. Never plaintext shared preferences (AD-17).
class FlutterSecureKeyStorage implements SecureKeyStorage {
  FlutterSecureKeyStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? _defaultStorage();

  // ignore: prefer_const_constructors
  static FlutterSecureStorage _defaultStorage() => FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

/// Where the database lives on the device.
Future<File> defaultDatabaseFile() async {
  final Directory documents = await getApplicationDocumentsDirectory();
  return File(p.join(documents.path, kDatabaseFileName));
}

/// The executor the running app uses: the device keystore, the device path.
QueryExecutor deviceEncryptedExecutor({
  SecureKeyStorage? storage,
  Future<File> Function()? resolveFile,
  bool logStatements = false,
}) {
  return encryptedExecutorWith(
    storage: storage ?? FlutterSecureKeyStorage(),
    resolveFile: resolveFile ?? defaultDatabaseFile,
    logStatements: logStatements,
  );
}
