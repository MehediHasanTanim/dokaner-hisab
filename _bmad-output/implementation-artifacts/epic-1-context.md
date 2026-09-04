# Epic 1 Context: Open Hisab and set up my shop

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Epic 1 takes a shop owner from install to a working, private, offline-capable app that already contains their real business: they sign in with a Bangladeshi mobile number and an OTP, name their shop and themselves, record what money the shop holds today, and land on a Home screen showing their own figures rather than sample data. It matters twice over. For the owner it is the whole first impression — the target is a first real transaction within about five minutes of install, in Bangla, at a counter, possibly with no connection. For the build it is the foundation every later epic writes into: the monorepo and pinned stack, the design tokens and bundled Bangla fonts, the numeral formatter, the encrypted local database with its money/quantity/identity/time conventions, and the offline sync skeleton. None of that is a separate "setup" epic — it ships as stories inside an outcome the owner can see, and after first sign-in nothing here requires a network.

## Stories

- Story 1.1: Stand up the workspace and pin the stack
- Story 1.2: Make the app look like Hisab
- Story 1.3: Show numbers the way the owner reads them
- Story 1.4: Keep the shop's data safe on the phone
- Story 1.5: Sign in with my phone number
- Story 1.6: Stay signed in, and sign out safely
- Story 1.7: Tell Hisab about my business
- Story 1.8: Record what money the shop has today
- Story 1.9: Choose my language
- Story 1.10: Lock the app
- Story 1.11: Work with no internet at all

## Requirements & Constraints

Scope covered: FR-1–FR-4, FR-6–FR-8, FR-93, FR-94.

- **Authentication (FR-1).** Phone + SMS OTP only, no passwords. Accept `+8801XXXXXXXXX` with operator prefixes 013–019 and reject anything else inline in Bangla. OTP delivery within 30s, 5-minute expiry (distinct message from "wrong code"), 5 requests per number per hour and 5 wrong entries invalidate the code (NFR-14). Credentials go to platform secure storage, never shared preferences or plain files (NFR-11). Signing in on a new device restores the existing Business; it never creates a second one.
- **Session (FR-6).** Reopening the app never re-prompts; access tokens refresh silently (JWT access + refresh, refresh rotated on use). Sign-out is blocked while records are unsynced, with an offer to sync first; a clean sign-out clears local credentials.
- **Business and owner (FR-2, FR-3).** Exactly one Business per owner: required name 1–100 chars, type from the fixed PRD list, optional address that appears on receipts. Currency is ৳ BDT, not editable in MVP. Owner name drives the Home greeting; optional email is format-validated and used only for recovery and owner-initiated receipts. An owner who already has a Business routes straight to Home.
- **Opening balances (FR-4).** One input per Money Account, each rendered **empty rather than zero** so a blank differs from a deliberate zero, with a live total. Skipping is allowed but priced with a one-line warning, and the screen stays reachable from Settings. Opening balances count toward Money Account balances only — never toward Sales, Expense or Profit.
- **Language (FR-8).** Bangla by default regardless of device locale; English switchable in Settings, persisting across restarts and devices. Complete Bangla coverage of every string, error, notification and label — an untranslated user-facing string is a defect (NFR-20).
- **App lock (FR-7).** Off by default. When on, biometric or device PIN on cold start and after 5 minutes in background; fallback is the device PIN, never a bypass. Background sync keeps running while locked.
- **Offline (FR-93, FR-94, NFR-9).** Every screen in this epic reads from the local database and behaves identically with no connectivity — no spinner, no error, no banner, no greyed control attributable to the network.
- **Performance floor.** Local write to perceived confirmation under 100 ms including SQLCipher overhead, measured and recorded on a mid-range 2023 Android device (NFR-1, NFR-2); cold start to interactive Home under 3 s (NFR-3). Targets are Android 8.0+ / iOS 14+, phone, portrait.

## Technical Decisions

