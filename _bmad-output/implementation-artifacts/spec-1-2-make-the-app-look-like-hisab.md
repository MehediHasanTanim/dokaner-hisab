---
title: 'Story 1.2: Make the app look like Hisab'
type: 'feature'
created: '2026-09-04'
status: 'in-review'
baseline_commit: 'c196677bb6789cc13c0b31543763553d317d1529'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-1-context.md'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-hisab-dokan-2026-08-29/DESIGN.md'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-hisab-dokan-2026-08-29/EXPERIENCE.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** `apps/mobile` is still the Flutter counter demo — purple Material defaults, system fonts, no tokens. Every later screen in every epic consumes the theme, so any screen built before it exists will hard-code colours and sizes that then have to be unpicked. Bangla is the harder half: system fonts render Bangla conjuncts unreliably on both platforms and in generated PDFs, so the faces must be bundled, not requested.

**Approach:** Make the DESIGN.md tokens the only source of colour, type, radius and spacing in the app; build a Material 3 theme that overrides only the documented delta; bundle Noto Serif Bengali and Hind Siliguri as app assets with tabular figures on globally; and add a check that fails the build when any widget outside the theme layer writes a literal.

## Boundaries & Constraints

**Always:** DESIGN.md is the authority on values — read them from it, never retype from memory. Material 3 stays the base; override the documented delta only, so M3 keeps supplying anatomy, states and accessibility behaviour. Fonts ship as bundled assets. Tabular figures are on for every numeral with no exception. Every hit target ≥48dp, primary actions 54px, quick actions ≥80px. Colour never the sole carrier of meaning. Bangla labels on interactive elements.

**Ask First:** Any token value that would differ from DESIGN.md. Adding a package not already in `pubspec.lock`. Any change to `minSdk`, `targetSdk` or the plugin set.

**Never:** No `google_fonts` or any runtime font download — the app must render correctly with no connection. No literal colour, radius or font size in a widget. No shadows for hierarchy (bottom sheets and the centre nav button are the only two exceptions, and neither exists yet). No gradients, no emoji as iconography. No English financial vocabulary on a user-facing surface. Do not build Home, navigation or any Epic-1 feature screen — the preview screen here is scaffolding, not product.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Bangla conjuncts | Text `ক্ত`, `ঙ্ক`, `হিসাব`, `বাকি` in both families | Conjuncts form correctly, no tofu boxes, on Android, iOS and in a generated PDF | Test fails if the glyph is missing from the bundled face |
| Column of amounts | Several figures stacked in a ledger column | Digits align vertically — tabular figures active | Test fails if glyph advance widths differ |
| Largest system font | `textScaler` at the platform maximum, 5-inch logical viewport | No truncation, overlap or clipping on the preview screen | Overflow test fails the build |
| Literal in a widget | A widget outside `lib/theme/` writes `Color(0x…)`, `fontSize:` or `BorderRadius.circular(` | Token check reports file and line, exits non-zero | CI blocks the merge |
| Fonts absent | `assets/fonts/` empty at build time | Fetch script explains what to run; build fails loudly rather than falling back to a system font | Never silently substitute |

</frozen-after-approval>

## Code Map

- `apps/mobile/lib/main.dart` -- still the counter demo (`MyApp`, `MyHomePage`, `_counter`); the whole file is replaced.
- `apps/mobile/test/widget_test.dart` -- asserts the counter increments; replaced with theme tests.
- `apps/mobile/pubspec.yaml` -- deps already resolved and locked by Story 1.1; needs an `assets`/`fonts` block. Its header comment still says "Story 1.1 is NOT complete" — stale, correct it.
- `apps/mobile/analysis_options.yaml` -- `flutter_lints` only; excludes `build/`, `android/`, `ios/`.
- `apps/mobile/scripts/bootstrap.sh` -- existing pattern for a repo script; follow its shape.
- `_bmad-output/planning-artifacts/ux-designs/.../DESIGN.md` -- frontmatter carries every token value and component spec. **Read-only, and the authority.**
- `.github/workflows/ci.yml` -- `flutter` job gated on `pubspec.lock`; the token check and tests hook in here.
- Read-only evidence: no `lib/theme/`, no `assets/`, no golden files exist yet. `intl`, `pdf` and `printing` are already in the lockfile — no new dependency is needed.

## Tasks & Acceptance

