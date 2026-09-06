// What happens after a wrong PIN: a growing wait, and never anything worse.
//
// The threat this story defends against is a person holding the phone and
// tapping a keypad — not an attacker with the storage file and a GPU. Against a
// person, a delay that grows is a complete defence: six digits at one attempt
// every fifteen minutes is centuries. Against the file, no lockout helps at
// all, which is exactly why the PIN does not wrap the database key.
//
// So this file counts failures and computes a wait. It does NOT:
//
//   * cap the number of attempts — an owner who misremembers their own PIN
//     must always be able to keep trying;
//   * wipe, clear or damage anything — there is no path from a wrong PIN to a
//     lost খাতা anywhere in this app, and `lockout_test.dart` asserts it;
//   * hold the count in memory — a lockout that a force-quit resets is not a
//     lockout, it is a pause. The count and the deadline go to the same
//     platform keystore the PIN itself uses.
//
// KNOWN LIMIT, stated rather than hidden: the deadline is wall-clock, so
// someone who can change the device clock can skip a wait. Defeating that needs
// a monotonic clock the OS preserves across kills, which Android and iOS do not
// offer to an app. What is defended is the case the threat model names — a
// person tapping a keypad — and a forward clock jump costs the attacker the
// same wait in real time on the next failure. A *backward* jump is clamped
// below, so a wrong clock can never lock an owner out for years.

import 'dart:math';

import '../data/db/encryption.dart' show SecureKeyStorage;

/// The wait after each successive wrong PIN.
///
/// The first two are free: at a counter, one hand on the phone and a customer
/// waiting, a mistyped digit is not an attack. From the third the wait grows
/// steeply, and it stops growing at fifteen minutes — a ceiling, not a cap on
/// attempts. Fifteen minutes already makes guessing hopeless, and anything
/// longer punishes the owner far more than the person who took their phone.
const List<Duration> kPinBackoff = <Duration>[
  Duration.zero,
  Duration.zero,
  Duration(seconds: 15),
  Duration(seconds: 30),
  Duration(minutes: 1),
  Duration(minutes: 5),
  Duration(minutes: 15),
];

/// The longest an owner is ever made to wait. Also the clamp applied to a
/// stored deadline, so a device clock that moved backwards cannot strand
/// anyone.
Duration get kPinMaxWait => kPinBackoff.last;

/// How many wrong PINs there have been, and until when the keypad is closed.
class LockoutState {
  const LockoutState({this.failures = 0, this.waitingUntil});

  /// Consecutive wrong entries since the last correct one.
  final int failures;

  /// When the next attempt is allowed, in UTC. Null when there is no wait.
  final DateTime? waitingUntil;

  /// A fresh state: no failures, no wait. What a correct PIN restores.
  static const LockoutState clear = LockoutState();

  /// How long is left of the wait at [now]. Zero when the keypad is open.
  Duration remaining(DateTime now) {
    final DateTime? until = waitingUntil;
    if (until == null) {
      return Duration.zero;
    }
    final Duration left = until.difference(now.toUtc());
    return left.isNegative ? Duration.zero : left;
  }

  /// True while the owner must wait.
  bool isWaiting(DateTime now) => remaining(now) > Duration.zero;

  /// `<failures>:<deadline in milliseconds since epoch, UTC, 0 for none>`.
  ///
  /// A two-field string rather than JSON: it is written to a keystore entry
  /// that a person may one day read while debugging a locked-out phone, and it
  /// should be obvious at a glance what it says.
  String encode() =>
      '$failures:${waitingUntil?.toUtc().millisecondsSinceEpoch ?? 0}';

  /// Parses a stored value. Never throws.
  ///
  /// A record this build cannot read is treated as "no failures yet". That is a
  /// deliberate fail-open on a *counter*: failing closed on an unreadable
  /// counter would brick the app for its owner, and anyone who can write
  /// garbage into the platform keystore can equally well erase the entry. The
  /// PIN record itself fails closed — see `pin_store.dart`, where a malformed
  /// record throws rather than letting anybody in.
  static LockoutState decode(String? raw) {
    if (raw == null) {
      return clear;
    }
    final List<String> parts = raw.split(':');
    if (parts.length != 2) {
      return clear;
    }
    final int? failures = int.tryParse(parts[0]);
    final int? deadline = int.tryParse(parts[1]);
    if (failures == null || deadline == null || failures < 0 || deadline < 0) {
      return clear;
    }
    return LockoutState(
      failures: failures,
      waitingUntil: deadline == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(deadline, isUtc: true),
    );
  }

  @override
  String toString() => 'LockoutState(failures: $failures, until: $waitingUntil)';
}

/// The attempt counter, persisted beside the PIN.
class PinLockout {
  PinLockout(this.storage, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// The keystore entry. Versioned like every other entry in this app.
  static const String stateKeyName = 'hisab.pin.attempts.v1';

  final SecureKeyStorage storage;
  final DateTime Function() _clock;

  /// The wait imposed after [failures] consecutive wrong entries.
  static Duration waitAfter(int failures) {
    if (failures < 1) {
      return Duration.zero;
    }
    return kPinBackoff[min(failures, kPinBackoff.length) - 1];
  }

  /// The stored state, with its deadline clamped against a moved clock.
  Future<LockoutState> read() async {
    final String? raw;
    try {
      raw = await storage.read(stateKeyName);
    } on Object catch (error) {
      throw PinLockoutUnavailableException(
        'Could not read the PIN attempt count from the platform keystore.',
        error,
      );
    }
    return _clamped(LockoutState.decode(raw));
  }

  /// Counts one wrong PIN and returns the state that follows it.
  Future<LockoutState> recordFailure() async {
    final LockoutState current = await read();
    final int failures = current.failures + 1;
    final Duration wait = waitAfter(failures);
    final LockoutState next = LockoutState(
      failures: failures,
      waitingUntil: wait > Duration.zero
          ? _clock().toUtc().add(wait)
          : current.waitingUntil,
    );
    await _persist(next);
    return next;
  }

  /// Clears the count after a correct PIN. The only thing that clears it.
  Future<LockoutState> recordSuccess() async {
    await _persist(LockoutState.clear);
    return LockoutState.clear;
  }

  Future<void> _persist(LockoutState state) async {
    try {
      await storage.write(stateKeyName, state.encode());
    } on Object catch (error) {
      throw PinLockoutUnavailableException(
        'Could not write the PIN attempt count to the platform keystore.',
        error,
      );
    }
  }

  /// A deadline further away than the longest wait can only come from a device
  /// clock that moved backwards. It is brought back to the ceiling rather than
  /// honoured — and rather than dropped, which would hand a free attempt to
  /// anyone who changes the date.
  LockoutState _clamped(LockoutState state) {
    final DateTime? until = state.waitingUntil;
    if (until == null) {
      return state;
    }
    final DateTime now = _clock().toUtc();
    final DateTime ceiling = now.add(kPinMaxWait);
    if (until.isAfter(ceiling)) {
      return LockoutState(failures: state.failures, waitingUntil: ceiling);
    }
    return state;
  }
}

/// The keystore could not be reached to read or write the attempt count.
class PinLockoutUnavailableException implements Exception {
  const PinLockoutUnavailableException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'PinLockoutUnavailableException: $message';
}
