---
title: 'Story 1.3: Show numbers the way the owner reads them'
type: 'feature'
created: '2026-09-05'
status: 'in-review'
baseline_commit: 'ebb0d7e4cb6f118359f12f9762c0d4e347ceee84'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-1-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-1-2-make-the-app-look-like-hisab.md'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-hisab-dokan-2026-08-29/DESIGN.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Money is stored as integer paisa and quantity as integer milli-units, and nothing yet turns either into something a shop owner reads. The owner writes ৳১,০৮,৫০০ in their khata — Bangla digits, lakh grouping — and will type figures back in whichever script their keyboard is in. Every surface in the product (screens, receipts, reports, CSV, notifications, the AI draft parser) has to render the identical stored value, and the moment a second implementation appears the two drift and a receipt disagrees with a screen.

**Approach:** One formatter and one parser, in `lib/format/`, taking the stored integer and a language and returning the string — and the reverse. Grouping and digits are implemented explicitly rather than delegated to locale data, because the acceptance criterion names the exact output. A build check makes a second implementation fail CI, the same way the theme's literal check does.

## Boundaries & Constraints

**Always:** Money crosses this boundary as integer paisa, quantity as integer milli-units; the formatter never takes or returns a double for a stored value. Bangla renders Bangla digits with lakh grouping — ৳১,০৮,৫০০, never ৳১০৮,৫০০. English renders Western digits with Western grouping from the identical stored value. Input accepts Bangla digits, Western digits or a mix in either mode. Parsing is total: it returns a result, never throws on user input.

**Decided by Tanim, 05-09-2026:**
- Paisa are hidden when zero and shown as two digits when non-zero: ৳১,০৮,৫০০ and ৳১,০৮,৫০০.৫০. Never round a displayed figure — a column that does not sum to its total is the one defect this product cannot ship.
- CSV and any other machine-readable surface always emit Western digits, ungrouped, with a `.` decimal: `108500.50`. A CSV carrying Bangla digits and lakh commas is unopenable in the spreadsheet the owner's accountant uses.

**Ask First:** Any rounding rule beyond banker's rounding already fixed by AD-1. Any change to how paisa or milli-units are stored. Adding a package.

**Never:** No second formatter or parser anywhere — no `NumberFormat` construction, no `toStringAsFixed`, no hand-written ৳ concatenation outside `lib/format/`. No double arithmetic on a stored money value. No locale-data dependency for the grouping rule. Do not build the language *setting* — that is Story 1.9; this story exposes the language as a parameter with a Bangla default and nothing persisted.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Lakh grouping | 10850000 paisa, Bangla | `৳১,০৮,৫০০` — last three digits, then twos | N/A |
| Same value, English | 10850000 paisa, English | `৳108,500` | N/A |
| Non-zero paisa | 10850050 paisa, Bangla | `৳১,০৮,৫০০.৫০` | N/A |
| Below one taka | 50 paisa, Bangla | `৳০.৫০` | N/A |
| Zero | 0 paisa | `৳০` / `৳0`, never blank — a deliberate zero differs from an unanswered field | N/A |
| Negative | -10850000 paisa | `−৳১,০৮,৫০০` with U+2212, sign before the currency mark | N/A |
| Large | 999999999999 paisa | Groups correctly past a crore; no overflow, no scientific notation | N/A |
| Quantity | 2500 milli, unit কেজি | `২.৫ কেজি` — trailing zeros trimmed, never `২.৫০০` | N/A |
| Whole quantity | 3000 milli | `৩` , not `৩.০` | N/A |
| Parse Bangla | `১,০৮,৫০০` | 10850000 paisa | N/A |
| Parse Western | `108500.50` | 10850050 paisa | N/A |
| Parse mixed script | `১08,৫00.5` | 10850050 paisa — the keypad belongs to the device | N/A |
| Parse decorated | `৳ ১,০৮,৫০০ ` with spaces, mark, commas | 10850000 paisa | N/A |
| Parse rubbish | `abc`, `১.২.৩`, `--5`, empty | A typed failure the caller can turn into a Bangla message | Returns a failure result; never throws |
| Parse over-precise | `10.999` taka | Rejected rather than silently rounded — the owner sees what they typed | Failure result |
| Machine-readable | 10850050 paisa, export mode | `108500.50` in any language | N/A |
| Round trip | Any paisa value → format → parse | The identical integer comes back | N/A |

</frozen-after-approval>

## Code Map

- `apps/mobile/lib/theme/tokens.dart` -- `HisabColors`, `HisabTypeScale`, `HisabSpacing`, `HisabMetrics`. Read-only here; the formatter has no styling.
- `apps/mobile/lib/theme/hisab_theme.dart` -- `HisabTextStyles` carries tabular figures on every numeric style. The formatter produces the string; the theme aligns it. Do not restate alignment concerns in `lib/format/`.
- `apps/mobile/lib/theme/theme_preview.dart` -- the dev screen. `_TypeScale._amount` currently holds a hard-coded `'৳১,০৮,৫০০'`; it becomes a formatter call, which is what proves the utility on a device.
- `apps/mobile/lib/main.dart` -- already wraps the app in `ProviderScope`. The language provider goes in `lib/format/`, is read here or by the preview, and persists nothing.
- `apps/mobile/tool/check_theme_tokens.dart` -- the existing pattern for a build-time check: rules with a `what` and an `instead`, file:line reporting, exit 1. The number check follows its shape; do not merge the two files.
- `apps/mobile/.github/../ci.yml` (repo root `.github/workflows/ci.yml`) -- flutter job runs the font check, `dart run tool/check_theme_tokens.dart`, `flutter analyze`, `flutter test`. The new check joins that list.
- `apps/mobile/test/theme/` -- existing test layout and style to follow: one file per concern, a `support/` folder for fixtures, reasons on every expect.
- `intl` ^0.20.3 is in `pubspec.lock` and is used for date formatting later; it is **not** the grouping implementation here.
- Read-only evidence: no `lib/format/`, no existing number handling anywhere in `lib/`.

