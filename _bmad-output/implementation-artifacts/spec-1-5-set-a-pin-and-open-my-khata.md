---
title: 'Story 1.5: Set a PIN and open my খাতা'
type: 'feature'
created: '2026-09-06'
status: 'in-review'
baseline_commit: 'bd6beb783663f81536e25900141880318fc19999'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-1-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-1-4-keep-the-shops-data-safe-on-the-phone.md'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-hisab-dokan-2026-08-29/EXPERIENCE.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The app opens straight into whatever screen is wired to `home`. Anyone holding the phone can read the shop's ledger and its customers' phone numbers. SMS OTP was the planned gate, but it costs money per message, needs a BTRC-registered sender ID that takes weeks, and puts a network round trip between install and a shop owner's first sale.

**Approach:** A six-digit PIN chosen on the device. No phone number, no network call, nothing to wait for. The PIN is stored only as a salted hash in the platform keystore and gates the app on cold start and after five minutes in the background. It does **not** wrap the database key — Story 1.4's SQLCipher key stays keystore-held and untouched.

## Boundaries & Constraints

**Always:** The PIN is six digits. Only a salted hash reaches storage. Failed attempts back off with a growing delay. Every string the owner reads is Bangla. Repositories stay the sole database surface (AR-29) and Riverpod notifiers the only state mutators. The lock gates reading, never recording: background sync is unaffected.

**Never:** The PIN is never written in the clear, never logged, never sent anywhere — there is no network call in this story at all. The PIN never derives or wraps the SQLCipher key (see Design Notes — this is the load-bearing decision). Wrong attempts never wipe data. No phone number is collected. No "forgot PIN" path silently lets anyone in.

**Ask First:** Adding any package beyond `crypto`. Any change to how the database key is stored. Any reduction in the honesty of the no-backup warning.

## Decisions this story makes

| Gap | Decision | Why |
|---|---|---|
| Does the PIN encrypt the database? | **No.** It is an access gate; AD-17's keystore key still encrypts the file | A six-digit secret is a million combinations — seconds to brute force offline. Wrapping the key with it would buy almost no security and would mean a forgotten PIN destroys the shop's records forever |
| Hashing | PBKDF2-HMAC-SHA256, 32-byte random salt, high iteration count, constant-time compare | `crypto` is already in the lockfile transitively; promote it to a direct dependency. Argon2 would be better and needs a package that is not there |
| Lockout policy | Growing delay, no cap on total attempts, **no wipe** | The threat is a person holding the phone, not an automated attacker with the file. Wiping a shop's ledger because the owner misremembered is a worse outcome than the attack |
| Forgotten PIN | No reset. The screen says so, in Bangla, and names reinstalling as the only way — which erases the খাতা | There is no second identity yet to prove ownership with. A reset that anyone can trigger is not a lock. Epic 6's phone number is what makes reset possible |
| Lock default | **On.** Story 1.10 had it off by default | With no account behind it, the PIN is the only thing between a stolen phone and the ledger |
| Biometric | Not built. Interface only | Needs `local_auth`, absent from the lockfile, plus a `FlutterFragmentActivity` change on Android. A convenience over the PIN, not a replacement — recorded as an open action item rather than counted as done |

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| First launch | No PIN in the keystore | The set-PIN screen, in Bangla, with confirm | N/A |
| Weak PIN | `111111`, `123456`, `654321`, a top-N common PIN | Refused with the reason stated | Not silently accepted |
| Mismatch | Confirm differs from the first entry | Says so and clears the confirm field only | N/A |
| Set | Six digits, confirmed | Salt and hash written to the keystore, then read back and verified before the owner is let in | A keystore failure is surfaced; the owner is not told they are protected when they are not |
| Correct PIN | Matching entry | Unlocks | N/A |
| Wrong PIN | Non-matching entry | Refused, attempt counted, next attempt delayed longer | Never a wipe |
| Backoff | Several wrong entries | The wait is stated in Bangla with the seconds counting down | N/A |
| Backoff survives a kill | App force-quit mid-lockout | The delay still applies on relaunch | Persisted, not held in memory |
| Cold start | App launched, PIN already set | Locked before any ledger data is on screen | N/A |
| Background 5 min | Foreground after ≥5 minutes away | Locked | N/A |
| Background 30 s | Foreground after a short interruption | Not locked — a shop owner answering a call is not a threat | N/A |
| Locked + sync | Sync work pending while locked | Continues; recording and syncing are not gated | N/A |
| No backup warning | Owner has not linked a phone | Told plainly, in Bangla, that the খাতা lives only on this phone | Never buried, never alarming |
| Forgotten PIN | Owner taps "আমি পিন ভুলে গেছি" | The truth: no way back in without a linked number; reinstalling erases the খাতা | No bypass offered |

