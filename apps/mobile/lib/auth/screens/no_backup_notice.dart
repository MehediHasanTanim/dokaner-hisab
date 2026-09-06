// The one sentence in this story that costs the owner something real.
//
// A PIN promises protection, and the honest half of that promise is what it
// does NOT protect against: this খাতা exists on this phone and nowhere else.
// No account, no phone number, no server copy — the shop's whole record is one
// dropped handset away from gone, and the owner has to know that on the day
// they set the PIN, not on the day they lose the phone.
//
// EXPERIENCE.md § Voice: "Say what a number leaves out, in the same breath",
// and "warnings state the consequence, then allow the action". So this is a
// plain statement on the warning surface at the point of consequence — not a
// dialog, not a red alarm, and not something the owner can dismiss and forget,
// because the consequence does not go away when the banner does.
//
// It says nothing about a future backup. Epic 6 links a phone number and makes
// both backup and PIN reset possible; promising that here would be a promise
// this build cannot keep.

import 'package:flutter/material.dart';

import '../../theme/hisab_theme.dart';
import '../../theme/tokens.dart';

/// The plain truth about where the খাতা lives.
class NoBackupNotice extends StatelessWidget {
  const NoBackupNotice({super.key});

  /// Kept as a constant so a test can assert this exact sentence reaches the
  /// owner, and so the wording is changed in one place by someone who has read
  /// why it is worded this way.
  static const String message =
      'আপনার খাতা শুধু এই ফোনেই থাকে। ফোন হারালে বা অ্যাপ মুছে ফেললে হিসাব '
      'ফিরে পাওয়ার কোনো উপায় নেই।';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: HisabColors.warnSurface,
      child: Padding(
        padding: const EdgeInsets.all(HisabMetrics.cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.info_outline,
              color: HisabColors.warn,
              size: HisabMetrics.iconSize,
            ),
            const SizedBox(width: HisabSpacing.s3),
            Expanded(
              child: Text(message, style: HisabTextStyles.banner),
            ),
          ],
        ),
      ),
    );
  }
}
