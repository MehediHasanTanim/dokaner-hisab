// Whether the খাতা is open, and what closes it.
//
// AR-29: a Riverpod notifier is the only thing that mutates this state. The
// gate widget observes the lifecycle and calls in; the two screens call in; no
// widget flips a flag of its own. There is exactly one answer to "is the app
// locked" in the running app, and it is `state.phase` here.
//
// WHAT LOCKS THE APP, and nothing else does:
//
//   * a cold start, always, before any ledger figure is built (`restore`);
//   * coming back after five minutes or more away (`onForegrounded`).
//
// Thirty seconds away is a shop owner answering a call, which is not a threat
// and must not cost them a PIN entry with a customer waiting. Five minutes is
// the number FR-7 names.
//
// WHAT THE LOCK DOES NOT TOUCH. Recording and syncing are not gated. This
// controller holds no repository, opens no database and cancels no work: the
// lock is on *reading* the খাতা on screen. A sync queue draining in the
// background while the phone sits locked on the counter is the correct
// behaviour, not a leak.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/encryption.dart' show SecureKeyStorage;
import '../data/db/platform_keystore.dart' show FlutterSecureKeyStorage;
import 'lockout.dart';
import 'pin_store.dart';

/// Where the app is between launch and the খাতা.
enum LockPhase {
  /// Before the keystore has answered. Nothing from the ledger is built in this
  /// phase — it is the first frame of a cold start, and rendering the app
  /// "until we find out" is exactly the leak this story exists to close.
  unknown,

  /// No PIN on this device yet: the set-PIN screen.
  needsPin,

  /// A PIN exists and has not been entered: the unlock screen.
  locked,

  /// The owner is in.
  open,

  /// The platform keystore could not be reached, so neither "there is a PIN"
  /// nor "there is not" can be answered honestly. The খাতা stays shut and the
  /// owner is told why — the one thing this app must never do is open on the
  /// strength of a question it could not ask.
  unavailable,
}

/// The lock, as the widgets see it.
class LockState {
  const LockState({
    required this.phase,
    this.lockout = LockoutState.clear,
    this.lastAttemptFailed = false,
  });

  final LockPhase phase;

  /// The persisted attempt count and wait.
  final LockoutState lockout;

  /// True when the most recent entry was wrong — what the unlock screen says
  /// "পিন মেলেনি" about. Cleared as soon as the owner types again.
  final bool lastAttemptFailed;

  bool get isOpen => phase == LockPhase.open;

  LockState copyWith({
    LockPhase? phase,
    LockoutState? lockout,
    bool? lastAttemptFailed,
  }) => LockState(
    phase: phase ?? this.phase,
    lockout: lockout ?? this.lockout,
    lastAttemptFailed: lastAttemptFailed ?? this.lastAttemptFailed,
  );

  @override
  String toString() => 'LockState($phase, $lockout, failed: $lastAttemptFailed)';
}

/// The one mutator of the lock (AR-29).
class LockController extends Notifier<LockState> {
  /// FR-7: locked again after five minutes in the background.
  static const Duration graceWindow = Duration(minutes: 5);

  DateTime? _leftAt;

  late PinStore _pins;
  late PinLockout _lockout;
  late DateTime Function() _clock;

  @override
  LockState build() {
    _pins = ref.watch(pinStoreProvider);
    _lockout = ref.watch(pinLockoutProvider);
    _clock = ref.watch(lockClockProvider);
    // Deliberately NOT `unknown -> open`. The gate calls `restore()` as it
    // mounts; until the keystore answers, the app shows nothing of the ledger.
    return const LockState(phase: LockPhase.unknown);
  }

  /// Reads the keystore and decides the opening screen. Called once, by the
  /// gate, on a cold start.
  Future<void> restore() async {
    try {
      final bool hasPin = await _pins.isSet();
      final LockoutState lockout = hasPin
          ? await _lockout.read()
          : LockoutState.clear;
      state = LockState(
        phase: hasPin ? LockPhase.locked : LockPhase.needsPin,
        lockout: lockout,
      );
    } on PinSecurityException {
      state = const LockState(phase: LockPhase.unavailable);
    } on PinLockoutUnavailableException {
      state = const LockState(phase: LockPhase.unavailable);
    }
  }