</frozen-after-approval>

## Code Map

- `apps/mobile/lib/data/db/encryption.dart` -- `SecureKeyStorage` is the interface to the platform keystore, and `FlutterSecureKeyStorage` in `platform_keystore.dart` implements it. **Reuse them.** The PIN's salt and hash are two more keystore entries; do not introduce a second storage abstraction.
- `apps/mobile/lib/data/db/encryption.dart` -- `DatabaseKeyStore` shows the pattern this story follows: write, read back, compare, and refuse to proceed if the keystore lied. Also `mintDatabaseKeyHex` for `Random.secure()`.
- `apps/mobile/lib/format/language.dart` -- `HisabLanguage` and its Riverpod provider. Lock strings follow the language; digits in the countdown go through `lib/format/`.
- `apps/mobile/lib/theme/` -- every colour, size and radius. No literals: `tool/check_theme_tokens.dart` enforces it. A PIN keypad is buttons at `HisabMetrics.minHitTarget` or larger.
- `apps/mobile/lib/main.dart` -- `ProviderScope` + `MaterialApp` with `home: ThemePreviewScreen()`. The lock gate wraps whatever `home` is, so the preview stays reachable behind it.
- `apps/mobile/lib/data/providers.dart` -- where repository providers live; the PIN providers follow the same shape.
- `apps/mobile/pubspec.yaml` -- `crypto` is **transitive**; promote it with `flutter pub add crypto`. `flutter_secure_storage ^11.0.0` is already direct.
- `apps/mobile/tool/check_*.dart` -- three build checks exist; follow the pattern if a fourth is warranted, do not merge files.
- Read-only evidence: no lock, no PIN, no `WidgetsBindingObserver` anywhere in `lib/` today.

## Tasks & Acceptance

**Execution:**
- [x] `apps/mobile/pubspec.yaml` -- promote `crypto` to a direct dependency via `flutter pub add crypto` -- depending on a transitive package is depending on someone else's choice.
- [x] `apps/mobile/lib/auth/pin_policy.dart` -- what six digits are, and which are refused: all-same, ascending or descending runs, and a short list of the commonest -- the rule belongs in one testable place, not in a form validator.
- [x] `apps/mobile/lib/auth/pin_store.dart` -- salt, PBKDF2 hash, constant-time compare, and the write-read-verify dance from `DatabaseKeyStore` -- the PIN never exists in storage in a readable form.
- [x] `apps/mobile/lib/auth/lockout.dart` -- attempt count and the growing delay, persisted so a force-quit does not reset it -- an in-memory lockout is not a lockout.
- [x] `apps/mobile/lib/auth/lock_controller.dart` -- a Riverpod notifier holding locked/unlocked, driven by cold start and by five minutes in the background -- AR-29: notifiers are the only state mutators.
- [x] `apps/mobile/lib/auth/lock_gate.dart` -- the widget that wraps the app, observes lifecycle, and shows the lock screen over everything -- one gate, so no screen can be reached around it.
- [x] `apps/mobile/lib/auth/screens/set_pin_screen.dart` -- choose and confirm, in Bangla, with the weak-PIN reason shown inline.
- [x] `apps/mobile/lib/auth/screens/unlock_screen.dart` -- the keypad, the wrong-PIN message, the counting-down wait, and the honest "আমি পিন ভুলে গেছি" text.
- [x] `apps/mobile/lib/auth/screens/no_backup_notice.dart` -- the one sentence that tells the owner their খাতা lives only on this phone -- the single place this story costs a user something real.
- [x] `apps/mobile/lib/auth/biometrics.dart` -- the interface and a no-op implementation, with the `local_auth` requirement written down -- an honest placeholder, not a pretend feature.
- [x] `apps/mobile/lib/main.dart` -- wrap `home` in the lock gate.
- [x] `apps/mobile/test/auth/pin_policy_test.dart` -- every weak-PIN row, and that six ordinary digits pass.
- [x] `apps/mobile/test/auth/pin_store_test.dart` -- a hash is stored and the PIN is not; the same PIN verifies; a different one does not; two installs of the same PIN produce different hashes.
- [x] `apps/mobile/test/auth/lockout_test.dart` -- the delay grows, it survives a restart, and no path wipes data.
- [x] `apps/mobile/test/auth/lock_gate_test.dart` -- locked on cold start; locked after 5 minutes away; not locked after 30 seconds; ledger content is not on screen while locked.

