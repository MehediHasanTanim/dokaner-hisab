# Railway — three environments

AR-26. Development, staging and production are **three separate Railway
projects**, each with its own managed Postgres, managed Redis, object storage
and credentials. A production credential must never be reachable from a
developer machine.

Region: **Singapore** — nearest Railway region to Bangladesh.

## Per project

| Service | Notes |
| --- | --- |
| `api` | container from `apps/api`, `npm run build && npm start` |
| `worker` | same image, BullMQ worker entrypoint |
| `ai` | container from `apps/ai`, uvicorn |
| `admin` | container from `apps/admin`, `next start` |
| Postgres | managed, **point-in-time recovery enabled** |
| Redis | managed |

## Backups

RPO 15–60 minutes, RTO 1–4 hours. **Rehearse a restore before launch**, not
after an incident (Story 6.6).

## Reversibility

Nothing in application code may reference Railway. Everything reaches infra
through environment variables and standard clients, so the provider stays
replaceable — that is an architecture constraint, not a preference.

## Environment variables

Copy each app's `.env.example` and fill per environment. Never commit a real
value; `.gitignore` excludes `.env*` except the examples.
