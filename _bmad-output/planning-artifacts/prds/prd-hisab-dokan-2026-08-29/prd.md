---
title: Hisab
status: draft
created: 2026-08-29
updated: 2026-08-29
---

# PRD: Hisab

*Bangla-first business management for Bangladesh's small shops. Working title — confirm.*

## 0. Document Purpose

This PRD defines the **MVP** of Hisab for the product manager, the downstream BMAD workflows (`bmad-ux`, `bmad-architecture`, `bmad-create-epics-and-stories`), and the engineers who will build it. It is scoped deliberately: only the MVP. The advanced roadmap in `docs/features/02_Hisab_Advanced_Features.md` is referenced but explicitly out of scope (§5, §6.2).

It builds on inputs that already exist and does not duplicate them:

| Input | Location | Role here |
|---|---|---|
| MVP feature list | `docs/features/01_Hisab_MVP_Features.md` | Scope boundary for §4 and §6.1 |
| Detailed feature spec | `docs/features/Hisab_Details_Features.md` | Behavioral source for §4 descriptions and §2.3 journeys |
| Advanced features | `docs/features/02_Hisab_Advanced_Features.md` | Deferred-item source for §5 and §6.2 |
| Technical design | `docs/design/Hisab_Technical_Design.md` | **Authoritative** on stack, data model, sync and AI architecture. This PRD states *what*; that document states *how*. Where a requirement here has a technical counterpart, it is cited by section (e.g. TD §31). |

Structure: vocabulary is anchored in the Glossary (§3) and used verbatim throughout. Features (§4) group functional requirements, numbered globally **FR-1 … FR-120** so downstream artifacts have stable references even if features are reorganized. **FR IDs are append-only:** an FR added after the first draft takes the next free number and sits in whichever feature it belongs to, so numbering runs out of sequence in two places (FR-119 in §4.7, FR-120 in §4.18) rather than renumbering and breaking references. User journeys are numbered **UJ-1 … UJ-10**; FRs cite the journeys they realize. Success metrics are **SM-**; counter-metrics **SM-C**. Inferences not confirmed by a source document or by Tanim are tagged inline `[ASSUMPTION]` and indexed in §16.

**Companion file:** `addendum.md` in this workspace holds technical depth, rejected alternatives and downstream detail that belongs to architecture or UX rather than to this PRD.

---

## 1. Vision

In Bangladesh, several million small businesses — the grocery on the corner, the pharmacy, the clothing shop, the Facebook seller working from home — run their entire financial life in a paper khata. Who owes what, what was sold today, what the stock is worth, whether the month was profitable: all of it lives in a notebook, in the owner's head, and nowhere else. The notebook gets wet, gets lost, gets disputed. The owner cannot answer "did I make money this month?" without an evening of arithmetic they will not do.

Hisab replaces that notebook. It is a Bangla-first mobile app in which a shop owner records a sale, a due, a payment, a purchase or an expense in seconds, and gets back the three things the notebook never gave them: an accurate running balance for every customer and supplier, a live picture of stock and cash across cash/bKash/Nagad/Rocket/bank, and a plain-language answer to *how is the business doing*. It works with no internet, because the shop's mobile data does, and it syncs to the cloud when the connection returns — so the হিসাব cannot be lost.

The wedge is speed and language. Existing accounting software asks a shop owner to learn double-entry vocabulary in English; Hisab asks them to tap **বাকি দিলাম** and type a number. On top of that reliable foundation sits a thin, carefully bounded layer of AI: the owner can ask "এই মাসে সবচেয়ে বেশি বিক্রি কোন পণ্যে?" and get an answer computed from their own ledger, get an evening summary of the day, and — the differentiator — type a sentence like *"Rahim 1500 টাকার মাল নিয়েছে, 500 টাকা দিয়েছে"* and have Hisab turn it into a transaction they confirm with one tap. AI makes entry faster and the numbers legible; it never becomes the system of record. Financial data stays deterministic (TD §1).

Positioning follows from that: not "accounting software", but **আপনার ব্যবসার পুরো হিসাব এক জায়গায়** — বাকি হিসাব, বিক্রি ও স্টক, লাভ-ক্ষতির হিসাব.

## 2. Target User

Hisab's user is the **owner** of a small Bangladeshi business who personally handles the money: grocery, clothing, electronics, restaurant, pharmacy, hardware, cosmetics, mobile/accessories, small wholesale, Facebook/online selling, and home-based businesses. They are comfortable with a smartphone and with bKash; they are not comfortable with accounting software, and they have never used the words "accounts receivable". They are usually the only person who will touch the app.

### 2.1 Jobs To Be Done

**Functional**

- When a customer takes goods on credit, record who owes how much, so I can collect it later without arguing about the amount.
- When someone pays me, reduce their due and know what remains — instantly, in front of the customer.
- When I buy stock, record what I owe the supplier and how much stock came in.
- Know how much money I actually have, split across cash, bKash, Nagad, Rocket and the bank.
- Know what sold today and roughly what I earned on it.
- Know what is about to run out before a customer asks for it.
- Give a customer a receipt they can keep, without a printer.
- At month end, know whether I made a profit — without doing arithmetic.

**Emotional**

- Stop the low-grade fear that the khata gets lost, damaged, or copied wrong and I lose money I am owed.
- Feel confident, not embarrassed, when a customer disputes a balance — the record is right there.
- Stop feeling that "proper" business tools are for educated city people and not for me.

**Social**

- Ask for money owed in a way that is polite and impersonal — the app said it, not me.
- Look organized and legitimate to customers and to suppliers.

**Contextual**

- Do all of this one-handed, standing behind a counter, in under ten seconds, while a customer waits.
- Do it when the mobile data has dropped, and trust that nothing is lost.

### 2.2 Non-Users (v1)

- **Businesses with employees who need their own logins.** MVP is single-user per business (§4.1). A shop with three cashiers can use Hisab, but they will share the owner's account, which we do not recommend.
- **Multi-branch operations.** One business = one location in MVP.
- **Businesses needing formal accounting output** — VAT/tax filings, balance sheets, double-entry journals, an accountant's export. Hisab's profit figure is an operating estimate, not a statutory account.
- **Manufacturers** needing bill-of-materials, work-in-progress or production costing.
- **Businesses whose primary need is a POS terminal** — barcode-driven checkout with a cash drawer and thermal printer. Barcode scanning is deferred (§6.2).
- **Non-Bangladesh businesses.** MVP is BDT-only, Bangla-first, and models bKash/Nagad/Rocket specifically.

### 2.3 Key User Journeys

> **UJ-1. Rahman sets up his grocery in the time it takes to make tea.**
> Rahman, 41, has run Rahman Grocery in Mirpur for nine years and keeps a paper khata behind the counter. He installs Hisab on a Thursday afternoon after a supplier's rep mentions it. **Entry state:** unauthenticated, fresh install, on mobile data. He enters his phone number, receives an OTP by SMS, and is in. Hisab asks four things in sequence, one per screen with large type: what is the business called (Rahman Grocery), what kind of business (Grocery), what currency (৳ BDT, pre-selected), and — the one that matters — **আজ ব্যবসায় মোট কত টাকা আছে?** He enters cash ৳50,000, bank ৳100,000, bKash ৳25,000, and skips Nagad and Rocket. **Climax:** the Home screen appears with his shop's name at the top, ৳175,000 in money accounts, and six large action buttons. Nothing is fake or pre-filled; the numbers are his. **Resolution:** he is on Home, ready to record his first sale, roughly two minutes after opening the app. **Edge case:** if the SMS does not arrive within 60 seconds he can request a resend, and after two failures the screen offers a support number rather than a dead end.

> **UJ-2. Rahim takes goods on credit and Rahman does not reach for the khata.**
> A regular customer, Rahim Ahmed, picks up rice and oil and says he will pay on Friday. Rahman is standing at the counter with Rahim in front of him. **Entry state:** authenticated, Home screen, may or may not have signal. He taps **+ বিক্রি**, types "রহ" into the customer field and picks Rahim Ahmed from two matches, adds Rice 5kg × 2 and Soybean Oil 2L × 1 (prices pre-fill from the product record; he overrides oil to ৳380), sees the total ৳1,080, enters paid ৳500, and Hisab shows **বাকি ৳580** before he saves. **Climax:** he taps Save; the screen confirms in under a second and shows Rahim's new balance — আগের বাকি ৳3,500, বর্তমান বাকি ৳4,080 — with a Share Receipt button. Rahim sees the number too, and agrees with it. **Resolution:** stock for both products has dropped, Rahman's cash is up ৳500, Rahim's ledger has a new line, and Rahman is back on Home. **Edge case:** the shop's data is down — the sale saves locally, the receipt still generates, and a small pending-sync indicator appears; nothing about the flow changes (§4.15).

> **UJ-3. Rahim pays on Friday and the balance settles in front of him.**
> Friday evening, Rahim comes in with ৳3,000 in cash. **Entry state:** Rahman is on Home. He taps **+ টাকা পেলাম**, picks Rahim, types 3000, taps Cash, and confirms. **Climax:** Hisab responds *রহিমের বাকি ৳4,080 থেকে কমে ৳1,080 হলো* — the arithmetic Rahman used to do on the back of a receipt, done and shown to both of them. **Resolution:** cash balance up ৳3,000, Rahim's ledger has a credit line, and if Rahim wants it, a payment receipt shares to WhatsApp. **Edge case:** Rahim pays ৳5,000 against a ৳4,080 due — Hisab accepts it and shows the balance as ৳920 in Rahim's favour (advance), rather than refusing the entry.

> **UJ-4. Rahman restocks and knows exactly what he now owes Karim.**
> The wholesaler delivers. **Entry state:** Home, mid-morning. Rahman taps Purchases → New Purchase, selects Karim Wholesale, adds Rice 5kg × 100 @ ৳320 and Oil 5L × 50 @ ৳850, total ৳74,500, and records ৳40,000 paid in cash. **Climax:** on save, three things happen at once and Hisab says so — stock for both products increases, ৳34,500 is added to what he owes Karim, and his cash drops ৳40,000. **Resolution:** the supplier ledger shows Karim at ৳34,500 outstanding, and Home's **আপনাকে দিতে হবে** figure has moved. **Edge case:** Rice 5kg was not yet a product in Hisab — he creates it inline from the purchase screen without losing the rows already entered.

> **UJ-5. Rahman closes the day in thirty seconds.**
> 9:40pm, shutters half down. **Entry state:** authenticated, Home. He opens the daily summary. **Climax:** one screen — বিক্রি ৳54,500, নগদ বিক্রি ৳32,000, বাকি বিক্রি ৳22,500, সংগ্রহ ৳18,000, খরচ ৳6,500, আনুমানিক লাভ ৳11,200 — plus a line telling him Rice 5kg sold most today and Oil 5L will likely run out in three days. **Resolution:** he knows whether it was a good day, in one screen, without opening a report builder. He goes home.

> **UJ-6. Rahman finds out he is owed ৳85,400 and does something about it.**
> Sunday, quiet. **Entry state:** Home, tapping **আপনার কাছ থেকে পাবেন ৳85,400**. He gets a list of customers with outstanding balances, largest first, with days-since-last-payment. Three names are over 30 days. **Climax:** on the worst one he taps **Send Reminder**; Hisab drafts *ভাই, আপনার কাছে ৳5,500 বাকি আছে। সুবিধামতো পরিশোধ করবেন। ধন্যবাদ।* and he sends it via WhatsApp with one more tap — polite, and not in his own words. **Resolution:** three reminders sent in two minutes, and the app records that they were sent so he does not nag the same person twice. **Edge case:** a customer he trusts and does not want chased — he sets reminders off for that customer and they drop out of the list.

> **UJ-7. Rahman asks the app a question he used to ask his nephew.**
> Month end. **Entry state:** authenticated, online. He opens **Ask Hisab** and types *এই মাসে সবচেয়ে বেশি বিক্রি কোন পণ্যে?* **Climax:** in about three seconds — *এই মাসে Rice 5kg সবচেয়ে বেশি বিক্রি হয়েছে — ৳85,000।* — with a tappable line showing the underlying figure so he can see where it came from. He asks two more: কার কাছে সবচেয়ে বেশি টাকা পাব, and গত মাসের তুলনায় বিক্রি কেমন. **Resolution:** three answers he would previously not have bothered to compute. **Edge case:** he asks something Hisab cannot answer from his data ("আগামী মাসে কত বিক্রি হবে?") and gets an honest "I can't forecast yet" rather than an invented number.

> **UJ-8. Rahman types a sentence instead of filling a form.**
> Busy evening, three customers waiting. **Entry state:** Home, online. He taps the AI entry field and types, in the mix of Bangla and English he actually uses: *"Rahim 1500 টাকার মাল নিয়েছে, 500 টাকা দিয়েছে।"* **Climax:** Hisab shows a filled-in confirmation card — Customer: Rahim Ahmed / Sale ৳1,500 / Paid ৳500 / New due ৳1,000 / আগের বাকি ৳3,500 → বর্তমান বাকি ৳4,500 — with **Save** and **Edit**. He checks the customer name is the right Rahim, taps Save. **Resolution:** a normal Sale exists in the ledger, indistinguishable from one entered by form, in about eight seconds. **Edge case:** two customers named Rahim — Hisab does not guess; it asks which one, showing each one's current balance to disambiguate.

> **UJ-9. The internet dies for four hours and Rahman never notices.**
> Load-shedding takes out the local tower mid-afternoon. **Entry state:** authenticated, session already established, connection lost. Rahman records eleven sales, two customer payments and one expense across the afternoon. Every screen behaves exactly as it does online; balances, ledgers and stock all update; receipts generate. A small indicator shows *১৪টি এন্ট্রি সিঙ্ক হয়নি*. **Climax:** at 6pm the connection returns and the queue drains by itself; the indicator clears without Rahman doing anything. **Resolution:** his evening summary includes all fourteen entries. **Edge case:** he had also opened Hisab on a second phone that afternoon — on sync, an entry conflict is resolved by the documented rule (TD §15) and, if it is not automatically resolvable, surfaced to him as a plain-language choice rather than silently dropped.

> **UJ-10. Rahman changes phones and his হিসাব is still there.**
> His old phone is stolen. He buys a new one, installs Hisab, and signs in with the same phone number and an OTP. **Climax:** the app restores his business, customers, suppliers, products, stock and full ledger history from the cloud, with a progress indicator. **Resolution:** he is back in business with nothing lost except the entries that had never synced from the stolen device — and the app tells him honestly which period is complete rather than implying everything is there.

---

## 3. Glossary

Downstream workflows and readers must use these terms exactly. FRs, UJs and SMs use Glossary terms verbatim; introducing a synonym anywhere in this PRD is a discipline violation.

**Core entities**

- **User** — an individual identified by a Bangladeshi mobile number. One User owns exactly one Business in MVP.
- **Business** — the shop or enterprise being tracked. Owns all other records. All data is scoped to exactly one Business (multi-tenancy boundary, TD §51). One Business, one location, in MVP.
- **Owner** — the User who created the Business and holds full access. The only role with app access in MVP.
- **Customer** — a person or entity the Business sells to. Has a name, optional phone, and a running Customer Balance.
- **Supplier** — a person or entity the Business buys from. Has a name, optional phone, and a running Supplier Balance.
- **Party** — collective term for a Customer or a Supplier where a requirement applies to both.

**Money and balances**

