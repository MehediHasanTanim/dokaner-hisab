# হিসাব · Hisab

Bangla-first business management for Bangladesh's small shops. Record a sale in
seconds, keep the বাকি হিসাব straight, and know whether the month made money —
on a phone with no signal.

## Workspace

```
apps/
  mobile/      Flutter client — the product. Local-first; the device owns the write.
  api/         NestJS on Fastify + Prisma + PostgreSQL. Durable replica, entitlements.
  ai/          Python FastAPI. READ-ONLY. Classifies intent; never writes money.
  admin/       Next.js staff console. Not owner-facing.
packages/
  contracts/   Shared types: money, quantity, error envelope, sync classification.
infra/railway/ Three environments, one Railway project each.
```

## Before you write code

Read these three, in order. They are the contract, not background reading:

1. `_bmad-output/planning-artifacts/architecture/architecture-hisab-dokan-2026-08-29/ARCHITECTURE-SPINE.md` — AD-1…AD-24. Invariants a story cannot violate even while satisfying its requirement.
2. `_bmad-output/planning-artifacts/ux-designs/ux-hisab-dokan-2026-08-29/EXPERIENCE.md` and `DESIGN.md` — behaviour and visual identity.
3. `_bmad-output/planning-artifacts/epics.md` — 8 epics, 81 stories, with acceptance criteria.

`docs/design/Hisab_Technical_Design.md` is **partially superseded** — it carries
a header naming what changed. Where it and the spine disagree, the spine wins.

## The five rules most easily broken

- **Money is integer paisa; quantity is integer milli-units.** Storage only — every screen shows taka and whole units.
- **Financial tables are append-only.** No `UPDATE`, no `DELETE`, device or server. Corrections write a reversal plus a new record.
- **One transaction commits as one envelope** — sale, items, stock movements, layer consumptions, ledger entry, money movement, together or not at all.
- **Derived figures are derived.** Balances come from their entries; stock value from open cost layers. Never a stored authoritative total.
- **Offline is not a state.** No banner, no greyed control, no connectivity error. Only a pending-sync count.

## Getting started

```bash
nvm use            # Node 22.23.2
npm install        # workspaces: api, admin, contracts
npm run typecheck && npm run lint && npm run test
```

The AI service and the Flutter client have their own setup — see
`apps/ai/pyproject.toml` and `apps/mobile/README.md`.

Versions and how they were pinned: `VERSIONS.md`.
