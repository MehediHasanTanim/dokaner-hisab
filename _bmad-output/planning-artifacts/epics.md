---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - _bmad-output/planning-artifacts/prds/prd-hisab-dokan-2026-08-29/prd.md
  - _bmad-output/planning-artifacts/prds/prd-hisab-dokan-2026-08-29/addendum.md
  - _bmad-output/planning-artifacts/architecture/architecture-hisab-dokan-2026-08-29/ARCHITECTURE-SPINE.md
  - _bmad-output/planning-artifacts/ux-designs/ux-hisab-dokan-2026-08-29/DESIGN.md
  - _bmad-output/planning-artifacts/ux-designs/ux-hisab-dokan-2026-08-29/EXPERIENCE.md
---

# Hisab - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Hisab, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

The PRD's stable FR ids are preserved verbatim — the architecture spine binds them and downstream artifacts cite them, so renumbering would break those references.

- **FR-1** — Phone-number authentication with OTP. A User can authenticate by entering a Bangladeshi mobile number and the one-time code sent to it by SMS.
- **FR-2** — Business creation. An authenticated User with no Business can create exactly one Business by supplying its name and type.
- **FR-3** — Owner profile capture. The Owner can supply their own name, and optionally an email, during setup.
- **FR-4** — Opening Balance entry. The Owner can record a starting balance for each Money Account during setup.
- **FR-5** — Party opening balance. The Owner can record an existing due for a Customer or Supplier at the time that Party is created.
- **FR-6** — Session persistence and sign-out. An authenticated Owner stays authenticated across app restarts and can sign out deliberately.
- **FR-7** — App lock. The Owner can require a device PIN or biometric to open the app.
- **FR-8** — Language. The app presents Bangla as the default interface language, with English available.
- **FR-9** — Today's figures. The Home screen displays Today's Sales, Today's Collection, Today's Expense and Today's Profit for the current calendar day.
- **FR-10** — Receivable and Payable summary. The Home screen displays total Receivable and total Payable, each tappable through to the underlying list.
- **FR-11** — Low Stock panel. The Home screen displays Products that are Low Stock or Out of Stock.
- **FR-12** — Money Account summary. The Home screen displays the balance of each Money Account with a non-zero balance, and their total.
- **FR-13** — Quick Actions. The Home screen presents six primary actions that open their flow in one tap: **+ বিক্রি**, **+ টাকা পেলাম**, **+ টাকা দিলাম**, **+ বাকি দিলাম**, **+ খরচ**, **+ পণ্য যোগ**.
- **FR-14** — Greeting and Business identity. The Home screen shows a time-appropriate greeting, the Owner's name and the Business name.
- **FR-15** — Create and edit Customer. The Owner can create a Customer with a name and optional phone, address, and opening balance, and edit those details later.
- **FR-16** — Delete or archive Customer. The Owner can remove a Customer who was created in error, and archive one who is no longer active.
- **FR-17** — Customer list. The Owner can see all Customers with their current balances and find one quickly.
- **FR-18** — Customer detail. The Owner can view one Customer's summary and act on it.
- **FR-19** — Customer Ledger. The Owner can view a chronological Ledger for one Customer with a running balance.
- **FR-20** — Record a credit given (বাকি দিলাম). The Owner can record an amount a Customer owes, with a description, without itemising Products.
- **FR-21** — Customers with outstanding balances. The Owner can see every Customer who owes money, prioritised for collection.
- **FR-22** — Customer transaction history filters. The Owner can filter a Customer's Ledger by date range and transaction type.
- **FR-23** — Manual balance adjustment. The Owner can correct a Customer Balance or Supplier Balance with an explicit adjustment.
- **FR-24** — Create and edit Supplier. The Owner can create a Supplier with a name and optional phone, address and opening balance, and edit those details later.
- **FR-25** — Delete or archive Supplier. The Owner can remove a Supplier created in error and archive an inactive one.
- **FR-26** — Supplier list and detail. The Owner can see all Suppliers with balances, and open one.
- **FR-27** — Supplier Ledger. The Owner can view a chronological Ledger for one Supplier with a running balance.
- **FR-28** — Record a due taken. The Owner can record an amount owed to a Supplier without itemising Products.
- **FR-29** — Suppliers with outstanding balances. The Owner can see every Supplier the Business owes, sorted by amount.
- **FR-30** — Create a Sale. The Owner can record a Sale of one or more Products to an optional Customer, with a Paid amount and Payment Method.
- **FR-31** — Add and edit Sale Items. The Owner can add Products to a Sale with quantity, unit price and line discount.
- **FR-32** — Sale totals and discount. The Owner can apply an order-level discount and sees the resulting Total before saving.
- **FR-33** — Record payment against a Sale. The Owner can record how much the Customer paid now, by which Payment Method, with the remainder becoming Due.
- **FR-34** — Sale list. The Owner can browse and filter past Sales.
- **FR-35** — Sale detail. The Owner can open a Sale and see everything it recorded.
- **FR-36** — Correct a Sale. The Owner can correct a Sale they entered wrongly.
- **FR-37** — Void a Sale. The Owner can remove a Sale entered in error.
- **FR-38** — Walk-in cash sale fast path. The Owner can record a cash sale with no Customer in the minimum possible number of taps.
- **FR-39** — Sales affect stock. Every itemised Sale decrements Inventory for each Sale Item.
- **FR-40** — Create a Purchase. The Owner can record a Purchase of one or more Products from a Supplier with a Paid amount and Payment Method.
- **FR-41** — Add Purchase Items. The Owner can add Products with quantity and unit cost.
- **FR-42** — Purchase payment and due. The Owner can record how much was paid now, with the remainder becoming a Supplier Due.
- **FR-43** — Purchase list and detail. The Owner can browse, filter and open past Purchases.
- **FR-44** — Edit or delete a Purchase. The Owner can correct or remove a Purchase.
- **FR-45** — Purchases affect stock. Every itemised Purchase increments Inventory for each Purchase Item.
- **FR-46** — Create and edit Product. The Owner can create a Product with a name and Unit, and optionally SKU, barcode value, Category, purchase price, selling price, Minimum Stock, opening stock and default Supplier.
- **FR-47** — Product categories. The Owner can group Products into Categories.
- **FR-48** — Units. Every Product has one Unit from the fixed list: Piece, Kg, Gram, Liter, Box, Packet, Dozen, Meter.
- **FR-49** — Product list. The Owner can browse, search and filter Products.
- **FR-50** — Product detail. The Owner can see one Product's full position.
- **FR-51** — Inventory summary. The Owner can see the state of stock across the Business.
- **FR-52** — Stock Movement trail. Every change to Inventory is recorded as a Stock Movement with a reason.
- **FR-53** — Manual stock adjustment. The Owner can correct a Product's Inventory and record damage or loss.
- **FR-54** — Low Stock threshold. The Owner can set a Minimum Stock level per Product that drives Low Stock warnings.
- **FR-55** — Bulk product entry. The Owner can add several Products in one session without returning to the list between each.
- **FR-119** — Import a product catalogue from a file. The Owner can populate their Product catalogue by importing a spreadsheet, rather than entering hundreds of items by hand.
- **FR-56** — Product performance. The Owner can see which Products actually sell.
- **FR-57** — Record an Expense. The Owner can record an Expense with amount, Expense Category, Payment Method, date and optional note.
- **FR-58** — Expense Categories. The Owner can classify Expenses using seeded categories and add their own.
- **FR-59** — Expense list and detail. The Owner can browse, filter, edit and delete Expenses.
- **FR-60** — Recurring Expenses. The Owner can define an Expense that repeats, and be reminded when it is due.
- **FR-61** — Owner withdrawal. The Owner can record money taken out of the Business for personal use, separately from Expenses.
- **FR-62** — Record a Customer Payment (টাকা পেলাম). The Owner can record money received from a Customer against their Balance.
- **FR-63** — Record a Supplier Payment (টাকা দিলাম). The Owner can record money paid to a Supplier against the Supplier Balance.
- **FR-64** — Payment Methods. Every Payment, Sale payment, Purchase payment and Expense names one Payment Method.
- **FR-65** — Payment receipt. The Owner can share a Receipt for a Customer Payment.
- **FR-66** — Money Accounts view. The Owner can see the balance of every Money Account and the total.
- **FR-67** — Account Transfer. The Owner can move money between two Money Accounts.
- **FR-68** — Negative balance handling. The app records a Money Account balance going negative rather than blocking the entry.
- **FR-69** — Payment history. The Owner can browse all Payments across Parties and accounts.
- **FR-70** — Sales Return. The Owner can record goods returned by a Customer against an existing Sale.
- **FR-71** — Standalone Sales Return. The Owner can record a return where the original Sale is not in Hisab.
- **FR-72** — Purchase Return. The Owner can record goods returned to a Supplier against an existing Purchase.
- **FR-73** — Return visibility. Returns are visible from both the original transaction and the reports.
- **FR-74** — Generate a Sale Receipt. The Owner can generate a Receipt for any Sale.
- **FR-75** — Share a Receipt. The Owner can share a Receipt through the phone's sharing options.
- **FR-76** — Print a Receipt. The Owner can print a Receipt where the device supports printing.
- **FR-77** — Share a Ledger statement. The Owner can share a Customer's or Supplier's Ledger as a PDF for a date range.
- **FR-78** — Daily summary. The Owner can see one screen summarising the day's business.
- **FR-79** — Sales report. The Owner can see sales performance over a period.
- **FR-80** — Expense report. The Owner can see spending over a period, by Category.
- **FR-81** — Profit report. The Owner can see whether the Business made money over a period.
- **FR-82** — Dues and inventory reports. The Owner can see outstanding balances and stock position as reports.
- **FR-83** — Report integrity disclosures. Every report states what it excludes.
- **FR-84** — Export a report. The Owner can export any report as a PDF.
- **FR-85** — Global search. The Owner can search across Customers, Suppliers, Products, Sales, Purchases and Expenses from one field.
- **FR-86** — Search from context. Every list screen has a scoped search over just that list.
- **FR-87** — Recent and suggested. Search suggests recent entities before the Owner types.
- **FR-88** — Due reminder list. The Owner can see which Customers are overdue and act from that list.
- **FR-89** — Send a reminder. The Owner can send a Customer a payment reminder through WhatsApp or SMS.
- **FR-90** — Reminder schedule per Customer. The Owner can set how often a Customer should appear as due for a reminder.
- **FR-91** — Notifications. Hisab notifies the Owner about stock, dues, recurring expenses and unrecorded days.
- **FR-92** — Notification preferences. The Owner controls what Hisab notifies them about.
- **FR-93** — Offline transaction recording. The Owner can record every transaction type with no network connection.
- **FR-94** — Local-first reads. Every screen renders from the local database.
- **FR-95** — Sync queue and status. The Owner can see what has not yet reached the cloud.
- **FR-96** — Automatic sync. Hisab syncs without the Owner asking.
- **FR-97** — Conflict resolution. Concurrent edits from two devices resolve by documented rules, and the unresolvable ones reach the Owner.
- **FR-98** — Cloud backup. The Owner's data is backed up to the cloud continuously and they can see that it is.
- **FR-99** — Restore on a new device. The Owner can sign in on a new device and get their Business back.
- **FR-100** — Ask Hisab — question answering. The Owner can ask a question in Bangla or English about their own business and get an answer computed from their data.
- **FR-101** — Ask Hisab — scope and safety. Ask Hisab answers only about the Owner's own Business and only about the past.
- **FR-102** — AI Daily Summary. The Owner receives a short written summary of their business day.
- **FR-103** — AI Transaction Entry — drafting. The Owner can type a sentence describing a transaction and receive a Transaction Draft.
- **FR-104** — AI Transaction Entry — confirmation gate. No AI-drafted transaction is saved without explicit Owner confirmation.
- **FR-105** — AI Transaction Entry — ambiguity handling. Where the AI cannot resolve an entity or an amount with confidence, it asks rather than guesses.
- **FR-106** — AI availability and degradation. AI features degrade honestly when unavailable.
- **FR-107** — AI usage limits. AI usage is metered per Business and enforced against the Plan.
- **FR-108** — AI transparency. The Owner can tell what is AI-generated.
- **FR-109** — Plans and entitlements. Every Business is on a Plan that determines its Usage Limits.
- **FR-110** — Limit enforcement. Reaching a Usage Limit is communicated clearly and never destroys data.
- **FR-111** — Plan status and upgrade interest. The Owner can see their Plan, their usage, and register interest in upgrading.
- **FR-112** — Manual Plan assignment. Hisab staff can move a Business between Plans without an app release.
- **FR-113** — Business settings. The Owner can edit their Business details and Money Account opening balances after setup.
- **FR-114** — App settings. The Owner can control language, app lock, notifications and AI.
- **FR-115** — Analytics. Hisab records product events to inform the roadmap, without exporting financial detail.
- **FR-116** — Data export. The Owner can export their own data.
- **FR-117** — Audit trail. Financially significant changes are recorded and inspectable.
- **FR-118** — Help and support. The Owner can get help without leaving the app.
- **FR-120** — Account and data deletion. The Owner can delete their account and all their Business data from inside the app.

### NonFunctional Requirements

Extracted from PRD §8. Feature-specific NFRs stay attached to their features in PRD §4 and are cited by the stories that implement them.

- **NFR-1** *(Performance)* — API p95 under 500 ms; local transaction write to perceived confirmation under 100 ms; search under 300 ms; Home under 1 second; AI response under 4 seconds p95.
- **NFR-2** *(Performance)* — Every one of these must hold on a mid-range 2023 Android device on a 3G connection, not on a flagship on wifi.
- **NFR-3** *(Performance)* — App cold start to interactive Home: under 3 seconds.
- **NFR-4** *(Performance)* — APK size under 40 MB.
- **NFR-5** *(Reliability and correctness)* — Financial writes are atomic and transactional end to end (TD §31). A partially applied Sale — stock moved but ledger not, or the reverse — is a defect of the highest severity.
- **NFR-6** *(Reliability and correctness)* — Every derived figure must be reproducible from its underlying records: Party Balance from Ledger Entries, Inventory from Stock Movements, Money Account balance from movements. Any drift between a stored aggregate and its derivation is a P0 defect.
- **NFR-7** *(Reliability and correctness)* — Idempotency on every write endpoint, so retries after a dropped connection cannot double-post (TD §32).
- **NFR-8** *(Reliability and correctness)* — No data loss under app kill, device restart, storage pressure or force-quit mid-write.
- **NFR-9** *(Offline)* — The app is fully functional for all transaction recording, all reads and all reports with zero connectivity, for an unbounded period, limited only by device storage.
- **NFR-10** *(Offline)* — Sync queue survives app termination and device restart.
- **NFR-11** *(Security)* — All traffic over TLS. Credentials in platform secure storage, never in shared preferences or plain files (TD §36).
- **NFR-12** *(Security)* — Every API request is scoped server-side to the authenticated User's Business; no client-supplied identifier can widen that scope (TD §51).
- **NFR-13** *(Security)* — Local database is encrypted at rest.
- **NFR-14** *(Security)* — OTP endpoints are rate-limited per number and per IP (FR-1).
- **NFR-15** *(Accessibility and device reality)* — Minimum touch target 48×48 dp throughout; primary Quick Actions larger.
- **NFR-16** *(Accessibility and device reality)* — Legible at the largest system font size without truncation or overlap on a 5-inch screen.
- **NFR-17** *(Accessibility and device reality)* — Usable one-handed for the six Quick Action flows.
- **NFR-18** *(Accessibility and device reality)* — Sufficient contrast for a screen viewed in daylight at a shop front.
- **NFR-19** *(Accessibility and device reality)* — Android 8.0+ and iOS 14+.
- **NFR-20** *(Localisation)* — Complete Bangla coverage: every string, error message, notification, Receipt and report. An untranslated English string in a user-facing surface is a defect, not a polish item.
- **NFR-21** *(Localisation)* — Bangla renders with correct conjuncts on device and in generated PDFs, which requires an embedded font (§4.11 NFRs).
- **NFR-22** *(Localisation)* — Asia/Dhaka is the business day boundary for all "today" calculations.
- **NFR-23** *(Observability)* — Sync failures, financial-write failures, AI failures and crashes are reported with enough context to diagnose without the Owner's data (TD §63).
- **NFR-24** *(Observability)* — A dashboard exists for sync queue depth, sync failure rate and financial-write error rate before launch.

