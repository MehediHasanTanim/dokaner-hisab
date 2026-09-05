---
title: "Story 1.4: Keep the shop's data safe on the phone"
type: 'feature'
created: '2026-09-05'
status: 'in-review'
baseline_commit: '672c6c44bd6c83e1bee68f787999f88554ee13f6'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-1-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-1-3-show-numbers-the-way-the-owner-reads-them.md'
  - '{project-root}/_bmad-output/planning-artifacts/architecture/architecture-hisab-dokan-2026-08-29/ARCHITECTURE-SPINE.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Nothing is stored yet. Everything the owner records lives on the phone first and syncs later, so the local database is the product's real system of record — and a phone left on a counter is stolen or borrowed. It has to be encrypted, and the conventions it establishes (money, quantity, identity, time, append-only) are the ones every table in every later epic inherits. Get them wrong here and every later story inherits the mistake.

**Approach:** Drift over SQLCipher with a key minted on device and held in the platform keystore. Four tables only — User, Business, MoneyAccount, MoneyMovement — with the column conventions expressed as reusable Drift mixins so a later table cannot quietly deviate. Repositories become the sole database surface, and build-time checks make each invariant fail CI rather than review.

## Boundaries & Constraints

**Always:** Money columns are integer paisa named `…Paisa`; quantity columns integer milli-units named `…Milli` (AD-1, AD-2). Every primary key is a client-minted UUIDv7 and every foreign key stores that UUID; there is no `serverId` anywhere (AD-3). Every transaction row stores a UTC timestamp **and** a `businessDate` derived once at creation against Asia/Dhaka (AD-14). Financial tables are append-only — no UPDATE, no DELETE — and a correction is a reversal plus a new row (AD-4). Every table carries `businessId` (AD-11). Every table is classified financial or reference in one registry, with a check that fails on an unclassified table (AD-9). Financial tables carry no unique constraint besides the primary key (AD-10).

**Never:** No `openingBalancePaisa`, and no balance column on `MoneyAccount` — a balance is `Σ MoneyMovement.amountPaisa` and nothing else (AD-19). No table beyond the four; the full schema is not created upfront. No widget reads or writes the database. No key in the bundle, in plaintext preferences, or derived from anything guessable. No `double` anywhere near a stored value. No seeding of the five Money Accounts here — that belongs to the story that creates a Business.

**Ask First:** Any fifth table. Any deviation from the four ADs above. Adding a package not already in `pubspec.lock`. Any change to how the key is stored.

## Decisions this story must make, because the planning artifacts do not state them

| Gap | Decision | Why |
|---|---|---|
| `MoneyMovement.type` values — only `Opening` is stated | Store the type as text with a Dart enum; define `opening` **only**, and document that later stories add values | A text column takes a new enum value with no migration; inventing `payment`/`expense`/`transfer` now would guess at stories not yet specified |
| Reversal linkage | The reversing row carries `reversesId`; there is **no** `reversedById` on the original | Setting `reversedById` after the fact is an UPDATE on a financial row, which AD-4 forbids. "Was this reversed?" is a read-time lookup. AD-15 names `reversedById` on `Sale`; the same contradiction will surface in Epic 4 and is flagged, not fixed, here |
| Is `User` financial or reference? | Reference | It is mutable identity, not a money record |
| Currency column on `Business` | None — ৳ BDT is a constant | "Displayed and not editable in MVP"; a column implies a choice that does not exist |
| Money Account extensibility | Table carries a `type` from the five stated values plus a display name; nothing here adds accounts | The PRD fixes five and says nothing about owner-added ones. The shape allows it later without a migration; this story does not decide it |
| Key material | 256 bits from the platform CSPRNG, hex-encoded, written once via `flutter_secure_storage` | AD-17 says keystore-backed and not guessable. On Android that package stores an AES-GCM blob whose key lives in the Android Keystore — which is what AD-17's "never in shared preferences" is aimed at (plaintext prefs), not a prohibition on the package |
| Asia/Dhaka conversion | Fixed UTC+6, hand-implemented, no `timezone` package | Bangladesh abolished DST in 2010 and has one offset. A tz database would add data files and a load step for a constant. **Flagged in-file:** this is wrong the day the product leaves Bangladesh |

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| First run | No key in the keystore | A 256-bit key is minted and stored; the database opens encrypted | Failure to reach the keystore surfaces as a typed error, never a silent unencrypted fallback |
| Later runs | Key present | The same key opens the same database | A key that fails to open the file is reported, never regenerated over the data |
| Encryption is real | The database file, read raw | The header is not `SQLite format 3` — an unencrypted file is a failing test, not a warning | N/A |
| Business date at 23:00 UTC | Timestamp 2026-09-05T23:00Z | `businessDate` is 2026-09-06 — Dhaka is already the next day | N/A |
| Business date at 17:00 UTC | Timestamp 2026-09-05T17:00Z | `businessDate` is 2026-09-05 — 23:00 in Dhaka | N/A |
| Opening balance | An owner sets ৳5,000 on Cash | One `MoneyMovement`, type `opening`, `amountPaisa` 500000 | N/A |
| Correcting it | Owner changes it to ৳4,000 | A reversal row (−500000, `reversesId` set) **plus** a new row (+400000); the original is untouched | An attempted UPDATE on a financial table throws in debug and is caught by a test |
| Account balance | Three movements on one account | `Σ amountPaisa`, computed at read time | N/A |
| Skipped account | Owner leaves an account blank at setup | No row is written — a blank is not a zero | N/A |
| Ordering | Two movements, same `businessDate` | Ordered by `(businessDate, id)` — UUIDv7 is time-ordered, so the tiebreak is creation order | N/A |
| Widget touches the DB | A file under `lib/` outside `lib/data/` imports drift | The check reports file and line and exits non-zero | CI blocks the merge |
| Unclassified table | A new table with no entry in the registry | The classification check fails the build | CI blocks the merge |
| Local write latency | A movement inserted on a mid-range 2023 Android device | Confirms within 100 ms (NFR-1), and the measured figure is recorded in the repo | N/A |