  /// Stores a new PIN and opens the খাতা.
  ///
  /// Throws [PinSecurityException] — weak PIN, or a keystore that would not
  /// keep it. The screen shows the reason; the owner is never told they are
  /// protected on the strength of a write that failed.
  Future<void> choosePin(String pin) async {
    await _pins.save(pin);
    await _lockout.recordSuccess();
    state = const LockState(phase: LockPhase.open);
  }

  /// Tries [pin]. True when it opened the খাতা.
  ///
  /// A wrong PIN counts an attempt and lengthens the wait. It never wipes, and
  /// there is no attempt at which it starts to.
  Future<bool> submit(String pin) async {
    if (state.lockout.isWaiting(_clock())) {
      return false;
    }

    try {
      final bool correct = await _pins.verify(pin);
      if (correct) {
        final LockoutState cleared = await _lockout.recordSuccess();
        state = LockState(phase: LockPhase.open, lockout: cleared);
        return true;
      }

      final LockoutState next = await _lockout.recordFailure();
      state = LockState(
        phase: LockPhase.locked,
        lockout: next,
        lastAttemptFailed: true,
      );
      return false;
    } on PinSecurityException {
      // A keystore that stopped answering mid-session. Not an unlock, and not
      // a counted attempt either — the owner may well have typed it correctly.
      state = const LockState(phase: LockPhase.unavailable);
      return false;
    } on PinLockoutUnavailableException {
      state = const LockState(phase: LockPhase.unavailable);
      return false;
    }
  }

  /// Clears the "পিন মেলেনি" line as soon as the owner starts typing again.
  void clearFailureNotice() {
    if (state.lastAttemptFailed) {
      state = state.copyWith(lastAttemptFailed: false);
    }
  }

  /// Closes the খাতা now. Used by the five-minute rule, and available to a
  /// later "lock now" control.
  void lockNow() {
    if (state.phase == LockPhase.open) {
      state = state.copyWith(phase: LockPhase.locked, lastAttemptFailed: false);
    }
  }

  /// The app went to the background. Only the moment is recorded — locking on
  /// the way out would mean the owner returns to a PIN screen after glancing at
  /// a notification.
  void onBackgrounded() => _leftAt = _clock();

  /// The app came back. Five minutes or more away and the খাতা closes.
  void onForegrounded() {
    final DateTime? left = _leftAt;
    _leftAt = null;
    if (left == null) {
      return;
    }
    if (_clock().difference(left) >= graceWindow) {
      lockNow();
    }
  }

  /// Visible for the screens: how long is left of the current wait.
  Duration remainingWait() => state.lockout.remaining(_clock());
}

/// The platform keystore (AD-17), shared with the database key.
///
/// One entry point to secure storage in the whole app. A test overrides this
/// provider and everything above it — the PIN store, the lockout, both screens
/// — runs unchanged with no platform channel.
final Provider<SecureKeyStorage> secureKeyStorageProvider =
    Provider<SecureKeyStorage>((ref) => FlutterSecureKeyStorage());

/// The clock the lock reads. Injected so the five-minute rule and the countdown
/// can be tested without waiting five minutes.
final Provider<DateTime Function()> lockClockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

/// The salt and digest (never the PIN).
final Provider<PinStore> pinStoreProvider = Provider<PinStore>(
  (ref) => PinStore(ref.watch(secureKeyStorageProvider)),
);

/// The persisted attempt count and growing wait.
final Provider<PinLockout> pinLockoutProvider = Provider<PinLockout>(
  (ref) => PinLockout(
    ref.watch(secureKeyStorageProvider),
    clock: ref.watch(lockClockProvider),
  ),
);

/// Whether the খাতা is open.
final NotifierProvider<LockController, LockState> lockControllerProvider =
    NotifierProvider<LockController, LockState>(LockController.new);