- **Money Account** — a place the Business's money sits: Cash, bKash, Nagad, Rocket, or Bank. Each has a balance. Every Payment names one. (The user-facing label is *টাকার হিসাব*; "wallet" is not used.)
- **Payment Method** — the channel of a single money movement: Cash, bKash, Nagad, Rocket, Bank, Card, or Other. Selecting a Payment Method selects the corresponding Money Account, except Card and Other, which map to a Money Account the Owner picks.
- **Customer Balance** — net amount a Customer owes the Business. Positive = Customer owes (receivable, *পাবেন*). Negative = Customer has paid in advance.
- **Supplier Balance** — net amount the Business owes a Supplier. Positive = Business owes (payable, *দিতে হবে*). Negative = Business has paid in advance.
- **Receivable** — the sum of all positive Customer Balances. User-facing: **আপনার কাছ থেকে পাবেন**. Never rendered as "accounts receivable".
- **Payable** — the sum of all positive Supplier Balances. User-facing: **আপনাকে দিতে হবে**. Never rendered as "accounts payable".
- **Opening Balance** — the starting figure entered at setup: per Money Account, and per Party when the Owner records a pre-existing due.

**Transactions**

- **Sale** — goods or services given to a Customer (or to a walk-in with no Customer) in exchange for money now, later, or both. Has Sale Items, a Total, a Paid amount, and a Due amount (Total − Paid).
- **Sale Item** — one line of a Sale: Product, quantity, unit price, line discount.
- **Purchase** — goods received from a Supplier. Has Purchase Items, Total, Paid, Due. Increases Inventory.
- **Purchase Item** — one line of a Purchase: Product, quantity, unit cost.
- **Expense** — money spent on running the Business that is not a Purchase of stock (rent, electricity, salary, transport…). Has an Expense Category.
- **Expense Category** — the classification of an Expense, from a fixed starting list the Owner can extend.
- **Payment** — a movement of money between the Business and a Party, or into/out of a Money Account. Typed: **Customer Payment** (money received from a Customer, *টাকা পেলাম*), **Supplier Payment** (money paid to a Supplier, *টাকা দিলাম*), or **Account Transfer** (money moved between two Money Accounts — never revenue, never Expense).
- **Sales Return** — goods returned by a Customer. Increases Inventory, reduces the Customer Balance, reduces reported Sales.
- **Purchase Return** — goods returned to a Supplier. Reduces Inventory and reduces the Supplier Balance.
- **Ledger** — the chronological, running-balance record of every transaction against one Party. **Customer Ledger** and **Supplier Ledger** are the two kinds. The Ledger is derived from transactions, never edited directly.
- **Ledger Entry** — one line of a Ledger: date, description, debit, credit, resulting balance, and a link to the transaction that produced it.
- **Due** — the unpaid portion of a single Sale or Purchase. Distinct from Balance, which is the Party-level net across all their transactions.

**Products and stock**

- **Product** — a sellable or purchasable item. Has name, optional SKU, optional barcode, Category, purchase price, selling price, Unit, Minimum Stock, and optionally a default Supplier.
- **Unit** — the measure a Product is counted in: Piece, Kg, Gram, Liter, Box, Packet, Dozen, Meter.
- **Inventory** — current stock quantity per Product for the Business.
- **Stock Movement** — an auditable change to Inventory with a reason: Purchase, Sale, Sales Return, Purchase Return, Damage, or Manual Adjustment. Every Inventory change has exactly one Stock Movement.
- **Minimum Stock** — the per-Product threshold at or below which the Product is Low Stock.
- **Low Stock** — a Product whose Inventory is at or below its Minimum Stock and above zero. **Out of Stock** is Inventory of zero or less.
- **Stock Value** — Inventory quantity × purchase price, summed across Products.

**Reporting**

- **Gross Profit** — Sales revenue minus Cost of Goods Sold for the period.
- **Cost of Goods Sold (COGS)** — the cost of the Products sold in the period, computed **FIFO**: the earliest-acquired stock is consumed first, at the price it was acquired at. Decided by Tanim, closing TD §55's open choice. See **Cost Layer**.
- **Cost Layer** — a quantity of one Product acquired at one cost, with an acquisition date. A Purchase creates a Cost Layer; a Sale, Damage or Purchase Return consumes from the oldest open Layer first. Cost Layers are what make FIFO computable and are consumed in date order, never in entry order.
- **Net Profit** — Gross Profit minus Expenses minus Damage for the period. User-facing as *লাভ*; presented as an estimate.
- **Receipt** — the shareable PDF or image record of a single Sale or Customer Payment given to a Customer. "Invoice" and "Receipt" are the same artifact in MVP; the term used everywhere is **Receipt**.

**System**

- **Sync** — the process of reconciling locally recorded transactions with the server. **Pending Sync** describes a record saved locally but not yet acknowledged by the server.
- **Ask Hisab** — the AI question-answering feature (§4.16).
- **AI Transaction Entry** — the AI natural-language transaction-drafting feature (§4.16). It produces a **Transaction Draft**, never a saved transaction.
- **Transaction Draft** — a proposed transaction produced by AI Transaction Entry, shown for confirmation. Has no financial effect until the Owner confirms it, at which point it is saved through the same validation path as a form-entered transaction.
- **Plan** — a subscription tier: Free or Pro in MVP. Determines usage limits.
- **Usage Limit** — a Plan-enforced ceiling (number of Customers, Products, AI requests…), enforced server-side.

---

## 4. Features

Each subsection is a coherent feature: behavioral description, then nested Functional Requirements with testable consequences, then feature-specific NFRs and notes where they apply. FRs are numbered globally so downstream artifacts have stable references.

### 4.1 Authentication and Business Setup

**Description:** First contact with the product. A new Owner authenticates with their Bangladeshi mobile number and a one-time SMS code — no password to invent, forget or reset, which matters for a user who may share a phone-shop-installed device and does not use email much. Immediately after first authentication, a four-to-six step setup collects the minimum needed to make the Home screen truthful: business name, business type, currency, optional address, owner name, and Opening Balance per Money Account. The setup is one question per screen, large type, Bangla labels, skippable where the answer is optional. It ends on Home. Realizes UJ-1, UJ-10.

The Opening Balance step is the one that must not be skipped silently: without it every subsequent cash figure is wrong, so it is presented as *আজ ব্যবসায় মোট কত টাকা আছে?* with a row per Money Account and an explicit "I'll do this later" escape that warns what it costs.

**Functional Requirements:**

#### FR-1: Phone-number authentication with OTP

A User can authenticate by entering a Bangladeshi mobile number and the one-time code sent to it by SMS. Realizes UJ-1, UJ-10.

**Consequences (testable):**
- A valid BD mobile number (`+8801XXXXXXXXX`, 11 local digits, operator prefixes 013–019) is accepted; other formats are rejected at input with an inline Bangla message.
- Submitting a number sends an OTP within 30 seconds and shows a code-entry screen with a visible countdown.
- The OTP expires 5 minutes after issue; an expired code is rejected with a distinct message from an incorrect code.
- A resend is available after 60 seconds; at most 5 OTP requests per number per hour are accepted, after which further requests are refused with a message naming when the User can retry.
- 5 consecutive incorrect code entries invalidate the code and require a fresh request.
- On success, the app stores credentials in device secure storage (TD §36) and the User is not asked to authenticate again on that device until they sign out or the session is revoked.
- The same phone number authenticating on a new device restores that User's existing Business (FR-99), it does not create a second one.

#### FR-2: Business creation

An authenticated User with no Business can create exactly one Business by supplying its name and type. Realizes UJ-1.

**Consequences (testable):**
- Business name is required, 1–100 characters, and is displayed on the Home screen and on every Receipt.
- Business type is selected from: Grocery, Clothing, Electronics, Restaurant, Pharmacy, Hardware, Cosmetics, Mobile & Accessories, Wholesale, Online Business, Other.
- Currency is ৳ BDT, displayed and not editable in MVP.
- Business address is optional, free text, and appears on Receipts when present.
- On creation the User is assigned the Owner role for that Business.
- A User who already owns a Business is routed to Home, not to setup.

#### FR-3: Owner profile capture

The Owner can supply their own name, and optionally an email, during setup. Realizes UJ-1.

**Consequences (testable):**
- Owner name is required and used in the Home greeting.
- Email is optional; when supplied it is validated for format and used only for account recovery and receipts the Owner chooses to email. `[ASSUMPTION: email is not used for marketing in MVP.]`
- Phone number is taken from the authenticated number and is not re-entered.

#### FR-4: Opening Balance entry

The Owner can record a starting balance for each Money Account during setup. Realizes UJ-1.

**Consequences (testable):**
- One input per Money Account (Cash, bKash, Nagad, Rocket, Bank), each defaulting to empty rather than zero so a blank is distinguishable from a deliberate zero.
- Each entered amount creates an opening Stock-of-money record dated the setup date; it is visible in the Money Account history as *প্রারম্ভিক ব্যালেন্স*.
- Opening Balances count toward Money Account balances but never toward Sales, Expense, or Profit figures in any report.
- The step can be skipped; skipping shows a one-line warning that cash figures will be incomplete until balances are set, and the same screen is reachable later from Settings.
- Opening Balances can be edited later; editing recomputes the current Money Account balance and is recorded in the audit trail (FR-117).

#### FR-5: Party opening balance

The Owner can record an existing due for a Customer or Supplier at the time that Party is created. Realizes UJ-1.

**Consequences (testable):**
- When creating a Customer or Supplier, an optional "আগের বাকি" amount can be entered.
- The amount creates a dated Ledger Entry labelled as an opening balance, and sets the Party's Balance accordingly.
- Opening Party balances are excluded from Sales and Purchase totals in all reports.
- A Party opening balance can only be set at creation; correcting it afterwards is done with a Manual Adjustment (FR-23), which is auditable.

#### FR-6: Session persistence and sign-out

An authenticated Owner stays authenticated across app restarts and can sign out deliberately.

**Consequences (testable):**
- Closing and reopening the app does not prompt for authentication.
- Sign-out clears local credentials and requires a fresh OTP on next use.
- Sign-out warns and blocks if there are Pending Sync records, offering to sync first. `[ASSUMPTION: blocking sign-out on unsynced data is preferable to silently discarding it; confirm with Tanim.]`
- An access token expiring is refreshed silently without interrupting the Owner (TD §36).

#### FR-7: App lock

The Owner can require a device PIN or biometric to open the app.

**Consequences (testable):**
- Off by default; enabled from Settings.
- When enabled, the app requires the device's biometric or PIN on cold start and on return to foreground after 5 minutes in background.
- Failing biometric falls back to device PIN, never to bypass.
- App lock does not affect Sync, which continues in background.

#### FR-8: Language

The app presents Bangla as the default interface language, with English available.

**Consequences (testable):**
- Default language on first launch is Bangla, regardless of device locale.
- The Owner can switch to English in Settings and back; the choice persists across restarts and devices.
- **Numerals follow the language setting.** In Bangla, all displayed numerals are Bangla digits (৳১,০৮০); in English, Western digits (৳1,080). One rule, no per-surface exceptions — dashboard, ledgers, reports, notifications and Receipts all obey it.
- Switching language re-renders every displayed figure in the other script without any data change; the stored value is script-independent.
- **Input is separate from display.** Amount and quantity fields accept Bangla digits, Western digits and a mix of both, in either language mode, and normalise to one internal value. The device keypad is outside Hisab's control, so the app must never assume which script the Owner types.
- Thousand separators follow the language: Western grouping in English (1,080); the South Asian convention in Bangla where the figure exceeds five digits (১,০৮,৫০০ — lakh grouping, not 108,500).
- Currency is always prefixed ৳.
- Bangla digits must render correctly in generated PDF Receipts and reports, not only on screen (§4.11 NFRs).

**Feature-specific NFRs:**
- Cold start to the OTP screen: under 3 seconds on a mid-range 2023 Android device.
- The setup flow must be completable in under 3 minutes by a first-time user (validated in usability testing, SM-1).

---

### 4.2 Home Dashboard and Quick Actions

**Description:** The screen the Owner sees every time they open Hisab, and the screen from which nearly every transaction starts. It answers, without scrolling, the four questions the Owner has each day — what did I sell, what did I collect, what did I spend, what did I make — followed by the two that govern the business's health, Receivable and Payable, and then a Low Stock warning. Below or above these, six large Quick Action buttons launch the transaction flows directly, because a shop owner with a customer waiting must not have to navigate. Everything is Bangla-labelled and tap-target-generous. Realizes UJ-2, UJ-3, UJ-5, UJ-6.

**Functional Requirements:**

#### FR-9: Today's figures

The Home screen displays Today's Sales, Today's Collection, Today's Expense and Today's Profit for the current calendar day.

**Consequences (testable):**
- Today is the Business's local calendar day in Asia/Dhaka, from 00:00 to 23:59.
- Today's Sales = sum of Sale Totals dated today, minus Sales Returns dated today.
- Today's Collection = sum of Customer Payments received today, including the Paid portion of today's Sales.
- Today's Expense = sum of Expenses dated today. Account Transfers and Supplier Payments are excluded.
- Today's Profit = today's Gross Profit minus today's Expenses, labelled *আনুমানিক লাভ* (estimated).
- All four figures reflect transactions recorded offline as soon as they are saved locally, without waiting for Sync.

#### FR-10: Receivable and Payable summary

The Home screen displays total Receivable and total Payable, each tappable through to the underlying list.

**Consequences (testable):**
- Receivable = sum of positive Customer Balances across all Customers; negative balances are excluded, not netted.
- Payable = sum of positive Supplier Balances; negative balances excluded.
- Labels are **আপনার কাছ থেকে পাবেন** and **আপনাকে দিতে হবে** in Bangla mode.
- Tapping Receivable opens the Customers-with-dues list sorted by balance descending (FR-21).
- Tapping Payable opens the equivalent Supplier list.

#### FR-11: Low Stock panel

The Home screen displays Products that are Low Stock or Out of Stock.

**Consequences (testable):**
- Shows up to 5 Products, Out of Stock first, then Low Stock ascending by remaining quantity, with a count and a link to the full list when more exist.
- A Product with no Minimum Stock set never appears as Low Stock, only as Out of Stock when Inventory ≤ 0.
- The panel is hidden entirely, rather than shown empty, when no Product qualifies.
- Tapping a Product opens that Product's detail screen.

#### FR-12: Money Account summary

The Home screen displays the balance of each Money Account with a non-zero balance, and their total.

**Consequences (testable):**
- Accounts with a zero balance and no history are hidden; accounts with history are shown even at zero.
- The total equals the sum of displayed and hidden account balances.
- Tapping through opens the Money Accounts screen (FR-66).

#### FR-13: Quick Actions

The Home screen presents six primary actions that open their flow in one tap: **+ বিক্রি**, **+ টাকা পেলাম**, **+ টাকা দিলাম**, **+ বাকি দিলাম**, **+ খরচ**, **+ পণ্য যোগ**.

**Consequences (testable):**
- Each button opens its flow directly with no intermediate menu.
- Each tap target is at least 48×48 dp with its label fully visible without truncation at the default system font size and at the largest supported accessibility size.
- **+ বাকি দিলাম** opens a simplified credit-entry flow (FR-20) distinct from the full Sale flow.
- Actions are available and fully functional offline.

#### FR-14: Greeting and Business identity

The Home screen shows a time-appropriate greeting, the Owner's name and the Business name.