## Tasks & Acceptance

**Execution:**
- [x] `apps/mobile/lib/format/language.dart` -- `HisabLanguage { bangla, english }` plus a Riverpod provider defaulting to Bangla regardless of device locale -- Story 1.9 replaces the provider's backing store; every other file depends on the enum, not on the storage.
- [x] `apps/mobile/lib/format/digits.dart` -- Bangla↔Western digit mapping and the two grouping rules (lakh: last three then twos; Western: threes) -- one place where a digit's script and a group's width are decided.
- [x] `apps/mobile/lib/format/money.dart` -- paisa → display string in either language, plus the ungrouped Western export form -- the paisa-hidden-when-zero rule lives here and nowhere else.
- [x] `apps/mobile/lib/format/quantity.dart` -- milli-units → display string with trailing zeros trimmed, optional unit label -- quantity is not money and must not inherit the currency mark.
- [x] `apps/mobile/lib/format/parse.dart` -- text → paisa and text → milli, accepting either script or a mix, returning a typed success/failure -- total on user input, so a keypad can never crash a form.
- [x] `apps/mobile/lib/format/format.dart` -- the barrel every caller imports -- one import to reach for makes the rule obvious.
- [x] `apps/mobile/lib/theme/theme_preview.dart` -- replace the hard-coded amounts with formatter calls and add a section showing one stored value in both languages -- makes the story visible on a device and gives the widget tests something real.
- [x] `apps/mobile/tool/check_single_formatter.dart` -- fail on `NumberFormat(`, `toStringAsFixed(`, `intl` number APIs and literal `৳` outside `lib/format/`, reporting file, line and the fix -- "no second implementation" is worthless unenforced.
- [x] `apps/mobile/test/format/money_test.dart` -- every money row of the matrix, including the boundary at one taka, the negative sign, and a large value past a crore.
- [x] `apps/mobile/test/format/quantity_test.dart` -- trimming, whole values, and that quantity never carries ৳.
- [x] `apps/mobile/test/format/parse_test.dart` -- every parse row, plus a property-style round trip over a spread of paisa values.
- [x] `apps/mobile/test/format/single_source_test.dart` -- assert the check itself catches a planted violation, so the guard cannot rot into a no-op.
- [x] `.github/workflows/ci.yml` -- run the new check beside the theme one.

**Acceptance Criteria:**
- Given the same stored integer, when it is rendered in Bangla and in English, then only the digits and the grouping differ — the value never does.
- Given any surface that shows or reads a figure, when it needs a number, then it calls this utility, and CI fails if a second implementation appears.
- Given an owner typing on any keyboard, when they enter digits in either script or a mix, then the field accepts it and normalises to one internal value.
- Given a displayed figure, when it is read back by the parser, then the original stored integer returns unchanged.

## Spec Change Log

- **Review pass, 05-09-2026 — read by hand, no toolchain reachable.** The
  implementing agent ported `digits/money/quantity/parse` to Python and executed
  every value the tests assert (~230 assertions, 0 mismatches), and ported both
  build checks over the real `lib/` (0 violations). I re-ran both check ports
  independently — still 0 and 0 — walked the grouping, split and parser logic
  against the matrix by hand, and confirmed bracket balance across all 22 Dart
  files. No defects found this pass, unlike Story 1.2's.
- **The one unverified thing** is the Riverpod 3.4.2 API in
  `lib/format/language.dart`: `Notifier` + `NotifierProvider` is written from the
  documented core API and has never been compiled. If `flutter analyze` reports
  anything, look there first.

## Design Notes

**Why the grouping is hand-written.** `intl` can produce Indian grouping from locale data, but the acceptance criterion names the exact output — ৳১,০৮,৫০০, never ৳১০৮,৫০০ — and locale data changes between package versions. A twenty-line rule that is asserted directly is worth more here than a dependency whose behaviour is a moving target. `intl` stays in the project for dates.

**Lakh grouping, stated once:** take the digits right to left; the first group is three, every group after it is two. 10850000 paisa → 108500 taka → `1,08,500`.

**Parsing is total.** A parse failure is a normal outcome of a keypad, not an exception. Return a result the caller can turn into a Bangla message via the existing error-code pattern; never throw, so no form can crash on a stray keystroke.

## Verification

**Commands:**
- `cd apps/mobile && dart run tool/check_single_formatter.dart` -- expected: exit 0
- `cd apps/mobile && dart run tool/check_theme_tokens.dart` -- expected: still exit 0 after the preview edits
- `cd apps/mobile && flutter analyze` -- expected: no issues
- `cd apps/mobile && flutter test` -- expected: all pass
- `cd apps/mobile && flutter run` -- expected: the preview shows one stored value rendered in both languages