- **No starter template.** The workspace is stood up by hand: `apps/mobile`, `apps/api`, `apps/ai`, `apps/admin` plus `packages/contracts` (AR-25). The stack table pins nothing on purpose — pin every dependency against the live registry at scaffold time, commit lockfiles, and treat lockfiles as the authority afterwards. Stack is Flutter/Riverpod/GoRouter/Dio/Freezed on the client, NestJS-on-Fastify + Prisma + PostgreSQL + Redis/BullMQ on the server.
- **Infrastructure (AR-26).** Railway, Singapore region, three environments as separate projects with separate databases, Redis, storage and credentials; no production credential reachable from a developer machine. No provider-specific code — reach infrastructure through configuration and standard clients so the PaaS stays replaceable. CI blocks merge on lint, unit tests and per-app build.
- **Storage conventions, established here for the whole product.** Money is integer paisa in `…Paisa` fields (AR-1); quantity is integer milli-units in `…Milli` fields (AR-2); identity is client-minted lowercase UUIDv7 with no `serverId` and every FK storing that UUID (AR-3). Timestamps stored UTC, with a `businessDate` (`YYYY-MM-DD`) derived once at creation against Asia/Dhaka (AR-14, NFR-22). Both Drift and Prisma schemas follow these.
- **Local database (AR-17).** Drift over SQLCipher, key generated on device and held in the platform keystore — never bundled, never in shared preferences, never derived from anything guessable. Create **only** the tables this epic needs — User, Business, MoneyAccount, MoneyMovement — not the full schema upfront.
- **No opening-balance column (AR-19).** An opening balance is a `MoneyMovement` of type `Opening`; editing one writes a reversal plus a new movement and an audit entry — the original row is never updated. Financial tables are append-only generally (AR-4), and derived figures stay derived (AR-6).
- **Client architecture (AR-29).** Repositories are the sole database surface; Riverpod notifiers are the only state mutators; no widget touches the database.
- **Sync skeleton (AR-5, AR-22, AR-10).** Every write is enqueued as a self-contained envelope carrying any reference entity it depends on, tagged with a monotonically increasing per-device sequence, delivered in that order, and idempotent on the record's own UUIDv7 so replay produces identical server state. The queue survives app termination and restart (NFR-10).
- **API and errors.** REST under `/v1/...`, POST for every financial write; one error envelope `{error:{code,message,details?}}` with `SCREAMING_SNAKE` codes and Bangla text resolved client-side from the code (AR-16). `businessId` is resolved server-side from the authenticated principal, never trusted from a request body (AR-11). Structured JSON logs carry `businessId` and a correlation id and never an amount, party name or phone number (AR-30).
- **Migrations and gates.** Prisma server-side, Drift client-side, both forward-only and tested against a populated database before merge (AR-27). The financial test suite is a release gate on every epic (AR-28).

## UX & Interaction Patterns

- **Design tokens are the single theme source (UX-DR1, UX-DR2).** 13 colour tokens, 4 amount sizes plus 4 text roles, 5 radii, a 6-step spacing scale (4/8/12/16/22/32), themed onto Material 3 with only the delta overridden. No widget may declare a literal colour, radius or font size — enforce with a lint rule or review check. The look is a paper khata: warm off-white ground, 1px rules instead of shadows, money as the largest element on every screen, colour carrying exactly one meaning each (in, out, warning, AI).
- **Fonts (UX-DR3).** Noto Serif Bengali (600/700) for headings and receipts, Hind Siliguri (400–700) for UI and all numerals, both bundled as app assets rather than system fonts, tabular figures on globally. Verify Bangla conjunct rendering on Android, iOS and inside a generated PDF.
- **Numerals (UX-DR4).** One shared formatter/parser used by every surface — screens, receipts, reports, CSV export, notifications and the AI draft parser. Bangla mode renders Bangla digits with lakh grouping (৳১,০৮,৫০০, never ৳১০৮,৫০০); English mode renders Western digits and grouping from the identical stored value. Input accepts Bangla digits, Western digits or a mix in either mode and normalises to one internal value.
- **Onboarding flow.** Phone → OTP (six boxes, visible countdown, resend at 60s) → business name and type chips with address visibly optional → owner name → opening balances → Home showing the owner's own figures. Each step is a screen; the climax is real data on Home.
- **Offline is not a state (UX-DR14).** No offline banner, no greyed control, no connectivity-driven spinner or error anywhere — reviewed per screen.
- **Accessibility floor (UX-DR21–UX-DR24).** 48dp minimum hit targets (54px primary actions, 80px quick actions); full layout integrity at the largest system font size on a 5-inch screen with labels shortening before type does; a Bangla accessible label on every interactive element including icon-only controls; screen-reader order following visual order with the amount read before its label; colour never the sole carrier of meaning; reduced-motion honoured and no animation load-bearing.
- **Voice (UX-DR19, UX-DR20).** Microcopy states the outcome in the owner's words with the changed number, never operation status; the words receivable, payable, debit, credit, ledger and FIFO never appear in English on a user-facing surface.

## Cross-Story Dependencies

- Story 1.1 (workspace, pinned versions, environments, CI) precedes everything; its lockfiles are the version authority for all later stories and epics.
- Stories 1.2 and 1.3 are the presentation foundation: every later screen consumes the theme tokens, the bundled fonts and the single numeral formatter/parser.
- Story 1.4 establishes the encrypted store and the money/quantity/identity/time conventions that Stories 1.7, 1.8 and 1.11 write through, and that every later epic's tables must follow. It creates only User, Business, MoneyAccount and MoneyMovement.
- Story 1.5 gates 1.6, 1.7 and 1.8 — a Business cannot exist without an authenticated owner, and opening balances cannot exist without a Business and its Money Accounts.
- Story 1.6's sign-out check depends on the pending-sync state introduced by Story 1.11's queue.
- Story 1.8 depends on Money Accounts and on the append-only movement pattern from 1.4; the same screen must remain reachable from Settings.
- Story 1.9's language switch depends on Story 1.3's formatter for re-rendering figures without touching stored data.
- Story 1.11's envelope queue and per-device ordering are the skeleton every later epic's transactional writes extend; server-side envelope application and conflict handling beyond this skeleton belong to the sync epic.
- Downstream: every later epic writes into the store, conventions and sync queue established here; Home's full figure set, the tab/centre-button navigation shell and party/product tables arrive in later epics.