### Additional Requirements

Extracted from `ARCHITECTURE-SPINE.md` (AD-1 … AD-24, status final). These are binding invariants, not suggestions — a story that violates one is wrong even if it satisfies its FR.

**Starter template: NONE.** The spine names no starter or scaffold. Epic 1 Story 1 must therefore stand up the monorepo by hand — `apps/{mobile,api,ai,admin}` plus `packages/contracts` — and **pin every stack version at that moment against the live registry**, because the spine deliberately pins nothing (registry lookups were unavailable when it was written) and the lockfiles become the authority afterwards.

- **AR-1** — Money is integer paisa everywhere (`BIGINT`/`int`/`bigint`/JSON number); fields end `…Paisa`. Storage only: every surface renders taka. Rounding is half-to-even with the residual on the last consumed layer or last line. *(AD-1)*
- **AR-2** — Quantity is integer milli-units; fields end `…Milli`. Unit type decides whether the UI accepts a fraction. *(AD-2)*
- **AR-3** — Client-minted UUIDv7 is the only identity, on device and server, and is what every foreign key stores. No `serverId`. *(AD-3)*
- **AR-4** — Financial tables are append-only: no `UPDATE`, no `DELETE`, device or server. Corrections write a reversal plus a new record. *(AD-4)*
- **AR-5** — The atomic envelope: transaction + items + stock movements + layer consumptions + ledger entry + money movement commit in one local transaction, and apply server-side whole. *(AD-5)*
- **AR-6** — Derived figures are derived, never stored authoritatively: party balance from ledger entries, inventory from stock movements, account balance from money movements, stock value from open cost layers. *(AD-6)*
- **AR-7** — FIFO cost layers: `CostLayer` stores no remaining quantity; consumption order is `(businessDate, id)`; written consumption is the sole COGS authority; reversals write negative consumptions and never open layers; conservation (Σ consumed ≤ opened) asserted server-side. *(AD-7)*
- **AR-8** — Negative-stock sales cost provisionally and are reconciled by an appended `LayerConsumptionAdjustment`, never by restating. COGS = consumptions + adjustments. *(AD-8)*
- **AR-9** — Every table is classified financial or reference, exhaustively, with a build-time check failing the build on an unclassified table. Financial never conflicts; reference resolves last-writer-wins by server receipt time. *(AD-9)*
- **AR-10** — Idempotency on the record's own UUIDv7; financial writes carry no unique constraint besides the PK that an envelope could violate. *(AD-10)*
- **AR-11** — `businessId` is resolved server-side from the authenticated principal and injected; never trusted from a request body or an AI-extracted parameter. *(AD-11)*
- **AR-12** — The AI service holds a read-only DB role and has no write path. A Draft has no persistence; saving calls the same endpoint as a form entry. *(AD-12)*
- **AR-13** — Ask Hisab is a versioned catalogue of hand-written parameterised queries; the model returns a catalogue id and typed parameters only. *(AD-13)*
- **AR-14** — Timestamps stored UTC; business day boundary Asia/Dhaka; `businessDate` derived once at creation and stored. *(AD-14)*
- **AR-15** — Two per-Business receipt series from server-issued per-device blocks; partial unique index excludes the reversal chain; gaps accepted. *(AD-15)*
- **AR-16** — One error envelope `{error:{code,message,details?}}`; Bangla text resolved client-side from `code`. *(AD-16)*
- **AR-17** — Local database encrypted with SQLCipher; key in the platform keystore. *(AD-17)*
- **AR-18** — Analytics through a typed façade with a schema-level allow-list; no amounts, names or phone numbers. *(AD-18)*
- **AR-19** — No `openingBalancePaisa` column anywhere; opening balance is a `MoneyMovement`; editing it writes a reversal plus a new one. *(AD-19)*
- **AR-20** — `LedgerEntry` = `partyId` + `direction` + non-negative `amountPaisa` + source id, always from the Business's perspective. No stored running balance. *(AD-20)*
- **AR-21** — `SaleItem`/`PurchaseItem` carry an explicit `lineNo`. *(AD-21)*
- **AR-22** — Envelopes are self-contained (reference entities created offline travel inside) and apply in per-device enqueue order. *(AD-22)*
- **AR-23** — Sync outcomes split transient (retry with backoff indefinitely) from permanent 4xx (stop, move to `needs_attention`, surface with reason and action). Nothing dropped, nothing retrying into a wall. *(AD-23)*
- **AR-24** — Pull cursor is a server-assigned monotonic change id, never a timestamp; a stale watermark triggers full resync. *(AD-24)*
- **AR-25** — Monorepo layout `apps/mobile|api|ai|admin` + `packages/contracts`; contracts generated from OpenAPI and shared. *(Structural Seed)*
- **AR-26** — **Railway** (decided 2026-09-03): managed Postgres with PITR, managed Redis, container deploys from git, three environments as separate Railway projects, Singapore region, no provider-specific code so the choice stays reversible. Backups RPO 15–60 min, RTO 1–4 h, restore rehearsed before launch. *(Structural Seed)*
- **AR-27** — Prisma migrations server-side, Drift migrations client-side, both forward-only, both tested against a populated database before merge. *(Conventions)*
- **AR-28** — The financial test suite is a release gate on every epic: atomicity, reproducibility of every derived figure, FIFO consumption order, provisional reconciliation, idempotent replay. *(Conventions)*
- **AR-29** — Riverpod notifiers are the only client state mutators; repositories are the sole database surface; no widget writes to the DB. *(Conventions)*
- **AR-30** — Structured JSON logging with `businessId` and correlation id, never an amount, a party name or a phone number. *(Conventions)*

### UX Design Requirements

Extracted from `DESIGN.md` and `EXPERIENCE.md` (both status final). Each is scoped to generate a story with testable acceptance criteria.

**Foundation and tokens**

- **UX-DR1** — Implement the design token set as the app's single theme source: 13 colour tokens, 4 amount type sizes plus 4 text roles, 5 radii, a 6-step spacing scale. No literal colour or size may appear in a widget.
- **UX-DR2** — Theme Material 3 to those tokens (colour scheme, type scale, corner radii, density). Components inherit M3 anatomy and accessibility behaviour; only the delta is overridden.
- **UX-DR3** — Bundle **Noto Serif Bengali** (600/700, headings/receipts) and **Hind Siliguri** (400–700, UI and all numerals) as app assets, not system fonts, with tabular figures enabled globally. Verify Bangla conjunct rendering on both platforms and inside generated PDFs.
- **UX-DR4** — Numeral formatter and parser: render Bangla digits with **lakh grouping** in Bangla mode and Western digits with Western grouping in English mode; parse input accepting Bangla digits, Western digits and a mix, in either mode. One shared utility used by every surface, including receipts, reports and the AI draft parser.

**Components (each reusable, each its own story-sized unit)**

- **UX-DR5** — `QuickActionTile`: ≥80px, icon over two-word label, no truncation at the largest accessibility font size, opens its flow in one tap, functional offline.
- **UX-DR6** — `AmountField`: raises to 26–34px in accent on focus, accepts both digit scripts, formats on blur only (never mid-keystroke).
- **UX-DR7** — `PartyPicker`: type-ahead over name and phone, bidirectional Bangla↔Latin matching, every row shows the party's current balance, inline "create new" as the last row returning to the flow with nothing lost.
- **UX-DR8** — `LedgerRow`: fixed grid (date, description, credit, running balance), read-only, taps through to its source transaction, running balance heavier than the rest, final row heaviest.
- **UX-DR9** — `DisclosureBanner`: inline at the point of consequence, non-dismissible, warning palette — carries the honesty statements (non-itemised sale, missing cost basis, provisional costing).
- **UX-DR10** — `ConfirmationSummary`: the three-effect card (amount, party balance from→to, money account effect) rendered **above** the save button on every money flow.
- **UX-DR11** — `AiSurface`: distinct fill and border plus a persistent label, used for every AI-generated element; must never resemble a saved record.
- **UX-DR12** — `ChipGroup`: single- and multi-select variants, selection shown by fill change (never border), last-used option pre-selected per flow.

**Navigation and information architecture**

- **UX-DR13** — Implement বিকল্প খ: three tabs (হোম, খাতা, আরও) plus a raised centre action button that opens the six quick actions as a sheet **from any tab**. বিক্রি, পণ্য and রিপোর্ট are pushed screens under আরও with back navigation. Depth capped at three; one modal or sheet level, never two.

**State patterns**

- **UX-DR14** — Offline is not a state: no offline banner, no greyed control, no connectivity-driven error or spinner anywhere. Enforced by review on every screen.
- **UX-DR15** — Pending-sync indicator: unobtrusive count, absent at zero, distinguishing *waiting for connection* from *sync failing*, with `needs_attention` items visually distinct and actionable (AR-23).
- **UX-DR16** — Empty states name the first action and nothing else — no illustration, no explanatory paragraph. Panels that are usually empty (low stock) hide entirely rather than render empty.
- **UX-DR17** — Unusual-value rendering: negative money account in warning treatment, negative party balance as *জমা আছে* (advance) rather than a minus sign, negative stock as শেষ with the true figure on the product detail.
- **UX-DR18** — Correction transparency: the ledger shows original, reversal and correction as three visible lines; the UI never implies history was erased. No undo affordance anywhere.

**Voice and content**

- **UX-DR19** — Microcopy states outcomes in the owner's words with the changed number (*রহিমের বাকি ৳৪,০৮০ থেকে কমে ৳১,০৮০ হলো*), never operation status. Fixed Bangla vocabulary; the words receivable, payable, debit, credit, ledger and FIFO never appear in English on a user-facing surface.
- **UX-DR20** — Complete Bangla string coverage for every screen, error, notification, receipt and report. An untranslated user-facing string is a defect, not polish.

**Accessibility**

- **UX-DR21** — 48dp minimum hit target throughout; 54px primary actions; 80px quick actions.
- **UX-DR22** — Full layout integrity at the largest system font size on a 5-inch screen — no truncation, no overlap, no clipped Bangla label. Labels shorten before type does.
- **UX-DR23** — Bangla accessible label on every interactive element including icon-only controls; screen-reader order follows visual order, with the amount read before its label in summary cards.
- **UX-DR24** — Colour is never the sole carrier of meaning (money in/out differ by sign and position; low stock carries a word as well as amber); `prefers-reduced-motion` honoured, no animation load-bearing.
- **UX-DR25** — All six quick-action flows completable one-handed.

**App identity**

- **UX-DR26** — App icon (খাতা — ledger with spine band): Android adaptive two-layer with all meaning inside the 66dp safe circle, opaque 1024px iOS square with no pre-rounded corners, flat white notification silhouette. Mark traced to outlines — no shipped icon depends on a webfont.

### FR Coverage Map

### FR Coverage Map

All 120 FRs are mapped; no FR appears twice and none is unassigned.

