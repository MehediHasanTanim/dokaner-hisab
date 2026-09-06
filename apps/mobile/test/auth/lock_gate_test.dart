// The gate, from the owner's side and from a stranger's.
//
// The first acceptance criterion is the one this file exists for: "given a
// stolen phone, when someone opens the app, then they see a PIN screen and no
// figure from the ledger". So the widget behind the gate carries a canary
// string that no other part of the tree contains, and every locked state
// asserts it is nowhere on screen — not covered, not scrolled off: absent.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/auth/lock_controller.dart';
import 'package:hisab/auth/lock_gate.dart';
import 'package:hisab/auth/lockout.dart';
import 'package:hisab/auth/pin_store.dart';
import 'package:hisab/auth/screens/no_backup_notice.dart';
import 'package:hisab/auth/screens/set_pin_screen.dart';
import 'package:hisab/auth/screens/unlock_screen.dart';
import 'package:hisab/format/format.dart';
import 'package:hisab/theme/hisab_theme.dart';

import 'support/keystore.dart';

/// A figure from the ledger. If this is ever on screen while the app is locked,
/// the lock leaks.
const String kLedgerCanary = 'রহিমের বাকি ৪,০৮০';

const String kPin = '482913';
const String kWrongPin = '730264';

/// Cheap KDF: this file is testing the gate, not the cost of PBKDF2.
const int kTestIterations = 1000;

final DateTime kStart = DateTime.utc(2026, 9, 6, 10, 0, 0);

class _LedgerCanaryScreen extends StatelessWidget {
  const _LedgerCanaryScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text(kLedgerCanary)));
}

Widget _app(FakeSecureStorage storage, FakeClock clock) {
  return ProviderScope(
    overrides: <Override>[
      secureKeyStorageProvider.overrideWithValue(storage),
      lockClockProvider.overrideWithValue(clock.call),
      pinStoreProvider.overrideWithValue(
        PinStore(storage, iterations: kTestIterations),
      ),
    ],
    child: MaterialApp(
      theme: HisabTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const LockGate(child: _LedgerCanaryScreen()),
    ),
  );
}