**Consequences (testable):**
- Greeting varies by local time (সুপ্রভাত / শুভ অপরাহ্ন / শুভ সন্ধ্যা).
- Business name is shown on every load and matches FR-2.

**Feature-specific NFRs:**
- Home renders complete with real figures in under 1 second from local data on a mid-range device, without waiting on the network (TD §64).
- Home is fully functional offline; no element shows a spinner or error state due to absent connectivity.

---

### 4.3 Customers and Customer Ledger

**Description:** The heart of the product. A Customer is created with as little as a name — phone optional, because half of a shop's credit customers are known by face — and thereafter carries a running Customer Balance that the Owner and the customer can both look at. The Customer Ledger is a chronological debit/credit/balance table derived from Sales, Customer Payments, Sales Returns and adjustments; it is never edited directly, which is what makes it trustworthy in a dispute. The **বাকি দিলাম** flow exists as a deliberately simplified path: when a customer takes goods and the Owner does not have time to itemise them, they record an amount and a description against the Customer, and the ledger is correct even if the inventory is not touched. Realizes UJ-2, UJ-3, UJ-6.

**Functional Requirements:**

#### FR-15: Create and edit Customer

The Owner can create a Customer with a name and optional phone, address, and opening balance, and edit those details later.

**Consequences (testable):**
- Name is required, 1–100 characters. Phone, address and note are optional.
- Duplicate names are permitted but the Owner is warned inline when an exact name match already exists, showing the existing Customer's balance so they can choose.
- Phone, when supplied, is validated as a BD mobile number and enables the Share/Reminder actions (FR-89).
- Creating a Customer from inside a Sale or Payment flow returns to that flow with the new Customer selected and no entered data lost.
- Editing a Customer's details never alters their Balance or Ledger.

#### FR-16: Delete or archive Customer

The Owner can remove a Customer who was created in error, and archive one who is no longer active.

**Consequences (testable):**
- A Customer with zero transactions can be deleted outright.
- A Customer with any transaction cannot be deleted; the app offers Archive instead and says why.
- An archived Customer is hidden from lists and pickers by default, retains their full Ledger, and is excluded from Receivable only if their Balance is zero — a non-zero archived balance still counts, and the app warns before archiving in that case.
- Archived Customers can be restored.

#### FR-17: Customer list

The Owner can see all Customers with their current balances and find one quickly.

**Consequences (testable):**
- Default sort is most-recently-transacted first.
- Sorts available: name, balance descending, most recent.
- Each row shows name, balance with direction (পাবেন / advance / settled), and time since last transaction.
- Type-ahead filters the list on name and phone within 300 ms for up to 5,000 Customers (TD §64).

#### FR-18: Customer detail

The Owner can view one Customer's summary and act on it.

**Consequences (testable):**
- Shows name, phone, current Balance with direction, and date of last transaction.
- Offers, as primary actions: **+ বিক্রি**, **টাকা পেলাম**, **হিসাব দেখুন**, and Share/Remind when a phone is present.
- Balance shown matches the Ledger's final running balance exactly.

#### FR-19: Customer Ledger

The Owner can view a chronological Ledger for one Customer with a running balance. Realizes UJ-2, UJ-3.

**Consequences (testable):**
- Columns: date, description, debit, credit, resulting balance. Ordered oldest to newest by transaction date, then by creation time for same-day entries.
- A Sale creates a debit for its Total; a Customer Payment creates a credit; a Sales Return creates a credit; a Manual Adjustment creates either.
- The header states the position in plain Bangla — *রহিম আপনার কাছে ৳4,500 পাবেন* or the advance equivalent — never as a bare signed number.
- Every Ledger Entry links to the transaction that produced it, and opening that transaction shows its full detail.
- The running balance after the final entry equals the Customer Balance shown everywhere else in the app.
- The Ledger can be filtered by date range and shared as a PDF (FR-77).
- The Ledger is read-only: there is no path to edit a Ledger Entry directly.

#### FR-20: Record a credit given (বাকি দিলাম)

The Owner can record an amount a Customer owes, with a description, without itemising Products.

**Consequences (testable):**
- Requires Customer and amount; description optional but prompted.
- Creates a Sale with no Sale Items, a Total equal to the amount, Paid of zero, and the description carried through.
- Increases the Customer Balance by the amount and appears in the Ledger as a debit.
- Does **not** change Inventory, and the Sale is flagged as non-itemised so that Gross Profit calculations exclude it from COGS and reports disclose the exclusion (FR-83).
- Confirmation states the new balance: *রহিমের বাকি: ৳7,000*.
- Works fully offline.

#### FR-21: Customers with outstanding balances

The Owner can see every Customer who owes money, prioritised for collection. Realizes UJ-6.

**Consequences (testable):**
- Lists all Customers with positive Balance, sorted by balance descending by default, with an alternative sort by days since last payment.
- Each row shows balance, days since last payment, and a Send Reminder action when the Customer has a phone.
- Total at the top equals Receivable on Home (FR-10).
- Customers with reminders disabled (FR-92) are visually marked and can be filtered out.

#### FR-22: Customer transaction history filters

The Owner can filter a Customer's Ledger by date range and transaction type.

**Consequences (testable):**
- Ranges: today, this week, this month, custom.
- Types: Sales, Payments, Returns, Adjustments — multi-select.
- Filtering shows an opening balance line for the range so the running balance stays meaningful.

#### FR-23: Manual balance adjustment

The Owner can correct a Customer Balance or Supplier Balance with an explicit adjustment.

**Consequences (testable):**
- Requires a direction, an amount and a reason (free text, required).
- Creates a Ledger Entry labelled *সমন্বয়* with the reason visible.
- Never modifies or deletes an existing transaction.
- Recorded in the audit trail with timestamp and device (FR-117).
- Adjustments are excluded from Sales, Purchase, Expense and Profit figures in all reports.

**Notes:**
- `[NOTE FOR PM]` The non-itemised Sale created by FR-20 is the single largest source of imprecision in Gross Profit. It is the right trade for entry speed, but the reports must be honest about it (FR-83), and post-MVP we should measure what fraction of Sales are non-itemised.

---

### 4.4 Suppliers and Supplier Ledger

**Description:** Structurally the mirror of Customers, and deliberately so — the Owner learns one mental model and applies it in both directions. A Supplier carries a Supplier Balance the Business owes; Purchases debit it, Supplier Payments credit it, Purchase Returns credit it. The **টাকা দিলাম** flow is the counterpart of **টাকা পেলাম**. Realizes UJ-4.

**Functional Requirements:**

#### FR-24: Create and edit Supplier

The Owner can create a Supplier with a name and optional phone, address and opening balance, and edit those details later.

**Consequences (testable):**
- Same field rules, duplicate warning and inline-creation behaviour as FR-15.
- A Supplier can be linked as the default supplier of a Product (FR-46).

#### FR-25: Delete or archive Supplier

The Owner can remove a Supplier created in error and archive an inactive one.

**Consequences (testable):**
- Same rules as FR-16, applied to Purchases, Supplier Payments and Purchase Returns.

#### FR-26: Supplier list and detail

The Owner can see all Suppliers with balances, and open one.

**Consequences (testable):**
- Row shows name, Supplier Balance with direction (*দিতে হবে* / advance / settled), and last transaction date.
- Detail offers **+ ক্রয়**, **টাকা দিলাম**, **হিসাব দেখুন**, and Share when a phone is present.

#### FR-27: Supplier Ledger

The Owner can view a chronological Ledger for one Supplier with a running balance.

**Consequences (testable):**
- Same structure, linkage and read-only rules as FR-19.
- A Purchase creates a credit to the Supplier (increasing what is owed); a Supplier Payment creates a debit; a Purchase Return creates a debit.
- Header states the position in plain Bangla — *করিম হোলসেলকে দিতে হবে ৳35,500*.

#### FR-28: Record a due taken

The Owner can record an amount owed to a Supplier without itemising Products.

**Consequences (testable):**
- Mirror of FR-20: creates a non-itemised Purchase, increases Supplier Balance, does not change Inventory, is flagged so COGS excludes it.

#### FR-29: Suppliers with outstanding balances

The Owner can see every Supplier the Business owes, sorted by amount.

**Consequences (testable):**
- Total at the top equals Payable on Home (FR-10).
- No automated reminders are sent to Suppliers in MVP — this list is for the Owner's planning only.

---

### 4.5 Sales

**Description:** The most-used flow in the app and the one whose speed determines whether Hisab replaces the khata. A Sale names an optional Customer (walk-in cash sales need none), a list of Sale Items with quantities and prices pre-filled from the Product record, an optional discount, and a Paid amount with a Payment Method. Cash sale and credit sale are not separate flows — they are the same flow with Paid equal to or less than Total, which is exactly how the Owner thinks about it. Crucially, **Sales and the Ledger are not separate systems**: saving a Sale with a Due writes the Ledger Entry, moves the money, and decrements stock in one atomic operation (TD §31). Realizes UJ-2, UJ-8.

**Functional Requirements:**

#### FR-30: Create a Sale

The Owner can record a Sale of one or more Products to an optional Customer, with a Paid amount and Payment Method. Realizes UJ-2.

**Consequences (testable):**
- Customer is optional; omitting it creates a walk-in Sale that requires Paid = Total.
- At least one Sale Item, or a non-zero Total in the non-itemised path (FR-20), is required.
- Sale date defaults to now and can be backdated, but not future-dated.
- Saving is atomic: Sale, Sale Items, Stock Movements, Ledger Entry and Money Account movement all commit together or none do (TD §31).
- On success the confirmation shows Total, Paid, Due, and — where a Customer is named — their previous and new Balance.
- The Sale is assigned a Receipt number from one of **two per-Business series**, chosen by whether a Customer is named: a Customer Sale series and a separate walk-in (cash) Sale series. Numbers are **unique, ascending and never reused**, including across offline entries (TD §32).
- **Numbers are not guaranteed gap-free.** Offline allocation draws from a server-issued block, and an abandoned block leaves a gap (architecture AD-15). Gap-free numbering and offline allocation are mutually exclusive, and the offline receipt is the one that matters — a slip handed to a customer must carry its final number. If an Owner asks, the honest answer is that a missing number means a block was retired, not that a sale is missing.
- The two series are visually distinguishable on the Receipt and in lists by prefix — proposed `INV-` for Customer Sales and `CS-` for walk-in Sales. `[ASSUMPTION: prefixes proposed here; confirm the exact scheme with Tanim.]`
- A Sale that gains a Customer through correction (FR-36) keeps its original series and number; it is not renumbered into the other series.
- The whole flow works offline with identical behaviour and identical numbering guarantees for both series.

#### FR-31: Add and edit Sale Items

The Owner can add Products to a Sale with quantity, unit price and line discount.

**Consequences (testable):**
- Selecting a Product pre-fills its selling price and Unit; the Owner can override the price on the line without changing the Product record.
- Quantity accepts decimals for weight/volume Units (Kg, Gram, Liter, Meter) and whole numbers only for count Units (Piece, Box, Packet, Dozen).
- Line total = quantity × unit price − line discount, recomputed and displayed as the Owner types.
- A Product not yet in Hisab can be created inline without losing lines already entered.
- An item can be removed; removing the last item leaves the Sale unsaveable rather than silently empty.

#### FR-32: Sale totals and discount

The Owner can apply an order-level discount and sees the resulting Total before saving.

**Consequences (testable):**
- Subtotal = sum of line totals. Discount can be entered as an amount or a percentage and is displayed both ways.
- Total = Subtotal − order discount, and can never be negative; an over-large discount is rejected with an inline message.
- Total is visible on screen at all times during item entry, not only on a summary step.

#### FR-33: Record payment against a Sale

The Owner can record how much the Customer paid now, by which Payment Method, with the remainder becoming Due. Realizes UJ-2.

**Consequences (testable):**
- Paid defaults to Total (the common cash case) and can be reduced to zero.
- Paid may not exceed Total on the Sale screen; overpayment is handled as a separate Customer Payment (FR-62).
- Due = Total − Paid, displayed live as *বাকি ৳580* before the Owner commits.
- Paid > 0 requires a Payment Method and credits the corresponding Money Account.
- Paid < Total requires a Customer; a walk-in Sale cannot carry a Due.
- Split payment across two Payment Methods is **not** supported in MVP. `[NON-GOAL for MVP]`

#### FR-34: Sale list

The Owner can browse and filter past Sales.

**Consequences (testable):**
- Default view is today, newest first, with a day total at the top.
- Filters: date range, Customer, paid/partially-paid/unpaid, Payment Method.
- Each row shows receipt number, Customer or *ক্যাশ বিক্রি*, Total, and Due when non-zero.
- Pending Sync Sales are visually marked in the list.

#### FR-35: Sale detail

The Owner can open a Sale and see everything it recorded.

**Consequences (testable):**
- Shows Customer, date, receipt number, all Sale Items with quantity/price/line total, discount, Total, Paid, Due, Payment Method.
- Offers Share Receipt (FR-74), Edit (FR-36), Delete (FR-37) and Sales Return (FR-70).
- Shows the resulting Customer Balance at the time of the Sale and the current one.

#### FR-36: Correct a Sale

The Owner can correct a Sale they entered wrongly.

**Consequences (testable):**
- The Owner-facing action is **Edit**: they open the Sale, change what was wrong, and save. The Owner is not asked to understand reversals.
- **Mechanism:** the system does not mutate the original Sale. It writes a reversal and a corrected Sale, per TD §15, which treats financial transactions as immutable and prefers `Original → Reversal → Corrected` over in-place edit specifically because it removes a whole class of sync conflict.
- Stock Movements, the Ledger Entry and the Money Account movement all net to the corrected values, and the three commit atomically with the reversal and correction.
- The Customer Ledger shows the correction transparently — the original entry, its reversal, and the corrected entry — rather than silently rewriting history. This is what lets a disputed balance be traced (§9).
- The corrected Sale keeps the original's receipt number; the reversal carries its own reference. `[ASSUMPTION: an Owner who has already handed a customer a receipt should not find its number reassigned. Confirm with Tanim.]`
- The prior values are retained in the audit trail with actor, timestamp and device (FR-117).
- A Sale that has an associated Sales Return cannot be corrected; the Owner must reverse the return first, and the app says so.
- Correcting an already-synced Sale generates new records, not a duplicate of the original (TD §32).

#### FR-37: Void a Sale

The Owner can remove a Sale entered in error.

**Consequences (testable):**
- The Owner-facing action is **Delete**; the mechanism is a reversal, per TD §15 and FR-36. Nothing is erased.
- Deletion requires an explicit confirmation naming the amount and the Customer.
- The reversal undoes stock, ledger and money effects atomically.
- The Sale is marked void, remains visible in the audit trail and in the Ledger as an original-plus-reversal pair, and its receipt number is never reissued.
- A voided Sale is excluded from every report figure for its original date.
- A Sale with a Sales Return cannot be deleted until the return is reversed.

#### FR-38: Walk-in cash sale fast path

The Owner can record a cash sale with no Customer in the minimum possible number of taps.

**Consequences (testable):**
- From Home, a cash Sale of a single Product with default price is recordable in no more than 5 taps plus quantity entry.
- No Customer selection step is shown unless the Owner explicitly opts to attach one.

#### FR-39: Sales affect stock

Every itemised Sale decrements Inventory for each Sale Item.

