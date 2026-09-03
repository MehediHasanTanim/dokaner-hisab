# PRD Addendum — Hisab MVP

Depth that belongs downstream (architecture, UX spec, sprint planning) rather than in the PRD's main narrative. Companion to `prd.md`.

---

## A. Relationship to the existing technical design

`docs/design/Hisab_Technical_Design.md` (2,515 lines) was written before this PRD and is treated as **authoritative** by Tanim's decision. It is not superseded by anything here. The division of labour:

- **`prd.md` states capabilities** — what the Owner can do, and what must be true for each capability to be considered delivered.
- **The technical design states mechanism** — stack, schema, sync protocol, API shapes, deployment.

Where a PRD requirement has a technical counterpart it cites the design by section (TD §N). `bmad-architecture` should therefore run in **validate-and-format** mode: confirm the design covers every FR, surface gaps, and re-express it as a BMAD architecture artifact — not re-open the stack.

**Decided and closed (from the technical design, not to be re-litigated):**

| Layer | Choice | TD § |
|---|---|---|
| Mobile | Flutter / Dart, Riverpod, GoRouter, Dio, Freezed | §5 |
| Local DB | Drift + SQLite | §5, §12 |
| Backend | NestJS on Fastify, Prisma, PostgreSQL | §6 |
| Cache / jobs | Redis, BullMQ | §45, §46 |
| AI service | Python / FastAPI, provider-abstracted LLM, pgvector | §7, §41 |
| Admin | Next.js, TypeScript, Tailwind, TanStack Query | §8 |
| Architecture | Offline-first client, modular monolith server | §4, §11 |
| Repo | Monorepo | §65 |

## B. Gaps between the PRD's FRs and the technical design

Things `prd.md` requires that the technical design does not currently specify. These are `bmad-architecture` inputs, not PRD changes.

1. **Local database encryption at rest** (§8 NFR). The design covers transport and server-side security (TD §52) but does not state local encryption. A stolen phone (UJ-10) carries the shop's full financial history.
2. **Receipt numbering under offline entry** (FR-30). TD §32 covers idempotency; it does not specify how a gap-free per-Business sequential receipt number is generated on a device that has been offline for hours. Options: device-prefixed sequence reconciled at sync, or server-allocated blocks pre-fetched. Needs an explicit decision.
3. **Bangla font embedding for PDF generation** (§4.11 NFR). System fonts will not render Bangla conjuncts reliably in generated PDFs on both platforms. Font choice, licence and bundle-size impact (against the 40 MB APK target) need deciding.
4. **Non-itemised Sale flag** (FR-20, FR-28, FR-83). The Sale/Purchase schema (TD §25, §26) needs a field distinguishing itemised from non-itemised so COGS and Product reports can exclude them and disclose the exclusion.
5. **Owner withdrawal entity** (FR-61). Detailed spec §45 describes it; TD's schema (§18–§30) has no entity for it. It is neither an Expense nor a Payment and needs its own type or a typed flag.
6. **COGS costing method — DECIDED: FIFO** (Tanim, 2026-08-29, closing TD §55). This is the single largest schema consequence in the answer set, and it lands on epic 4, not epic 9. See §G below for what it requires.
7. **Damage handling** (FR-53). Stock Movement type exists; whether it produces a financial effect is undecided (§15 Q5).
8. **Conflict surfacing UI** (FR-97). TD §15 defines resolution rules but not what an unresolvable conflict looks like to the Owner. This is a UX deliverable.
9. **Ask Hisab query catalogue** (FR-100). TD §40 and §42 establish that answers come from parameterised queries rather than RAG over financial data. The actual catalogue of supported questions → query templates does not exist yet and is a concrete architecture deliverable.
10. **Analytics field-level allow-list** (FR-115). TD §71 lists events; the PRD requires that no monetary amount or personal name is ever transmitted. That needs a schema-level allow-list, not a convention.
11. **Account deletion** (§15 Q7). Not in the design; likely required by both stores.

## C. Options considered and set aside

**Android-first phased launch.** Recommended and rejected by Tanim in favour of simultaneous release. The trade-off accepted: iOS review cycles, TestFlight distribution and iOS device testing land inside the same timeline (R-6). Sprint planning should size this explicitly rather than absorbing it.

**Employee roles in MVP.** Rejected. `BusinessMember` and role stay in the schema (TD §21) so the addition is purely additive later. The cost of deferring is that a shop with cashiers shares one account; the cost of including it is invite flows, permission enforcement across every endpoint, and genuine multi-device sync conflicts (R-5) in the very first release.