| FR | Requirement | Epic |
| --- | --- | --- |
| FR-1 | Phone-number authentication with OTP | 1 — Open Hisab and set up my shop |
| FR-2 | Business creation | 1 — Open Hisab and set up my shop |
| FR-3 | Owner profile capture | 1 — Open Hisab and set up my shop |
| FR-4 | Opening Balance entry | 1 — Open Hisab and set up my shop |
| FR-5 | Party opening balance | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-6 | Session persistence and sign-out | 1 — Open Hisab and set up my shop |
| FR-7 | App lock | 1 — Open Hisab and set up my shop |
| FR-8 | Language | 1 — Open Hisab and set up my shop |
| FR-9 | Today's figures | 5 — Know how the business is doing |
| FR-10 | Receivable and Payable summary | 5 — Know how the business is doing |
| FR-11 | Low Stock panel | 5 — Know how the business is doing |
| FR-12 | Money Account summary | 5 — Know how the business is doing |
| FR-13 | Quick Actions | 5 — Know how the business is doing |
| FR-14 | Greeting and Business identity | 5 — Know how the business is doing |
| FR-15 | Create and edit Customer | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-16 | Delete or archive Customer | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-17 | Customer list | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-18 | Customer detail | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-19 | Customer Ledger | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-20 | Record a credit given (বাকি দিলাম) | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-21 | Customers with outstanding balances | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-22 | Customer transaction history filters | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-23 | Manual balance adjustment | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-24 | Create and edit Supplier | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-25 | Delete or archive Supplier | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-26 | Supplier list and detail | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-27 | Supplier Ledger | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-28 | Record a due taken | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-29 | Suppliers with outstanding balances | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-30 | Create a Sale | 4 — Sell and buy |
| FR-31 | Add and edit Sale Items | 4 — Sell and buy |
| FR-32 | Sale totals and discount | 4 — Sell and buy |
| FR-33 | Record payment against a Sale | 4 — Sell and buy |
| FR-34 | Sale list | 4 — Sell and buy |
| FR-35 | Sale detail | 4 — Sell and buy |
| FR-36 | Correct a Sale | 4 — Sell and buy |
| FR-37 | Void a Sale | 4 — Sell and buy |
| FR-38 | Walk-in cash sale fast path | 4 — Sell and buy |
| FR-39 | Sales affect stock | 4 — Sell and buy |
| FR-40 | Create a Purchase | 4 — Sell and buy |
| FR-41 | Add Purchase Items | 4 — Sell and buy |
| FR-42 | Purchase payment and due | 4 — Sell and buy |
| FR-43 | Purchase list and detail | 4 — Sell and buy |
| FR-44 | Edit or delete a Purchase | 4 — Sell and buy |
| FR-45 | Purchases affect stock | 4 — Sell and buy |
| FR-46 | Create and edit Product | 3 — Stock I can trust |
| FR-47 | Product categories | 3 — Stock I can trust |
| FR-48 | Units | 3 — Stock I can trust |
| FR-49 | Product list | 3 — Stock I can trust |
| FR-50 | Product detail | 3 — Stock I can trust |
| FR-51 | Inventory summary | 3 — Stock I can trust |
| FR-52 | Stock Movement trail | 3 — Stock I can trust |
| FR-53 | Manual stock adjustment | 3 — Stock I can trust |
| FR-54 | Low Stock threshold | 3 — Stock I can trust |
| FR-55 | Bulk product entry | 3 — Stock I can trust |
| FR-56 | Product performance | 5 — Know how the business is doing |
| FR-57 | Record an Expense | 5 — Know how the business is doing |
| FR-58 | Expense Categories | 5 — Know how the business is doing |
| FR-59 | Expense list and detail | 5 — Know how the business is doing |
| FR-60 | Recurring Expenses | 5 — Know how the business is doing |
| FR-61 | Owner withdrawal | 5 — Know how the business is doing |
| FR-62 | Record a Customer Payment (টাকা পেলাম) | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-63 | Record a Supplier Payment (টাকা দিলাম) | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-64 | Payment Methods | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-65 | Payment receipt | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-66 | Money Accounts view | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-67 | Account Transfer | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-68 | Negative balance handling | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-69 | Payment history | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-70 | Sales Return | 4 — Sell and buy |
| FR-71 | Standalone Sales Return | 4 — Sell and buy |
| FR-72 | Purchase Return | 4 — Sell and buy |
| FR-73 | Return visibility | 4 — Sell and buy |
| FR-74 | Generate a Sale Receipt | 4 — Sell and buy |
| FR-75 | Share a Receipt | 4 — Sell and buy |
| FR-76 | Print a Receipt | 4 — Sell and buy |
| FR-77 | Share a Ledger statement | 4 — Sell and buy |
| FR-78 | Daily summary | 5 — Know how the business is doing |
| FR-79 | Sales report | 5 — Know how the business is doing |
| FR-80 | Expense report | 5 — Know how the business is doing |
| FR-81 | Profit report | 5 — Know how the business is doing |
| FR-82 | Dues and inventory reports | 5 — Know how the business is doing |
| FR-83 | Report integrity disclosures | 5 — Know how the business is doing |
| FR-84 | Export a report | 5 — Know how the business is doing |
| FR-85 | Global search | 5 — Know how the business is doing |
| FR-86 | Search from context | 5 — Know how the business is doing |
| FR-87 | Recent and suggested | 5 — Know how the business is doing |
| FR-88 | Due reminder list | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-89 | Send a reminder | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-90 | Reminder schedule per Customer | 2 — Keep বাকি হিসাব — who owes me, who I owe |
| FR-91 | Notifications | 6 — Never lose my হিসাব |
| FR-92 | Notification preferences | 6 — Never lose my হিসাব |
| FR-93 | Offline transaction recording | 1 — Open Hisab and set up my shop |
| FR-94 | Local-first reads | 1 — Open Hisab and set up my shop |
| FR-95 | Sync queue and status | 6 — Never lose my হিসাব |
| FR-96 | Automatic sync | 6 — Never lose my হিসাব |
| FR-97 | Conflict resolution | 6 — Never lose my হিসাব |
| FR-98 | Cloud backup | 6 — Never lose my হিসাব |
| FR-99 | Restore on a new device | 6 — Never lose my হিসাব |
| FR-100 | Ask Hisab — question answering | 7 — Talk to Hisab |
| FR-101 | Ask Hisab — scope and safety | 7 — Talk to Hisab |
| FR-102 | AI Daily Summary | 7 — Talk to Hisab |
| FR-103 | AI Transaction Entry — drafting | 7 — Talk to Hisab |
| FR-104 | AI Transaction Entry — confirmation gate | 7 — Talk to Hisab |
| FR-105 | AI Transaction Entry — ambiguity handling | 7 — Talk to Hisab |
| FR-106 | AI availability and degradation | 7 — Talk to Hisab |
| FR-107 | AI usage limits | 7 — Talk to Hisab |
| FR-108 | AI transparency | 7 — Talk to Hisab |
| FR-109 | Plans and entitlements | 8 — Ready to ship |
| FR-110 | Limit enforcement | 8 — Ready to ship |
| FR-111 | Plan status and upgrade interest | 8 — Ready to ship |
| FR-112 | Manual Plan assignment | 8 — Ready to ship |
| FR-113 | Business settings | 8 — Ready to ship |
| FR-114 | App settings | 8 — Ready to ship |
| FR-115 | Analytics | 8 — Ready to ship |
| FR-116 | Data export | 8 — Ready to ship |
| FR-117 | Audit trail | 8 — Ready to ship |
| FR-118 | Help and support | 8 — Ready to ship |
| FR-119 | Import a product catalogue from a file | 3 — Stock I can trust |
| FR-120 | Account and data deletion | 8 — Ready to ship |

## Epic List

Eight epics. The structure is deliberately **fewer and larger** than the fifteen sketched in the PRD addendum: the architecture spine, both UX spines and the PRD are all reviewed and final, so the risk that early feedback redirects a later epic is low — and the addendum's split would have had three separate epics editing the same transaction, ledger and stock files.

### Epic 1: Open Hisab and set up my shop

A shop owner installs Hisab, signs in with their phone number, tells it about their business, records what money the shop has today — and lands on a Home screen showing their own figures, not sample data. Nothing in this epic needs a connection after the first sign-in.

**Standalone:** delivers a working, encrypted, offline-capable app with a real business in it. **Enables:** every later epic writes into the store this one establishes.

**Consolidation note:** the unglamorous foundation lives here rather than in a "setup" epic with no user value — the monorepo, the pinned versions, the design tokens, the bundled Bangla fonts, the numeral formatter, the encrypted local database and the sync skeleton are all *stories inside* an epic whose outcome an owner can see.

**FRs covered:** FR-1–FR-8, FR-93–FR-94

### Epic 2: Keep বাকি হিসাব — who owes me, who I owe

The heart of the product, and deliberately the second thing built: an owner can record who owes them and who they owe, take and make payments across cash/bKash/Nagad/Rocket/bank, read a running ledger they can show a customer, and chase what they're owed — **with no products and no sales in the system at all.**

**Standalone:** a shop that never opens the Products screen still gets full value. **Enables:** sales and purchases in Epic 4 attach to these parties and write into these ledgers.

**Consolidation note:** parties, ledgers, payments, money accounts and reminders are one epic because they all write `LedgerEntry` and `MoneyMovement`. Splitting them would have three epics editing the same files in sequence.

**FRs covered:** FR-5, FR-15–FR-29, FR-62–FR-69, FR-88–FR-90

### Epic 3: Stock I can trust

An owner gets a catalogue — typed in, or imported from a spreadsheet they already have — with stock levels, low-stock warnings, damage and adjustments. Underneath it, the FIFO cost machinery that every profit figure later depends on.

**Standalone:** stock tracking works on its own; an owner can know what they hold and what it's worth. **Enables:** Epic 4's sales and purchases consume and open the cost layers this epic defines.

**Why this precedes selling:** the `CostLayer` / `LayerConsumption` schema is the single most consequential structure in the build (AR-7, AR-8, risk R-11). Establishing and testing it against manual adjustments and damage — where the inputs are simple — is far cheaper than discovering its edge cases inside the sale flow.

**FRs covered:** FR-46–FR-55, FR-119

### Epic 4: Sell and buy

The flow the whole product is measured on: an owner records a sale in under twenty seconds, cash or credit, itemised or not, and hands the customer a receipt. Plus purchases, corrections, voids and returns.

**Standalone:** completes the transaction surface. **Depends on** Epics 2 and 3, and requires neither 5 nor anything later.

**Consolidation note:** sales, purchases and returns are one epic on purpose. All three write the same atomic envelope (AR-5), the same ledger entries, the same stock movements and the same layer consumptions. As three epics they would rewrite the same files three times, and the reversal semantics (AR-4) only make sense specified once.

**FRs covered:** FR-30–FR-45, FR-70–FR-77

### Epic 5: Know how the business is doing

An owner opens the app and knows, without asking anyone: what sold today, what came in, what went out, what they're owed, what they made this month — and can find any customer, product or receipt by typing part of its name in either script.

**Standalone:** every figure reads from what Epics 1–4 already record. **Depends on** all of them; nothing later is required.

**Consolidation note:** expenses join the reporting epic because they are the last missing input to a truthful profit figure, and because Home, the daily summary and all six reports read the same aggregates — separating them would mean two epics rewriting the same query layer.

**FRs covered:** FR-9–FR-14, FR-56, FR-57–FR-61, FR-78–FR-87

### Epic 6: Never lose my হিসাব

The epic that decides whether an owner keeps using Hisab after their first bad week: the sync queue becomes visible and honest, conflicts surface instead of vanishing, the cloud copy is provably current, a new phone restores everything, and the app tells them the few things they'd otherwise miss.

**Standalone:** hardens what Epic 1 established. Offline recording (FR-93, FR-94) is a property of the architecture from Epic 1 onward, not something this epic adds — what lands here is everything that makes it *trustworthy*.

**Note:** AR-23's `needs_attention` state and AR-24's cursor are here, and both are worth building before real users generate the failures they handle.

**FRs covered:** FR-91–FR-92, FR-95–FR-99

### Epic 7: Talk to Hisab

The differentiator: an owner asks a question in Bangla and gets an answer computed from their own ledger, reads a two-sentence summary of their day, and types *"Rahim 1500 টাকার মাল নিয়েছে, 500 টাকা দিয়েছে"* instead of filling a form.

**Standalone:** entirely behind feature flags (AR-12, FR-106). The product ships and works with this epic switched off, which is exactly why it can be last.

**⚠️ Scheduling exception — the one thing that must not wait for its epic.** The Banglish parsing spike (risk R-2) needs to run **during Epics 1–2**, months before this epic starts. If parsing quality is poor, the product's positioning changes, and finding that out in week 14 is too late. The spike is a story here but its *execution* is early.

**FRs covered:** FR-100–FR-108

### Epic 8: Ready to ship

Everything that stands between a working app and two store listings: plan limits enforced server-side, settings, the owner's own data export, the audit trail, in-app account deletion, and the store submissions themselves.

**Standalone:** the release epic. **Depends on** everything, and nothing depends on it.

**Note:** FR-120 (account deletion) is a store-submission gate, not a nice-to-have — both stores reject apps that support account creation without an in-app deletion path. It cannot slip.

**FRs covered:** FR-109–FR-118, FR-120

---

## Epic 1: Open Hisab and set up my shop

A shop owner installs Hisab, signs in with their phone number, tells it about their business, records what money the shop has today — and lands on a Home screen showing their own figures. Everything this epic builds keeps working with no connection.

**FRs covered:** FR-1–FR-4, FR-6–FR-8, FR-93, FR-94 · **UX-DRs:** UX-DR1–UX-DR4, UX-DR14, UX-DR21–UX-DR23 · **Architecture:** AR-1, AR-2, AR-3, AR-5, AR-14, AR-16, AR-17, AR-22, AR-25, AR-26, AR-27, AR-30

### Story 1.1: Stand up the workspace and pin the stack

As the engineer building Hisab,
I want a monorepo with every dependency pinned to a version I verified today,
So that no later story inherits a guessed version, and the lockfiles become the single source of truth.

**Acceptance Criteria:**

**Given** an empty repository and no starter template (the architecture spine deliberately names none)
**When** the workspace is created
**Then** `apps/mobile`, `apps/api`, `apps/ai`, `apps/admin` and `packages/contracts` exist as described in the spine's Structural Seed
**And** every dependency in every app is pinned to an exact version **checked against the live registry at this moment**, not carried from the spine's Stack table, which pins nothing on purpose
**And** the resolved versions are committed as lockfiles, which are the authority from here on

**Given** the workspace exists
**When** a pull request is opened
**Then** CI runs lint, unit tests and a build for each app and blocks the merge on any failure

**Given** three environments are required on **Railway** (AR-26)
**When** infrastructure is provisioned
**Then** development, staging and production exist as separate Railway projects in the Singapore region with separate databases, Redis, storage and credentials, and no production credential is reachable from a developer machine

**Given** the spine forbids provider-specific code (AR-26)
**When** any infrastructure is accessed from application code
**Then** it is reached through configuration and a standard client, so the PaaS vendor remains replaceable

### Story 1.2: Make the app look like Hisab

As a shop owner,
I want the app to read clearly at arm's length in daylight and to be written in my language,
So that it feels like something made for my shop rather than software I have to decode.

**Acceptance Criteria:**

**Given** the design tokens in DESIGN.md (UX-DR1)
**When** the theme is implemented
**Then** all 13 colour tokens, the 4 amount sizes, the 4 text roles, the 5 radii and the 6-step spacing scale exist as the single theme source
**And** no widget anywhere declares a literal colour, radius or font size — a lint rule or review check enforces this

**Given** Material 3 is the base system (UX-DR2)
**When** components are themed
**Then** M3 anatomy, states and accessibility behaviour are inherited, and only the documented delta is overridden

**Given** Bangla must render correctly on screen and in generated PDFs (UX-DR3)
**When** fonts are configured
**Then** Noto Serif Bengali (600/700) and Hind Siliguri (400–700) ship as bundled app assets, not system fonts
**And** tabular figures are enabled globally so columns of money align
**And** a rendering test confirms correct Bangla conjuncts on Android, on iOS, and inside a generated PDF

**Given** an owner using the largest system font size on a 5-inch screen (UX-DR22)
**When** any themed screen is displayed
**Then** no label truncates, overlaps or clips

**Given** the accessibility floor (UX-DR21, UX-DR23, UX-DR24)
**When** any themed component is built
**Then** every hit target is at least 48dp, every interactive element carries a Bangla accessible label including icon-only controls, and screen-reader order follows visual order
**And** **colour is never the sole carrier of meaning** — money in and out differ by sign and position as well as hue, and low stock carries a word as well as amber
**And** `prefers-reduced-motion` is honoured and no animation is load-bearing

### Story 1.3: Show numbers the way the owner reads them

As a shop owner,
I want to see ৳১,০৮,৫০০ when I use Bangla and ৳108,500 when I use English, and to type either,
So that the numbers look like the ones I write in my khata.

**Acceptance Criteria:**

**Given** the app language is Bangla (UX-DR4)
**When** any monetary or quantity figure is displayed
**Then** it renders in Bangla digits using **lakh grouping** — ৳১,০৮,৫০০, never ৳১০৮,৫০০

**Given** the app language is English
**When** the same figure is displayed
**Then** it renders in Western digits with Western grouping, from the identical stored value