**Acceptance Criteria:**
- Given a stolen phone, when someone opens the app, then they see a PIN screen and no figure from the ledger, and no number of attempts destroys the owner's data.
- Given the keystore, when it is dumped, then it holds a salt and a hash and nothing from which the PIN can be read back.
- Given an owner with no phone number linked, when they use the app, then they have been told plainly in Bangla that the খাতা lives only on this phone.
- Given the app is locked, when sync work is pending, then it continues — the lock is on reading, not on recording.

## Spec Change Log

- **Review pass, 06-09-2026 — read by hand, plus one real verification.** No Dart
  toolchain is reachable, but the cryptography could be checked properly: I
  ported `pbkdf2HmacSha256` to Python exactly as written and compared it against
  `hashlib.pbkdf2_hmac` over six cases — 1, 2, 3, 4096 and 100,000 iterations, 20,
  32 and 64-byte outputs, including the shipping parameters. **Byte-exact on
  every one.** The RFC vector pinned in `pin_store_test.dart`
  (`password`/`salt`/1 iteration) is also correct — verified independently, not
  taken on trust, which matters because the implementing agent said plainly it
  had written that vector from memory.
- Ported all three build checks over `lib/` again: **0 violations** each. Bracket
  balance across the 16 new and edited files: clean. `crypto` resolves at exactly
  3.0.7 against a `^3.0.7` constraint, so `flutter pub get` is a no-op.
- **Verified by reading:** when the phase is not `open`, `LockGate` does not build
  the child at all rather than overlaying it — so no ledger widget exists in the
  tree, and none appears in the task-switcher thumbnail. `AppLifecycleState.inactive`
  deliberately does not start the five-minute clock, so a notification shade or an
  incoming call does not lock the app in the owner's hand.
- **Three things beyond the spec, all flagged rather than buried:** a shared
  `pin_keypad.dart` (the alternative was two copies of a keypad), a
  `LockPhase.unavailable` for a keystore that throws on cold start (otherwise an
  unhandled exception behind a blank screen), and a test-support fake keystore
  that models "accepts writes and stores nothing" — which is what proves the
  read-back verification earns its place.
- **Unverified, and it is the usual list:** nothing has been compiled.
  `ConsumerStatefulWidget`, `provider.select`, `overrideWithValue` and the
  `AppLifecycleState` or-pattern are written from the documented APIs and are not
  attested anywhere else in this repo.
- **One number worth measuring:** 100,000 PBKDF2 iterations run on the UI isolate.
  If unlock stutters on a low-end phone, move the derivation to a background
  isolate rather than lowering the count — the count is stored per record, so it
  can be changed later without locking anyone out.

## Design Notes

**The PIN does not wrap the database key, and that is the decision to argue with if you disagree with any.** Six digits is a million combinations: anyone who can read the storage exhausts that in seconds regardless of the KDF. So wrapping AD-17's key with it would add almost nothing an attacker notices, while guaranteeing that a shop owner who forgets six digits loses nine years of records with no recourse. The keystore already provides at-rest protection. The PIN's job is the person at the counter, and it should be honest about being that.

**Backoff, not lockout.** The threat model is a human tapping a keypad. A growing delay defeats that completely. A wipe defeats the owner.

## Verification

**Commands:**
- `cd apps/mobile && flutter pub add crypto` -- expected: resolved and locked
- `cd apps/mobile && dart run build_runner build --delete-conflicting-outputs`
- `cd apps/mobile && dart run tool/check_theme_tokens.dart && dart run tool/check_single_formatter.dart && dart run tool/check_data_access.dart` -- expected: exit 0
- `cd apps/mobile && flutter analyze && flutter test` -- expected: clean
- `cd apps/mobile && flutter run` -- expected: set a PIN, force-quit, reopen, be asked for it
