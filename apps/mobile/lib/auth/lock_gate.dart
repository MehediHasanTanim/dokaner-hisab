// The one gate. Everything the owner can reach is behind it.
//
// `main.dart` wraps `home` in this widget, so there is a single place the lock
// is applied and no screen can be reached around it. When the lock is on, the
// child is NOT BUILT — not covered, not faded, not pushed under a route. That
// distinction is the point: a lock screen drawn over a live ledger still has
// the ledger in the widget tree, in the OS task-switcher thumbnail, and one
// stray route pop away. Here there is nothing to reveal, because nothing was
// built.
//
// The cost is honest and small: the child rebuilds when the app unlocks, so a
// scroll position taken before a five-minute absence is lost. A lost scroll
// position is worth a khata that cannot leak.
//
// WHAT IS NOT GATED. This widget gates rendering. It holds no repository,
// closes no database and cancels no background work — recording and syncing
// continue while the phone sits locked, which is what the story asks for.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/hisab_theme.dart';
import '../theme/tokens.dart';
import 'lock_controller.dart';
import 'screens/set_pin_screen.dart';
import 'screens/unlock_screen.dart';

/// Wraps the app in the PIN lock.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({required this.child, super.key});

  /// What the owner sees once they are in.
  final Widget child;

  @override
  LockGateState createState() => LockGateState();
}

/// Public so a widget test can drive the lifecycle callbacks directly, the way
/// `ScaffoldState` and `FormState` are public. It holds no state of its own —
/// the lock lives in the notifier (AR-29).
class LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Deferred by a microtask: a provider must not be written during the build
    // that is mounting its reader. Until it answers, `LockPhase.unknown` shows
    // an empty page — never the child.
    unawaited(
      Future<void>.microtask(
        () => ref.read(lockControllerProvider.notifier).restore(),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final LockController controller = ref.read(
      lockControllerProvider.notifier,
    );
    switch (state) {
      case AppLifecycleState.paused ||
          AppLifecycleState.hidden ||
          AppLifecycleState.detached:
        controller.onBackgrounded();
      case AppLifecycleState.resumed:
        controller.onForegrounded();
      case AppLifecycleState.inactive:
        // The app switcher, a notification shade, an incoming call banner. The
        // owner has not left, and starting the five-minute clock here would
        // lock the app while it is still in their hand.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LockPhase phase = ref.watch(
      lockControllerProvider.select((LockState state) => state.phase),
    );

    return switch (phase) {
      // The first frame of a cold start, before the keystore has answered.
      // Blank paper, deliberately: no ledger, and no flash of one.
      LockPhase.unknown => const Scaffold(body: SizedBox.expand()),
      LockPhase.needsPin => const SetPinScreen(),
      LockPhase.locked => const UnlockScreen(),
      LockPhase.open => widget.child,
      LockPhase.unavailable => const _KeystoreUnavailableScreen(),
    };
  }
}

/// What the owner sees when the phone's own secure storage will not answer.
///
/// Not the ledger, and not a set-PIN screen either: with the keystore
/// unreachable this build cannot tell whether a PIN already exists, and
/// offering to set one would invite an owner to lock a khata that may already
/// be locked by digits they still remember.
class _KeystoreUnavailableScreen extends StatelessWidget {
  const _KeystoreUnavailableScreen();

  static const String message =
      'ফোনের নিরাপদ ভাণ্ডারে পৌঁছানো যাচ্ছে না, তাই খাতা খোলা হচ্ছে না। '
      'অ্যাপটি একবার বন্ধ করে আবার খুলুন।';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HisabSpacing.screenMargin),
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: HisabTextStyles.body,
            ),
          ),
        ),
      ),
    );
  }
}