/// Taps a PIN on the keypad. The labels are Bangla digits; the value behind
/// them is Western — that conversion is `lib/format/`'s and is asserted here by
/// using it to find the keys.
Future<void> _tapPin(WidgetTester tester, String pin) async {
  for (final String digit in pin.split('')) {
    await tester.tap(
      find.widgetWithText(
        TextButton,
        HisabDigits.toScript(digit, HisabLanguage.bangla),
      ),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> _leaveAndReturn(WidgetTester tester, FakeClock clock, Duration away) async {
  final LockGateState gate = tester.state<LockGateState>(
    find.byType(LockGate),
  );
  gate.didChangeAppLifecycleState(AppLifecycleState.paused);
  clock.advance(away);
  gate.didChangeAppLifecycleState(AppLifecycleState.resumed);
  await tester.pumpAndSettle();
}

void main() {
  late FakeSecureStorage storage;
  late FakeClock clock;

  setUp(() {
    storage = FakeSecureStorage();
    clock = FakeClock(kStart);
  });

  group('first launch', () {
    testWidgets('asks for a PIN and shows nothing from the ledger', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();

      expect(find.byType(SetPinScreen), findsOneWidget);
      expect(find.text(kLedgerCanary), findsNothing);
    });

    testWidgets('says plainly that the khata lives only on this phone', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();

      expect(find.byType(NoBackupNotice), findsOneWidget);
      expect(find.text(NoBackupNotice.message), findsOneWidget);
    });

    testWidgets('a PIN chosen and confirmed opens the khata', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();

      await _tapPin(tester, kPin);
      expect(
        find.text(kLedgerCanary),
        findsNothing,
        reason: 'the first entry is not the PIN yet — it has to be confirmed',
      );

      await _tapPin(tester, kPin);
      expect(find.text(kLedgerCanary), findsOneWidget);
      expect(storage.values.containsKey(PinStore.hashKeyName), isTrue);
    });

    testWidgets('a weak PIN is refused with the reason on screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();

      await _tapPin(tester, '111111');

      expect(find.byType(SetPinScreen), findsOneWidget);
      expect(
        find.textContaining('একই সংখ্যা ছয়বার'),
        findsOneWidget,
        reason: 'a refusal with no stated reason is a dead end',
      );
      expect(storage.values.containsKey(PinStore.hashKeyName), isFalse);
    });

    testWidgets('a mismatched confirmation says so', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();

      await _tapPin(tester, kPin);
      await _tapPin(tester, kWrongPin);

      expect(find.textContaining('মেলেনি'), findsOneWidget);
      expect(find.text(kLedgerCanary), findsNothing);
    });
  });

  group('cold start with a PIN already set', () {
    setUp(() async {
      await PinStore(storage, iterations: kTestIterations).save(kPin);
    });

    testWidgets('is locked before any ledger figure is built', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app(storage, clock));

      // The very first frame, before the keystore has answered.
      expect(find.text(kLedgerCanary), findsNothing);

      await tester.pumpAndSettle();
      expect(find.byType(UnlockScreen), findsOneWidget);
      expect(find.text(kLedgerCanary), findsNothing);
    });

    testWidgets('the right PIN unlocks', (WidgetTester tester) async {
      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();

      await _tapPin(tester, kPin);

      expect(find.text(kLedgerCanary), findsOneWidget);
      expect(find.byType(UnlockScreen), findsNothing);
    });

    testWidgets('a wrong PIN is refused, counted, and destroys nothing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();

      await _tapPin(tester, kWrongPin);

      expect(find.text(kLedgerCanary), findsNothing);
      expect(find.textContaining('পিন মেলেনি'), findsOneWidget);
      expect(
        LockoutState.decode(storage.values[PinLockout.stateKeyName]).failures,
        1,
      );

      // And the owner can still get in.
      await _tapPin(tester, kPin);
      expect(find.text(kLedgerCanary), findsOneWidget);
    });

    testWidgets('the honest answer to a forgotten PIN offers no way in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();

      await tester.tap(find.text(kForgottenPinLabel));
      await tester.pumpAndSettle();

      expect(find.text(kForgottenPinAnswer), findsOneWidget);
      expect(find.text(kLedgerCanary), findsNothing);
    });
  });

  group('coming back from the background', () {
    setUp(() async {
      await PinStore(storage, iterations: kTestIterations).save(kPin);
    });

    Future<void> unlock(WidgetTester tester) async {
      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();
      await _tapPin(tester, kPin);
      expect(find.text(kLedgerCanary), findsOneWidget);
    }

    testWidgets('thirty seconds away is not a threat', (
      WidgetTester tester,
    ) async {
      await unlock(tester);
      await _leaveAndReturn(tester, clock, const Duration(seconds: 30));

      expect(
        find.text(kLedgerCanary),
        findsOneWidget,
        reason: 'a shop owner answering a call must not lose their place',
      );
    });

    testWidgets('four minutes fifty-nine is still not', (
      WidgetTester tester,
    ) async {
      await unlock(tester);
      await _leaveAndReturn(
        tester,
        clock,
        const Duration(minutes: 4, seconds: 59),
      );

      expect(find.text(kLedgerCanary), findsOneWidget);
    });

    testWidgets('five minutes away locks it', (WidgetTester tester) async {
      await unlock(tester);
      await _leaveAndReturn(tester, clock, LockController.graceWindow);

      expect(find.byType(UnlockScreen), findsOneWidget);
      expect(find.text(kLedgerCanary), findsNothing);
    });

    testWidgets('an hour away locks it', (WidgetTester tester) async {
      await unlock(tester);
      await _leaveAndReturn(tester, clock, const Duration(hours: 1));

      expect(find.text(kLedgerCanary), findsNothing);
    });

    testWidgets('the gate is what observes the lifecycle', (
      WidgetTester tester,
    ) async {
      await unlock(tester);
      expect(
        tester.state<LockGateState>(find.byType(LockGate)),
        isA<WidgetsBindingObserver>(),
        reason: 'without the observer nothing would ever re-lock the app',
      );
    });
  });

  group('a keystore that will not answer', () {
    testWidgets('the app says so and opens nothing', (
      WidgetTester tester,
    ) async {
      storage.failing = true;

      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('নিরাপদ ভাণ্ডারে পৌঁছানো যাচ্ছে না'),
        findsOneWidget,
      );
      expect(find.text(kLedgerCanary), findsNothing);
      expect(
        find.byType(SetPinScreen),
        findsNothing,
        reason:
            'offering to set a PIN would invite an owner to lock a khata that '
            'may already be locked with digits they remember',
      );
    });

    testWidgets('a write that stores nothing does not claim to have locked it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_app(storage, clock));
      await tester.pumpAndSettle();

      storage.swallowing = true;
      await _tapPin(tester, kPin);
      await _tapPin(tester, kPin);

      expect(find.text(kLedgerCanary), findsNothing);
      expect(find.text(kPinNotStoredMessage), findsOneWidget);
    });
  });

  group('a lockout that outlives the app', () {
    testWidgets('a wait recorded before a force-quit still applies', (
      WidgetTester tester,
    ) async {
      await PinStore(storage, iterations: kTestIterations).save(kPin);
      final PinLockout lockout = PinLockout(storage, clock: clock.call);
      await lockout.recordFailure();
      await lockout.recordFailure();
      await lockout.recordFailure();

      // A completely fresh app over the same keystore.
      await tester.pumpWidget(_app(storage, clock));
      // Pumped by hand rather than settled: the countdown runs a one-second
      // timer, so there is deliberately no such thing as a settled frame while
      // a wait is on screen.
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('সেকেন্ড বাকি'), findsOneWidget);
      expect(find.text(kLedgerCanary), findsNothing);

      final TextButton key = tester.widget<TextButton>(
        find.widgetWithText(
          TextButton,
          HisabDigits.toScript('4', HisabLanguage.bangla),
        ),
      );
      expect(
        key.onPressed,
        isNull,
        reason: 'the keypad is closed while the wait runs, and says so',
      );

      // The wait passes and the keypad opens again — a delay, never a wipe.
      clock.advance(PinLockout.waitAfter(3));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await _tapPin(tester, kPin);
      expect(find.text(kLedgerCanary), findsOneWidget);
    });
  });
}
