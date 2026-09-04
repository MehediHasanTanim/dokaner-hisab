# Pinned versions

Story 1.1 requires every dependency pinned to a version **checked against the
live registry at the moment of scaffolding** — not carried from the
architecture spine, which deliberately pins nothing. This file records what was
checked, when, and what could not be.

Verified **03-09-2026** against `registry.npmjs.org` and `pypi.org`.
From here on the **lockfiles are the authority**, not this file.

## Runtime

| | Version | Source |
| --- | --- | --- |
| Node | 22.23.2 (`.nvmrc`) | installed toolchain |
| Python | 3.12 | CI pin |
| Flutter SDK | 3.47.2 | `flutter --version` on Tanim's machine |
| Dart SDK | 3.13.2 | same — `pubspec.yaml` floors at `>=3.13.0 <4.0.0` |
| DevTools | 2.60.0 | same |

## npm — verified live

`@nestjs/*` 12.0.1 (config 12.0.0) · `@prisma/client` 7.10.0 · `prisma` 7.10.0 ·
`fastify` 5.12.1 · `typescript` 7.0.2 · `@types/node` 26.4.1 · `zod` 4.5.4 ·
`class-validator` 0.15.1 · `ioredis` 6.0.0 · `bullmq` 6.3.4 · `next` 16.3.4 ·
`react`/`react-dom` 19.2.8 · `tailwindcss` 4.3.3 · `@tanstack/react-query` 5.102.8 ·
`eslint` 10.9.1 · `prettier` 3.9.6 · `vitest` 4.1.11 · `uuid` 14.0.2 ·
`supertest` 7.2.2 · `@types/supertest` 7.2.1 · `@nestjs/cli` 12.0.0 ·
`@nestjs/schematics` 12.0.0 · `@types/react` 19.2.18 · `@types/react-dom` 19.2.5 ·
`reflect-metadata` 0.2.2 · `rxjs` 7.8.2

## PyPI — verified live

`fastapi` 0.141.1 · `uvicorn` 0.52.4 · `pydantic` 2.13.5 ·
`pydantic-settings` 2.15.0 · `psycopg` 3.3.5 · `httpx` 0.28.1 ·
`pytest` 9.1.1 · `ruff` 0.16.5

## Three things the install caught that a hand-written pin would not

**`@nestjs/cli` is 12.0.0, not 12.0.1.** It does not share a version with
`@nestjs/core`, and assuming it did failed the install outright. Same for
`@nestjs/schematics`.

**TypeScript 7 removed `baseUrl`.** `apps/api/tsconfig.json` used it and would
not compile. Replaced per the compiler's own guidance.

**React 19 types no longer expose a global `JSX` namespace.** `apps/admin`
needed `@types/react`, `@types/react-dom`, a committed `next-env.d.ts` and
`jsxImportSource`. Without them nothing with JSX typechecks.

None of these were predictable from the version numbers alone, which is the
whole argument for the story's "verify, don't assume" acceptance criterion.

## Two judgement calls worth knowing about

**Prisma is pinned to 7.10.0, not the registry's `latest`.** `npm dist-tag`
currently points `prisma` at **8.0.0-rc.12** — a release candidate. Pinning an
RC in a financial ledger is not a trade worth making, and `@prisma/client`'s
stable latest is 7.10.0, so the CLI and client are pinned together at 7.10.0.
Revisit when 8.x goes stable.

**TypeScript 7.0.2 is a major-version jump** and is pinned because it is the
current stable. If it turns out to conflict with NestJS 12's decorator
emit, drop to the newest 6.x — but verify against the registry first rather
than assuming a version.

## Verification actually run

`npm run typecheck` passes across `contracts`, `api` and `admin` on the pinned
set. `package-lock.json` (lockfileVersion 3, 535 entries) is committed and is
the authority from here on.

## pub.dev — resolved by `flutter pub add` on 03-09-2026

Resolved on Tanim's machine, because pub.dev is unreachable from the
environment that scaffolded this workspace. `pubspec.lock` is the authority.

`flutter_riverpod` 3.4.2 · `riverpod_annotation` 4.0.6 · `riverpod_generator` 4.0.8 ·
`go_router` 18.0.1 · `dio` 5.11.0 · `drift` 2.34.4 · `drift_dev` 2.34.6 ·
`sqlite3` 3.5.2 · `flutter_secure_storage` 11.0.0 · `connectivity_plus` 7.3.1 ·
`firebase_core` 4.14.0 · `firebase_messaging` 16.6.0 ·
`flutter_local_notifications` 22.3.0 · `freezed` 4.0.1 / `freezed_annotation` 3.1.0 ·
`json_serializable` 6.14.1 / `json_annotation` 4.12.0 · `intl` 0.20.3 ·
`uuid` 4.6.0 · `share_plus` 13.3.0 · `pdf` 3.13.0 · `printing` 5.15.0 ·
`path_provider` 2.1.6 · `build_runner` 2.16.1 · `flutter_lints` 6.0.0 · `mocktail` 1.0.5

