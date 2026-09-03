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
| Flutter SDK | 3.47.2 | supplied by Tanim from his installed toolchain |

## npm — verified live

`@nestjs/*` 12.0.1 (config 12.0.0) · `@prisma/client` 7.10.0 · `prisma` 7.10.0 ·
`fastify` 5.12.1 · `typescript` 7.0.2 · `@types/node` 26.4.1 · `zod` 4.5.4 ·
`class-validator` 0.15.1 · `ioredis` 6.0.0 · `bullmq` 6.3.4 · `next` 16.3.4 ·
`react`/`react-dom` 19.2.8 · `tailwindcss` 4.3.3 · `@tanstack/react-query` 5.102.8 ·
`eslint` 10.9.1 · `prettier` 3.9.6 · `vitest` 4.1.11 · `uuid` 14.0.2 ·
`supertest` 7.2.2 · `@types/supertest` 7.2.1

## PyPI — verified live

`fastapi` 0.141.1 · `uvicorn` 0.52.4 · `pydantic` 2.13.5 ·
`pydantic-settings` 2.15.0 · `psycopg` 3.3.5 · `httpx` 0.28.1 ·
`pytest` 9.1.1 · `ruff` 0.16.5

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

## Not verified — outstanding

**Every Dart/Flutter package.** `pub.dev` was unreachable from the environment
that generated this workspace, and no Flutter toolchain was present. No package
version has been written into `apps/mobile/pubspec.yaml`, because a guessed
version is precisely what this story exists to prevent.

Run `apps/mobile/scripts/bootstrap.sh` on a machine with Flutter 3.47.2. It uses
`flutter pub add`, which resolves against pub.dev and writes exact versions into
`pubspec.yaml` and `pubspec.lock`. Commit both. **Story 1.1 is not complete
until that is done.**