</frozen-after-approval>

## Code Map

- `apps/mobile/lib/format/` -- the number layer from Story 1.3. Storage-side code passes integers; **nothing in `lib/data/` formats a figure**. `MoneyFormat.paisaPerTaka` and `QuantityFormat.milliPerUnit` are the scale constants — do not redeclare them.
- `apps/mobile/lib/main.dart` -- `ProviderScope` is already in place. The database provider is created here or read from it; no widget receives a `Database` instance.
- `apps/mobile/pubspec.yaml` -- `drift ^2.34.4`, `drift_dev ^2.34.6`, `sqlite3 ^3.5.2`, `flutter_secure_storage ^11.0.0`, `uuid ^4.6.0`, `path_provider ^2.1.6`, `build_runner ^2.16.1` are all resolved and locked. The `hooks: user_defines: sqlite3: source: sqlcipher` block is what makes the bundled SQLite a SQLCipher build — it is already there and is load-bearing.
- `apps/mobile/tool/check_theme_tokens.dart`, `tool/check_single_formatter.dart` -- the established pattern for a build-time check: a rule list with `what` and `instead`, `file:line:col` reporting, exit 1, and a test that plants a violation. Follow it; write a third file, do not merge.
- `.github/workflows/ci.yml` -- fonts check → theme check → formatter check → `flutter analyze` → `flutter test`. Code generation must run **before** analyze, and the new checks join the list.
- `apps/mobile/test/theme/`, `test/format/` -- the test layout to follow.
- Read-only evidence: no `lib/data/`, no Drift usage, no generated code anywhere in the repo yet.

## Tasks & Acceptance

**Execution:**
- [x] `apps/mobile/lib/data/ids.dart` -- UUIDv7 minting behind one function -- AD-3 rests on v7's time ordering; one call site makes the version auditable.
- [x] `apps/mobile/lib/data/business_date.dart` -- UTC instant → Asia/Dhaka business date, and the fixed-offset caveat -- AD-14 derives this once at creation, so it must be one function everything calls.
- [x] `apps/mobile/lib/data/classification.dart` -- the AD-9 registry: every table named exactly once as financial or reference -- an unclassified table is the hole AD-9 exists to close.
- [x] `apps/mobile/lib/data/db/encryption.dart` -- mint, store and read the key; open the database with it; fail loudly rather than fall back to plaintext -- a silent unencrypted fallback is the worst possible outcome of this story.
- [x] `apps/mobile/lib/data/db/columns.dart` -- Drift mixins for the conventions: UUIDv7 primary key, `businessId`, UTC timestamp plus `businessDate`, and the append-only marker -- a convention that must be retyped per table is a convention that will be forgotten.
- [x] `apps/mobile/lib/data/db/tables.dart` -- Users, Businesses, MoneyAccounts, MoneyMovements, and nothing else -- four tables, the conventions applied, no balance column anywhere.
- [x] `apps/mobile/lib/data/db/database.dart` -- the Drift database, schema version 1, forward-only migration strategy, and the guard that makes an UPDATE or DELETE on a financial table throw -- AD-4 enforced by the database, not by discipline.
- [x] `apps/mobile/lib/data/repositories/*.dart` -- one repository per table, plus the account-balance read (`Σ amountPaisa`) and the opening-balance correction (reversal + new row in one transaction) -- AR-29 makes these the sole database surface.
- [x] `apps/mobile/lib/data/providers.dart` -- Riverpod providers for the database and the repositories -- the only way a caller reaches storage.
- [x] `apps/mobile/tool/check_data_access.dart` -- fail on: drift imported outside `lib/data/`, a `…Paisa`/`…Milli` naming violation, a balance-shaped column, `serverId`, and a table missing from the registry -- five invariants, each cheap to check and expensive to discover late.
- [x] `apps/mobile/test/data/conventions_test.dart` -- assert the four ADs against the real schema: PK types, no `serverId`, column naming, no balance column, every table classified.
- [x] `apps/mobile/test/data/encryption_test.dart` -- assert the file on disk is not a readable SQLite database, that a wrong key fails to open it, and that a second run reuses the stored key.
- [x] `apps/mobile/test/data/money_movement_test.dart` -- opening balance, correction by reversal, balance as a sum, ordering by `(businessDate, id)`, and that an UPDATE on a financial table throws.
- [x] `apps/mobile/test/data/business_date_test.dart` -- the two boundary rows of the matrix plus midnight either side.
- [x] `apps/mobile/test/data/check_data_access_test.dart` -- plant a violation per rule so the guard cannot rot into a no-op.
- [x] `apps/mobile/tool/benchmark_local_write.dart` -- a runnable harness that inserts a movement N times and prints median and p95 -- NFR-1 requires a *measured* figure, and a number nobody can reproduce is not a measurement.
- [x] `apps/mobile/BENCHMARKS.md` -- where the measured figure and the device it came from are recorded, with the harness command -- the AC asks for it to be recorded.
- [x] `.github/workflows/ci.yml` -- run `dart run build_runner build --delete-conflicting-outputs` before analyze, and add the data check.