**Execution:**
- [x] `apps/mobile/scripts/fetch-fonts.sh` -- fetch Hind Siliguri (400/500/600/700) and Noto Serif Bengali (600/700) from the google/fonts repo into `assets/fonts/` under fixed filenames, instancing the variable face to static weights with `fonttools` if the repo ships no statics -- filenames must be deterministic or the pubspec cannot declare them, and a wrong face is invisible until a shop owner sees a tofu box.
- [x] `apps/mobile/assets/fonts/MANIFEST.txt` -- record each file's source URL, sha256 and licence -- bundled binaries need provenance.
- [x] `apps/mobile/lib/theme/tokens.dart` -- every colour, type role, radius and spacing step from DESIGN.md as named constants; no `ThemeData` here -- one file to diff against the design doc.
- [x] `apps/mobile/lib/theme/hisab_theme.dart` -- build M3 `ThemeData` from tokens: `ColorScheme`, `TextTheme` with tabular figures, and the component themes DESIGN.md specifies (button 54px/r13, card r14 + 1px rule, chip r999, field r12, app bar 58px, bottom nav 66px) -- the delta, and only the delta.
- [x] `apps/mobile/lib/theme/theme_preview.dart` -- a dev-only screen showing the palette, the type scale, both money colours, and one ledger row, all in Bangla -- gives the accessibility and overflow tests something real to render and makes the theme visible on a device.
- [x] `apps/mobile/lib/main.dart` -- replace the counter demo with `ProviderScope` + `MaterialApp` using the theme and the preview screen -- Riverpod scope now so no later story retrofits it.
- [x] `apps/mobile/pubspec.yaml` -- declare the font families and the assets directory; correct the stale Story 1.1 header comment.
- [x] `apps/mobile/tool/check_theme_tokens.dart` -- fail on `Color(0x`, `Colors.`, `fontSize:`, `BorderRadius.circular(`, `Radius.circular(` under `lib/` outside `lib/theme/`, reporting file and line -- the "no literals" rule is worthless unenforced.
- [x] `apps/mobile/test/theme/tokens_test.dart` -- assert each token's value and each group's count against DESIGN.md -- catches a token drifting from the design doc.
- [x] `apps/mobile/test/theme/typography_test.dart` -- assert tabular figures on every numeric style and the two families resolved from bundled assets -- covers the alignment and font-source rows of the matrix.
- [x] `apps/mobile/test/theme/bangla_rendering_test.dart` -- golden test of the conjunct sample in both families; plus a PDF built with the bundled TTF asserting the Bangla glyphs are present in the output -- covers the conjunct row on all three surfaces.
- [x] `apps/mobile/test/theme/accessibility_test.dart` -- assert ≥48dp hit targets on the preview screen and no overflow at maximum `textScaler` on a 5-inch viewport -- covers the largest-font row.
- [x] `.github/workflows/ci.yml` -- run `dart run tool/check_theme_tokens.dart`, `flutter analyze` and `flutter test` in the flutter job; fail if `assets/fonts/` is empty -- makes every rule above a merge gate.

**Acceptance Criteria:**
- Given the theme is the only source of style, when any widget outside `lib/theme/` declares a literal colour, radius or font size, then the token check exits non-zero naming file and line, and CI blocks the merge.
- Given Material 3 is the base, when a themed component is inspected, then it retains M3 states and semantics and differs from stock M3 only where DESIGN.md documents a delta.
- Given the app is built with no network available, when any screen renders Bangla, then it uses the bundled faces and never a system font or a downloaded one.
- Given a screen-reader user, when the preview screen is traversed, then every interactive element exposes a Bangla label, order follows visual order, and meaning survives with colour ignored.
- Given `prefers-reduced-motion`, when the app runs, then no animation is load-bearing and none is required to understand a screen.

## Design Notes

**Token count discrepancy — resolve toward DESIGN.md.** The epic's AC says "13 colour tokens". DESIGN.md's frontmatter defines **15** (`paper, paper-sunk, surface, rule, ink, ink-muted, ink-faint, accent, money-in, money-out, warn, warn-surface, warn-rule, ai-surface, ai-rule`), of which `accent` and `money-in` share a value by design — one colour doing two non-conflicting jobs. Implement all 15 names; the "13" is a stale count, not a smaller palette. The other counts in the AC are correct: 4 amount sizes, 4 text roles, 5 radii, 6 spacing steps.

**Fonts cannot be fetched by the build agent.** Both the cloud container and the device shell are blocked from `fonts.gstatic.com` and `github.com` raw downloads, so the TTFs must be fetched on the developer's machine by the script and then committed. CI must fail rather than build without them.

**Two families, one rule about numerals.** Noto Serif Bengali sets titles and receipts only, never below 17px and never body copy. Hind Siliguri sets everything else *including every number*, always with `FontFeature.tabularFigures()`. A ledger whose digits wander is a ledger the owner will not trust.

## Verification

**Commands:**
- `cd apps/mobile && ./scripts/fetch-fonts.sh` -- expected: six TTFs in `assets/fonts/` plus a MANIFEST with matching sha256s
- `cd apps/mobile && flutter analyze` -- expected: no issues
- `cd apps/mobile && dart run tool/check_theme_tokens.dart` -- expected: exit 0, no literals reported
- `cd apps/mobile && flutter test` -- expected: all tests pass; goldens generated once with `--update-goldens` and reviewed by eye before being committed
- `cd apps/mobile && flutter run` -- expected: the preview screen renders in Bangla on paper ground with correct conjuncts