**Consequences (testable):**
- One Stock Movement of type Sale per Sale Item, linked to the Sale.
- Selling more than the recorded Inventory is **permitted** but warns before saving; the resulting Inventory may go negative and the Product is shown as Out of Stock. `[ASSUMPTION: blocking the sale would be worse than an inaccurate stock count for a shop whose stock records lag reality. Confirm with Tanim.]`
- Under FIFO, a Sale into negative stock has no Cost Layer to consume and is costed provisionally, then reconciled on the next Purchase (FR-52). This interaction is the main complexity FIFO adds and needs explicit test coverage (TD §68).
- Non-itemised Sales (FR-20) produce no Stock Movement.

**Feature-specific NFRs:**
- Saving a Sale gives perceived confirmation in under 100 ms from local persistence, independent of network (TD §64).
- A Sale with up to 50 Sale Items saves without visible degradation.

---

### 4.6 Purchases

**Description:** The Owner buys stock from a Supplier, usually on partial credit. A Purchase raises Inventory, raises the Supplier Balance by the unpaid amount, and moves money out of a Money Account for the paid part — again atomically, so the three views of the same event cannot disagree. The flow mirrors Sales closely enough that the Owner does not learn a second model. Realizes UJ-4.

**Functional Requirements:**

#### FR-40: Create a Purchase

The Owner can record a Purchase of one or more Products from a Supplier with a Paid amount and Payment Method. Realizes UJ-4.

**Consequences (testable):**
- Supplier is required for a Purchase carrying a Due; a cash Purchase with Paid = Total may omit the Supplier.
- Purchase date defaults to now, may be backdated, may not be future-dated.
- Saving is atomic across Purchase, Purchase Items, Stock Movements, Supplier Ledger Entry and Money Account movement.
- Confirmation states the three effects explicitly: stock increased, Supplier Balance now X, Money Account reduced by Y.
- Works fully offline.

#### FR-41: Add Purchase Items

The Owner can add Products with quantity and unit cost.

**Consequences (testable):**
- Selecting a Product pre-fills its last purchase price; the Owner can override it.
- Overriding the unit cost offers to update the Product's stored purchase price, defaulted to **yes**, because a stale purchase price silently corrupts Gross Profit.
- A Product not in Hisab can be created inline without losing entered lines.
- Quantity rules follow Unit type as in FR-31.

#### FR-42: Purchase payment and due

The Owner can record how much was paid now, with the remainder becoming a Supplier Due.

**Consequences (testable):**
- Paid defaults to zero for a Purchase with a Supplier (the common credit case) and to Total for a cash Purchase.
- Paid may not exceed Total; overpayment is recorded as a separate Supplier Payment.
- Due = Total − Paid increases the Supplier Balance and appears in the Supplier Ledger.
- Paid > 0 requires a Payment Method and debits the corresponding Money Account.

#### FR-43: Purchase list and detail

The Owner can browse, filter and open past Purchases.

**Consequences (testable):**
- Filters: date range, Supplier, paid/partially-paid/unpaid.
- Detail shows all items with quantity and unit cost, Total, Paid, Due, Payment Method, and the resulting Supplier Balance.
- Offers Edit, Delete and Purchase Return (FR-72).

#### FR-44: Edit or delete a Purchase

The Owner can correct or remove a Purchase.

**Consequences (testable):**
- Same reversal-based mechanism, atomicity, audit-trail and blocked-by-return rules as FR-36 and FR-37, applied to stock, the Supplier Ledger and the Money Account.
- Deleting a Purchase whose stock has since been sold is permitted and may drive Inventory negative; the Owner is warned with the affected Products named.

#### FR-45: Purchases affect stock

Every itemised Purchase increments Inventory for each Purchase Item.

**Consequences (testable):**
- One Stock Movement of type Purchase per Purchase Item, linked to the Purchase.
- Non-itemised Purchases (FR-28) produce no Stock Movement.

---

### 4.7 Products and Inventory

**Description:** A Product catalogue light enough that a grocery with 400 SKUs can populate it gradually — most fields optional, creation possible inline from a Sale or Purchase — but complete enough to drive selling prices, stock levels, low-stock warnings and Gross Profit. Inventory is a derived quantity backed by an append-only Stock Movement trail: every change has a reason, which is what lets the Owner answer "where did those five bags go?". Realizes UJ-4, UJ-5.

**Functional Requirements:**

#### FR-46: Create and edit Product

The Owner can create a Product with a name and Unit, and optionally SKU, barcode value, Category, purchase price, selling price, Minimum Stock, opening stock and default Supplier.

**Consequences (testable):**
- Name and Unit are required; everything else is optional.
- Barcode is stored as a text value and is searchable; no camera scanning in MVP (§6.2).
- Selling price below purchase price is allowed but warned inline.
- Opening stock entered at creation produces a Stock Movement of type Manual Adjustment labelled as opening stock, dated the creation date.
- Editing purchase price does not retroactively change COGS on past Sales.
- Product creation is available inline from Sale, Purchase and Quick Actions.

#### FR-47: Product categories

The Owner can group Products into Categories.

**Consequences (testable):**
- Category is optional and free-text with autocomplete over existing Categories.
- Products can be filtered by Category in the list and in reports.

#### FR-48: Units

Every Product has one Unit from the fixed list: Piece, Kg, Gram, Liter, Box, Packet, Dozen, Meter.

**Consequences (testable):**
- Unit governs whether quantities accept decimals (FR-31).
- Unit is displayed everywhere a quantity is displayed.
- Unit cannot be changed once the Product has Stock Movements, because the historical quantities would become meaningless; the app says so and offers to create a new Product instead.

#### FR-49: Product list

The Owner can browse, search and filter Products.

**Consequences (testable):**
- Shows name, current Inventory with Unit, selling price, and a Low/Out of Stock marker.
- Filters: Category, Low Stock, Out of Stock.
- Sorts: name, stock ascending, best-selling.
- Type-ahead search matches name, SKU and barcode within 300 ms for up to 5,000 Products.

#### FR-50: Product detail

The Owner can see one Product's full position.

**Consequences (testable):**
- Shows Inventory, Unit, purchase price, selling price, Stock Value for this Product, Minimum Stock, Category and default Supplier.
- Shows recent Stock Movements with date, type, signed quantity and resulting quantity.
- Offers Adjust Stock (FR-53) and Edit.

#### FR-51: Inventory summary

The Owner can see the state of stock across the Business.

**Consequences (testable):**
- Shows total Product count, total Stock Value, Low Stock count and Out of Stock count.
- Stock Value = Σ (Inventory × purchase price) over Products with a purchase price; Products without one are excluded and the exclusion is disclosed with a count.
- Counts match the Home Low Stock panel (FR-11).

#### FR-52: Stock Movement trail

Every change to Inventory is recorded as a Stock Movement with a reason.

**Consequences (testable):**
- Types: Purchase, Sale, Sales Return, Purchase Return, Damage, Manual Adjustment.
- Each Movement stores signed quantity, resulting quantity, timestamp, reason and a link to the originating transaction where one exists.
- Stock Movements are append-only; a correction is a new Movement, never an edit or delete of an existing one.
- Current Inventory always equals the sum of signed quantities of that Product's Stock Movements.
- **FIFO Cost Layers.** Every Movement that adds stock (Purchase, Sales Return, opening stock, import) opens a Cost Layer carrying quantity, unit cost and acquisition date. Every Movement that removes stock (Sale, Damage, Purchase Return) consumes from the oldest open Layer first and records, on the Movement, exactly which Layers it drew from and at what cost. That record is what makes COGS (FR-81) reproducible and auditable rather than recomputed-on-read.
- Layer consumption is computed at save time, locally, so COGS is correct offline and identical after Sync.
- **Selling into negative stock** (FR-39) consumes no Layer, because none exists. The Movement is recorded with a provisional cost equal to the Product's current purchase price and marked provisional; the next Purchase that brings Inventory back to or above zero reconciles it to the actual cost and restates the affected COGS. The profit report discloses provisional-cost Movements in the period (FR-83).
- A correction or void (FR-36, FR-37) restores the consumed Layers to their prior state as a new Movement, in reverse consumption order; Layers are never deleted.

#### FR-53: Manual stock adjustment

The Owner can correct a Product's Inventory and record damage or loss.

**Consequences (testable):**
- Requires a new quantity or a signed delta, a type (Damage or Manual Adjustment) and a reason (required free text).
- Creates one Stock Movement; does not create a Sale, Purchase or Expense.
- **A Damage adjustment records a cost.** Its value — quantity × the cost of the stock consumed, computed by FIFO layer (FR-52) — is recorded as a business cost and reduces Net Profit for the adjustment's period (FR-81). Spoilage in a grocery is a real loss and reporting it only as a smaller Stock Value would overstate profit.
- Damage appears in the profit report as its own line (*নষ্ট*), separate from Expenses, so the Owner can see how much they are losing to spoilage.
- A Manual Adjustment, by contrast, carries **no** financial effect — it is a count correction, not a loss. The distinction between the two types is therefore financially significant and the entry screen must make it unmistakable, not a dropdown default.
- Damage adjustments are also summarised in the inventory report (FR-82).

#### FR-54: Low Stock threshold

The Owner can set a Minimum Stock level per Product that drives Low Stock warnings.

**Consequences (testable):**
- Optional per Product, non-negative, expressed in the Product's Unit.
- When Inventory ≤ Minimum Stock and > 0, the Product is Low Stock; at ≤ 0 it is Out of Stock.
- Crossing into Low Stock triggers a notification at most once per Product per 24 hours (FR-91).

#### FR-55: Bulk product entry

The Owner can add several Products in one session without returning to the list between each.

**Consequences (testable):**
- After saving a Product from the add flow, the app offers Save & Add Another, retaining Category and Unit from the previous entry.

#### FR-119: Import a product catalogue from a file

The Owner can populate their Product catalogue by importing a spreadsheet, rather than entering hundreds of items by hand.

*Moved into MVP by Tanim's decision (§15, Q1 closed). It closes the largest onboarding risk in the product (R-3): a grocery with 400 SKUs that never populates Products silently loses inventory, profit and every Product-level report.*

**Consequences (testable):**
- Accepts CSV and XLSX. A downloadable template with the expected columns is offered in the same screen, in Bangla and English.
- Columns: name (required), Unit (required), SKU, barcode, Category, purchase price, selling price, opening stock, Minimum Stock. Column order is not significant; headers are matched case-insensitively in either language.
- **Preview before commit.** The Owner sees a parsed table with row count, a per-row validation state and a plain-Bangla summary of what will happen, and must confirm. Nothing is written before confirmation.
- Rows that fail validation are listed with the row number and the reason, and can be skipped while the valid rows import — a single bad row never aborts the whole file.
- A row whose name matches an existing Product is flagged as a duplicate, and the Owner chooses once for the whole file: skip duplicates, or update the existing Products' prices and thresholds. Duplicate handling never creates a second Product with the same name silently.
- Opening stock in an imported row creates a Stock Movement of type Manual Adjustment labelled as opening stock, dated the import date, and — under FIFO (FR-52) — a cost layer at the row's purchase price. A row with opening stock but no purchase price imports the stock and flags the Product as lacking a cost basis (FR-83).
- The import is atomic: it commits as one transaction, so a failure part-way leaves no partial catalogue.
- Import is capped at 2,000 rows per file and shows progress; a file that exceeds the cap is rejected with a message saying so, not truncated silently.
- **Import works offline**, like every other write in the product (FR-93). Parsing, validation, the preview and the commit all run on the device; the imported Products sync afterwards as ordinary records. Decided deliberately: an exception here would be the one place the Owner is told a connection is required, and the promise is worth keeping literally.
- The Plan limit check (FR-110) runs against the locally cached entitlement at commit time and is re-verified server-side on sync; an import that passes locally but exceeds the limit server-side surfaces per the sync rejection path, never silently.
- The Owner can undo an import in full within 24 hours, provided none of the imported Products has since been transacted against.
- Importing is available on the Free Plan and counts against the Plan's Product limit; a file that would exceed the limit is rejected before commit, naming the limit (FR-110).

**Notes:**
- `[NOTE FOR PM]` This FR carries a new number rather than slotting in as FR-56 because FR IDs are append-only once assigned (§0). Its natural home is here, in §4.7.
- The single highest-value companion to this is a *shop-type starter catalogue* — pre-built Bangla product lists for grocery, pharmacy and so on, offered at setup. Not scoped here; worth considering if import uptake is low.

#### FR-56: Product performance

The Owner can see which Products actually sell.

**Consequences (testable):**
- Top-selling Products by revenue and by quantity, for a selectable period.
- Slowest-moving Products: those with stock and no Sale in the period.
- Both lists exclude non-itemised Sales and say so.

**Feature-specific NFRs:**
- Product search returns results in under 300 ms locally at 5,000 Products (TD §64).
- Inventory figures are computed locally and are correct offline.

---

### 4.8 Expenses

**Description:** Everything the Business spends that is not stock. Categories are pre-seeded with the ones a Bangladeshi shop actually has — rent, electricity, gas, internet, salary, transport, packaging, maintenance, marketing, food — so the Owner picks rather than types. Recurring expenses (rent, salary, internet) are defined once and reminded about, because those are exactly the ones forgotten and exactly the ones that make the profit figure wrong. Owner withdrawal is modelled separately from Expense, because a shop owner taking ৳5,000 for household costs is not a business cost and treating it as one understates profit. Realizes UJ-5.

**Functional Requirements:**

#### FR-57: Record an Expense

The Owner can record an Expense with amount, Expense Category, Payment Method, date and optional note.

**Consequences (testable):**
- Amount, Category and Payment Method are required; note and attachment optional.
- Saving debits the corresponding Money Account atomically with creating the Expense.
- Date defaults to today, may be backdated, may not be future-dated.
- Expenses appear in Today's Expense (FR-9) and reduce Net Profit for their period.
- Works fully offline.

#### FR-58: Expense Categories

The Owner can classify Expenses using seeded categories and add their own.

**Consequences (testable):**
- Seeded: Rent, Electricity, Gas, Internet, Employee Salary, Transport, Packaging, Maintenance, Marketing, Food, Other — with Bangla labels.
- The Owner can add a Category; added Categories persist and appear in the picker and reports.
- A Category in use cannot be deleted; it can be renamed, and the rename applies to historical Expenses.

#### FR-59: Expense list and detail

The Owner can browse, filter, edit and delete Expenses.

**Consequences (testable):**
- Filters: date range, Category, Payment Method.
- List shows a period total at the top matching the reports.
- Editing or deleting is implemented as a reversal plus a corrected entry (TD §15), nets the Money Account effect atomically, and is recorded in the audit trail.

#### FR-60: Recurring Expenses

The Owner can define an Expense that repeats, and be reminded when it is due.

**Consequences (testable):**
- Defined with amount, Category, frequency (monthly only in MVP), and day of month.
- Hisab sends a reminder 3 days before and on the due date (FR-91).
- A reminder offers one-tap recording of the Expense with the stored values pre-filled, editable before saving.
- Recurring definitions never create an Expense automatically; the Owner always confirms. `[ASSUMPTION: auto-posting expenses the Owner did not confirm would violate the "financial data is deterministic and owner-controlled" principle. Confirm with Tanim.]`
- A recurring definition can be paused or deleted without affecting Expenses already recorded from it.

#### FR-61: Owner withdrawal

The Owner can record money taken out of the Business for personal use, separately from Expenses.