**Given** an amount or quantity input in either language mode
**When** the owner types Bangla digits, Western digits, or a mix of both
**Then** the input is accepted and normalised to one internal value

**Given** the formatter and parser exist
**When** any surface displays or reads a figure — screens, receipts, reports, CSV export, notifications, and the AI draft parser
**Then** it uses this one shared utility, with no second implementation anywhere

### Story 1.4: Keep the shop's data safe on the phone

As a shop owner,
I want everything I record kept on my phone and unreadable if the phone is stolen,
So that I never lose my হিসাব and nobody else can read it.

**Acceptance Criteria:**

**Given** the local database is created (AR-17)
**When** the app first runs
**Then** the database is Drift over SQLCipher, and its key is generated on device and stored in the platform keystore — never in the bundle, never in shared preferences, never derived from anything guessable

**Given** the money and quantity conventions (AR-1, AR-2)
**When** any table with a monetary or quantity column is defined
**Then** monetary columns are integer paisa named `…Paisa` and quantity columns are integer milli-units named `…Milli`, in both the Drift and Prisma schemas

**Given** the identity rule (AR-3)
**When** any synced entity is defined
**Then** its primary key is a client-minted UUIDv7, there is no `serverId` column, and every foreign key stores that UUID

**Given** the time rule (AR-14)
**When** any transaction table is defined
**Then** it stores a UTC timestamp **and** a `businessDate` derived once at creation against Asia/Dhaka

**Given** tables are created only when a story needs them
**When** this story runs
**Then** it creates **only** the tables Epic 1 requires — User, Business, MoneyAccount, MoneyMovement — and establishes the column conventions above as the rule every later story follows. It does **not** create the full schema upfront.

**Given** the client state rule (AR-29)
**When** data access is implemented
**Then** repositories are the **sole** database surface and Riverpod notifiers the only state mutators — no widget reads or writes the database directly, enforced by review

**Given** SQLCipher adds a read/write cost on low-end devices
**When** the encrypted database is benchmarked on a mid-range 2023 Android device
**Then** a local write still confirms within 100 ms (NFR-1), and the measured figure is recorded

### Story 1.5: Sign in with my phone number

As a shop owner,
I want to sign in with my mobile number and a code, with no password to remember,
So that I can start using the app without creating credentials I will forget.

**Acceptance Criteria:**

**Given** the sign-in screen (FR-1)
**When** a Bangladeshi mobile number is entered
**Then** the format `+8801XXXXXXXXX` with operator prefixes 013–019 is accepted, and any other format is rejected inline in Bangla

**Given** a valid number is submitted
**When** the request succeeds
**Then** an OTP is sent within 30 seconds and a code-entry screen appears with a visible countdown

**Given** a code has been issued
**When** it is used after 5 minutes
**Then** it is rejected with a message distinct from the one for an incorrect code

**Given** repeated attempts
**When** 5 OTP requests are made for one number within an hour
**Then** further requests are refused with a message naming when the owner may retry
**And** 5 consecutive incorrect entries invalidate the code and require a fresh request

**Given** a successful sign-in
**When** credentials are stored
**Then** they are written to platform secure storage, never to plain files

**Given** an owner who already has a Business signs in on a new device
**When** authentication succeeds
**Then** their existing Business is restored, and no second Business is created

### Story 1.6: Stay signed in, and sign out safely

As a shop owner,
I want the app to remember me between uses and to warn me before I sign out with unsaved work,
So that I am not asked for a code every morning and cannot lose entries by accident.

**Acceptance Criteria:**

**Given** an authenticated owner (FR-6)
**When** the app is closed and reopened
**Then** no authentication is requested

**Given** an access token expires
**When** the app makes a request
**Then** the token is refreshed silently with no interruption

**Given** records are still waiting to sync
**When** the owner chooses to sign out
**Then** the sign-out is blocked with an explanation and an offer to sync first

**Given** the owner signs out with nothing pending
**When** sign-out completes
**Then** local credentials are cleared and the next use requires a fresh OTP

### Story 1.7: Tell Hisab about my business

As a shop owner,
I want to give my shop's name and type once,
So that the app shows my shop's name and my receipts carry it.

**Acceptance Criteria:**

**Given** an authenticated owner with no Business (FR-2)
**When** setup runs
**Then** exactly one Business can be created, with a required name of 1–100 characters and a type from the eleven listed in the PRD

**Given** the Business is created
**When** currency is displayed
**Then** it is ৳ BDT and is not editable in MVP

**Given** an optional address is supplied
**When** a Receipt is later generated
**Then** the address appears on it

**Given** the owner supplies their own name and optionally an email (FR-3)
**When** setup completes
**Then** the name is used in the Home greeting, and the email — if given — is validated for format and used only for recovery and owner-initiated receipts

**Given** an owner who already owns a Business
**When** they open the app
**Then** they are routed to Home, not to setup

### Story 1.8: Record what money the shop has today

As a shop owner,
I want to enter how much cash, bKash, Nagad, Rocket and bank money the shop has right now,
So that every figure the app shows me afterwards starts from the truth.

**Acceptance Criteria:**

**Given** the opening balance step (FR-4)
**When** it is displayed
**Then** there is one input per Money Account, each **empty rather than zero**, so a blank is distinguishable from a deliberate zero, with a live total

**Given** an amount is entered for an account (AR-19)
**When** it is saved
**Then** it is stored as a `MoneyMovement` of type `Opening` — **no `openingBalancePaisa` column exists on any table** — and appears in that account's history as প্রারম্ভিক ব্যালেন্স

**Given** opening balances exist
**When** any report is generated
**Then** they count toward Money Account balances and never toward Sales, Expense or Profit

**Given** the owner chooses to skip the step
**When** they tap skip
**Then** a one-line warning states that cash figures will be incomplete until balances are set, and the same screen remains reachable from Settings

**Given** an opening balance is edited later (FR-113, AR-19)
**When** the change is saved
**Then** a reversal movement plus a new movement are written — the original is never updated — and the change is recorded in the audit trail

### Story 1.9: Choose my language

As a shop owner,
I want the app in Bangla by default and the option to switch to English,
So that I can read it without help.

**Acceptance Criteria:**

**Given** a first launch (FR-8)
**When** the app opens
**Then** the interface is Bangla regardless of the device locale

**Given** the owner switches language in Settings
**When** the choice is made
**Then** it persists across restarts and across devices, and every displayed figure re-renders per Story 1.3 with no data change

**Given** any user-facing surface (UX-DR20)
**When** it is displayed in Bangla
**Then** every string, error, notification and label is translated — an untranslated user-facing string is a defect, not a polish item

### Story 1.10: Lock the app

As a shop owner,
I want to require my fingerprint or PIN before the app opens,
So that someone holding my phone cannot read my business.

**Acceptance Criteria:**

**Given** app lock is off by default (FR-7)
**When** the owner enables it in Settings
**Then** the device biometric or PIN is required on cold start and on returning to foreground after 5 minutes in background

**Given** biometric authentication fails
**When** the fallback is offered
**Then** it is the device PIN, never a bypass

**Given** app lock is enabled
**When** the app is locked
**Then** background sync continues unaffected

### Story 1.11: Work with no internet at all

As a shop owner,
I want the app to behave exactly the same when the mobile data is gone,
So that I never stop recording because of the network.

**Acceptance Criteria:**

**Given** no connectivity (FR-93, FR-94, UX-DR14)
**When** any screen built in this epic is used
**Then** it renders from the local database, and **no screen shows a spinner, an error or a degraded state attributable to absent connectivity**
**And** there is no offline banner and no greyed-out control anywhere

**Given** a write is made offline
**When** it is saved
**Then** it commits to the local database and confirms within 100 ms, independent of the network

**Given** the sync skeleton (AR-5, AR-22)
**When** a record is written
**Then** it is enqueued as a self-contained envelope carrying any reference entity it depends on, with a monotonically increasing per-device sequence number

**Given** connectivity returns
**When** the queue drains
**Then** envelopes are delivered in per-device order, and re-delivering any envelope produces the same server state (AR-10)

---

## Epic 2: Keep বাকি হিসাব — who owes me, who I owe

An owner records who owes them and who they owe, takes and makes payments across all five money accounts, reads a running ledger they can show a customer, and chases what they are owed — **with no products and no sales in the system**.

**FRs covered:** FR-5, FR-15–FR-29, FR-62–FR-69, FR-88–FR-90 · **UX-DRs:** UX-DR6–UX-DR8, UX-DR10, UX-DR17–UX-DR19 · **Architecture:** AR-4, AR-5, AR-6, AR-9, AR-19, AR-20

### Story 2.1: Add a customer in seconds

As a shop owner,
I want to add a customer with just their name, and record what they already owe me,
So that I can start tracking a regular customer without stopping to collect their details.

**Acceptance Criteria:**

**Given** the new-customer screen (FR-15)
**When** a name of 1–100 characters is entered
**Then** the Customer is created — phone, address and note all optional

**Given** a name that exactly matches an existing Customer
**When** it is entered
**Then** an inline warning shows the existing Customer **with their current balance**, so the owner can tell two people apart before creating a duplicate

**Given** an existing due is recorded at creation (FR-5)
**When** the amount is saved
**Then** a dated `LedgerEntry` labelled আগের বাকি is written and sets the Customer's balance
**And** it is excluded from Sales totals in every report
**And** it can only be set at creation — correcting it afterwards uses a Manual Adjustment (Story 2.11)

**Given** the Customer is created from inside another flow
**When** creation completes
**Then** the originating flow resumes with the new Customer selected and nothing entered lost

### Story 2.2: Add a supplier

As a shop owner,
I want to add a wholesaler the same way I add a customer,
So that I only learn one way of doing things.

**Acceptance Criteria:**

**Given** the new-supplier screen (FR-24)
**When** a Supplier is created
**Then** the field rules, duplicate warning, opening-due behaviour and inline-creation behaviour are identical to Story 2.1

**Given** a Supplier exists
**When** a Product is later defined
**Then** the Supplier can be linked as that Product's default supplier

### Story 2.3: Find a person by name, however I spell it

As a shop owner,
I want to type "rohim" or "রহিম" and find Rahim either way,
So that I never fail to find a customer because of spelling.

**Acceptance Criteria:**

**Given** the matching test corpus (UX-DR7)
**When** it is built
**Then** it holds at least 300 real Bangladeshi person, shop and product names, each with its common Bangla spelling, its common Latin transliteration and at least two plausible misspellings
**And** it is committed to the repository and runs in CI, so match quality cannot silently regress

**Given** a query in either script
**When** the party picker searches
**Then** the correct record appears in the top 3 results for **at least 95%** of corpus queries
**And** matching combines bidirectional transliteration, phonetic equivalence for স/শ/ষ, ক/খ and vowel-length variants, and edit-distance tolerance scaled to name length

**Given** results are returned
**When** they are displayed
**Then** each row shows the party's current balance, and an exact match always outranks a transliterated one

**Given** up to 5,000 Customers
**When** the owner types
**Then** results appear within 300 ms from local data

### Story 2.4: বাকি দিলাম — record what someone took on credit

As a shop owner,
I want to record that a customer took goods worth a certain amount without listing every item,
So that I can serve the next customer instead of typing.

**Acceptance Criteria:**

**Given** the বাকি দিলাম flow (FR-20)
**When** a Customer and amount are entered with an optional description
**Then** a Sale is created with **no Sale Items**, Total equal to the amount and Paid of zero
**And** the Customer's balance increases and a debit appears in their ledger
**And** **no Stock Movement is produced**, and the Sale is flagged non-itemised so COGS excludes it

**Given** the Sale is non-itemised
**When** the entry screen is shown
**Then** a non-dismissible disclosure states, inline, that stock will not change and profit cannot be computed for this sale (UX-DR9)

**Given** the entry is saved
**When** confirmation appears
**Then** it states the new balance in the owner's words — *রহিমের বাকি: ৳৬,০০০*

**Given** no connectivity
**When** the flow is used
**Then** it behaves identically

### Story 2.5: টাকা পেলাম — record money a customer paid

As a shop owner,
I want to record a payment and show the customer their new balance immediately,
So that we both agree on the number before they leave.

**Acceptance Criteria:**

**Given** a Customer Payment (FR-62)
**When** amount and Payment Method are entered
**Then** the named Money Account increases and a credit `LedgerEntry` is written, atomically (AR-5)

**Given** the payment saves
**When** confirmation appears
**Then** it reads as arithmetic the customer can follow — *রহিমের বাকি ৳৪,০৮০ থেকে কমে ৳১,০৮০ হলো*

**Given** a payment larger than the balance owed
**When** it is saved
**Then** it is accepted and the balance becomes an advance, rendered as *৳৯২০ জমা আছে* rather than a negative number (UX-DR17)

**Given** the Payment Method chips (FR-64)
**When** they are shown
**Then** Cash, bKash, Nagad, Rocket, Bank, Card and Other are offered, the last-used is pre-selected, and Card and Other require naming the settling Money Account

**Given** payments are recorded against the balance as a whole
**When** the ledger is read
**Then** no payment is allocated to a specific Sale — per-invoice allocation is explicitly out of MVP

**Given** a recorded Customer Payment (FR-65)
**When** the owner shares a receipt for it
**Then** it shows Business name, Customer, amount received, Payment Method, date and the resulting balance
**And** it shares through the same channels as a Sale Receipt

**Given** the Payment Method chips (UX-DR12)
**When** implemented
**Then** they use the shared `ChipGroup` component in single-select mode, with selection shown by **fill change, never a border change** — a border change is invisible at arm's length
**And** the same component serves category, date-range and report filters in multi-select mode

### Story 2.6: টাকা দিলাম — record money paid to a supplier

As a shop owner,
I want to record what I paid a wholesaler,
So that I know what I still owe them.

**Acceptance Criteria:**

**Given** a Supplier Payment (FR-63)
**When** it is saved
**Then** the named Money Account decreases and a debit Supplier `LedgerEntry` is written, atomically

**Given** a payment exceeding what is owed
**When** it is saved
**Then** it is accepted as an advance, shown as such

**Given** the payment exceeds the Money Account balance (FR-68)
**When** the owner confirms
**Then** it is **accepted** with an inline warning naming the resulting negative balance — recording what actually happened is never blocked

### Story 2.7: Read a customer's খাতা

As a shop owner,
I want a dated list of everything between me and a customer with a running balance,
So that I can settle a disagreement by showing the screen.

**Acceptance Criteria:**

**Given** a Customer Ledger (FR-19, AR-20)
**When** it is displayed
**Then** columns are date, description, debit, credit and running balance, ordered by transaction date then creation time
**And** the running balance is **computed as a display projection**, never read from a stored column — so a backdated entry re-projects correctly instead of contradicting Home

**Given** the ledger header
**When** it states the position
**Then** it reads in plain Bangla — *রহিম আপনার কাছে ৳৪,৫০০ পাবেন* — never as a bare signed number