**Full billing integration in MVP.** Rejected in favour of plan plumbing plus manual assignment (FR-109–112). Willingness to pay is measured by upgrade interest (SM-6) rather than completed payments — a weaker signal, accepted to keep a payment-gateway integration out of the critical path (R-9).

**RAG over financial data for Ask Hisab.** Already rejected in TD §42 and reinforced here: retrieval over ledger text invites arithmetic hallucination on exactly the numbers that must never be wrong. Parameterised queries bound both cost and error.

**In-place editing of financial transactions.** Rejected — and this was a contradiction found during PRD validation, not a free choice. The first draft of FR-36/FR-37 had edits recompute the original transaction in place. TD §15 is explicit that financial transactions should be treated as immutable and that `Original → Reversal → Corrected` is preferred, because it removes a whole class of sync conflict. The PRD now keeps the Owner-facing verbs ("Edit", "Delete") and specifies reversal as the mechanism, with the correction visible in the Ledger. This aligns with the append-only guarantee already asserted in `prd.md` §9 and with the auditability the product's trust model depends on.

**Blocking entry on insufficient stock or insufficient cash** (FR-39, FR-68). Rejected. An Owner whose records lag reality must still be able to record what actually happened; blocking pushes them back to paper, which is the product's only real competitor.

**Auto-posting recurring Expenses** (FR-60). Rejected as inconsistent with "financial data is deterministic and Owner-controlled". Hisab reminds; the Owner confirms.

## D. Notes for `bmad-ux`

- §10's five-destination navigation is **proposed, not decided** — it is the first thing UX should test.
- The six Quick Actions (FR-13) are the highest-traffic surface in the product; SM-2 (under 20 seconds to a saved Sale) is effectively a UX requirement.
- UJ-1 through UJ-10 in `prd.md` §2.3 are the journeys to design against; mirror their IDs in the UX spec rather than renumbering.
- Two flows need real usability testing before they are built: business setup with Opening Balances (FR-4 — the skippable step that silently breaks every cash figure), and the AI Transaction Draft confirmation card (FR-104 — must invite checking, not reflexive tapping; see SM-C3).
- Bangla numerals vs Western digits (§15 Q3) should be settled by testing, not by a document.
- Any surface showing an amount is subject to §13's rule that money is the largest element on screen.

## E. Notes for `bmad-create-epics-and-stories`

Suggested epic boundaries, roughly in dependency order. TD §72–§77 contains a 16-week plan that should be reconciled against this (and against R-6).

1. Foundation — repo, CI, auth (FR-1, FR-6, FR-7), business setup (FR-2–FR-5), local DB + sync skeleton (FR-93–FR-96)
2. Parties and Ledgers — Customers, Suppliers, both Ledgers, বাকি দিলাম, adjustments (FR-15–FR-29)
3. Money — Money Accounts, Payment Methods, Customer/Supplier Payments, Transfers (FR-62–FR-69)
4. Products and Inventory — catalogue, Stock Movements, Low Stock (FR-46–FR-56)
5. Sales — full flow, edit/delete, walk-in fast path, stock effects (FR-30–FR-39)
6. Purchases (FR-40–FR-45), then Returns (FR-70–FR-73)
7. Expenses, recurring, Owner withdrawal (FR-57–FR-61)
8. Home dashboard and Search (FR-9–FR-14, FR-85–FR-87) — depends on most of the above
9. Receipts and Reports (FR-74–FR-84)
10. Reminders and Notifications (FR-88–FR-92)
11. Sync hardening — conflicts, backup, restore (FR-97–FR-99)
12. AI — Ask Hisab, Daily Summary, Transaction Entry (FR-100–FR-108). **The FR-103–105 spike (R-2) should run early, in parallel with epic 1–2, even though the epic lands late.**
13. Subscription foundation (FR-109–FR-112)
14. Settings, export, analytics, audit trail, help (FR-113–FR-118)
15. Launch — store listings, data-safety declarations, Bangla store copy, account deletion (§15 Q7)

Cross-cutting, not an epic: every transaction epic must satisfy the atomicity and reproducibility NFRs in §8, and TD §68's financial test suite is a release gate on each.

## F. Deferred detail retained from source docs

Kept here so it is not lost when the PRD stays MVP-scoped:

- **Voice Hisab** (detailed spec §38, TD §44) — the strongest differentiator, deferred behind text-based AI entry proving out. STT provider, Bangla dialect coverage and noisy-shop-environment performance are all unexplored.
- **Daily cash closing** (detailed spec §44) — expected vs actual cash with a reason for the difference. Matters most to shops with cashiers, which also need employee accounts; the two should ship together.
- **Multi-branch** (detailed spec §40, advanced §30–§34) — schema implications should be sanity-checked during architecture so the MVP does not foreclose it, even though nothing ships.
- **Business tier** (detailed spec §46) — the third subscription tier arrives with employee accounts and multi-branch.
- **bKash / Nagad direct integration** (detailed spec §10) — noted there as potentially a major feature; blocked on provider API availability, and a licensing question (§9) before it is scoped.