**Consequences (testable):**
- Recorded with amount, Money Account, date and optional note, labelled *মালিকের উত্তোলন*.
- Reduces the Money Account balance.
- Is **excluded** from Expenses and from Net Profit in every report.
- Appears in its own line in the profit report so the Owner can see cash out that was not a cost.

---

### 4.9 Payments, Money Accounts and Transfers

**Description:** The Bangladesh-specific part of the money model. A shop's money is not one number; it is cash in the drawer, a bKash balance, a Nagad balance, sometimes Rocket, and a bank account, and the Owner thinks about them separately. Every Payment names the Money Account it touches, so the app can show the split truthfully. Account Transfer exists because moving ৳20,000 from cash to bank is neither revenue nor expense, and any app that treats it as either will produce a profit figure the Owner knows is wrong and will stop trusting. Realizes UJ-3.

**Functional Requirements:**

#### FR-62: Record a Customer Payment (টাকা পেলাম)

The Owner can record money received from a Customer against their Balance. Realizes UJ-3.

**Consequences (testable):**
- Requires Customer, amount and Payment Method; date defaults to today, backdating allowed.
- Increases the named Money Account and creates a credit Ledger Entry, atomically.
- Confirmation states the change in plain Bangla: *রহিমের বাকি ৳4,080 থেকে কমে ৳1,080 হলো*.
- A payment exceeding the Customer Balance is accepted and produces a negative (advance) Balance, shown as such, not as an error.
- Payments are recorded against the Customer Balance as a whole, not allocated to specific Sales, in MVP. `[NON-GOAL for MVP: per-invoice payment allocation.]`
- Works fully offline.

#### FR-63: Record a Supplier Payment (টাকা দিলাম)

The Owner can record money paid to a Supplier against the Supplier Balance.

**Consequences (testable):**
- Mirror of FR-62: decreases the named Money Account, creates a debit Supplier Ledger Entry, permits overpayment as an advance.

#### FR-64: Payment Methods

Every Payment, Sale payment, Purchase payment and Expense names one Payment Method.

**Consequences (testable):**
- Available: Cash, bKash, Nagad, Rocket, Bank, Card, Other.
- Cash, bKash, Nagad, Rocket and Bank each map to their own Money Account.
- Card and Other require the Owner to name which Money Account they settle into, defaulting to Bank and Cash respectively.
- The most recently used Payment Method for that flow is pre-selected.
- No payment-provider API integration in MVP: these are records of what happened, not initiations of payment (§5).

#### FR-65: Payment receipt

The Owner can share a Receipt for a Customer Payment.

**Consequences (testable):**
- Generates a Receipt showing Business name, Customer, amount received, Payment Method, date, and resulting Balance.
- Shareable by the same channels as a Sale Receipt (FR-75).

#### FR-66: Money Accounts view

The Owner can see the balance of every Money Account and the total.

**Consequences (testable):**
- Lists Cash, bKash, Nagad, Rocket and Bank with current balances and a total.
- Each account opens a chronological history of every movement in and out with a running balance and links to source transactions.
- Balances are computed from movements; there is no directly editable balance field.

#### FR-67: Account Transfer

The Owner can move money between two Money Accounts.

**Consequences (testable):**
- Requires source account, destination account, amount and date; source and destination must differ.
- Decreases the source and increases the destination by the same amount, atomically.
- Is excluded from Sales, Collection, Expense, Gross Profit and Net Profit in every report.
- Appears in both accounts' histories, labelled as a transfer with the counterpart account named.

#### FR-68: Negative balance handling

The app records a Money Account balance going negative rather than blocking the entry.

**Consequences (testable):**
- A Payment or Expense larger than the Money Account balance is accepted, with an inline warning before saving.
- A negative Money Account balance is displayed in a warning treatment on the Money Accounts view.
- `[ASSUMPTION: an Owner whose cash record is behind reality must still be able to record what happened; blocking would push them back to paper. Confirm with Tanim.]`

#### FR-69: Payment history

The Owner can browse all Payments across Parties and accounts.

**Consequences (testable):**
- Filters: date range, type (Customer Payment / Supplier Payment / Account Transfer), Payment Method, Party.
- Each row links to the Party and to the affected Money Account.

---

### 4.10 Returns

**Description:** Goods come back — a customer returns a defective item, the Owner sends bad stock back to the wholesaler. A return is not an edit of the original transaction (which would destroy the record of what actually happened) but a new, linked transaction that reverses part of it. Stock, the Party's Balance and reported Sales or Purchases all move together.

**Functional Requirements:**

#### FR-70: Sales Return

The Owner can record goods returned by a Customer against an existing Sale.

**Consequences (testable):**
- Started from the Sale; the Owner selects which Sale Items and what quantity are coming back, up to the quantity originally sold.
- Requires a reason from a short list (Defective, Wrong item, Customer changed mind, Other) with free text for Other.
- Increases Inventory via Stock Movements of type Sales Return.
- Reduces the Customer Balance by the returned value; where the Sale was fully paid, the Owner chooses between refunding money now (which decreases a Money Account) or leaving it as a Customer advance.
- Reduces reported Sales for the return's date, not the original Sale's date.
- Saves atomically and works offline.

#### FR-71: Standalone Sales Return

The Owner can record a return where the original Sale is not in Hisab.

**Consequences (testable):**
- Requires Customer or walk-in, Product, quantity and value.
- Same stock, balance and reporting effects as FR-70, with no linked Sale.

#### FR-72: Purchase Return

The Owner can record goods returned to a Supplier against an existing Purchase.

**Consequences (testable):**
- Mirror of FR-70: decreases Inventory, decreases the Supplier Balance, reduces reported Purchases for the return date.
- Returning more than was purchased is rejected.
- Where the Purchase was paid, the Owner chooses between recording money back into a Money Account or leaving it as a Supplier advance.

#### FR-73: Return visibility

Returns are visible from both the original transaction and the reports.

**Consequences (testable):**
- The original Sale or Purchase shows its linked returns and the net quantity and value remaining.
- Sales reports show gross Sales, returns and net Sales as separate lines (FR-79).

---

### 4.11 Receipts

**Description:** A shop owner handing a customer a printed slip looks like a real business, and a customer who has a receipt argues less about the balance later. Hisab generates a clean Bangla receipt as a PDF and as an image, and shares it through WhatsApp, Messenger, SMS or anything else the phone offers — no printer required, though printing is available where the device supports it. Realizes UJ-2, UJ-3.

**Functional Requirements:**

#### FR-74: Generate a Sale Receipt

The Owner can generate a Receipt for any Sale.

**Consequences (testable):**
- Contains Business name, Business address when set, receipt number, date and time, Customer name when present, every Sale Item with quantity × unit price = line total, discount when non-zero, Total, Paid, Due, and Payment Method.
- Where the Sale left a Due and a Customer is named, the Receipt also shows the Customer's resulting Balance.
- Renders in Bangla by default and in English when the app language is English, with correct Bangla script rendering and ৳ formatting.
- Generates offline; no network required.

#### FR-75: Share a Receipt

The Owner can share a Receipt through the phone's sharing options.

**Consequences (testable):**
- Offers PDF and image (PNG) formats.
- Uses the OS share sheet, so WhatsApp, Messenger, SMS, email and file managers all work without per-app integration.
- Direct-to-WhatsApp is offered as a shortcut when the Customer has a phone number and WhatsApp is installed.
- Sharing is possible offline; the share target handles its own queuing.

#### FR-76: Print a Receipt

The Owner can print a Receipt where the device supports printing.

**Consequences (testable):**
- Uses the OS print dialog. No thermal-printer or Bluetooth-printer integration in MVP (§6.2).

#### FR-77: Share a Ledger statement

The Owner can share a Customer's or Supplier's Ledger as a PDF for a date range.

**Consequences (testable):**
- Contains Business name, Party name, date range, all Ledger Entries with running balance, and the closing balance stated in plain Bangla.
- Shared through the same OS share sheet as FR-75.

**Feature-specific NFRs:**
- A Receipt for a Sale of up to 30 items generates in under 2 seconds on a mid-range device.
- Bangla text must render with correct conjuncts and no tofu boxes in the generated PDF on both Android and iOS. This requires a Bangla font embedded in the app bundle rather than a system font; the technical design does not currently cover this (see `addendum.md` §B.3), and font choice, licence and bundle-size impact against the 40 MB APK target need an architecture decision.

---

### 4.12 Reports

**Description:** Six reports that answer the questions the Owner actually asks, in language they use, with no report builder and no chart-first design. The rule throughout: state the number in Bangla words first, show the breakdown second, and be explicit about what the number does *not* include — particularly the imprecision that non-itemised Sales introduce into profit. Realizes UJ-5, UJ-6.

**Functional Requirements:**

#### FR-78: Daily summary

The Owner can see one screen summarising the day's business. Realizes UJ-5.

**Consequences (testable):**
- Shows Sales, Cash Sales, Credit Sales, Collection, Expenses and estimated Profit for a selected day, defaulting to today.
- Cash Sales + Credit Sales = Sales.
- Reachable in one tap from Home.
- Computed locally; correct offline.

#### FR-79: Sales report

The Owner can see sales performance over a period.

**Consequences (testable):**
- Periods: today, yesterday, this week, this month, custom range.
- Shows gross Sales, Sales Returns, net Sales, transaction count, average sale value, Cash Sales and Credit Sales.
- Breaks down by day for ranges up to 31 days, and by month beyond that.
- Numbers reconcile exactly with the Sale list filtered to the same range (FR-34).

#### FR-80: Expense report

The Owner can see spending over a period, by Category.

**Consequences (testable):**
- Total Expenses for the period with a per-Category breakdown, largest first, with each Category's share.
- Excludes Owner withdrawals, Supplier Payments, Purchases, Damage and Account Transfers, and states that it does. Damage is a cost but not an Expense, and is reported on the profit report (FR-81), not here.

#### FR-81: Profit report

The Owner can see whether the Business made money over a period.

**Consequences (testable):**
- Shows Sales, Cost of Goods Sold, Gross Profit, Expenses, Damage and Net Profit for the period, in that order.
- COGS is computed **FIFO** from Cost Layers (FR-52), consistently across all periods, and the report's explanatory line says so in plain Bangla.
- Damage recorded in the period appears as its own cost line below Expenses (FR-53), and is included in Net Profit.
- Leads with a plain-language statement — *এই মাসে আপনার লাভ ≈ ৳115,000* — before the breakdown.
- Owner withdrawals are shown as a separate line below Net Profit, never inside it.
- Where non-itemised Sales exist in the period, the report states their value and that COGS could not be computed for them (FR-83).

#### FR-82: Dues and inventory reports

The Owner can see outstanding balances and stock position as reports.

**Consequences (testable):**
- Customer dues: every Customer with a positive Balance, total, and ageing buckets (0–7, 8–30, 31–60, 60+ days since last payment).
- Supplier dues: equivalent for Suppliers, without ageing buckets.
- Inventory: total Stock Value (valued at FIFO Cost Layers, not at current purchase price), Low Stock list, Out of Stock list, and Damage recorded in the period with its cost.
- Top customers by purchase value for the period.

#### FR-83: Report integrity disclosures

Every report states what it excludes.

**Consequences (testable):**
- Any report whose figures are affected by non-itemised Sales or Purchases shows their count and value, and states that COGS and Product-level figures exclude them.
- Any report affected by Products lacking a cost basis — no purchase price and no Cost Layer — shows the count of such Products.
- Any period containing provisional-cost Stock Movements from selling into negative stock (FR-52) discloses their count, and says that COGS for the period may be restated when the stock is replenished.
- Profit is labelled *আনুমানিক* (estimated) wherever it appears, in reports and on Home.

#### FR-84: Export a report

The Owner can export any report as a PDF.

**Consequences (testable):**
- Export includes Business name, report name, period and generation timestamp.
- Shared through the OS share sheet.
- CSV export of raw transactions is available from Settings (FR-116) rather than per report.

**Feature-specific NFRs:**
- All six reports compute from local data and are fully available offline.
- A month-range report over a Business with 10,000 transactions renders in under 2 seconds on a mid-range device.

---

### 4.13 Search

**Description:** One search field that finds anything the Owner can name — a customer, a supplier, a product, a receipt number, an amount. It exists because the alternative is teaching a shop owner an information architecture, and they will not learn one.

**Functional Requirements:**

#### FR-85: Global search

The Owner can search across Customers, Suppliers, Products, Sales, Purchases and Expenses from one field.

**Consequences (testable):**
- Matches Customer and Supplier name and phone, Product name, SKU and barcode value, receipt numbers, and Expense notes.
- Results are grouped by entity type with counts, most relevant group first.
- Partial and case-insensitive matching throughout.
- **Bidirectional Bangla↔Latin matching is a first-class requirement, not a nicety.** Typing `Rahim`, `rohim`, `রহিম` or `রাহীম` must all find a Customer stored under any of those spellings. It also serves AI entity resolution (FR-103), where a failure to match is a failure to draft a transaction.
- Testable target: on a curated test set of at least 300 real Bangladeshi person, shop and product names — each with its common Bangla spelling, its common Latin transliteration and at least two plausible misspellings — search returns the correct record in the top 3 results for **≥ 95%** of queries, with the same corpus used to gate FR-103's entity resolution.
- Matching combines transliteration (both directions), phonetic equivalence for the sounds Bangla and Latin transcribe inconsistently (স/শ/ষ → s/sh, ক/খ → k/kh, vowel-length variants), and edit-distance tolerance scaled to name length.
- Ranking is by match confidence, and an exact match always outranks a transliterated one.
- The test corpus is a build artifact checked into the repo and run in CI, so match quality cannot silently regress.
- Returns results within 300 ms locally at 5,000 Customers and 5,000 Products (TD §64).
- Works fully offline.

#### FR-86: Search from context

Every list screen has a scoped search over just that list.

**Consequences (testable):**
- Customer list searches only Customers, Product list only Products, and so on.
- Scoped search uses the same matching rules as FR-85.

#### FR-87: Recent and suggested

Search suggests recent entities before the Owner types.

**Consequences (testable):**
- The empty search state shows the 5 most recently transacted Customers and the 5 most recently sold Products.

---

### 4.14 Reminders and Notifications

**Description:** Two jobs. First, help the Owner collect the money they are owed — the single highest-value thing the app can do for their cash position — by surfacing who is overdue and drafting a polite Bangla message they send themselves. Second, tell them the few things they would otherwise miss: stock about to run out, a recurring expense due, a day not yet recorded. The discipline is restraint: an app that notifies too much gets its notifications turned off, and then the reminders that matter never arrive. Realizes UJ-6.

**Functional Requirements:**

#### FR-88: Due reminder list

The Owner can see which Customers are overdue and act from that list. Realizes UJ-6.

**Consequences (testable):**
- Reachable from Home's Receivable figure and from Reports.
- Ordered by a default of balance descending, with an alternative of longest-overdue first.
- Each row offers Send Reminder and টাকা পেলাম inline.

#### FR-89: Send a reminder

The Owner can send a Customer a payment reminder through WhatsApp or SMS.

**Consequences (testable):**
- Hisab drafts a polite Bangla message including the Business name and the exact outstanding amount, editable before sending.
- Default text: *ভাই, আপনার কাছে ৳X বাকি আছে। সুবিধামতো পরিশোধ করবেন। ধন্যবাদ।* — the Owner can edit the template once in Settings and it applies thereafter.
- Sends via the OS share sheet, WhatsApp deep link, or the SMS app — Hisab never sends a message on the Owner's behalf without them tapping send in that app. `[NON-GOAL for MVP: automated SMS gateway and WhatsApp Business API.]`
- Requires the Customer to have a phone number; the action is disabled with an explanation when absent.
- Hisab records that a reminder was sent, with timestamp, and shows it on the Customer.