**Given** any ledger row
**When** it is tapped
**Then** the transaction that produced it opens

**Given** the final running balance
**When** compared with the Customer Balance shown on Home and in the dues list
**Then** they are identical — a divergence is a P0 defect (AR-6)

**Given** the ledger is displayed
**When** the owner looks for an edit affordance
**Then** there is none — the ledger is read-only

**Given** ledger filters (FR-22)
**When** the owner narrows the view
**Then** date ranges of today, this week, this month and custom are available, with multi-select transaction types of Sales, Payments, Returns and Adjustments
**And** a filtered view shows an **opening balance line for the range**, so the running balance stays meaningful rather than starting from nothing

### Story 2.8: Read a supplier's খাতা

As a shop owner,
I want the supplier ledger to work exactly like the customer one,
So that I do not learn a second model.

**Acceptance Criteria:**

**Given** a Supplier Ledger (FR-27)
**When** displayed
**Then** structure, linkage and read-only rules match Story 2.7
**And** a Purchase increases what is owed, a Supplier Payment decreases it, a Purchase Return decreases it
**And** the header reads *করিম হোলসেলকে দিতে হবে ৳৩৫,৫০০*

**Given** the sign convention (AR-20)
**When** entries are written by any module
**Then** `direction` and a non-negative `amountPaisa` are always recorded **from the Business's perspective**, so Payable never comes out inverted

**Given** a due taken without itemising (FR-28)
**When** recorded
**Then** a non-itemised Purchase is created with no Stock Movement, flagged so COGS excludes it

### Story 2.9: Browse my customers and suppliers

As a shop owner,
I want a list of everyone with what they owe,
So that I can see my position at a glance.

**Acceptance Criteria:**

**Given** the Customer list (FR-17)
**When** displayed
**Then** default sort is most-recently-transacted, with alternatives of name and balance descending
**And** each row shows name, balance with direction (পাবেন / জমা আছে / মিটে গেছে) and time since last transaction

**Given** a Customer detail screen (FR-18)
**When** opened
**Then** it offers বিক্রি, টাকা পেলাম, হিসাব দেখুন, and Share/Remind when a phone is present
**And** the balance shown matches the ledger's final running balance exactly

**Given** the Supplier list and detail (FR-26)
**When** displayed
**Then** they mirror the customer equivalents, offering ক্রয়, টাকা দিলাম and হিসাব দেখুন

### Story 2.10: Remove or archive a party

As a shop owner,
I want to delete someone I added by mistake and hide someone who stopped coming,
So that my list stays useful without losing history.

**Acceptance Criteria:**

**Given** a Customer with no transactions (FR-16)
**When** delete is chosen
**Then** it is deleted outright

**Given** a Customer with any transaction
**When** delete is chosen
**Then** deletion is refused with the reason, and Archive is offered instead

**Given** an archived Customer
**When** lists and pickers are shown
**Then** they are hidden by default, retain their full ledger, and can be restored
**And** archiving one with a non-zero balance warns first, because that balance still counts toward Receivable

**Given** a Supplier (FR-25)
**When** the same actions are taken
**Then** the rules are identical

### Story 2.11: Correct a balance that is wrong

As a shop owner,
I want to fix a balance that does not match reality and say why,
So that the ledger can be trusted without me editing history.

**Acceptance Criteria:**

**Given** a Manual Adjustment (FR-23)
**When** it is recorded
**Then** a direction, an amount and a **required** free-text reason are captured
**And** a `LedgerEntry` labelled সমন্বয় is written with the reason visible

**Given** an adjustment is saved
**When** existing records are examined
**Then** **no existing transaction is modified or deleted** (AR-4)
**And** the adjustment is recorded in the audit trail with timestamp and device
**And** it is excluded from Sales, Purchase, Expense and Profit figures in every report

### Story 2.12: See my money by account, and move it between accounts

As a shop owner,
I want to see cash, bKash, Nagad, Rocket and bank separately, and move money between them,
So that the app matches how I actually keep my money.

**Acceptance Criteria:**

**Given** the Money Accounts screen (FR-66, AR-6, AR-19)
**When** displayed
**Then** each account shows a balance computed as `Σ MoneyMovement.amountPaisa` — **there is no editable balance field and no balance column**
**And** accounts with history show even at zero; accounts with neither balance nor history are hidden
**And** each opens a chronological history with a running total and links to source transactions

**Given** an Account Transfer (FR-67)
**When** source, destination and amount are entered
**Then** source and destination must differ, the source decreases and destination increases atomically
**And** it is **excluded from Sales, Collection, Expense, Gross Profit and Net Profit in every report**
**And** it appears in both accounts' histories naming the counterpart

**Given** a negative account balance (FR-68)
**When** displayed
**Then** it renders in the warning treatment rather than being hidden or blocked

**Given** the payment history view (FR-69)
**When** filtered
**Then** date range, type, Payment Method and Party filters apply, and each row links to its party and account

### Story 2.13: See everyone who owes me, worst first

As a shop owner,
I want a list of who owes me sorted by how much and how long,
So that I know who to chase today.

**Acceptance Criteria:**

**Given** the dues list (FR-21, FR-88)
**When** opened from Home's Receivable figure
**Then** every Customer with a positive balance is listed, sorted by balance descending, with an alternative sort by days since last payment
**And** the total at the top equals Home's Receivable exactly
**And** Receivable sums only **positive** balances — advances are excluded, not netted

**Given** a Customer with reminders disabled
**When** the list is shown
**Then** they are visually marked and can be filtered out

**Given** the supplier equivalent (FR-29)
**When** opened
**Then** it totals to Home's Payable, and **no automated reminder is ever sent to a Supplier** — the list is for the owner's planning

### Story 2.14: Ask for my money, politely

As a shop owner,
I want the app to write the reminder for me so it does not sound like I am accusing anyone,
So that I can chase payment without damaging the relationship.

**Acceptance Criteria:**

**Given** a Customer with a phone number (FR-89)
**When** Send Reminder is chosen
**Then** a polite Bangla message is drafted including the Business name and the exact outstanding amount, editable before sending
**And** the default template can be edited once in Settings and applies thereafter

**Given** the message is ready
**When** the owner sends it
**Then** it goes via the OS share sheet, a WhatsApp deep link or the SMS app — **Hisab never sends a message on the owner's behalf**, and operates no SMS gateway

**Given** a Customer with no phone number
**When** the dues list is shown
**Then** the reminder action is disabled with an explanation

**Given** a reminder is sent
**When** it completes
**Then** Hisab records the timestamp and shows it on the Customer, so the same person is not chased twice

**Given** a per-Customer reminder schedule (FR-90)
**When** set
**Then** options are Don't remind / every 7 days (default) / 15 / 30
**And** a Customer reminded more recently than their interval is not surfaced as due
**And** "Don't remind" removes them from the list while leaving their balance in Receivable

---

## Epic 3: Stock I can trust

An owner gets a catalogue — typed or imported — with stock levels, low-stock warnings, damage and adjustments, and underneath it the FIFO cost machinery every later profit figure depends on.

**FRs covered:** FR-46–FR-55, FR-119 · **UX-DRs:** UX-DR9 · **Architecture:** AR-2, AR-4, AR-6, AR-7, AR-8, AR-28

### Story 3.1: Add a product

As a shop owner,
I want to add a product with just a name and a unit,
So that I can build my catalogue as I go instead of before I start.

**Acceptance Criteria:**

**Given** the new-product screen (FR-46)
**When** a name and Unit are supplied
**Then** the Product is created — SKU, barcode, category, prices, minimum stock, opening stock and default supplier all optional

**Given** the Unit list (FR-48)
**When** shown
**Then** it is Piece, Kg, Gram, Liter, Box, Packet, Dozen, Meter
**And** the Unit governs whether quantity accepts decimals: Piece, Box, Packet and Dozen are whole-only; Kg, Gram, Liter and Meter accept up to three decimals, stored as integer milli-units (AR-2)

**Given** a Product with Stock Movements
**When** a Unit change is attempted
**Then** it is refused with an explanation, and creating a new Product is offered instead

**Given** a selling price below the purchase price
**When** entered
**Then** it is allowed with an inline warning

**Given** a barcode value
**When** entered
**Then** it is stored as searchable text — camera scanning is explicitly out of MVP

### Story 3.2: Value my stock at what it cost

As a shop owner,
I want the app to remember what each batch of stock cost me,
So that when I sell it, the profit figure is the truth and not an average that hides a price rise.

**Acceptance Criteria:**

**Given** the FIFO model (AR-7)
**When** stock arrives by any inward route — purchase, opening stock or import
**Then** a `CostLayer` is opened storing `openedQuantityMilli`, `unitCostPaisa`, `businessDate` and `id`
**And** it stores **no remaining quantity** — remaining is `openedQuantityMilli − Σ LayerConsumption.quantityMilli`, computed in the same local transaction as each consumption

**Given** stock leaves by any outward route
**When** the movement is saved
**Then** one `LayerConsumption` row is written per layer drawn from, recording quantity and cost taken
**And** consumption order is strictly `(businessDate, id)` — the owner-stated date, never the creation instant — so device and server compute identically

**Given** the conservation invariant
**When** any consumption is applied, on device or server
**Then** `Σ consumed ≤ opened` holds for every layer, and `Σ consumed` across a Product's layers equals its total outward Stock Movement quantity — asserted server-side and covered by the financial test suite (AR-28)

**Given** a backdated purchase whose `businessDate` precedes an already-written consumption
**When** it is saved
**Then** it joins the queue for **future** consumption only — written consumptions are never retro-applied — and any report period containing such a layer discloses it

**Given** a reversal of an outward movement
**When** it is applied
**Then** it writes **negative** `LayerConsumption` rows against the original layers in reverse consumption order, and never opens a new layer

### Story 3.3: Browse and find my products

As a shop owner,
I want to find a product by typing part of its name,
So that I am not scrolling through four hundred items.

**Acceptance Criteria:**

**Given** the Product list (FR-49)
**When** displayed
**Then** each row shows name, current Inventory with Unit, selling price and a Low/Out of Stock marker
**And** filters exist for Category, Low Stock and Out of Stock, with sorts by name and stock ascending

**Given** up to 5,000 Products
**When** the owner types
**Then** name, SKU and barcode match within 300 ms from local data

**Given** categories (FR-47)
**When** assigned
**Then** they are optional free text with autocomplete over existing categories, and filter the list and reports

### Story 3.4: See one product's full position

As a shop owner,
I want to open a product and see what I hold, what it cost and where it went,
So that I can answer "where did those five bags go?".

**Acceptance Criteria:**

**Given** a Product detail screen (FR-50)
**When** opened
**Then** it shows Inventory with Unit, purchase and selling price, this Product's stock value, minimum stock, category and default supplier
**And** it lists recent Stock Movements with date, type, signed quantity and resulting quantity

**Given** this Product's stock value (AR-6)
**When** computed
**Then** it is `Σ over open CostLayers of (remaining × unitCostPaisa)` — **never** `Product.purchasePricePaisa × quantity`

### Story 3.5: Every stock change has a reason

As a shop owner,
I want every change in stock to say why it happened,
So that a wrong count can be traced instead of argued about.

**Acceptance Criteria:**

**Given** the Stock Movement trail (FR-52, AR-4)
**When** any Inventory change occurs
**Then** exactly one Stock Movement is written, typed Purchase, Sale, Sales Return, Purchase Return, Damage or Manual Adjustment
**And** it stores signed quantity, resulting quantity, timestamp, reason and a link to its originating transaction where one exists

**Given** movements are append-only
**When** a correction is needed
**Then** a new Movement is written — an existing one is never edited or deleted

**Given** current Inventory
**When** recomputed from scratch
**Then** it equals the sum of signed quantities of that Product's Stock Movements

### Story 3.6: Fix a count, and record what spoiled

As a shop owner,
I want to correct a stock count and separately record stock that was damaged,
So that my profit reflects what I actually lost.

**Acceptance Criteria:**

**Given** a stock adjustment (FR-53)
**When** recorded
**Then** it requires a new quantity or signed delta, a type of **Damage** or **Manual Adjustment**, and a required free-text reason

**Given** the type is Damage
**When** it is saved
**Then** its value — quantity × the FIFO cost of the stock consumed — is recorded as a business cost and **reduces Net Profit** for the period
**And** it appears as its own line (নষ্ট) in the profit report, separate from Expenses

**Given** the type is Manual Adjustment
**When** it is saved
**Then** it carries **no financial effect** — it is a count correction only

**Given** the two types are financially different
**When** the entry screen is designed
**Then** the distinction is unmistakable and is never a silent dropdown default

### Story 3.7: Warn me before I run out

As a shop owner,
I want to know a product is running low before a customer asks for it,
So that I can reorder in time.

**Acceptance Criteria:**

**Given** a per-Product minimum stock (FR-54)
**When** set
**Then** it is optional, non-negative and expressed in the Product's Unit

**Given** Inventory falls to or below the minimum while above zero
**When** evaluated
**Then** the Product is Low Stock; at zero or below it is Out of Stock

**Given** a Product with no minimum set
**When** evaluated
**Then** it never appears as Low Stock — only as Out of Stock at zero or below

**Given** a Product crosses into Low Stock
**When** notification is considered
**Then** at most one notification per Product per 24 hours is raised

### Story 3.8: See my whole stock position

As a shop owner,
I want one screen telling me what my stock is worth and what needs attention,
So that I know where I stand without opening every product.

**Acceptance Criteria:**

**Given** the Inventory summary (FR-51)
**When** displayed
**Then** it shows total Product count, total Stock Value, Low Stock count and Out of Stock count
**And** Stock Value is `Σ over open CostLayers of (remaining × unitCostPaisa)` — the same definition used on Home and in the inventory report, with no second definition anywhere (AR-6)
**And** Products holding stock with **no cost layer** are excluded from the value and their count is disclosed

**Given** damage recorded in the period
**When** the summary is shown
**Then** it is listed with its cost

### Story 3.9: Add several products in one sitting

As a shop owner,
I want to keep adding products without going back to the list each time,
So that entering twenty items does not take twenty navigations.

**Acceptance Criteria:**

**Given** a Product has just been saved from the add flow (FR-55)
**When** the confirmation appears
**Then** Save & Add Another is offered, retaining Category and Unit from the previous entry

### Story 3.10: Import my catalogue from a spreadsheet

As a shop owner,
I want to load the product list I already keep in Excel,
So that I am not typing four hundred items by hand before the app is useful to me.

**Acceptance Criteria:**

**Given** a CSV or XLSX file (FR-119)
**When** it is opened
**Then** columns name and Unit are required; SKU, barcode, category, purchase price, selling price, opening stock and minimum stock are optional
**And** column order is insignificant and headers match case-insensitively in either language
**And** a downloadable template is offered on the same screen in Bangla and English