---

## G. FIFO: what the decision actually requires

Tanim chose FIFO over Weighted Average (Q8). TD §55 left it open and TD §27's `InventoryBalance` / `InventoryMovement` schema does not carry it. This is an epic-4 architecture deliverable, not a reporting detail.

**New schema surface**

- A **Cost Layer** entity per Product: quantity remaining, unit cost, acquisition date, source movement. Created by every inward movement (Purchase, Sales Return, opening stock, catalogue import).
- A **layer-consumption record** on every outward movement: which Layers it drew from, how much from each, at what cost. Without this, COGS is recomputed on every read and any historical restatement silently changes past reports.
- Current Inventory must still equal the sum of signed Stock Movement quantities *and* the sum of open Layer quantities. Those two must be reconcilable; a divergence is a P0 defect under `prd.md` §8.

**Where it gets hard**

1. **Offline layer computation.** COGS must be correct offline (`prd.md` FR-52), so layer consumption is computed on-device at save time and must produce the identical result server-side after Sync. Two devices consuming the same layers in different orders is the nastiest version of the sync-conflict problem (FR-97, R-5).
2. **Negative stock.** FR-39 deliberately permits selling into negative Inventory. FIFO has no layer to consume there. `prd.md` FR-52 specifies provisional costing at the current purchase price, reconciled by the next Purchase, with disclosure in the profit report (FR-83). This is the piece most likely to be got wrong and needs explicit tests in TD §68.
3. **Corrections and voids.** FR-36 and FR-37 write reversals rather than edits (TD §15). A reversal must restore consumed Layers in reverse consumption order — not just add quantity back, which would create a new layer at the wrong date and silently corrupt subsequent FIFO ordering.
4. **Returns.** A Sales Return restores stock: does it reopen the original consumed Layer at its original cost, or open a new Layer at the sale-time cost? `prd.md` FR-52 implies the former (restore in reverse consumption order). Confirm during architecture.
5. **Stock Value.** Now valued at open Layer costs, not at the Product's current purchase price (FR-82 updated). The two diverge as soon as prices move, which is exactly when the Owner notices.

**Recorded dissent, for the record.** Weighted Average removes items 1–5 entirely: one running average cost per Product, no layers, no ordering, no reconciliation, and negative stock is a non-event. The accuracy gain from FIFO is real but small for a grocery with slow-moving prices, and the Owner in this product overrides purchase prices ad hoc (FR-41), which erodes FIFO's precision anyway. The complexity was not visible when the choice was made, so `prd.md` §15 Q13 invites one reconsideration before epic 4 is cut. If FIFO is confirmed, this section is the spec.

## H. Other consequences of the 2026-08-29 answers

**Bangla numerals (Q3).** Display follows the language setting; input accepts both scripts always. Three things this touches that are easy to miss: the PDF generator must render Bangla digits (compounding the embedded-font gap in §B.3); Bangla thousand-grouping is the lakh convention (১,০৮,৫০০), not Western grouping in Bangla glyphs; and every parser that reads a user-entered amount — including AI Transaction Entry (FR-103) — must normalise both digit sets.

**Transliteration matching (Q4).** "As much as possible" was turned into a testable target in FR-85: ≥95% top-3 recall on a curated 300-name corpus, run in CI. Building that corpus is a real task with a real owner and should be a story in epic 2, not an afterthought in epic 8 — FR-103's entity resolution is gated on the same corpus, and search quality cannot be regression-tested without it. Expect this to need a Bangla phonetic-equivalence table rather than a generic fuzzy-match library.

**Catalogue import (Q1, FR-119).** Interacts with FIFO: an imported row with opening stock and a purchase price opens a Cost Layer; one without a purchase price imports stock with no cost basis and must be disclosed (FR-83). Also interacts with Plan limits (FR-110) — the limit check happens before commit, not per row.

**Account deletion (Q7, FR-120).** Soft-delete for 30 days then irreversible purge. Needs a scheduled purge job (BullMQ, TD §46), a visible state in the web admin, and care that the purge does not orphan analytics aggregates (FR-115).

**Free-tier limits (Q6, deferred).** The only build requirement is that limits are server-side configuration, changeable without a release or a migration. Nothing else in the plan waits on the number.

**Two new receipt series (Q9).** Two independent gap-free sequences per Business, both allocated offline, compounds the receipt-numbering gap already recorded in §B.2. Whatever scheme is chosen there must now allocate from two series without collision after an offline period.