#### FR-90: Reminder schedule per Customer

The Owner can set how often a Customer should appear as due for a reminder.

**Consequences (testable):**
- Per Customer: Don't remind / every 7 days (default) / every 15 days / every 30 days.
- A Customer whose last reminder is more recent than their interval is not surfaced as needing one.
- "Don't remind" removes the Customer from the due-reminder list while leaving their Balance in Receivable.

#### FR-91: Notifications

Hisab notifies the Owner about stock, dues, recurring expenses and unrecorded days.

**Consequences (testable):**
- Notification types in MVP: Low Stock reached, Customer payment overdue past their interval, recurring Expense due in 3 days and on the day, and no transaction recorded by 9pm on a day the app was opened.
- At most 3 notifications per day in total; excess is collapsed into one summary notification.
- Each type can be turned off individually in Settings, and all can be turned off together.
- Notifications are delivered by FCM when online and by local scheduled notification when the trigger is computable on-device (TD §48).
- Tapping a notification opens the relevant screen directly.

#### FR-92: Notification preferences

The Owner controls what Hisab notifies them about.

**Consequences (testable):**
- A Settings screen lists every notification type with an individual toggle and a plain-language description.
- Preferences persist across devices via Sync.

---

### 4.15 Offline-First Operation and Sync

**Description:** Not a feature the Owner asks for, and the one that decides whether they keep the app. Mobile data in a Mirpur shop drops for reasons no product decision can fix. Hisab's answer is that the local database is the primary store for everything the Owner does: every read comes from it, every write lands in it first and is acknowledged immediately, and a background queue reconciles with the server whenever a connection exists (TD §11–15). The Owner should be unable to tell, from the behaviour of any screen, whether they are online — except for one honest indicator showing what has not yet synced. Realizes UJ-9, UJ-10.

**Functional Requirements:**

#### FR-93: Offline transaction recording

The Owner can record every transaction type with no network connection. Realizes UJ-9.

**Consequences (testable):**
- Sales, Purchases, Customer Payments, Supplier Payments, Expenses, Account Transfers, Returns, stock adjustments, and Customer/Supplier/Product creation all complete offline with identical flows and identical confirmation.
- No screen in these flows displays a spinner, an error, or a degraded state attributable to absent connectivity.
- Balances, Ledgers, Inventory, Home figures and all six reports reflect offline entries immediately.
- Receipts generate offline (FR-74).

#### FR-94: Local-first reads

Every screen renders from the local database.

**Consequences (testable):**
- No screen's initial render is blocked on a network call.
- Server data, when it arrives, updates the screen without a visible reload or scroll jump.

#### FR-95: Sync queue and status

The Owner can see what has not yet reached the cloud.

**Consequences (testable):**
- A persistent, unobtrusive indicator shows the count of Pending Sync records, e.g. *১৪টি এন্ট্রি সিঙ্ক হয়নি*, and is absent when the count is zero.
- Tapping it lists the pending records and offers Sync Now.
- The indicator distinguishes "waiting for connection" from "sync failing", and the failing state names what to do.

#### FR-96: Automatic sync

Hisab syncs without the Owner asking.

**Consequences (testable):**
- Sync attempts on connection regained, on app foreground, after each write when online, and periodically in background.
- Failed items retry with exponential backoff and are never silently dropped.
- Sync is idempotent: a record delivered twice does not produce two transactions (TD §32).
- Sync never blocks the UI; the Owner can keep recording while it runs.

#### FR-97: Conflict resolution

Concurrent edits from two devices resolve by documented rules, and the unresolvable ones reach the Owner. Realizes UJ-9.

**Consequences (testable):**
- Automatic resolution follows the rules in TD §15, and financial transactions are never merged field-by-field.
- A conflict the rules cannot resolve is surfaced to the Owner as a plain-language choice showing both versions with their amounts, dates and source device — never resolved silently and never discarded.
- No resolution path can produce a Ledger whose running balance disagrees with the Party Balance.
- `[ASSUMPTION: single-owner MVP makes true conflicts rare — the same Owner on two devices. The requirement stands because a stolen-phone or new-phone scenario (UJ-10) can produce them.]`

#### FR-98: Cloud backup

The Owner's data is backed up to the cloud continuously and they can see that it is.

**Consequences (testable):**
- Every synced record is durably stored server-side (TD §62).
- Settings shows the timestamp of the last successful sync in plain language.
- The Owner is warned when no successful sync has occurred in 7 days while the device has had connectivity.

#### FR-99: Restore on a new device

The Owner can sign in on a new device and get their Business back. Realizes UJ-10.

**Consequences (testable):**
- Authenticating with the same phone number restores Business, Customers, Suppliers, Products, Inventory, all transactions and all Ledgers.
- Restore shows progress and the app is usable for reads as soon as the core entities have landed.
- The app states the timestamp of the most recent restored record, so the Owner knows what period is complete.
- Restoring never duplicates records that already exist locally.

**Feature-specific NFRs:**
- Local write to perceived confirmation: under 100 ms (TD §64).
- A restore of a Business with 12 months and ~20,000 transactions completes in under 3 minutes on a normal mobile connection. `[ASSUMPTION: target proposed here, not stated in the technical design.]`

---

### 4.16 AI: Ask Hisab, Daily Summary, Transaction Entry

**Description:** The differentiator, deliberately kept thin and deliberately kept out of the write path. Three capabilities: **Ask Hisab** answers questions about the Owner's own business in Bangla; **AI Daily Summary** turns the day's numbers into two or three sentences worth reading; **AI Transaction Entry** lets the Owner type a sentence in Bangla or Banglish and get a filled-in Transaction Draft to confirm. The governing constraint, from TD §1 and §43: **AI never writes financial data.** It reads, it drafts, it explains — and every transaction it proposes goes through the same validation and the same confirmation as one typed into a form. When the AI cannot answer from the Owner's data, it says so rather than inventing a number, because one hallucinated balance destroys the trust the whole product rests on. Realizes UJ-7, UJ-8.

**Functional Requirements:**

#### FR-100: Ask Hisab — question answering

The Owner can ask a question in Bangla or English about their own business and get an answer computed from their data. Realizes UJ-7.

**Consequences (testable):**
- Supports at minimum: best-selling Product for a period, who owes the most, total Sales/Expenses/Profit for a period, period-over-period comparison, slowest-moving Products, and largest Expense category.
- Answers are computed by executing bounded, parameterised queries against the Owner's data, never by the model recalling or estimating figures (TD §42).
- Every answer that contains a figure shows the figure's basis — the period and what was counted — expandable to the underlying list.
- A question outside the supported set returns an explicit "I can't answer that yet" with two examples of what can be asked, and never a fabricated number.
- Answers are in the app's current language.
- Requires connectivity; offline, the feature states that clearly rather than failing opaquely.

#### FR-101: Ask Hisab — scope and safety

Ask Hisab answers only about the Owner's own Business and only about the past.

**Consequences (testable):**
- Every query is scoped server-side to the authenticated Owner's Business (TD §51); no prompt content can widen that scope.
- Requests for forecasts, predictions or advice on future performance return an honest refusal in MVP, not an estimate.
- The AI never states a Customer Balance, Money Account balance or Profit figure that disagrees with what the corresponding screen shows.
- AI request and response content excludes Customer phone numbers and Business address (TD §43).

#### FR-102: AI Daily Summary

The Owner receives a short written summary of their business day. Realizes UJ-5.

**Consequences (testable):**
- Generated once per day for days with at least one transaction, available on demand from Home and offered as an evening notification (subject to FR-91 limits).
- Contains the day's Sales, Expenses, Collection and new credit given, plus at most two observations grounded in the data — for example the best-selling Product, or a Product likely to run out based on recent depletion.
- Every number in the summary matches FR-78's daily summary exactly.
- Observations are generated only where the underlying data supports them; a quiet day produces a short summary, not a padded one.
- The summary is stored and viewable for the past 30 days.

#### FR-103: AI Transaction Entry — drafting

The Owner can type a sentence describing a transaction and receive a Transaction Draft. Realizes UJ-8.

**Consequences (testable):**
- Accepts Bangla, English and mixed Banglish input, including transliterated numbers and common shop vocabulary.
- Supports drafting: a Sale with optional partial payment, a Customer Payment, a Supplier Payment, and an Expense. Purchases are supported where a Supplier and amount are identifiable. `[ASSUMPTION: this is the MVP intent set; broader parsing is Advanced (§6.2).]`
- Resolves the named Customer, Supplier or Product against existing records; an exact single match is applied, and no match offers inline creation.
- Produces a Transaction Draft with every field visible and editable before saving.
- The Draft shows the Party's current Balance and what it would become, so the Owner can sanity-check the outcome.

#### FR-104: AI Transaction Entry — confirmation gate

No AI-drafted transaction is saved without explicit Owner confirmation. Realizes UJ-8.

**Consequences (testable):**
- A Transaction Draft has zero financial effect until the Owner taps Save.
- On Save, the Draft is submitted through the same API and the same validation as a form-entered transaction (TD §39); there is no AI-specific write path.
- Every field of a Draft is editable before saving.
- The saved transaction is indistinguishable from a form-entered one in the Ledger and reports, but is tagged with its origin for analytics (FR-115).
- Discarding a Draft leaves no record other than an analytics event.

#### FR-105: AI Transaction Entry — ambiguity handling

Where the AI cannot resolve an entity or an amount with confidence, it asks rather than guesses. Realizes UJ-8.

**Consequences (testable):**
- Two or more Customers matching the named person produce a disambiguation prompt showing each candidate's current Balance; the app never picks one.
- An unparseable or partially parseable input produces a partially filled Draft with the missing fields empty and highlighted, not a Draft with invented values.
- Confidence below the configured threshold on any monetary amount blocks the Draft's Save until the Owner confirms that field explicitly.
- No Draft is ever produced with a Product, Customer or Supplier that does not exist in the Owner's data unless the Owner is explicitly offered the option to create it.

#### FR-106: AI availability and degradation

AI features degrade honestly when unavailable.

**Consequences (testable):**
- Offline, all three AI features show a clear state saying they need a connection; core transaction entry remains fully available.
- On AI service failure or timeout, the Owner is told and offered the equivalent form flow in one tap.
- AI features are behind a feature flag (TD §70) and can be disabled remotely without an app release.
- No AI failure can block, delay or corrupt a transaction entered by form.

#### FR-107: AI usage limits

AI usage is metered per Business and enforced against the Plan.

**Consequences (testable):**
- Each Ask Hisab question and each AI Transaction Entry draft counts as one AI request.
- The Free Plan permits a limited number of AI requests per month; Pro permits a higher limit (§4.17, §11).
- Reaching the limit shows what the limit is, when it resets, and what Pro offers — and never silently degrades answers.
- Limits are enforced server-side (TD §69).
- The AI Daily Summary does not count against the Owner's request limit.

#### FR-108: AI transparency

The Owner can tell what is AI-generated.

**Consequences (testable):**
- Ask Hisab answers, AI Daily Summaries and Transaction Drafts are visually marked as AI-generated.
- Settings explains in plain Bangla what AI features do with the Owner's data and that AI never records a transaction on its own.
- The Owner can turn AI features off entirely; with them off, no business data is sent to the AI service.

**Feature-specific NFRs:**
- Ask Hisab and AI Transaction Entry respond within 4 seconds at p95 (TD §64); beyond 8 seconds the request is abandoned and the form fallback offered.
- AI features never write to the local or server database except through the standard transaction API.

**Notes:**
- `[NOTE FOR PM]` FR-103 to FR-105 are the product's differentiator and its largest execution risk: Banglish parsing quality with real shop vocabulary is unproven. Recommend an early spike against transcribed real utterances before committing the MVP timeline (§14 R-2).

---

### 4.17 Subscription Foundation

**Description:** The plumbing that makes monetization possible later, without the payment integration that would slow the MVP down. Plans, usage limits and server-side enforcement exist and work; upgrading is handled manually by the Hisab team during validation. The purpose is to avoid the far more painful alternative — retrofitting limits onto a population of users who have never had them.

**Functional Requirements:**

#### FR-109: Plans and entitlements

Every Business is on a Plan that determines its Usage Limits.

**Consequences (testable):**
- Two Plans in MVP: Free and Pro. Every Business starts on Free.
- Plan determines limits on: number of Customers, number of Products, AI requests per month. `[ASSUMPTION: transaction count is deliberately not limited — capping the core action would break trust. Confirm with Tanim; §15 Q6.]`
- Entitlements are resolved server-side and cached on device for offline enforcement of read-only display; the authoritative check is always server-side (TD §69).

#### FR-110: Limit enforcement

Reaching a Usage Limit is communicated clearly and never destroys data.

**Consequences (testable):**
- Attempting to exceed a limit shows what the limit is, the current usage, and what Pro provides.
- Existing data is never deleted, hidden or made read-only because of a limit.
- Recording Sales, Payments, Expenses and Purchases is never blocked by a Plan limit.
- Limits are enforced server-side; a manipulated client cannot exceed them on sync, and a record rejected for a limit is surfaced to the Owner rather than dropped.

#### FR-111: Plan status and upgrade interest

The Owner can see their Plan, their usage, and register interest in upgrading.

**Consequences (testable):**
- Settings shows current Plan, usage against each limit, and what Pro includes.
- An Upgrade action records interest and shows how to complete an upgrade with the Hisab team; no in-app payment in MVP.
- Interest events are captured for analytics (FR-115) and are the primary willingness-to-pay signal during validation (SM-6).

#### FR-112: Manual Plan assignment

Hisab staff can move a Business between Plans without an app release.

**Consequences (testable):**
- Plan changes take effect on the device at the next sync, within 5 minutes of the change while online.
- A Plan change is recorded as a SubscriptionEvent with actor and timestamp (TD §69).

---

### 4.18 Settings, Data and Support

**Description:** The unglamorous surface that makes the rest safe to rely on: language, notifications, business details, data export, and the audit trail that lets a disputed number be traced.

**Functional Requirements:**

#### FR-113: Business settings

The Owner can edit their Business details and Money Account opening balances after setup.

**Consequences (testable):**
- Business name, type and address are editable; changes appear on subsequent Receipts and immediately on Home.
- Opening Balances are editable per FR-4 and are audited.

#### FR-114: App settings

The Owner can control language, app lock, notifications and AI.

**Consequences (testable):**
- Language (FR-8), app lock (FR-7), notification preferences (FR-92) and AI on/off (FR-108) are all reachable from one Settings screen.
- Settings changes persist across devices via Sync, except app lock, which is per device.

#### FR-115: Analytics

Hisab records product events to inform the roadmap, without exporting financial detail.

**Consequences (testable):**
- Events recorded: app_opened, business_created, customer_created, sale_created, payment_recorded, expense_created, product_created, purchase_created, report_viewed, ai_question, ai_transaction_drafted, ai_transaction_confirmed, ai_transaction_discarded, receipt_shared, reminder_sent, upgrade_interest (TD §71).
- Events carry Business identifier, timestamp and non-financial dimensions only. Monetary amounts, Customer names, Supplier names, Product names and phone numbers are never sent to analytics (TD §71).
- The Owner can opt out of analytics in Settings.

#### FR-116: Data export