**Given** the file is parsed
**When** the preview appears
**Then** it shows row count, a per-row validation state and a plain-Bangla summary of what will happen, and **nothing is written until the owner confirms**

**Given** rows that fail validation
**When** the preview is shown
**Then** each is listed with its row number and reason and is skipped — **a single bad row never aborts the file**

**Given** rows whose name matches an existing Product
**When** duplicates are found
**Then** the owner chooses once for the whole file: skip duplicates, or update existing prices and thresholds — never a silent second Product

**Given** an imported row carries opening stock and a purchase price
**When** it commits
**Then** a Manual Adjustment Stock Movement dated the import **and a CostLayer at that price** are created
**And** a row with opening stock but no purchase price imports the stock and flags the Product as lacking a cost basis

**Given** the import commits
**When** it is applied
**Then** it is atomic — a failure part-way leaves no partial catalogue
**And** it is capped at 2,000 rows with visible progress; a larger file is rejected with a message, never truncated silently

**Given** no connectivity
**When** the owner imports
**Then** **it works** — parsing, validation, preview and commit all run on the device, and the Products sync afterwards as ordinary records
**And** the Plan limit is checked against the cached entitlement at commit and re-verified server-side on sync, surfacing per the sync rejection path if it then fails

**Given** an import completed within 24 hours and none of its Products has been transacted against
**When** the owner chooses undo
**Then** the whole import is reversed

---

## Epic 4: Sell and buy

The flow the whole product is measured on: a sale recorded in under twenty seconds, cash or credit, with a receipt in the customer's hand. Plus purchases, corrections, voids and returns.

**FRs covered:** FR-30–FR-45, FR-70–FR-77 · **UX-DRs:** UX-DR5, UX-DR6, UX-DR9, UX-DR10, UX-DR18 · **Architecture:** AR-1, AR-4, AR-5, AR-7, AR-8, AR-10, AR-15, AR-21, AR-28

### Story 4.1: Record a cash sale in seconds

As a shop owner,
I want to record a walk-in sale with the fewest possible taps,
So that the customer behind them is not waiting.

**Acceptance Criteria:**

**Given** a cash sale with no Customer (FR-30, FR-38)
**When** recorded from Home
**Then** a single-Product sale at the default price completes in **no more than 5 taps plus quantity entry**
**And** no Customer selection step appears unless the owner opts to attach one
**And** a walk-in sale requires Paid = Total — it cannot carry a Due

**Given** Sale Items are added (FR-31, AR-21)
**When** a Product is selected
**Then** its selling price and Unit pre-fill, the price is overridable on the line without changing the Product record, and each line carries an explicit `lineNo`
**And** quantity accepts decimals only for Kg, Gram, Liter and Meter
**And** a Product not yet in Hisab can be created inline without losing lines already entered

**Given** the sale is being built (FR-32)
**When** items and discount change
**Then** the running Total is visible **at all times during item entry**, not only on a summary step
**And** Total = Subtotal − discount, can never be negative, and an over-large discount is rejected inline

**Given** the sale is saved (AR-5)
**When** it commits
**Then** Sale, Sale Items, Stock Movements, Layer Consumptions, Ledger Entry and Money Movement commit in **one local transaction or none of them**
**And** perceived confirmation arrives within 100 ms, independent of the network

### Story 4.2: Record a sale on credit

As a shop owner,
I want to record that a customer paid part now and owes the rest,
So that the ledger and the sale are the same event, not two things I have to remember to do.

**Acceptance Criteria:**

**Given** a Sale with a Customer (FR-33)
**When** the payment step is shown
**Then** Paid defaults to Total (the common cash case) and can be reduced to zero
**And** Paid may not exceed Total — overpayment is a separate Customer Payment
**And** Due = Total − Paid is displayed **live, before the owner commits** — *বাকি ৳৮৬০*

**Given** Paid is less than Total
**When** saving is attempted without a Customer
**Then** it is refused — a walk-in sale cannot carry a Due

**Given** the sale saves
**When** confirmation appears
**Then** it states Total, Paid, Due and the Customer's previous **and** new balance
**And** the ledger entry, the stock movement and the money movement all exist — sales and the ledger are never separate systems

**Given** split payment across two methods
**When** attempted
**Then** it is not supported in MVP

### Story 4.3: A sale moves stock and consumes cost

As a shop owner,
I want selling something to reduce my stock and record what that stock cost me,
So that my stock count and my profit are both right without extra work.

**Acceptance Criteria:**

**Given** an itemised Sale (FR-39, AR-7)
**When** it saves
**Then** one Stock Movement of type Sale is written per Sale Item, linked to the Sale
**And** Layer Consumptions are computed **on the device at save time** in `(businessDate, id)` order

**Given** stock is insufficient
**When** the owner confirms anyway
**Then** the sale is **permitted** with a warning before saving, Inventory may go negative, and the Product shows Out of Stock

**Given** a sale drove Inventory below zero (AR-8)
**When** consumption is written
**Then** it consumes no layer and is written `isProvisional = true` at the Product's current purchase price

**Given** a later inward movement brings Inventory to or above zero
**When** reconciliation runs
**Then** a `LayerConsumptionAdjustment` row is **appended** per provisional consumption in creation order, carrying the cost delta and reconciling layer id
**And** `isProvisional` is **never flipped** and the original row is never restated — a consumption is reconciled iff an adjustment references it
**And** COGS = Σ consumptions + Σ adjustments, on every tier

**Given** a non-itemised Sale
**When** saved
**Then** it produces no Stock Movement and no consumption

### Story 4.4: Browse and open past sales

As a shop owner,
I want to find a sale I recorded earlier,
So that I can check it or reprint the receipt.

**Acceptance Criteria:**

**Given** the Sale list (FR-34)
**When** opened
**Then** it defaults to today, newest first, with a day total at the top
**And** filters exist for date range, Customer, paid/partially-paid/unpaid and Payment Method
**And** each row shows receipt number, Customer or ক্যাশ বিক্রি, Total and Due when non-zero
**And** records still waiting to sync are visually marked

**Given** a Sale detail screen (FR-35)
**When** opened
**Then** it shows Customer, date, receipt number, every Sale Item with quantity/price/line total, discount, Total, Paid, Due and Payment Method
**And** it offers Share Receipt, Edit, Delete and Sales Return
**And** it shows the Customer's balance at the time of the Sale and now

### Story 4.5: Correct a sale I got wrong

As a shop owner,
I want to fix a sale I entered wrongly,
So that the ledger is right — without anyone being able to say I quietly changed history.

**Acceptance Criteria:**

**Given** a Sale needing correction (FR-36, AR-4)
**When** the owner taps Edit and saves
**Then** the original Sale is **not mutated** — a reversal and a corrected Sale are written
**And** stock, ledger and money effects net to the corrected values, committing atomically with the reversal

**Given** the correction is saved
**When** the Customer Ledger is displayed
**Then** the original entry, its reversal and the corrected entry are **all three visible** — this is what lets a disputed balance be traced

**Given** the corrected Sale (FR-30, AR-15)
**When** it is numbered
**Then** it keeps the original's receipt number, and the reversal carries none
**And** the uniqueness constraint is a **partial unique index excluding rows in the reversal chain**, so the correction envelope is not rejected

**Given** a Sale with an associated Sales Return
**When** correction is attempted
**Then** it is refused with an explanation, and the return must be reversed first

### Story 4.6: Remove a sale entered in error

As a shop owner,
I want to cancel a sale that never happened,
So that my figures are right without the record disappearing.

**Acceptance Criteria:**

**Given** a Sale to void (FR-37)
**When** delete is chosen
**Then** an explicit confirmation names the amount and the Customer

**Given** the void is confirmed
**When** it is applied
**Then** a reversal undoes stock, ledger and money effects atomically — **nothing is erased**
**And** the Sale is marked void, stays visible in the audit trail and in the ledger as an original-plus-reversal pair, and its receipt number is never reissued
**And** it is excluded from every report figure for its original date

**Given** the owner looks for an undo
**When** any correction or void completes
**Then** there is none — corrections are permanent record

### Story 4.7: Record a purchase from my supplier

As a shop owner,
I want to record goods arriving and what I paid,
So that my stock, my cash and what I owe all update at once.

**Acceptance Criteria:**

**Given** a Purchase (FR-40, FR-45)
**When** saved
**Then** Purchase, Purchase Items, Stock Movements, Cost Layers, Supplier Ledger Entry and Money Movement commit atomically
**And** confirmation states the three effects explicitly: stock increased, Supplier balance now X, Money Account reduced by Y

**Given** Purchase Items (FR-41)
**When** a Product is selected
**Then** its last purchase price pre-fills and is overridable
**And** overriding offers to update the Product's stored purchase price, **defaulted to yes**, because a stale purchase price silently corrupts future provisional costing
**And** a Product not in Hisab can be created inline without losing entered lines

**Given** payment (FR-42)
**When** entered
**Then** Paid defaults to zero for a Purchase with a Supplier (the common credit case) and to Total for a cash Purchase
**And** Due increases the Supplier balance and appears in their ledger

**Given** each Purchase Item
**When** it commits
**Then** a Cost Layer is opened at that unit cost with the Purchase's `businessDate` (AR-7)

### Story 4.8: Browse, correct and cancel purchases

As a shop owner,
I want purchases to work like sales,
So that I do not learn a second set of rules.

**Acceptance Criteria:**

**Given** the Purchase list and detail (FR-43)
**When** opened
**Then** filters are date range, Supplier and paid state; detail shows items with quantity and unit cost, Total, Paid, Due, Payment Method and the resulting Supplier balance

**Given** a Purchase correction or void (FR-44)
**When** applied
**Then** the same reversal mechanism, atomicity, audit trail and blocked-by-return rules as Stories 4.5 and 4.6 apply to stock, the Supplier Ledger and the Money Account
**And** the reversal writes negative Layer Consumptions in reverse consumption order and never opens a new layer

**Given** a Purchase whose stock has since been sold
**When** it is voided
**Then** it is permitted and may drive Inventory negative, with the affected Products named in the warning

### Story 4.9: Take goods back from a customer

As a shop owner,
I want to record a returned item and give the customer the right credit,
So that the return does not become an argument later.

**Acceptance Criteria:**

**Given** a Sales Return against a Sale (FR-70)
**When** items and quantities are selected
**Then** they cannot exceed the quantity originally sold, and a reason is required
**And** Inventory increases via Stock Movements of type Sales Return
**And** the return writes **negative Layer Consumptions against the original layers in reverse consumption order** — it does not open a new layer (AR-7)

**Given** the original Sale was fully paid
**When** the return is recorded
**Then** the owner chooses between refunding money now (decreasing a Money Account) or leaving it as a Customer advance

**Given** reported Sales
**When** the return is applied
**Then** it reduces Sales for the **return's** date, not the original Sale's

**Given** a return with no original Sale in Hisab (FR-71)
**When** recorded
**Then** Customer or walk-in, Product, quantity and value are captured
**And** having no consumption to reverse, it **opens a layer at the Product's current purchase price flagged provisional**, disclosed under report integrity

**Given** a Purchase Return (FR-72)
**When** recorded
**Then** it decreases Inventory, decreases the Supplier balance and reduces reported Purchases for the return date
**And** returning more than was purchased is rejected

**Given** returns exist (FR-73)
**When** the original transaction is opened
**Then** its linked returns and the net quantity and value remaining are shown

### Story 4.10: Give the customer a receipt

As a shop owner,
I want to hand my customer a proper receipt without owning a printer,
So that my shop looks legitimate and the customer has proof.

**Acceptance Criteria:**

**Given** any Sale (FR-74)
**When** a Receipt is generated
**Then** it contains Business name and address, receipt number, date and time, Customer name when present, every Sale Item as quantity × unit price = line total, discount when non-zero, Total, Paid, Due and Payment Method
**And** where a Due remains and a Customer is named, it also shows their resulting balance
**And** it renders in the app's current language with correct Bangla script and ৳ formatting
**And** **it generates with no network connection**

**Given** a Receipt of up to 30 items
**When** generated on a mid-range device
**Then** it completes within 2 seconds

**Given** Bangla text and Bangla numerals in the PDF
**When** rendered on Android and iOS
**Then** conjuncts are correct with no tofu boxes — which requires the bundled font from Story 1.2, not a system font

**Given** sharing (FR-75)
**When** the owner shares
**Then** PDF and PNG are offered through the OS share sheet, with a direct-to-WhatsApp shortcut when the Customer has a number and WhatsApp is installed
**And** sharing works offline — the target app handles its own queuing

**Given** printing (FR-76)
**When** chosen
**Then** the OS print dialog is used — no thermal or Bluetooth printer integration in MVP

**Given** a party ledger statement (FR-77)
**When** shared as PDF
**Then** it contains Business name, party name, date range, every Ledger Entry with running balance, and the closing balance stated in plain Bangla

---

## Epic 5: Know how the business is doing

An owner opens the app and knows what sold, what came in, what went out, what they are owed and what they made — and can find anything by typing part of its name in either script.

**FRs covered:** FR-9–FR-14, FR-56, FR-57–FR-61, FR-78–FR-87 · **UX-DRs:** UX-DR5, UX-DR9, UX-DR13, UX-DR16 · **Architecture:** AR-6, AR-7, AR-8, AR-14

### Story 5.1: Record what I spend

As a shop owner,
I want to record rent, electricity and the rest,
So that the profit figure is not a fantasy.

**Acceptance Criteria:**

**Given** an Expense (FR-57)
**When** recorded
**Then** amount, Expense Category and Payment Method are required; note and date optional, date defaulting to today, backdatable but never future-dated
**And** saving debits the Money Account atomically with creating the Expense

**Given** categories (FR-58)
**When** offered
**Then** Rent, Electricity, Gas, Internet, Employee Salary, Transport, Packaging, Maintenance, Marketing, Food and Other are seeded with Bangla labels
**And** the owner can add categories; one in use cannot be deleted but can be renamed, with the rename applying to historical Expenses

**Given** the Expense list (FR-59)
**When** displayed
**Then** filters are date range, Category and Payment Method, with a period total matching the reports
**And** editing or deleting writes a reversal plus a corrected entry (AR-4) and is audited

### Story 5.2: Remind me about the bills that repeat

As a shop owner,
I want to be reminded about rent and salary before they are due,
So that I do not forget the costs that make my profit wrong.

**Acceptance Criteria:**

**Given** a recurring Expense definition (FR-60)
**When** created
**Then** amount, Category, monthly frequency and day of month are captured

**Given** the due date approaches
**When** reminders fire
**Then** one is sent 3 days before and one on the day
**And** the reminder offers one-tap recording with stored values pre-filled and editable before saving

**Given** a recurring definition exists
**When** the due date passes without action
**Then** **no Expense is created automatically** — the owner always confirms

**Given** a definition is paused or deleted
**When** that happens
**Then** Expenses already recorded from it are unaffected

### Story 5.3: Keep my own money separate from the shop's

