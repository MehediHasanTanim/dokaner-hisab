// The screen between a phone and the খাতা.
//
// It shows four things and nothing else: six dots, a keypad, what went wrong,
// and — when a wait is running — how many seconds are left of it, counting
// down. There is no figure from the ledger anywhere on it, which is the first
// acceptance criterion of this story: someone holding a stolen phone learns
// nothing about the shop from this screen, not even whether it has money in it.
//
// THE WAIT IS STATED, NOT HIDDEN. A keypad that silently ignores taps reads as
// a broken app. The seconds are rendered through `lib/format/`, in the owner's
// digits, like every other number in the product (UX-DR4).
//
// "আমি পিন ভুলে গেছি" tells the truth and offers no bypass. There is no reset,
// because with no phone number linked there is no second identity to prove
// ownership with — a reset anyone could trigger is not a lock. What reinstalling
// costs is said plainly rather than discovered afterwards.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../format/format.dart';
import '../../theme/hisab_theme.dart';
import '../../theme/tokens.dart';
import '../lock_controller.dart';
import '../pin_policy.dart';
import 'pin_keypad.dart';

/// The honest answer to a forgotten PIN. A constant so a test can assert this
/// exact text is what the owner is shown.
const String kForgottenPinAnswer =
    'পিন ফিরে পাওয়ার কোনো উপায় নেই। এখনো কোনো মোবাইল নম্বর যুক্ত করা নেই, '
    'তাই আপনি যে মালিক তা প্রমাণ করার উপায়ও নেই। অ্যাপটি মুছে আবার বসালে ঢোকা '
    'যাবে, কিন্তু এই ফোনের পুরো খাতা তখন মুছে যাবে।';

/// The label the owner taps. Named in the story, word for word.
const String kForgottenPinLabel = 'আমি পিন ভুলে গেছি';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  String _entry = '';
  bool _checking = false;
  bool _showForgotten = false;

  /// Ticks once a second, only while a wait is running. Started and stopped
  /// from `build`, so there is no timer alive on a screen with no countdown on
  /// it — a permanent timer would rebuild this screen forever and would keep a
  /// test from ever settling.
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _syncTicker({required bool waiting}) {
    if (waiting && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (Timer _) {
        if (mounted) {
          setState(() {});
        }
      });
    } else if (!waiting && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }

  void _onDigit(String digit) {
    if (_checking || _entry.length >= kPinLength) {
      return;
    }
    ref.read(lockControllerProvider.notifier).clearFailureNotice();
    setState(() => _entry = '$_entry$digit');
    if (_entry.length == kPinLength) {
      _submit();
    }
  }

  void _onBackspace() {
    if (_checking || _entry.isEmpty) {
      return;
    }
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _checking = true);
    try {
      await ref.read(lockControllerProvider.notifier).submit(_entry);
    } finally {
      if (mounted) {
        // Cleared either way: on success the gate replaces this screen, and on
        // failure the next attempt starts from an empty keypad.
        setState(() {
          _entry = '';
          _checking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final HisabLanguage language = ref.watch(hisabLanguageProvider);
    final HisabLockState lock = ref.watch(lockControllerProvider);
    final DateTime now = ref.read(lockClockProvider)();
    final Duration wait = lock.lockout.remaining(now);
    final bool waiting = wait > Duration.zero;
    _syncTicker(waiting: waiting);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HisabSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('পিন দিন', style: HisabTextStyles.title),
              const SizedBox(height: HisabSpacing.s2),
              Text(
                'খাতা খুলতে আপনার ছয় সংখ্যার পিন দিন।',
                style: HisabTextStyles.body,
              ),
              const SizedBox(height: HisabSpacing.s5),
              PinDots(filled: _entry.length, language: language),
              const SizedBox(height: HisabSpacing.s3),
              _Message(language: language, lock: lock, wait: wait),
              const SizedBox(height: HisabSpacing.s5),
              PinKeypad(
                language: language,
                enabled: !waiting && !_checking,
                onDigit: _onDigit,
                onBackspace: _onBackspace,
              ),
              const SizedBox(height: HisabSpacing.s3),
              TextButton(
                onPressed: () =>
                    setState(() => _showForgotten = !_showForgotten),
                child: const Text(kForgottenPinLabel),
              ),
              if (_showForgotten) ...<Widget>[
                const SizedBox(height: HisabSpacing.s3),
                Card(
                  color: HisabColors.warnSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(HisabMetrics.cardPadding),
                    child: Text(
                      kForgottenPinAnswer,
                      style: HisabTextStyles.banner,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: HisabSpacing.s6),
            ],
          ),
        ),
      ),
    );
  }
}

/// The one line under the dots: the wait, or the wrong PIN, or nothing.
class _Message extends StatelessWidget {
  const _Message({
    required this.language,
    required this.lock,
    required this.wait,
  });

  final HisabLanguage language;
  final HisabLockState lock;
  final Duration wait;

  @override
  Widget build(BuildContext context) {
    if (wait > Duration.zero) {
      // Rounded up, so the last second is shown as one rather than as zero.
      final int seconds = (wait.inMilliseconds / Duration.millisecondsPerSecond)
          .ceil();
      return Text(
        'আবার চেষ্টা করতে ${_count(seconds, language)} সেকেন্ড বাকি।',
        textAlign: TextAlign.center,
        style: HisabTextStyles.body.copyWith(color: HisabColors.warn),
      );
    }

    if (lock.lastAttemptFailed) {
      return Text(
        'পিন মেলেনি। আবার চেষ্টা করুন।',
        textAlign: TextAlign.center,
        style: HisabTextStyles.body.copyWith(color: HisabColors.moneyOut),
      );
    }

    // The row keeps its height whether or not there is a message in it, so the
    // keypad does not jump under the owner's thumb when one appears.
    return Text('', style: HisabTextStyles.body);
  }
}

/// A plain count — seconds — in the owner's digits.
///
/// Grouping and script both come from `lib/format/`; this writes neither. There
/// is one digit-script rule in the product and this is not a second one.
String _count(int value, HisabLanguage language) => HisabDigits.toScript(
  HisabDigits.group(value.toString(), language),
  language,
);
