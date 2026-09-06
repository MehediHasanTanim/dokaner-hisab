// Choosing the six digits, and confirming them.
//
// This is the first screen a shop owner ever sees. It asks for one thing, in
// Bangla, with no phone number, no code to wait for and no network call — which
// is the whole argument for a PIN over SMS OTP: from install to a working app
// with nothing in between.
//
// Two stages on one screen rather than two screens: the second entry is the
// same keypad in the same place, and a mismatch clears only the confirmation,
// so the owner never loses the digits they already got right.
//
// A refused PIN says why, on the spot. `PinPolicy` owns both the rule and the
// sentence; this screen only places it.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../format/format.dart';
import '../../theme/hisab_theme.dart';
import '../../theme/tokens.dart';
import '../lock_controller.dart';
import '../pin_policy.dart';
import '../pin_store.dart';
import 'no_backup_notice.dart';
import 'pin_keypad.dart';

/// What the owner is told when the phone would not keep the PIN.
///
/// The important half is the second sentence: the app does not carry on and
/// leave them believing they are protected.
const String kPinNotStoredMessage =
    'ফোনের নিরাপদ ভাণ্ডারে পিনটি রাখা গেল না, তাই খাতায় তালা লাগেনি। '
    'আবার চেষ্টা করুন।';

class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  /// The first entry, held only until it is confirmed and hashed. Nothing on
  /// this screen writes a PIN anywhere else, and it is gone when the widget is.
  String _chosen = '';
  String _entry = '';
  bool _confirming = false;
  bool _saving = false;
  String? _error;

  void _onDigit(String digit) {
    if (_saving || _entry.length >= kPinLength) {
      return;
    }
    setState(() {
      _entry = '$_entry$digit';
      _error = null;
    });
    if (_entry.length == kPinLength) {
      _complete();
    }
  }

  void _onBackspace() {
    if (_saving || _entry.isEmpty) {
      return;
    }
    setState(() {
      _entry = _entry.substring(0, _entry.length - 1);
      _error = null;
    });
  }

  void _complete() {
    if (!_confirming) {
      final PinWeakness? weakness = PinPolicy.inspect(_entry);
      if (weakness != null) {
        setState(() {
          _error = weakness.reason;
          _entry = '';
        });
        return;
      }
      setState(() {
        _chosen = _entry;
        _entry = '';
        _confirming = true;
      });
      return;
    }

    if (_entry != _chosen) {
      // Only the confirmation is cleared: the owner's first six digits were
      // fine and asking for them again would be punishing the wrong entry.
      setState(() {
        _error = 'দুইবারের পিন মেলেনি। আবার দিন।';
        _entry = '';
      });
      return;
    }

    _save();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(lockControllerProvider.notifier).choosePin(_chosen);
      // On success the gate replaces this screen; there is nothing to set.
    } on WeakPinException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.weakness.reason;
        _chosen = '';
        _entry = '';
        _confirming = false;
      });
    } on PinSecurityException {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = kPinNotStoredMessage;
        _entry = '';
        _confirming = false;
        _chosen = '';
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final HisabLanguage language = ref.watch(hisabLanguageProvider);
    final String? error = _error;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HisabSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                _confirming ? 'আবার একই পিন দিন' : 'ছয় সংখ্যার একটি পিন দিন',
                style: HisabTextStyles.title,
              ),
              const SizedBox(height: HisabSpacing.s2),
              Text(
                _confirming
                    ? 'মনে আছে কি না দেখে নিই — পিনটি আরেকবার দিন।'
                    : 'এই পিন দিয়েই খাতা খুলবে। ফোন অন্য কারও হাতে পড়লে সে '
                          'আপনার হিসাব দেখতে পাবে না।',
                style: HisabTextStyles.body,
              ),
              const SizedBox(height: HisabSpacing.s5),
              PinDots(filled: _entry.length, language: language),
              const SizedBox(height: HisabSpacing.s3),
              if (error != null)
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: HisabTextStyles.body.copyWith(
                    color: HisabColors.moneyOut,
                  ),
                ),
              const SizedBox(height: HisabSpacing.s5),
              PinKeypad(
                language: language,
                enabled: !_saving,
                onDigit: _onDigit,
                onBackspace: _onBackspace,
              ),
              const SizedBox(height: HisabSpacing.s4),
              const NoBackupNotice(),
              const SizedBox(height: HisabSpacing.s6),
            ],
          ),
        ),
      ),
    );
  }
}