The Owner can export their own data.

**Consequences (testable):**
- CSV export of Customers, Suppliers, Products, Sales, Purchases, Payments and Expenses for a chosen date range.
- Export is generated and shared through the OS share sheet.
- Export is available to all Plans — the Owner's data is theirs regardless of what they pay.

#### FR-117: Audit trail

Financially significant changes are recorded and inspectable.

**Consequences (testable):**
- Creation, edit and deletion of Sales, Purchases, Payments, Expenses, Returns, stock adjustments and balance adjustments are recorded with actor, timestamp, device and the before/after values (TD §53).
- Deleted transactions are soft-deleted and remain in the trail.
- The Owner can view the change history of any individual transaction from its detail screen.

#### FR-118: Help and support

The Owner can get help without leaving the app.

**Consequences (testable):**
- A short Bangla help section covering the core flows.
- A contact action (phone or WhatsApp) reaching Hisab support.
- App version and a copyable diagnostic identifier are visible for support conversations.

#### FR-120: Account and data deletion

The Owner can delete their account and all their Business data from inside the app.

*Both Apple and Google require an in-app account-deletion path for any app that supports account creation; this is a store-submission gate, not a product choice, which is why it is specified here rather than left as an open question.*

**Consequences (testable):**
- Reachable from Settings in at most three taps, without contacting support and without leaving the app.
- Before deleting, the Owner is shown exactly what will be destroyed — Business, Customers, Suppliers, Products, every transaction and every Ledger — with counts, and is offered a CSV export (FR-116) in the same screen.
- Deletion requires re-authentication by OTP, not just a confirmation tap.
- Deletion is soft for 30 days, during which signing in again restores everything and the Owner is told how long they have left. After 30 days it is irreversible, and the app says so before the Owner commits.
- On confirmation the local database is wiped immediately, including any Pending Sync records, and the device is signed out.
- After the retention window, all personal and business data is purged server-side. Anonymous, non-reversible analytics aggregates may be retained (FR-115).
- The same phone number can register a fresh account afterwards and gets an empty Business, never the deleted one's data.
- A deletion in progress is visible in the web admin so support can answer questions about it (§12).

---

## 5. Non-Goals (Explicit)

What Hisab is not, and will not become in v1. These exist to stop the "while we're in here, let's also…" failure mode at epic, story and code level.

- **Hisab is not accounting software, and must not be positioned or built as such.** No double-entry journals, no chart of accounts, no trial balance, no statutory reporting. The Owner never sees the word "debit" in English or an accounting concept they did not ask for. Profit is an operating estimate, labelled as one.
- **Hisab is not a tax or VAT tool.** No VAT calculation, no NBR filing, no tax reports. A shop that needs these needs an accountant, and Hisab's export (FR-116) is what they give them.
- **Hisab is not a payment processor.** It records that money moved via bKash, Nagad, Rocket or bank; it never initiates, requests, holds or settles a payment. No provider APIs, no wallet integration, no payment links in MVP.
- **Hisab is not a messaging platform.** Reminders are drafted for the Owner and sent from the Owner's own WhatsApp or SMS app. Hisab operates no SMS gateway and no WhatsApp Business API in MVP, and never messages a Customer autonomously.
- **Hisab is not a POS system.** No cash drawer, no thermal printer integration, no barcode-scanner-driven checkout, no customer-facing display.
- **Hisab is not a multi-branch or multi-company platform.** One User, one Business, one location.
- **Hisab is not a team tool.** No employee accounts, no roles, no permissions, no approval workflows.
- **Hisab is not an e-commerce or order-management system.** No purchase orders, sales orders, online order intake, courier integration or delivery tracking.
- **AI is not the system of record and must never become a write path.** No AI feature may create, modify or delete financial data without explicit per-transaction Owner confirmation through the standard API. This is a hard architectural boundary, not a preference (TD §1, §43).
- **Hisab is not a forecasting tool in v1.** No cash-flow prediction, no demand forecasting, no anomaly detection, no churn scoring — because getting them wrong early costs more trust than getting them right earns.
- **Hisab does not aim to be an ERP.** Payroll, manufacturing, procurement workflows and CRM are all out (TD §2).
- **Hisab is not multi-currency.** BDT only.

## 6. MVP Scope

### 6.1 In Scope

- Phone + OTP authentication; single Owner per Business; guided business setup with Opening Balances (§4.1)
- Home dashboard with today's figures, Receivable, Payable, Low Stock, Money Accounts, and six Quick Actions (§4.2)
- Customer management and Customer Ledger, including the বাকি দিলাম fast path (§4.3)
- Supplier management and Supplier Ledger (§4.4)
- Sales — cash, credit and partial payment, itemised or not, with edit, delete and receipt (§4.5)
- Purchases, with stock and Supplier Balance effects (§4.6)
- Products, Inventory, FIFO Cost Layers, Stock Movements, Low Stock, manual adjustment, damage, product performance, and **CSV/XLSX catalogue import** (§4.7)
- Expenses with categories, recurring-expense reminders, and Owner withdrawal as a distinct concept (§4.8)
- Customer and Supplier Payments, five Money Accounts, seven Payment Methods, Account Transfers (§4.9)
- Sales Returns and Purchase Returns (§4.10)
- PDF and image Receipts and Ledger statements, shared via the OS share sheet (§4.11)
- Six reports — daily summary, sales, expenses, profit, dues, inventory — with integrity disclosures (§4.12)
- Global search across all entities (§4.13)
- Due-payment reminder list and per-Customer reminder schedules; four notification types (§4.14)
- Offline-first recording of every transaction type; automatic sync; conflict surfacing; cloud backup; new-device restore (§4.15)
- AI: Ask Hisab, AI Daily Summary, AI Transaction Entry — read-and-draft only, behind feature flags (§4.16)
- Subscription foundation: Free and Pro Plans, server-side usage limits, manual plan assignment, no in-app payment (§4.17)
- Settings, CSV export, analytics with financial data excluded, audit trail, in-app help, **in-app account and data deletion** (§4.18)
- Android and iOS from the same Flutter codebase, released together (§12)
- Internal web admin for support, business lookup, plan assignment and feature flags (§12)

### 6.2 Out of Scope for MVP

Deferred, with the reason where it matters. Everything below is drawn from `docs/features/02_Hisab_Advanced_Features.md`.

**Deferred to v2 (next after MVP validation)**

- **Voice Hisab** (Bangla/Banglish speech to transaction) — the highest-value deferred item and the strongest differentiator. Deferred because text-based AI Transaction Entry (FR-103) must prove its parsing quality first; voice adds STT error on top of parsing error. `[NOTE FOR PM: emotionally load-bearing — this is the demo that sells the product. Revisit the moment FR-103 hits its accuracy target.]`
- **Barcode scanning** — camera scanning of product barcodes. The barcode *field* exists in MVP (FR-46) so data entered now stays useful.
- **Employee accounts, roles and permissions** — the data model retains BusinessMember and role so this is additive, not a migration.
- **Automated payment reminders** — SMS gateway and WhatsApp Business API. MVP drafts, the Owner sends.
- **Recurring transactions beyond monthly Expenses.**
- **AI weekly and monthly report generation.**
- **Smart inventory forecasting and reorder suggestions.**
- **Daily cash closing / cash reconciliation** — the *মিলিয়ে দেখা* flow from the detailed spec §44. Deferred because it matters most to shops with cashiers, which are also the shops needing employee accounts.

**Deferred to v3+**

- Multi-branch, branch inventory, inter-branch transfers, consolidated reporting
- Purchase orders, sales orders, customer order management, courier integration
- Digital payment integrations (bKash/Nagad APIs) and in-app subscription billing
- Multi-currency
- Expense approval workflow, audit-log UI beyond per-transaction history
- AI cash-flow forecasting, sales forecasting, anomaly detection, customer churn detection
- Advanced P&L, cash-flow statements, balance-sheet reporting, tax/VAT support, accountant portal
- Loyalty programs, promotions and discount campaigns
- Advanced customer and product analytics, business benchmarking
- Device/session management, remote logout, suspicious-login detection
- Customizable dashboard

## 7. Success Metrics

Measured over the 90 days following public release, unless stated.

**On the targets.** Tanim confirmed these as written (§15 Q2 closed). They remain *unbenchmarked* — no comparable Bangladesh SMB app data was available to set them against — so they are a stated intent, not a validated prediction. Treat a miss in the first cohort as information about the target as much as about the product, and re-baseline after 90 days rather than reacting to a single number.

**Primary**

- **SM-1: Time to first recorded transaction.** Median elapsed time from first app open to the first saved Sale, Payment or Expense. Target: **under 5 minutes**. Validates FR-1 through FR-5, FR-13.
- **SM-2: Transaction entry speed.** Median time from tapping a Quick Action to a saved transaction, for a Sale with one to three items. Target: **under 20 seconds**; p90 under 45 seconds. This is the product's core promise and the one MVP success criterion stated in the source docs. Validates FR-30 through FR-33, FR-38, FR-62.
- **SM-3: Week-4 retention.** Share of Businesses that record at least one transaction in week 4 after activation. Target: **35%**. A shop that is still recording after a month has replaced the khata; one that is not, has not. Validates the product as a whole.
- **SM-4: Ledger reliance.** Share of retained Businesses with at least 10 Customers carrying a non-zero Balance by day 30. Target: **50%**. Customer ledger is the stated heart of the product; this measures whether it is actually being used as such. Validates FR-15 through FR-23.

**Secondary**

- **SM-5: AI Transaction Entry confirmation rate.** Share of Transaction Drafts saved without any field being edited. Target: **60%**; a Draft that always needs correcting is slower than the form and will be abandoned. Validates FR-103 through FR-105.
- **SM-6: Willingness to pay.** Share of Businesses active at day 30 that trigger upgrade interest (FR-111). Target: **15%**. The primary monetization signal in the absence of billing.
- **SM-7: Offline reliability.** Share of transactions recorded offline that reach the server successfully. Target: **99.9%**, with zero unexplained losses. Validates FR-93 through FR-99.
- **SM-8: Reminder-to-collection.** Share of reminders sent (FR-89) followed by a Customer Payment from that Customer within 7 days. Target: **25%**.
- **SM-9: Ask Hisab answer rate.** Share of Ask Hisab questions answered with a figure rather than a refusal. Target: **70%**, with the refusals concentrated in genuinely unsupported question types. Validates FR-100.

**Counter-metrics (do not optimize)**

- **SM-C1: Notification volume per active Business per week.** Must stay **at or below 10**. Counterbalances SM-3 and SM-8 — retention and collection metrics both create pressure to notify more, and the predictable result is that notifications get disabled and the reminders that matter stop arriving.
- **SM-C2: Non-itemised Sale share.** Share of Sales recorded via বাকি দিলাম with no Sale Items. Counterbalances SM-2 — optimizing entry speed pushes Owners toward the non-itemised path, which silently destroys the accuracy of Gross Profit (FR-83) and every Product-level report. Watch it; do not drive it to zero either, since the fast path is deliberate.
- **SM-C3: AI-originated share of transactions.** Counterbalances SM-5. A rising share is good only while SM-5 stays high; a high AI share with a falling confirmation rate means Owners are accepting Drafts without checking them, which is the failure mode that puts wrong numbers in the ledger.
- **SM-C4: Balance dispute contacts.** Support contacts where an Owner reports that a Balance is wrong. Must trend to zero. Counterbalances every speed metric. One wrong balance in front of a customer costs more trust than ten seconds saved earns.

## 8. Cross-Cutting Non-Functional Requirements

Beyond feature-specific NFRs stated in §4.

**Performance** (targets from TD §64)

- API p95 under 500 ms; local transaction write to perceived confirmation under 100 ms; search under 300 ms; Home under 1 second; AI response under 4 seconds p95.
- Every one of these must hold on a mid-range 2023 Android device on a 3G connection, not on a flagship on wifi.
- App cold start to interactive Home: under 3 seconds.
- APK size under 40 MB. `[ASSUMPTION: proposed; matters for users on metered data and low-storage devices.]`

**Reliability and correctness**

- Financial writes are atomic and transactional end to end (TD §31). A partially applied Sale — stock moved but ledger not, or the reverse — is a defect of the highest severity.
- Every derived figure must be reproducible from its underlying records: Party Balance from Ledger Entries, Inventory from Stock Movements, Money Account balance from movements. Any drift between a stored aggregate and its derivation is a P0 defect.
- Idempotency on every write endpoint, so retries after a dropped connection cannot double-post (TD §32).
- No data loss under app kill, device restart, storage pressure or force-quit mid-write.

**Offline**

- The app is fully functional for all transaction recording, all reads and all reports with zero connectivity, for an unbounded period, limited only by device storage.
- Sync queue survives app termination and device restart.

**Security**

- All traffic over TLS. Credentials in platform secure storage, never in shared preferences or plain files (TD §36).
- Every API request is scoped server-side to the authenticated User's Business; no client-supplied identifier can widen that scope (TD §51).
- Local database is encrypted at rest. `[ASSUMPTION: proposed — the technical design does not state local encryption. It matters because a stolen phone (UJ-10) carries the shop's full financial history.]`
- OTP endpoints are rate-limited per number and per IP (FR-1).

**Accessibility and device reality**

- Minimum touch target 48×48 dp throughout; primary Quick Actions larger.
- Legible at the largest system font size without truncation or overlap on a 5-inch screen.
- Usable one-handed for the six Quick Action flows.
- Sufficient contrast for a screen viewed in daylight at a shop front.
- Android 8.0+ and iOS 14+. `[ASSUMPTION: proposed floor; needs checking against Bangladesh device distribution.]`

**Localisation**

- Complete Bangla coverage: every string, error message, notification, Receipt and report. An untranslated English string in a user-facing surface is a defect, not a polish item.
- Bangla renders with correct conjuncts on device and in generated PDFs, which requires an embedded font (§4.11 NFRs).
- Asia/Dhaka is the business day boundary for all "today" calculations.

**Observability**

- Sync failures, financial-write failures, AI failures and crashes are reported with enough context to diagnose without the Owner's data (TD §63).
- A dashboard exists for sync queue depth, sync failure rate and financial-write error rate before launch.

## 9. Constraints and Guardrails

**Financial integrity (the hard boundary)**

- AI never writes. Every transaction, whatever its origin, is created through the same validated API path with explicit Owner confirmation (FR-104, TD §1, §43).
- **Financial transactions are immutable** (TD §15). Ledgers and Stock Movements are append-only, and every correction is a reversal plus a new entry — never an in-place edit or a deletion of history (FR-23, FR-36, FR-37, FR-52). The Owner sees "Edit" and "Delete"; the system writes reversals.
- Nothing is erased. Voided transactions stay visible and traceable. Receipt numbers are never reused (FR-30, FR-37).
- Every financially significant action is attributable — actor, timestamp, device, before and after (FR-117).

**Privacy**

- The Business's financial data belongs to the Owner. It is never shared, aggregated across businesses, or sold. Benchmarking against other businesses is out of scope and would require explicit consent if ever introduced.
- Customer phone numbers are collected to enable reminders and are never used for anything else, never messaged by Hisab directly, and never sent to the AI service (FR-101).
- Analytics carries no monetary amounts and no personal names (FR-115).
- Data sent to the AI provider is limited to what a query requires, is not used for model training, and is disclosed to the Owner in plain Bangla (FR-108). `[ASSUMPTION: no-training is a requirement on the provider contract; confirm it is achievable with the intended provider.]`
- The Owner can export everything (FR-116) and can delete their account and all their Business data from inside the app, with a 30-day grace period and an irreversible purge after it (FR-120).

