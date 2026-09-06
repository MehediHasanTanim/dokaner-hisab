// Biometric unlock: the interface, and an honest statement that it is not built.
//
// This file is a placeholder ON PURPOSE, and it is a placeholder that refuses
// rather than one that pretends. `UnavailableBiometricUnlock.isAvailable` is
// false and `authenticate` returns false, so every caller falls through to the
// PIN. Nothing in the app offers a fingerprint, so nothing has to explain why a
// fingerprint did not work.
//
// WHAT IT WOULD TAKE, written down so the next person does not rediscover it:
//
//   1. `local_auth` is NOT in pubspec.lock. Adding a package is an "Ask First"
//      in this story's boundaries, so it was not added.
//   2. On Android, `local_auth` requires the app's activity to be a
//      `FlutterFragmentActivity` rather than `FlutterActivity`, plus the
//      USE_BIOMETRIC permission. That is a change to the Android host, which
//      belongs in its own commit with its own device test.
//   3. On iOS it needs an NSFaceIDUsageDescription string, in Bangla.
//
// WHAT IT MUST NEVER BECOME. Biometric is a *convenience over* the PIN, never a
// replacement for it: the PIN stays the fallback, because a fingerprint that
// stops reading in a wet market must not lock an owner out of their own খাতা.
// And it changes nothing about storage — a successful fingerprint unlocks the
// gate; it does not decrypt anything and it does not stand in for the digest in
// `pin_store.dart`.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A way to unlock without typing six digits.
abstract interface class BiometricUnlock {
  /// True when this device has an enrolled biometric the app may use.
  Future<bool> isAvailable();

  /// Asks the platform to authenticate the owner. [reason] is shown by the OS
  /// prompt and is Bangla, like every other string the owner reads.
  ///
  /// Returns true only on a positive authentication. A cancel, a timeout and a
  /// failure are all false, and all fall through to the PIN.
  Future<bool> authenticate({required String reason});
}

/// The implementation this build ships: none.
///
/// Not a stub that returns true — that would be a lock that opens itself. Not a
/// throw either, because a caller should be able to ask "is biometric
/// available" on any device and get a plain no.
class UnavailableBiometricUnlock implements BiometricUnlock {
  const UnavailableBiometricUnlock();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate({required String reason}) async => false;
}

/// The biometric implementation in use. Overridden the day `local_auth` lands.
final Provider<BiometricUnlock> biometricUnlockProvider =
    Provider<BiometricUnlock>((ref) => const UnavailableBiometricUnlock());
