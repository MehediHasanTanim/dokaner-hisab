# apps/mobile

The Flutter client for Hisab.

## Before your first build: fetch the fonts

The two Bangla faces are **bundled assets, not a dependency**. Bangla conjuncts
do not render reliably from system fonts on either platform, and the same faces
have to render inside a generated PDF receipt (UX-DR3), so the app never
downloads a font and never falls back to a system one.

The `.ttf` files are fetched once and committed:

```bash
cd apps/mobile
./scripts/fetch-fonts.sh          # needs curl and `pip install fonttools`
```

That writes six faces, two OFL licence texts and a regenerated `MANIFEST.txt`
into `assets/fonts/`. Commit all of them. Until you do, the build fails on
purpose — CI checks for the six files before it does anything else, because a
silently substituted face is a tofu box in a shop owner's hand.

## Then

```bash
flutter pub get
dart run tool/check_theme_tokens.dart   # no style literals outside lib/theme/
flutter analyze
flutter test
flutter run                              # the theme preview screen
```

The golden image used by `test/theme/bangla_rendering_test.dart` is not in the
repository yet. Generate it once, **look at it** — formed conjuncts, no dotted
circles, no tofu — and commit it:

```bash
flutter test --update-goldens test/theme/bangla_rendering_test.dart
```

## Versions

Flutter **3.47.2** (Dart 3.13.2), pinned in `pubspec.yaml` and in
`.github/workflows/ci.yml`. Every package version was resolved against pub.dev
by `scripts/bootstrap.sh` and is locked in `pubspec.lock`. **The lockfile is the
authority**: add a package with `flutter pub add`, never by hand.

## The theme is the only source of style

`lib/theme/` holds the design system and is the only place in the app allowed to
write a colour, a font size or a radius:

- `tokens.dart` — every value transcribed from `DESIGN.md`. One flat file to
  diff against the design document. No `ThemeData`, no widgets.
- `hisab_theme.dart` — Material 3 with only the documented delta overridden, and
  the named text styles. M3 keeps supplying anatomy, states and accessibility
  behaviour.
- `theme_preview.dart` — a development-only screen. Scaffolding, not product.

Everywhere else, style comes from `Theme.of(context)` or from a named token.
`dart run tool/check_theme_tokens.dart` fails the build on a literal `Color(0x`,
`Colors.`, `fontSize:`, `BorderRadius.circular(` or `Radius.circular(` under
`lib/` outside `lib/theme/`, naming the file and line.

## Source tree

Feature-first clean architecture, per the architecture spine:

```
lib/
  theme/           # design tokens and the Material 3 theme
  core/            # db (Drift + SQLCipher), sync, formatting, errors
  features/
    <feature>/
      presentation/  # widgets, screens — never touches the database
      application/   # Riverpod notifiers — the only state mutators (AR-29)
      domain/        # entities, value objects — depends on nothing
      data/          # repositories — the SOLE database surface (AR-29)
```