### The resolution surfaced a blocker, now fixed

`flutter pub add` resolved **`sqlcipher_flutter_libs 0.7.0+eol`** and
**`sqlite3_flutter_libs 0.6.0+eol`**. The `+eol` is the author's own marker:
both packages are retired. They belong to `package:sqlite3` 2.x and are
obsolete under 3.x.

That is not cosmetic — AD-17 requires the local database to be encrypted with
SQLCipher, and the package that provided it no longer exists in a supported
form. Building on a retired encryption dependency is how a security invariant
quietly rots.

**Fix applied:** both packages removed; `sqlite3: ^3.5.2` added as a direct
dependency (it was already resolving transitively); SQLCipher selected through
pubspec configuration, which is how 3.x does it:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlcipher
```

Two consequences for later stories: `open.overrideFor` customisation and
`applyWorkaroundToOpenSqlite3OnOldAndroidVersions` must **not** be written —
3.x handles both. And the `sqlite3.wasm` asset, if web is ever targeted, comes
from the sqlite3.dart releases page.

### Two notes for whoever picks up Epic 1

**`uuid` 4.6.0 supports UUIDv7** (RFC 9562 v6/v7/v8) — confirmed, because AD-3
makes client-minted UUIDv7 the sole identity and the whole offline model rests
on it.

**`riverpod_analyzer_utils` resolves to `1.0.0-dev.11`**, a dev prerelease
pulled transitively by `riverpod_generator` 4.0.8. It is build-time only, so it
never ships in the app — a materially smaller risk than the Prisma RC, but
worth knowing before someone is surprised by a codegen change.

## Android build — desugaring, added 04-09-2026

The first `flutter run` failed before any Dart executed:

```
Dependency ':flutter_local_notifications' requires core library desugaring
to be enabled for :app.
```

This is not a version conflict. `flutter_local_notifications` calls `java.time`
APIs that do not exist on older Android runtimes, and asks the build to rewrite
them at compile time. AGP refuses the AAR unless the app opts in, so the fix is
in `apps/mobile/android/app/build.gradle.kts`, not in `pubspec.yaml`:

- `compileOptions { isCoreLibraryDesugaringEnabled = true }`
- `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`

**2.1.4 is deliberate.** It is the exact version the plugin's own README pins,
so it is the version its authors test against. 2.1.5 exists (2025-02, adds
`Stream.toList()` and a Chinese-locale week-name fix — neither relevant here)
but carries no benefit for this app and no evidence of being tested with the
plugin. A desugar/plugin mismatch does not fail the build; it fails as a
`NoSuchMethodError` on an old device in the field, which is exactly the class
of defect this project is trying not to ship. Maven Central and dl.google.com
are both blocked by the build environment's egress policy, so this version came
from the plugin README and the desugar_jdk_libs changelog rather than from a
registry query — the one pin in this file not verified against its own registry.

The plugin states AGP 8.11.1 as its floor. This project is on AGP 9.1.0,
Gradle 9.3.1, Kotlin 2.4.0, Java 17.

## Android compileSdk — pinned to 37, added 04-09-2026

`flutter_secure_storage` 11.x publishes AAR metadata requiring API 37. Flutter
3.47.2's `flutter.compileSdkVersion` is 36, so `:app:checkDebugAarMetadata`
rejects the build. `apps/mobile/android/app/build.gradle.kts` therefore sets
`compileSdk = 37` explicitly rather than taking Flutter's value.

Why this is safe: `compileSdk` decides only which APIs the code may reference
and is backward compatible. `targetSdk` (which opts the app into new runtime
behaviour) and `minSdk` (which decides device reach — the thing that matters for
low-end Android phones in Bangladesh) still come from Flutter and are untouched.
Those two are the ones that need a deliberate review before moving.

Why the package is not simply pinned down instead: AD-17 keeps the SQLCipher key
in the platform keystore, and `flutter_secure_storage` is what reaches it. It is
load-bearing for the encrypted local ledger, not a convenience.

AGP 9.1.0 warns that its maximum *recommended* `compileSdk` is 36. The warning is
advisory — AGP builds against 37 — so it is suppressed in `gradle.properties` via
`android.suppressUnsupportedCompileSdk=37`. A permanent warning on every build is
worse than none: it teaches the team to skim past build output. Revisit when AGP
supports 37 outright.

## Not verified — outstanding

`desugar_jdk_libs:2.1.4` — taken from the plugin README, not from Maven
Central, which the build environment cannot reach. Everything else is pinned to
a version resolved against its live registry, with every lockfile committed.
