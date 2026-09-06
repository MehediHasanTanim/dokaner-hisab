// A keystore that lives in a map, plus the two ways a real one fails.
//
// `flutter_secure_storage` is a plugin and needs a platform channel, which a
// `flutter test` unit test does not have. `SecureKeyStorage` exists for exactly
// this reason (Story 1.4), and the PIN reuses it rather than introducing a
// second storage abstraction.
//
// Two failure modes are modelled, because the PIN code treats them differently:
//
//   [failing]     every read and write throws — an unreachable keystore.
//   [swallowing]  writes report success and store nothing — a keystore that
//                 lies. This is the one that matters most: without the
//                 write-read-verify dance in `PinStore.save`, an owner would be
//                 told their খাতা is locked when it is not.

import 'package:hisab/data/db/encryption.dart';

class FakeSecureStorage implements SecureKeyStorage {
  FakeSecureStorage([Map<String, String>? initial])
    : _values = <String, String>{...?initial};

  final Map<String, String> _values;

  /// Every read and write throws.
  bool failing = false;

  /// Writes are accepted and dropped.
  bool swallowing = false;

  int writes = 0;
  int reads = 0;

  Map<String, String> get values => Map<String, String>.unmodifiable(_values);

  /// Every stored value as one string, for asserting that a secret is absent
  /// from the whole store rather than from one entry.
  String get dump => _values.entries
      .map((MapEntry<String, String> e) => '${e.key}=${e.value}')
      .join('\n');

  @override
  Future<String?> read(String key) async {
    reads++;
    if (failing) {
      throw StateError('keystore unavailable');
    }
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failing) {
      throw StateError('keystore unavailable');
    }
    writes++;
    if (swallowing) {
      return;
    }
    _values[key] = value;
  }
}

/// A clock a test moves by hand.
///
/// The five-minute background rule and the growing wait are both about time
/// passing, and a test that waits five real minutes is a test nobody runs.
class FakeClock {
  FakeClock(this.now);

  DateTime now;

  DateTime call() => now;

  void advance(Duration by) => now = now.add(by);
}