**Acceptance Criteria:**
- Given a phone that is stolen, when the database file is read off the device, then it is not a readable SQLite file and the key is not recoverable from the bundle or from plaintext preferences.
- Given any table defined in this story or a later one, when the build runs, then its money and quantity column names, its primary key, its `businessId` and its classification are checked, and CI fails on a violation.
- Given a financial row, when any code attempts to update or delete it, then the attempt fails rather than succeeding quietly.
- Given a widget, when it needs data, then it reaches a repository through a provider and cannot reach the database directly.
- Given the encrypted database on a mid-range 2023 Android device, when a local write is benchmarked, then the confirmed write is under 100 ms and the figure and the device are recorded in `BENCHMARKS.md`.

## Spec Change Log

- **Review pass, 05-09-2026 — read by hand; no toolchain reachable.** The
  implementing agent was cut off by a rate limit after the last file was written
  but before its own review. I read the security core (`encryption.dart`,
  `platform_keystore.dart`), the schema (`columns.dart`, `tables.dart`,
  `classification.dart`), the append-only enforcement in `database.dart`, the
  correction path in `MoneyMovementRepository`, `ids.dart` and
  `business_date.dart` line by line against the ADs, and ran an independent
  invariant scan over all of `lib/` (drift imported outside `lib/data/`,
  `serverId`, `openingBalancePaisa`, balance-shaped columns, `IntColumn` not
  named `…Paisa`/`…Milli`): **clean on every one**. Bracket balance across all
  43 Dart files: clean. No defects found this pass.
- **Verified by reading, worth naming:** `PRAGMA cipher_version` is asked
  *before* `PRAGMA key`, which is the only honest way to detect a plain-SQLite
  build — a plain build swallows `PRAGMA key` silently and writes a readable
  file. The raw-key form `PRAGMA key = "x'<64 hex>'"` is correct SQLCipher
  syntax. `Random.secure()`, not `Random()`.
- **Unverified, and it is the whole file set:** Drift code generation has never
  run, so no `.g.dart` exists and nothing here has been compiled. Companion
  shapes, `textEnum`, `TypeConverter` on a mixin column, and `primaryKey`
  declared in a mixin are all written from the documented API. The first
  `build_runner` run is the real test.

## Design Notes

**Code generation is not optional and cannot run here.** Drift needs `dart run build_runner build --delete-conflicting-outputs`; the `.g.dart` files do not exist until it runs. Nothing in this story compiles before that step, and CI must run it too.

**Append-only enforced by the database.** A `beforeUpdate`/`beforeDelete` interceptor on the financial tables throws. Discipline is what AD-4 asks for; a throw is what makes it true at three in the morning in Epic 5.

**Why `reversesId` and not `reversedById`.** Marking the original as reversed would be an UPDATE on a financial row. The reversing row points backwards instead, and "is this reversed?" is a lookup. This is a real divergence from AD-15's wording for `Sale`, recorded here so Epic 4 meets it as a known question rather than a surprise.

## Verification

**Commands:**
- `cd apps/mobile && dart run build_runner build --delete-conflicting-outputs` -- expected: generated files written, no errors
- `cd apps/mobile && dart run tool/check_data_access.dart` -- expected: exit 0
- `cd apps/mobile && flutter analyze` -- expected: no issues
- `cd apps/mobile && flutter test` -- expected: all pass
- `cd apps/mobile && flutter run` on a real Android device, then `dart run tool/benchmark_local_write.dart` -- expected: median and p95 under 100 ms; record both and the device in `BENCHMARKS.md`