As a shop owner,
I want money I take for myself recorded as a withdrawal, not an expense,
So that my profit figure tells me how the shop is doing, not how much I spent.

**Acceptance Criteria:**

**Given** an Owner withdrawal (FR-61)
**When** recorded
**Then** amount, Money Account, date and optional note are captured, labelled মালিকের উত্তোলন
**And** it reduces the Money Account balance
**And** it is **excluded from Expenses and from Net Profit in every report**
**And** it appears on its own line in the profit report, below Net Profit, so cash out that was not a cost is still visible

### Story 5.4: See my day the moment I open the app

As a shop owner,
I want the first screen to answer what I sold, collected, spent and made today,
So that I do not have to go looking.

**Acceptance Criteria:**

**Given** the Home screen (FR-9, AR-14)
**When** it loads
**Then** Today's Sales, Collection, Expense and Profit are shown for the Asia/Dhaka calendar day
**And** Sales = today's Sale Totals minus today's Sales Returns; Collection includes the Paid portion of today's Sales; Expense excludes Account Transfers and Supplier Payments; Profit is labelled আনুমানিক
**And** all four reflect transactions recorded offline **as soon as they are saved locally**, without waiting for sync

**Given** Receivable and Payable (FR-10)
**When** displayed
**Then** Receivable sums only positive Customer balances and Payable only positive Supplier balances — advances are excluded, not netted
**And** labels are আপনার কাছ থেকে পাবেন and আপনাকে দিতে হবে
**And** each taps through to its list

**Given** Low Stock and Money Accounts (FR-11, FR-12)
**When** displayed
**Then** up to 5 Products show, Out of Stock first, with a count and a link when more exist
**And** the panel is **hidden entirely** when no Product qualifies, rather than shown empty
**And** Money Accounts show each non-zero balance and their total, matching Story 2.12 exactly

**Given** Home is loaded on a mid-range device
**When** measured
**Then** it renders complete with real figures in under 1 second from local data, with no element blocked on the network

### Story 5.5: Record anything from anywhere

As a shop owner,
I want the record button reachable from every screen,
So that I never navigate home first to write down a sale.

**Acceptance Criteria:**

**Given** the chosen navigation (UX-DR13, FR-13)
**When** the app is displayed
**Then** three tabs — হোম, খাতা, আরও — sit beside a raised centre action button
**And** the centre button opens the six quick actions as a sheet **from any tab**
**And** বিক্রি, পণ্য and রিপোর্ট are pushed screens under আরও with back navigation

**Given** a quick action (FR-13, UX-DR5)
**When** tapped
**Then** its flow opens directly with no intermediate menu
**And** each target is at least 48×48 dp with its label fully visible at the default **and** largest accessibility font size
**And** all six work fully offline
**And** বাকি দিলাম opens the simplified credit flow, not the full Sale flow

**Given** all six quick-action flows (UX-DR25)
**When** tested on a 5-inch device
**Then** each is completable **one-handed**, thumb-reachable from the centre button to the save action

**Given** the Home header (FR-14)
**When** displayed
**Then** it shows a time-appropriate Bangla greeting, the owner's name and the Business name

### Story 5.6: Close the day in thirty seconds

As a shop owner,
I want one screen summarising the day,
So that I know whether it was a good day before I go home.

**Acceptance Criteria:**

**Given** the daily summary (FR-78)
**When** opened — reachable in one tap from Home
**Then** it shows Sales, Cash Sales, Credit Sales, Collection, Expenses, Damage and estimated Profit for a selected day, defaulting to today
**And** Cash Sales + Credit Sales = Sales
**And** every figure is computed locally and is correct offline
**And** the same numbers appear identically in the sales and profit reports — a divergence is a defect

### Story 5.7: See sales and spending over a period

As a shop owner,
I want to compare this week with last,
So that I can tell whether things are getting better.

**Acceptance Criteria:**

**Given** the sales report (FR-79)
**When** a period is chosen from today, yesterday, this week, this month or custom
**Then** it shows gross Sales, Sales Returns, net Sales, transaction count, average sale value, Cash Sales and Credit Sales
**And** it breaks down by day for ranges up to 31 days and by month beyond
**And** the figures reconcile exactly with the Sale list filtered to the same range

**Given** the expense report (FR-80)
**When** displayed
**Then** it totals Expenses per Category, largest first, with each Category's share
**And** it **excludes** Owner withdrawals, Supplier Payments, Purchases, Damage and Account Transfers, and states that it does

**Given** product performance (FR-56)
**When** displayed
**Then** top-selling Products by revenue and by quantity are listed for the period, plus slowest-moving Products holding stock with no Sale
**And** both **exclude non-itemised Sales** and say so

### Story 5.8: Tell me whether I made money

As a shop owner,
I want a straight answer about my profit, in words before numbers,
So that I do not need to understand accounting to run my shop.

**Acceptance Criteria:**

**Given** the profit report (FR-81)
**When** displayed
**Then** it leads with a plain-language statement — *এই মাসে আপনার লাভ ≈ ৳১,১৩,৯০০* — before any breakdown
**And** the breakdown shows Sales, Cost of Goods Sold, Gross Profit, Expenses, Damage and Net Profit in that order
**And** COGS = Σ Layer Consumptions + Σ Adjustments for the period (AR-7, AR-8)
**And** the costing method is named in plain Bangla — *আগে যে মাল কেনা, সেটাই আগে বিক্রি* — never as "FIFO"
**And** Owner withdrawals appear as a separate line **below** Net Profit, never inside it

**Given** dues and inventory reports (FR-82)
**When** displayed
**Then** customer dues list every positive balance with a total and ageing buckets of 0–7, 8–30, 31–60 and 60+ days since last payment
**And** the inventory report shows Stock Value **valued at open Cost Layers**, Low Stock, Out of Stock and Damage with its cost

### Story 5.9: Tell me what the numbers leave out

As a shop owner,
I want the app to admit where a figure is incomplete,
So that I can trust the ones it does not warn me about.

**Acceptance Criteria:**

**Given** any report affected by non-itemised Sales or Purchases (FR-83)
**When** displayed
**Then** it shows their count and value and states that COGS and Product-level figures exclude them

**Given** Products lacking a cost basis — no purchase price and no Cost Layer
**When** a valuation is shown
**Then** the count of such Products is disclosed

**Given** a period containing unreconciled provisional consumptions (AR-8)
**When** a profit figure is shown
**Then** their count is disclosed, with a statement that COGS for the period may be restated when the stock is replenished

**Given** any profit figure anywhere, including Home
**When** displayed
**Then** it is labelled আনুমানিক

**Given** a report (FR-84)
**When** exported
**Then** a PDF is produced carrying Business name, report name, period and generation timestamp, shared through the OS share sheet

### Story 5.10: Find anything by typing part of it

As a shop owner,
I want one search that finds a customer, a product or a receipt,
So that I do not have to know which screen a thing lives on.

**Acceptance Criteria:**

**Given** global search (FR-85)
**When** a query is entered
**Then** it matches Customer and Supplier name and phone, Product name, SKU and barcode, receipt numbers and Expense notes
**And** results are grouped by entity type with counts, most relevant group first
**And** matching uses the **same Bangla↔Latin engine and corpus built in Story 2.3**, holding the ≥95% top-3 recall target
**And** results return within 300 ms at 5,000 Customers and 5,000 Products, and work fully offline

**Given** any list screen (FR-86)
**When** its scoped search is used
**Then** it searches only that list, using the same matching rules

**Given** an empty search (FR-87)
**When** displayed
**Then** it shows the 5 most recently transacted Customers and the 5 most recently sold Products

---

## Epic 6: Never lose my হিসাব

The epic that decides whether an owner keeps using Hisab after a bad week: the sync queue becomes visible and honest, conflicts surface instead of vanishing, the cloud copy is provably current, and a new phone restores everything.

**FRs covered:** FR-91, FR-92, FR-95–FR-99 · **UX-DRs:** UX-DR15 · **Architecture:** AR-9, AR-10, AR-22, AR-23, AR-24

### Story 6.1: Show me what has not reached the cloud

As a shop owner,
I want to know how many entries are still on my phone only,
So that I know whether it is safe to hand the phone to someone.

**Acceptance Criteria:**

**Given** records awaiting sync (FR-95, UX-DR15)
**When** any screen is shown
**Then** a persistent, unobtrusive count appears — *১৪টি এন্ট্রি সিঙ্ক হয়নি* — and is **absent entirely at zero**

**Given** the indicator is tapped
**When** the sync screen opens
**Then** the pending records are listed with a Sync Now action

**Given** the sync state
**When** displayed
**Then** *waiting for a connection* is visually and textually distinct from *sync is failing*, and the failing state says what to do

### Story 6.2: Sync without me asking

As a shop owner,
I want the app to catch up by itself whenever the signal comes back,
So that I never think about syncing at all.

**Acceptance Criteria:**

**Given** the sync triggers (FR-96)
**When** any of them occurs — connection regained, app foreground, after a write while online, or the periodic background pass
**Then** the queue drains without the owner acting, and the UI is never blocked

**Given** envelopes in the queue (AR-22)
**When** they are delivered
**Then** they apply in per-device enqueue order, and any reference entity created offline travels **inside** the envelope that first references it — a sale never lands before its customer

**Given** an envelope is delivered more than once (AR-10)
**When** the server applies it
**Then** the resulting state is identical — no double-posted transaction, no duplicated ledger entry

**Given** the server receives a financial write
**When** it is applied
**Then** it stores what the envelope contains — it does **not** recompute FIFO consumption, which the device already calculated

### Story 6.3: Tell me when something needs me, and stop retrying when it does

As a shop owner,
I want the app to keep trying quietly when the network is bad, but to tell me plainly when something is actually wrong,
So that I am neither bothered by nothing nor left with a stuck indicator I cannot fix.

**Acceptance Criteria:**

**Given** a sync response (AR-23)
**When** it is classified
**Then** it is exactly one of transient — network error, timeout, 5xx or explicit retry-later — or permanent, meaning any 4xx

**Given** a transient failure
**When** it occurs
**Then** it retries with exponential backoff indefinitely, the indicator reads *waiting for a connection*, and the owner is asked to do nothing

**Given** a permanent rejection — validation failure, plan limit exceeded, auth failure
**When** it occurs
**Then** **retrying stops immediately**, the envelope moves to a `needs_attention` state, and it is surfaced with the reason in plain Bangla **and an action that can resolve it**

**Given** a record in `needs_attention`
**When** the pending count is shown
**Then** it is included in the total and is visually distinct from one merely waiting
**And** it is never discarded

### Story 6.4: Pick up changes I made on another device

As a shop owner,
I want the app to fetch what changed elsewhere without missing anything,
So that two phones never drift apart.

**Acceptance Criteria:**

**Given** the pull cursor (AR-24)
**When** the device requests changes
**Then** it presents the highest **server-assigned monotonic change id** it has applied — **never a timestamp**, because a skewed device clock would make it skip changes it never received
**And** the server returns a page of changes plus the next watermark

**Given** a replayed pull from the same watermark
**When** applied
**Then** the resulting state is identical

**Given** a watermark older than the server's retention horizon
**When** presented
**Then** the server answers with a distinct code and the device performs a **full resync** through the restore path rather than quietly missing the gap

### Story 6.5: Resolve a clash without losing anything

As a shop owner,
I want the app to never silently drop something I recorded,
So that I can trust it even when I have used two phones.

**Acceptance Criteria:**

**Given** financial records from two devices (AR-9, FR-97)
**When** they sync
**Then** both are kept — append-only records do not conflict, and the balance is their sum

**Given** mutable reference data edited on two devices
**When** it syncs
**Then** it resolves last-writer-wins by **server receipt time**, with the loser's version retained in the audit trail

**Given** a conflict neither rule resolves
**When** it is detected
**Then** it is surfaced to the owner as a plain-language choice showing both versions with amounts, dates and source device — **never resolved silently and never discarded**

**Given** any resolution path
**When** it completes
**Then** no path can produce a Ledger whose running balance disagrees with the Party Balance

### Story 6.6: Know my হিসাব is safely in the cloud

As a shop owner,
I want to see that my data is backed up and when,
So that I can stop worrying about losing the khata.

**Acceptance Criteria:**

**Given** synced records (FR-98)
**When** stored server-side
**Then** they are durably persisted, with managed point-in-time recovery and a restore rehearsed **before** launch rather than after an incident

**Given** the Settings screen
**When** displayed
**Then** it shows the timestamp of the last successful sync in plain language

**Given** no successful sync for 7 days while the device has had connectivity
**When** detected
**Then** the owner is warned

### Story 6.7: Get everything back on a new phone

As a shop owner,
I want to sign in on a new phone and find my whole business there,
So that losing a phone does not mean losing my business records.

**Acceptance Criteria:**

**Given** a new device (FR-99)
**When** the owner authenticates with the same phone number
**Then** Business, Customers, Suppliers, Products, Inventory, Cost Layers, all transactions and all Ledgers are restored

**Given** the restore is running
**When** it progresses
**Then** progress is shown, and the app is usable for reads as soon as core entities have landed

**Given** the restore completes
**When** the owner is informed
**Then** the app states the timestamp of the most recent restored record, so the owner knows **honestly** which period is complete
**And** restoring never duplicates records that already exist locally

**Given** a business of roughly 20,000 transactions over 12 months
**When** restored on a normal mobile connection
**Then** it completes within 3 minutes

### Story 6.8: Tell me the few things I would otherwise miss

As a shop owner,
I want to be told about low stock, overdue customers and bills due — and nothing else,
So that I keep notifications switched on.

**Acceptance Criteria:**

**Given** the notification types (FR-91)
**When** they fire
**Then** they are limited to: Low Stock reached, a Customer overdue past their interval, a recurring Expense due in 3 days and on the day, and no transaction recorded by 9pm on a day the app was opened

**Given** a busy day
**When** notifications are counted
**Then** **at most 3 per day** are delivered, with any excess collapsed into one summary
**And** SM-C1 caps this at 10 per active business per week — exceeding it is a defect, not a growth tactic

**Given** connectivity
**When** a trigger occurs
**Then** it is delivered by push when online and by local scheduled notification when the trigger is computable on-device

**Given** a notification
**When** tapped
**Then** it opens the relevant screen directly

**Given** the preferences screen (FR-92)
**When** displayed
**Then** every notification type has an individual toggle with a plain-language description, plus a global off
**And** preferences persist across devices via sync

---

## Epic 7: Talk to Hisab

The differentiator: ask a question in Bangla and get an answer computed from your own ledger; read a two-sentence summary of the day; type a sentence instead of filling a form. Entirely behind feature flags — the product ships and works with this epic switched off.

**FRs covered:** FR-100–FR-108 · **UX-DRs:** UX-DR11 · **Architecture:** AR-11, AR-12, AR-13, AR-18

### Story 7.1: Prove Banglish parsing works — before committing to it

