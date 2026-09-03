# apps/mobile

The Flutter client. **This app is not fully scaffolded yet** — see below.

## Story 1.1 status: incomplete for this app

Story 1.1 requires every dependency pinned to a version verified against the
live registry. The environment that generated this workspace could not reach
`pub.dev` and had no Flutter toolchain, so no Dart package version has been
written. Guessing them would have violated the acceptance criterion the story
exists to enforce.

The Flutter SDK version **3.47.2** is pinned in `pubspec.yaml`, supplied by
Tanim from the installed toolchain on 03-09-2026.

## To finish it

On a machine with Flutter 3.47.2 installed:

```bash
cd apps/mobile
flutter create . --project-name hisab --org com.hisab --platforms=android,ios
./scripts/bootstrap.sh
```

`flutter create` generates the `android/`, `ios/`, `lib/` and `test/`
scaffolding into this directory without overwriting `pubspec.yaml`'s
dependency block if it already resolved. `bootstrap.sh` then resolves every
package against pub.dev and writes exact versions into `pubspec.yaml` and
`pubspec.lock`.

**Commit both files.** From that point the lockfile is the authority, and
Story 1.1's remaining acceptance criterion is met.

## Then set up the source tree

Feature-first clean architecture, per the architecture spine:

```
lib/
  core/            # db (Drift + SQLCipher), sync, theme, formatting, errors
  features/
    <feature>/
      presentation/  # widgets, screens — never touches the database
      application/   # Riverpod notifiers — the only state mutators (AR-29)
      domain/        # entities, value objects — depends on nothing
      data/          # repositories — the SOLE database surface (AR-29)
```
