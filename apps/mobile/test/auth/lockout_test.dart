// The wait grows, it survives a force-quit, and nothing here destroys anything.
//
// The third of those is the one worth stating as a test rather than a comment:
// "wrong attempts never wipe data" is a claim about code that does not exist,
// and the way to keep it true a year from now is to assert that the PIN record
// is untouched after a run of failures long past any threshold someone might be
// tempted to add.

import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/auth/lockout.dart';
import 'package:hisab/auth/pin_store.dart';

import 'support/keystore.dart';

final DateTime kStart = DateTime.utc(2026, 9, 6, 10, 0, 0);

void main() {
  group('the delay grows', () {
    test('the first two are free, then it climbs', () {
      expect(PinLockout.waitAfter(0), Duration.zero);
      expect(PinLockout.waitAfter(1), Duration.zero);
      expect(PinLockout.waitAfter(2), Duration.zero);
      expect(PinLockout.waitAfter(3), greaterThan(Duration.zero));

      Duration previous = Duration.zero;
      for (int failures = 3; failures <= kPinBackoff.length; failures++) {
        final Duration wait = PinLockout.waitAfter(failures);
        expect(
          wait,
          greaterThan(previous),
          reason: 'attempt $failures must cost more than the one before it',
        );
        previous = wait;
      }
    });

    test('it never stops being at least the ceiling', () {
      // No cap on attempts, and no wipe: the hundredth wrong entry is the same
      // fifteen minutes as the tenth. An owner who misremembers their own PIN
      // is always able to keep trying.
      expect(PinLockout.waitAfter(100), kPinMaxWait);
      expect(PinLockout.waitAfter(1000), kPinMaxWait);
      expect(kPinMaxWait, const Duration(minutes: 15));
    });

    test('a failure sets a deadline the owner has to wait out', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final FakeClock clock = FakeClock(kStart);
      final PinLockout lockout = PinLockout(storage, clock: clock.call);

      await lockout.recordFailure();
      await lockout.recordFailure();
      final LockoutState third = await lockout.recordFailure();

      expect(third.failures, 3);
      expect(third.isWaiting(clock.now), isTrue);
      expect(third.remaining(clock.now), PinLockout.waitAfter(3));

      clock.advance(PinLockout.waitAfter(3));
      expect(third.isWaiting(clock.now), isFalse);
      expect(third.remaining(clock.now), Duration.zero);
    });

    test('a correct PIN clears it', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final FakeClock clock = FakeClock(kStart);
      final PinLockout lockout = PinLockout(storage, clock: clock.call);

      await lockout.recordFailure();
      await lockout.recordFailure();
      await lockout.recordFailure();
      await lockout.recordSuccess();

      final LockoutState state = await lockout.read();
      expect(state.failures, 0);
      expect(state.isWaiting(clock.now), isFalse);
    });
  });

  group('it survives being killed', () {
    test('the count and the deadline outlive the object holding them',
        () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final FakeClock clock = FakeClock(kStart);

      final PinLockout before = PinLockout(storage, clock: clock.call);
      await before.recordFailure();
      await before.recordFailure();
      await before.recordFailure();
      await before.recordFailure();

      // Force-quit: everything in memory is gone, the keystore is not.
      final PinLockout afterRelaunch = PinLockout(storage, clock: clock.call);
      final LockoutState state = await afterRelaunch.read();

      expect(state.failures, 4);
      expect(
        state.isWaiting(clock.now),
        isTrue,
        reason: 'a lockout a force-quit resets is not a lockout',
      );
      expect(state.remaining(clock.now), PinLockout.waitAfter(4));
    });

    test('the next failure after a relaunch keeps counting up', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final FakeClock clock = FakeClock(kStart);

      await PinLockout(storage, clock: clock.call).recordFailure();
      await PinLockout(storage, clock: clock.call).recordFailure();
      final LockoutState third =
          await PinLockout(storage, clock: clock.call).recordFailure();

      expect(third.failures, 3);
    });

    test('a deadline from a moved-back clock is clamped, not honoured',
        () async {
      final FakeSecureStorage storage = FakeSecureStorage(<String, String>{
        PinLockout.stateKeyName:
            const LockoutState(failures: 4).encode().replaceFirst(
              ':0',
              ':${DateTime.utc(2030).millisecondsSinceEpoch}',
            ),
      });
      final FakeClock clock = FakeClock(kStart);

      final LockoutState state = await PinLockout(
        storage,
        clock: clock.call,
      ).read();

      expect(state.remaining(clock.now), lessThanOrEqualTo(kPinMaxWait));
    });

    test('an unreadable counter does not brick the app', () async {
      final FakeSecureStorage storage = FakeSecureStorage(<String, String>{
        PinLockout.stateKeyName: 'nonsense',
      });
      final LockoutState state = await PinLockout(storage).read();
      expect(state.failures, 0);
      expect(state.isWaiting(DateTime.now()), isFalse);
    });
  });

  group('nothing here destroys anything', () {
    test('the PIN record is untouched after a long run of wrong entries',
        () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final PinStore pins = PinStore(storage, iterations: 1000);
      await pins.save('482913');

      final String salt = storage.values[PinStore.saltKeyName]!;
      final String hash = storage.values[PinStore.hashKeyName]!;

      final FakeClock clock = FakeClock(kStart);
      final PinLockout lockout = PinLockout(storage, clock: clock.call);
      for (int i = 0; i < 50; i++) {
        expect(await pins.verify('000001'), isFalse);
        await lockout.recordFailure();
        clock.advance(kPinMaxWait);
      }

      expect(storage.values[PinStore.saltKeyName], salt);
      expect(storage.values[PinStore.hashKeyName], hash);
      expect(
        await pins.verify('482913'),
        isTrue,
        reason:
            'fifty wrong entries and the owner can still get in — the threat '
            'is a person at a counter, and wiping defeats the owner, not them',
      );
    });

    test('the lockout writes only its own entry', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      await PinLockout(storage).recordFailure();
      expect(storage.values.keys, <String>[PinLockout.stateKeyName]);
    });
  });
}