As the team,
we want to know whether real shop utterances can be parsed accurately,
So that we find out in week 3 rather than week 14 whether the product's differentiator is viable.

**⚠️ Scheduling exception: this story's epic is last, but its execution belongs in Epics 1–2.** Risk R-2. If parsing quality is poor, the product's positioning changes — and the feature flag in Story 7.8 is what lets the product ship without it.

**Acceptance Criteria:**

**Given** a corpus of transcribed **real** shop utterances in Bangla, English and mixed Banglish
**When** the spike runs
**Then** measured accuracy is reported for each supported intent — Sale, Customer Payment, Supplier Payment, Expense, and Purchase where identifiable

**Given** the measured accuracy
**When** compared with SM-5's target of 60% of drafts saved without any field edited
**Then** a go / no-go recommendation is made **before** the AI epic is scheduled

### Story 7.2: Ask a question about my own business

As a shop owner,
I want to ask *এই মাসে সবচেয়ে বেশি বিক্রি কোন পণ্যে?* and get a real answer,
So that I learn things about my shop I would never have worked out by hand.

**Acceptance Criteria:**

**Given** the question catalogue (FR-100, AR-13)
**When** it is built
**Then** it supports at minimum: best-selling Product for a period, who owes the most, total Sales/Expenses/Profit for a period, period-over-period comparison, slowest-moving Products and largest Expense category

**Given** a question is asked
**When** it is answered
**Then** the answer is computed by executing a **hand-written parameterised query** from the versioned catalogue
**And** the model's only outputs are a catalogue entry id and typed parameters — it **never composes, completes or edits SQL**

**Given** an answer containing a figure
**When** displayed
**Then** the figure's basis — the period and what was counted — is shown, expandable to the underlying list

**Given** a question matching no catalogue entry
**When** asked
**Then** an explicit "I can't answer that yet" is returned with two examples of what can be asked — **never a fabricated number**

**Given** no connectivity
**When** the feature is opened
**Then** it states clearly that it needs a connection, while core transaction entry stays fully available

### Story 7.3: Never let the AI see or say the wrong thing

As a shop owner,
I want to be certain the AI only sees my business and only tells me the truth,
So that I can use it without wondering what it knows.

**Acceptance Criteria:**

**Given** any AI query (FR-101, AR-11)
**When** it executes
**Then** it is scoped server-side to the authenticated owner's Business, and **no prompt content or AI-extracted parameter can widen that scope**

**Given** a request for a forecast or prediction
**When** asked in MVP
**Then** an honest refusal is returned, not an estimate

**Given** any figure the AI states
**When** compared with the corresponding screen
**Then** they agree — a Customer Balance, Money Account balance or Profit figure that disagrees with the app is a defect

**Given** AI request and response content
**When** transmitted
**Then** it excludes Customer phone numbers and the Business address

### Story 7.4: Read my day in two sentences

As a shop owner,
I want a short written summary of the day rather than a chart,
So that I understand it at a glance while closing the shop.

**Acceptance Criteria:**

**Given** a day with at least one transaction (FR-102)
**When** the summary is generated
**Then** it is produced once per day, available on demand from Home and offered as an evening notification within the daily cap

**Given** the summary content
**When** written
**Then** it contains the day's Sales, Expenses, Collection and new credit given, plus **at most two** observations grounded in the data
**And** every number matches the daily summary screen exactly

**Given** a quiet day
**When** the summary is generated
**Then** it is short — never padded to look substantial

**Given** past summaries
**When** the owner looks back
**Then** the last 30 days are viewable

### Story 7.5: Type a sentence instead of filling a form

As a shop owner,
I want to type *"Rahim 1500 টাকার মাল নিয়েছে, 500 টাকা দিয়েছে"* and have Hisab understand it,
So that recording a sale takes eight seconds when three customers are waiting.

**Acceptance Criteria:**

**Given** natural-language input (FR-103)
**When** parsed
**Then** Bangla, English and mixed Banglish are accepted, including transliterated numbers and common shop vocabulary
**And** supported intents are Sale with optional partial payment, Customer Payment, Supplier Payment, Expense, and Purchase where a Supplier and amount are identifiable

**Given** a named party or product
**When** resolved
**Then** matching uses the same engine and corpus as Story 2.3; an exact single match is applied and no match offers inline creation

**Given** a Transaction Draft is produced
**When** displayed
**Then** every field is visible and editable, and the party's current balance **and what it would become** are shown

### Story 7.6: Check before it saves

As a shop owner,
I want to see exactly what Hisab understood before anything is recorded,
So that a misunderstanding never becomes a wrong number in my ledger.

**Acceptance Criteria:**

**Given** a Transaction Draft (FR-104, AR-12)
**When** it exists
**Then** it has **zero financial effect** until the owner taps Save, and the screen says so

**Given** the owner saves a Draft
**When** it commits
**Then** it goes through the **same API and the same validation** as a form-entered transaction — there is no AI-specific write path
**And** the saved transaction is indistinguishable in the ledger and reports, but is tagged with its origin for analytics

**Given** the confirmation card (UX-DR11, SM-C3)
**When** designed
**Then** it sits on the AI surface, is labelled AI-generated, and the Save button is **not** the largest element on screen — the card must invite checking, not reflexive tapping

**Given** a Draft is discarded
**When** it is dismissed
**Then** nothing remains but an analytics event

**Given** ambiguity (FR-105)
**When** two or more parties match the named person
**Then** a disambiguation prompt shows each candidate **with their current balance** — the app never picks
**And** an unparseable or partial input produces a Draft with missing fields **empty and highlighted**, never invented
**And** confidence below threshold on any monetary amount blocks Save until that field is explicitly confirmed
**And** no Draft ever contains a Product, Customer or Supplier that does not exist unless creation is explicitly offered

### Story 7.7: Fail honestly

As a shop owner,
I want the AI to say plainly when it cannot help and give me the normal way instead,
So that a failure costs me two seconds rather than a transaction.

**Acceptance Criteria:**

**Given** no connectivity (FR-106)
**When** any AI feature is opened
**Then** it states clearly that it needs a connection, and core transaction entry remains fully available

**Given** an AI service failure or timeout
**When** it occurs
**Then** the owner is told and offered the equivalent form flow **in one tap**

**Given** the AI feature flag
**When** toggled remotely
**Then** AI features can be disabled without an app release

**Given** any AI failure
**When** it happens
**Then** it cannot block, delay or corrupt a transaction entered by form

### Story 7.8: Meter it, and let me turn it off

As a shop owner,
I want to know what AI costs me and be able to switch it off entirely,
So that I stay in control of my own data and my subscription.

**Acceptance Criteria:**

**Given** AI usage (FR-107)
**When** metered
**Then** each Ask Hisab question and each Transaction Draft counts as one request, enforced **server-side**
**And** the Free plan permits a limited monthly number and Pro a higher one
**And** the daily summary does **not** count against the owner's limit

**Given** the limit is reached
**When** the owner asks again
**Then** they are told what the limit is, when it resets and what Pro offers — answers are **never silently degraded**

**Given** AI-generated content (FR-108, UX-DR11)
**When** displayed
**Then** Ask Hisab answers, daily summaries and Drafts are visually marked as AI-generated

**Given** the Settings screen
**When** opened
**Then** it explains in plain Bangla what AI features do with the owner's data and that AI never records a transaction on its own
**And** AI can be turned off entirely, after which **no business data is sent to the AI service**

---

## Epic 8: Ready to ship

Everything between a working app and two store listings: plan limits enforced server-side, settings, the owner's own data, the audit trail, in-app account deletion, and the submissions.

**FRs covered:** FR-109–FR-118, FR-120 · **UX-DRs:** UX-DR26 · **Architecture:** AR-11, AR-16, AR-18, AR-26

### Story 8.1: Put every business on a plan

As the Hisab team,
we want plans and limits to exist and be enforced from day one,
So that we never have to retrofit limits onto users who have never had them.

**Acceptance Criteria:**

**Given** Plans (FR-109)
**When** defined
**Then** Free and Pro exist and every Business starts on Free
**And** Plan determines limits on number of Customers, number of Products and AI requests per month
**And** **transaction count is deliberately not limited** — capping the core action would break trust

**Given** every limit value
**When** implemented
**Then** it is **server-side configuration, changeable without an app release and without a migration** — no limit is compiled into the client
**And** entitlements resolve server-side and cache on device for display only; the authoritative check is always server-side

### Story 8.2: Reach a limit without losing anything

As a shop owner,
I want hitting a limit to be an explanation rather than a wall,
So that I never feel the app has taken my data hostage.

**Acceptance Criteria:**

**Given** a limit is reached (FR-110)
**When** the owner attempts to exceed it
**Then** they are shown the limit, their current usage and what Pro provides

**Given** existing data
**When** a limit is exceeded
**Then** **nothing is deleted, hidden or made read-only**

**Given** the core actions
**When** any limit is in force
**Then** recording Sales, Payments, Expenses and Purchases is **never blocked**

**Given** a record rejected server-side for a limit
**When** it syncs
**Then** it surfaces to the owner via the `needs_attention` path (AR-23), never dropped

### Story 8.3: See my plan and tell you I want more

As a shop owner,
I want to see what I am using and register that I would pay for more,
So that I can get the features I need.

**Acceptance Criteria:**

**Given** the plan screen (FR-111)
**When** displayed
**Then** it shows the current Plan, usage against each limit and what Pro includes

**Given** the upgrade action
**When** tapped
**Then** interest is recorded and how to complete an upgrade with the Hisab team is shown — **no in-app payment in MVP**
**And** the event is captured for analytics as the primary willingness-to-pay signal (SM-6)

**Given** a plan change made by staff (FR-112)
**When** applied
**Then** it takes effect on device at the next sync, within 5 minutes while online
**And** it is recorded as a SubscriptionEvent with actor and timestamp

### Story 8.4: Change my business and app settings

As a shop owner,
I want to correct my shop's details and control how the app behaves,
So that the app stays right as my business changes.

**Acceptance Criteria:**

**Given** business settings (FR-113)
**When** edited
**Then** name, type and address are editable, appearing on subsequent Receipts and immediately on Home
**And** opening balances are editable per Story 1.8 — as a reversal plus a new movement — and are audited

**Given** app settings (FR-114)
**When** opened
**Then** language, app lock, notification preferences and the AI toggle are all reachable from one screen
**And** settings persist across devices via sync, except app lock which is per device

### Story 8.5: Keep analytics away from my money

As a shop owner,
I want to know that no amount and no customer's name ever leaves my phone for analytics,
So that I can leave analytics on without worrying.

**Acceptance Criteria:**

**Given** the analytics façade (FR-115, AR-18)
**When** implemented
**Then** events are emitted through a single typed façade with a **schema-level allow-list** of permitted dimensions
**And** monetary amounts, quantities, party names, product names and phone numbers are **not in the allow-list and cannot be attached** — adding a dimension requires a reviewable change to the allow-list

**Given** the event set
**When** defined
**Then** it covers app_opened, business_created, customer_created, sale_created, payment_recorded, expense_created, product_created, purchase_created, report_viewed, ai_question, ai_transaction_drafted, ai_transaction_confirmed, ai_transaction_discarded, receipt_shared, reminder_sent and upgrade_interest

**Given** the owner
**When** they choose
**Then** they can opt out of analytics in Settings

### Story 8.6: Take my own data with me

As a shop owner,
I want to download everything I have recorded,
So that my business records are mine regardless of what I pay.

**Acceptance Criteria:**

**Given** data export (FR-116)
**When** requested
**Then** Customers, Suppliers, Products, Sales, Purchases, Payments and Expenses export as CSV for a chosen date range
**And** it is shared through the OS share sheet
**And** it is **available on every Plan, including Free**

### Story 8.7: Trace any number back to what made it

As a shop owner,
I want to see who changed what and when,
So that a disputed figure can be settled with a record rather than a memory.

**Acceptance Criteria:**

**Given** the audit trail (FR-117)
**When** any financially significant change occurs — creation, correction or void of Sales, Purchases, Payments, Expenses, Returns, stock adjustments or balance adjustments
**Then** actor, timestamp, device and before/after values are recorded

**Given** a voided transaction
**When** the trail is read
**Then** it remains present — soft-deleted, never erased

**Given** any individual transaction
**When** opened
**Then** its change history is viewable from its detail screen

### Story 8.8: Get help without leaving the app

As a shop owner,
I want to find out how something works or reach someone,
So that I do not abandon the app when I get stuck.

**Acceptance Criteria:**

**Given** the help section (FR-118)
**When** opened
**Then** it covers the core flows in short Bangla
**And** a contact action reaches Hisab support by phone or WhatsApp
**And** app version and a copyable diagnostic identifier are visible for support conversations

### Story 8.9: Delete my account and everything in it

As a shop owner,
I want to delete my account from inside the app,
So that leaving is as easy as joining.

**⚠️ Store-submission gate. Both Apple and Google reject apps supporting account creation without an in-app deletion path. This cannot slip.**

**Acceptance Criteria:**

**Given** account deletion (FR-120)
**When** the owner looks for it
**Then** it is reachable from Settings in **at most three taps**, without contacting support and without leaving the app

**Given** deletion is requested
**When** the confirmation is shown
**Then** it states exactly what will be destroyed — Business, Customers, Suppliers, Products, every transaction and every Ledger — **with counts**
**And** a CSV export is offered on the same screen
**And** re-authentication by OTP is required, not just a confirmation tap

**Given** deletion is confirmed
**When** it executes
**Then** the local database is wiped immediately including pending records, and the device signs out
**And** the deletion is **soft for 30 days**, during which signing in restores everything and the owner is told how long remains
**And** after the retention window a scheduled job purges all personal and business data server-side; only non-reversible anonymous aggregates may remain
**And** the same phone number registering afterwards gets an **empty** Business, never the deleted one's data

**Given** a deletion in progress
**When** support is contacted
**Then** its state is visible in the admin console

### Story 8.10: Put Hisab in front of shop owners

As the Hisab team,
we want both store listings complete and accurate,
So that the app reaches the people it was built for.

**Acceptance Criteria:**

**Given** the app icon (UX-DR26)
**When** produced
**Then** the খাতা mark is **traced to outlines** — no shipped icon depends on a webfont
**And** Android ships two adaptive layers on a 108dp canvas with everything meaningful inside the central 66dp safe circle
**And** iOS ships one opaque 1024px square with **no pre-rounded corners**
**And** a flat white notification silhouette exists

**Given** the store listings
**When** submitted
**Then** both carry Bangla store copy, screenshots and accurate data-safety declarations describing the financial data collected and the AI processing performed

**Given** the shortlist of icons
**When** finally chosen
**Then** it has been checked on a real Android home screen beside bKash, Nagad and imo, and in greyscale

**Given** the release
**When** it is cut
**Then** the financial test suite (AR-28) passes: atomicity, reproducibility of every derived figure, FIFO consumption order, provisional reconciliation and idempotent replay