**Cost**

- AI cost per Business per month must stay within the Pro price point's gross margin, which is what makes FR-107's metering non-negotiable rather than a nicety.
- Ask Hisab answers are computed by parameterised query rather than by feeding ledgers to a model, which bounds both cost and hallucination risk (TD §42).
- SMS OTP is a per-message cost and a fraud target; FR-1's rate limits are cost control as much as security.

**Regulatory**

- Hisab records payments, it does not process them, so it is not a payment service provider and needs no such licence — a boundary the product must not drift across without legal review.
- Both app stores' data-safety declarations must accurately describe the financial data collected and the AI processing performed.

## 10. Information Architecture

Three bottom-navigation destinations and a central action button. Decided by Tanim after `bmad-ux` drew both candidates; the five-tab split originally proposed here was rejected.

**হোম | খাতা | ⊕ | আরও**

- **হোম (Home)** — dashboard: today's figures, Receivable, Payable, Low Stock, Money Accounts (§4.2)
- **খাতা (Ledger)** — Customers, Suppliers, both Ledgers, Payments, the dues list (§4.3, §4.4, §4.9)
- **⊕ (Record)** — the centre button. Opens the six Quick Actions as a sheet, from any tab (§4.2, FR-13)
- **আরও (More)** — Sales, Purchases, Products, Inventory, Expenses, Reports, Ask Hisab, Settings, Help (§4.5–§4.8, §4.12, §4.16, §4.18)

**Why this shape.** Recording is the app's job, so it gets the largest target on screen and is reachable from every tab rather than only from Home — which is what SM-2 (a saved Sale in under 20 seconds) actually turns on. Three Bangla labels also breathe where five do not, and label truncation at large accessibility sizes was the first thing to break in the five-tab version.

**What it costs, stated plainly.** বিক্রি, পণ্য and রিপোর্ট lose their permanent home and move under আরও, so browsing sales history or the product list is one tap deeper than it was. The centre-button convention is also learned rather than obvious, and may not be one a first-time shop owner has. Both are worth watching in the first usability round.

Global search is reachable from হোম and from every list. MVP is targeted at roughly 25–30 screens; the detailed spec's guidance of "12–15 major screens" refers to primary destinations, and this PRD's FR set implies that many primaries plus their detail and entry screens.

## 11. Monetization

Free and Pro only in MVP; the third Business tier from the source docs arrives with employee accounts and multi-branch, both of which are deferred.

| | Free | Pro |
|---|---|---|
| Businesses | 1 | 1 |
| Users | 1 | 1 |
| Customers | up to 100 | unlimited |
| Products | up to 50 | unlimited |
| Transactions | unlimited | unlimited |
| Ledgers, Sales, Purchases, Expenses, Payments | ✓ | ✓ |
| Inventory and stock tracking | ✓ | ✓ |
| Reports | daily summary only | all six |
| PDF Receipts | ✓ | ✓ |
| Cloud backup and multi-device | ✓ | ✓ |
| Ask Hisab | 20 requests/month | 300 requests/month |
| AI Transaction Entry | 20 requests/month | shared with above |
| AI Daily Summary | ✓ | ✓ |

Indicative Pro price: **৳199–299/month**, to be validated with real users rather than fixed now. No in-app purchase in MVP; upgrade interest is captured (FR-111) and fulfilled manually. Cloud backup is deliberately *not* gated — an Owner losing their হিসাব because they were on the free tier would be the single most damaging thing the product could do to its reputation.

**The limit numbers above are placeholders.** Tanim deferred the decision to just before store submission (§15 Q6). What this means for the build: FR-109 and FR-110 must treat every limit as server-side configuration, changeable without an app release and without a migration. No limit may be compiled into the client. Build it that way and the deferral costs nothing; hardcode a single number and the decision becomes a release.

## 12. Platform

- **Android and iOS ship together at launch**, from one Flutter codebase (TD §5). Decided by Tanim, overriding a phased Android-first recommendation; the cost is iOS review cycles, TestFlight distribution and iOS device testing inside the same timeline, and it should be reflected in the sprint plan.
- **Android 8.0+ / iOS 14+** `[ASSUMPTION]`, phone form factor. Tablet is not a target; layouts should not break on one.
- **Internal web admin** (Next.js, TD §8) is in MVP scope but is a staff tool, not a user surface: business lookup for support, manual Plan assignment (FR-112), feature-flag control (FR-106) and system monitoring. It has no Owner-facing features and does not need design polish.
- **No web app for Owners** in MVP.
- Both stores' listings, data-safety declarations and Bangla store copy are launch deliverables.

## 13. Aesthetic and Tone

**Voice.** Hisab speaks the way a trusted, literate friend explains money to a shopkeeper: direct, warm, never condescending, never clever. Every user-facing string states the outcome in the Owner's own words — *রহিমের বাকি ৳4,080 থেকে কমে ৳1,080 হলো* — rather than a status like "Payment recorded successfully". Numbers come with their meaning attached.

**Vocabulary — non-negotiable.** পাবেন / দিতে হবে, বাকি, বিক্রি, খরচ, লাভ, মালিকের উত্তোলন. Never receivable, payable, debit, credit, reconcile, or ledger in English in a user-facing surface. §3's Glossary is the internal vocabulary; the Bangla labels are the external one, and the mapping is fixed.

**Visual.** Large type and large targets, because the screen is read at arm's length in daylight with one hand. Money is the largest element on any screen it appears on. Colour carries meaning consistently: money coming in, money going out, warning. Iconography is literal — a shop, a person, a bag — not abstract fintech geometry.

**Anti-references.** Do not look like enterprise accounting software (dense tables, English jargon, tabbed forms). Do not look like a crypto or trading app (dark, dense, chart-forward). Do not lead with charts: the Owner wants a number and a sentence, and a chart is what you show after they ask why.

**AI tone.** Confident about what it computed, plainly honest about what it cannot do. It never apologises at length, never speculates, and never presents an estimate as a fact.

## 14. Risk and Mitigations

| ID | Risk | Impact | Mitigation |
|---|---|---|---|
| R-1 | **A wrong balance shown to a customer.** Any arithmetic, sync or conflict defect that puts a wrong number on screen destroys the trust the product depends on and returns the Owner to paper permanently. | Critical | Atomic financial writes (TD §31); derived figures always reproducible from their records (§8); the financial test suite in TD §68 as a release gate; SM-C4 monitored from day one. |
| R-2 | **Banglish parsing quality is unproven.** FR-103–105 is the differentiator; if Drafts are usually wrong, the feature is slower than the form and gets abandoned — taking the product's positioning with it. | High | Spike against transcribed real shop utterances before committing the timeline; ambiguity always asks rather than guesses (FR-105); SM-5 gates the feature's promotion; the feature flag (FR-106) allows shipping without it. |
| R-3 | **Catalogue onboarding is the drop-off point.** A grocery with 400 SKUs may never populate Products, which silently disables inventory, profit and product reports. | Medium *(was High)* | **CSV/XLSX import brought into MVP** (FR-119, Tanim's decision on Q1) — the primary mitigation. Plus inline creation everywhere (FR-46); the Ledger works fully with no Products at all; watch SM-4 against Product count in early cohorts. Residual risk: an Owner who has no spreadsheet to import, which a shop-type starter catalogue would address post-MVP. |
| R-4 | **Non-itemised Sales erode profit accuracy.** The বাকি দিলাম fast path is correct for entry speed and corrosive to every Product-level and profit figure. | Medium | Explicit disclosure in every affected report (FR-83); SM-C2 monitored; consider prompting for items on high-value non-itemised Sales post-MVP. |
| R-5 | **Sync conflicts on multi-device use.** Rare in a single-Owner MVP, catastrophic when they silently drop a transaction. | Medium | Documented resolution rules (TD §15); unresolvable conflicts surfaced, never discarded (FR-97); idempotent writes (TD §32); SM-7 at 99.9% with zero unexplained losses. |
| R-6 | **iOS and Android together compresses the timeline.** Simultaneous launch adds review cycles and device testing to a 16-week plan sized without them. | Medium | Reflect the real cost in sprint planning; keep the web admin deliberately minimal; treat store submission as a scheduled milestone, not an end-of-project task. |
| R-11 | **FIFO complexity, and its collision with negative stock.** FIFO (Q8) requires Cost Layers, layer consumption on every outward movement, layer restoration on every correction and return, and all of it computed on-device so COGS is right offline. It also has no defined answer when stock goes negative (FR-39), which the product deliberately permits. | High | Cost Layers specified as first-class in FR-52 with provisional costing and reconciliation for negative stock; explicit test coverage required in TD §68; decided before epic 4 so the schema carries it from the start rather than being retrofitted. **Worth a second look before epic 4 is cut** — Weighted Average removes this entire class of complexity, and the accuracy gain from FIFO is small where a grocery's purchase prices move slowly. |
| R-7 | **AI cost per Business exceeds the Pro margin.** Unmetered AI on a ৳199–299 price point can invert unit economics. | Medium | Server-side metering from day one (FR-107); parameterised queries rather than ledger-in-context (TD §42); provider abstraction (TD §7) to allow switching on cost. |
| R-8 | **SMS OTP cost and delivery.** Per-message cost, plus delivery reliability across BD operators, sits directly on the activation funnel (SM-1). | Medium | Rate limits (FR-1); test delivery across all operator prefixes before launch; have a fallback provider identified. |
| R-9 | **No in-app billing means monetization is unvalidated at launch.** Upgrade interest is a weaker signal than a completed payment. | Low–Medium | SM-6 as an explicit, watched metric; keep the billing integration scoped and ready to follow quickly if interest is strong. |
| R-10 | **Store rejection on financial-app or data-safety grounds.** Both stores scrutinise finance-category apps and AI data handling. | Low–Medium | Accurate data-safety declarations (§9); in-app account deletion specified as a store gate (FR-120); submit a build for review early rather than at the end. |

## 15. Open Questions

All ten questions from the first draft were answered by Tanim on 2026-08-29. What remains open is listed first; the closed decisions follow, kept here because downstream workflows need the reasoning, not just the verdict.

### Still open

- **Q6 — Free-tier limits. Deferred to just before store submission.** Owner: Tanim. Revisit condition: before the first store build is submitted. The build must not wait on it — FR-109 and FR-110 treat every limit as server-side configuration (§11), so the number can be set on the day. The only thing that would make this expensive is compiling a limit into the client.
- ~~**FR-30 gap-free receipt numbering**~~ *Closed 2026-08-29: gaps accepted. FR-30 relaxed to unique + ascending + never reused; architecture AD-15 stands as written.*
- **Q11 — Receipt-series prefixes.** `INV-` for Customer Sales and `CS-` for walk-in Sales are proposed in FR-30, not chosen. Cheap to change now, expensive after Owners have handed out receipts. Owner: Tanim, before epic 5.
- ~~**Q12 — Should catalogue import work offline?**~~ *Closed 2026-08-29: yes. FR-119 updated; the client carries the parser.*
- **Q13 — Is FIFO still the right call given what it costs?** Not a reopening of Q8, which is decided and specified. But R-11 quantifies the complexity FIFO adds — Cost Layers, offline layer computation, provisional costing for negative stock, layer restoration on every correction — and that complexity was not visible when the choice was made. Weighted Average removes all of it, and the accuracy difference is small where purchase prices move slowly, which is the common grocery case. Worth five minutes of reconsideration before epic 4 is cut; entirely reasonable to confirm FIFO and move on.

### Closed

| # | Question | Decision | Where it landed |
|---|---|---|---|
| Q1 | CSV / bulk product import in MVP? | **Yes** | New FR-119; §6.1; removed from §6.2; R-3 downgraded High → Medium |
| Q2 | Are the SM targets right for Bangladesh? | **Keep as proposed** | §7 — targets stand, explicitly marked unbenchmarked; re-baseline after 90 days |
| Q3 | Bangla or Western numerals? | **Follow the language setting** — Bangla digits in Bangla, Western in English | FR-8, rewritten; input accepts both scripts regardless of mode |
| Q4 | How much Bangla↔Latin matching? | **As much as possible** | FR-85, rewritten with a testable target: ≥95% top-3 recall on a 300-name corpus, run in CI; gates FR-103 too |
| Q5 | Should Damage reduce Net Profit? | **Yes** | FR-53, FR-81, FR-80, FR-82, Glossary; Damage is a costed line, Manual Adjustment stays non-financial |
| Q7 | Account and data deletion | **Added** — treated as a store-submission gate rather than a preference | New FR-120 |
| Q8 | COGS method | **FIFO** | Glossary (COGS, Cost Layer), FR-52, FR-81; new risk R-11 |
| Q9 | Separate receipt series for walk-in Sales? | **Yes** — two per-Business series | FR-30 |
| Q10 | Is 16 weeks realistic? | **Yes** | Accepted; R-6 stays a watch item for sprint planning, now with FR-119 and FR-120 added to scope |

## 16. Assumptions Index

Assumptions still awaiting confirmation. Nine of the first draft's twenty-one were closed by Tanim's answers and have been removed from this list rather than left to rot.

1. **§4.1 / FR-3** — Owner email is used only for recovery and Owner-initiated receipt emails, never for marketing.
2. **§4.1 / FR-6** — Sign-out is blocked while Pending Sync records exist, rather than silently discarding them.
3. **§4.5 / FR-30** — Receipt-series prefixes `INV-` and `CS-`. See Q11.
4. **§4.5 / FR-36** — A corrected Sale keeps the original's receipt number, so a receipt already handed to a customer stays valid.
5. **§4.5 / FR-39** — Selling below recorded stock is permitted with a warning, allowing negative Inventory, rather than blocked. *Now load-bearing: under FIFO this is the case with no Cost Layer to consume (FR-52, R-11).*
6. **§4.7 / FR-119** — Catalogue import requires connectivity. See Q12.
7. **§4.8 / FR-60** — Recurring Expenses never auto-post; the Owner confirms every one.
8. **§4.9 / FR-68** — Money Account balances may go negative with a warning rather than blocking the entry.
9. **§4.15** — Restore of ~20,000 transactions completes in under 3 minutes; target proposed here, not in the technical design.
10. **§4.15 / FR-97** — True sync conflicts are rare in a single-Owner MVP, but the requirement stands for the new-device case.
11. **§4.16 / FR-103** — The MVP AI intent set is Sale, Customer Payment, Supplier Payment, Expense, and Purchase where identifiable.
12. **§4.17 / FR-109** — Transaction count is deliberately not a Plan limit.
13. **§8** — APK under 40 MB; local database encrypted at rest; Android 8.0+ / iOS 14+.
14. **§9** — The AI provider contract can guarantee no training on Hisab data.
15. *(closed 2026-08-29)* §10's navigation is decided — three tabs plus a centre action button. See §10.
16. **§12** — Android 8.0+ / iOS 14+ floor needs checking against Bangladesh device distribution.

**Closed by Tanim on 2026-08-29:** numerals follow the language setting (was #3); Damage reduces Net Profit (was #5); CSV import is in MVP (was #6); transliteration matching is a first-class requirement with a measurable target (was #9); SM targets stand as proposed (was #14); account deletion is specified (was #17); free-tier limits deferred but built as configuration (was #19); COGS is FIFO; walk-in Sales get their own receipt series.
