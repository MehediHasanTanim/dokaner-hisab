---
name: Hisab
description: How Hisab behaves — IA, microcopy, component behaviour, states, interaction, accessibility, and the flows that carry the product's promises.
status: final
created: 2026-08-29
updated: 2026-08-29
sources:
  - _bmad-output/planning-artifacts/prds/prd-hisab-dokan-2026-08-29/prd.md
  - _bmad-output/planning-artifacts/prds/prd-hisab-dokan-2026-08-29/addendum.md
---

# Hisab — Experience Spine

Behaviour, structure and states. Visual identity lives in [DESIGN.md](./DESIGN.md) and is referenced here by token name as `{colors.money-out}`, `{components.ledger-row}`. Where a mock and these two spines disagree, the spines win.

Visual reference: the canvas in `.working/` — 39 screen artboards, a navigation A/B, and a design-system sheet. `Main.dc.html` is the only interactive one and carries the core sale flow as internal steps.

## Foundation

**Form factor.** Phone only. Android 8.0+ and iOS 14+, released together, one Flutter codebase. Portrait. Tablet is not a target and must not break. There is no owner-facing web surface; the Next.js admin is a staff tool with no design obligation beyond legibility.

**UI system.** Material 3, heavily themed. Components inherit M3 anatomy, states and accessibility behaviour; this document specifies only the delta. Where M3 and this document disagree on *behaviour*, this document wins; where they disagree on a detail neither specifies, take the M3 default rather than inventing one.

**The condition every decision is made against.** One-handed, at arm's length, in daylight, at a counter, with a customer waiting and the mobile data possibly gone. Every screen is fully functional offline; nothing shows a spinner or an error because the network is absent (FR-93, FR-94).

## Information Architecture

**Decided: বিকল্প খ — three tabs and a centre action button.** Both candidates were drawn and argued; Tanim chose খ. PRD §10 is updated to match, and PRD assumption #15 is closed.

- **হোম** — dashboard. Today's figures, receivable and payable, low stock, money accounts.
- **খাতা** — customers, suppliers, both ledgers, payments, the dues list. The heart of the product.
- **⊕** — the centre button, raised above the bar. Opens the six quick actions as a sheet **from any tab**, plus AI entry.
- **আরও** — sales, purchases, returns, products, inventory, catalogue import, expenses, reports, Ask Hisab, money accounts, settings, help.

The centre button is the point of the shape: recording is the app's job, so it is the largest target on screen and is never more than one tap away, from anywhere. That is what SM-2 turns on.

**The cost, which the build should watch.** বিক্রি, পণ্য and রিপোর্ট are no longer tab roots — they are pushed screens under আরও, one tap deeper than before. And the raised-centre-button convention is learned, not innate; an owner who has never used an app shaped this way may not read it as "record something". Both belong in the first usability round.

Global search is reachable from হোম and from every list. Depth is capped at three: tab → list → detail. A detail screen may open one modal or one bottom sheet; never two.

**Surface closure.** Every FR in PRD §4 lands on a surface, and every surface is reached by at least one flow below. Two deliberate merges: supplier list and supplier detail are exact structural mirrors of the customer equivalents and share their specifications; the receipt preview is a state of the sale rather than a destination.

## Voice and Tone

Hisab talks the way a literate friend explains money to a shopkeeper: direct, warm, never clever, never condescending. Brand voice is in DESIGN.md § Brand & Style; this is the microcopy contract.

**State the outcome, not the operation.** Not *Payment recorded successfully* but *রহিমের বাকি ৳৪,০৮০ থেকে কমে ৳১,০৮০ হলো*. Every confirmation names the number that changed and what it became.

**Fixed vocabulary — non-negotiable.** পাবেন · দিতে হবে · বাকি · বিক্রি · খরচ · লাভ · নষ্ট · মালিকের উত্তোলন · টাকার হিসাব. The words receivable, payable, debit, credit, reconcile and ledger never appear in English on a user-facing surface, in either language mode. PRD §3's Glossary is the internal vocabulary; this is the external one, and the mapping is fixed.

**Numbers carry their meaning.** A figure never appears without saying what it counts and over what period. লাভ is always আনুমানিক.

**Say what a number leaves out, in the same breath.** *এই মাসের ১১টি বিক্রি পণ্যের হিসাব ছাড়া লেখা — সেগুলোর ক্রয়মূল্য বের করা যায়নি.* This is the product's honesty contract and it is microcopy work, not a legal footnote.

**Warnings state the consequence, then allow the action.** *ব্যাংকে আছে ৳৮,৫০০ — এই টাকা দিলে হিসাব ঋণাত্মক হবে। তবু লেখা যাবে।* Hisab does not block the owner from recording what actually happened (FR-39, FR-68).

**No English accounting jargon reaches a Bangla surface — including the words that are not in the banned list.** FIFO is the case that caught this: the costing method is real and the profit report must name it, but it names it as *আগে যে মাল কেনা, সেটাই আগে বিক্রি*, not as an acronym. If a term has no plain Bangla rendering, that is a signal the screen is explaining the wrong thing.

**AI speaks confidently about what it computed and plainly about what it cannot do.** *এটা এখনো বলতে পারি না।* No apologising at length, no speculation, no estimate dressed as a fact.

## Component Patterns

Visual specs in DESIGN.md § Components; behaviour here.

**Quick action tile.** One tap opens its flow with no intermediate menu, from a cold app or a warm one, online or off. Labels are at most two words so they never truncate at the largest system font size — the constraint is on the wording, not the type. `+ বাকি দিলাম` opens the simplified credit path (FR-20), which is a different screen from `+ বিক্রি`, not a mode of it.

**Amount field.** Focus raises it to `{typography.scale.amount-lg}` in `{colors.accent}`. Accepts Bangla digits, Western digits and a mix regardless of language mode, and normalises on blur. Never auto-formats mid-keystroke — grouping appears on blur, because reformatting under the thumb loses the owner's place.

**Party picker.** Type-ahead over name and phone, matching across Bangla and Latin script in both directions (FR-85). Every result row shows the party's current balance, because the balance is how an owner tells two Rahims apart. An exact single match is applied silently; two or more matches always ask (FR-105) and never guess. "Create new" is always the last row, and creating inline returns to the flow with nothing lost.

**Ledger row.** Read-only. Tapping opens the transaction that produced it. The running balance column is heavier than the rest and the final row's balance is heaviest — the eye should land on "what is the position now" first and read upward for why.

**Chip group.** Single-select for payment method, category, date range; multi-select for report filters. The last-used option in each flow is pre-selected. Selected state is a fill change (DESIGN.md), never a border change.

**Disclosure banner.** Appears inline at the point of consequence — inside the বাকি দিলাম screen, not in a help page. It is never dismissible, because the consequence is permanent.

**Confirmation summary.** Every money flow ends with a card stating: the amount, the effect on the party's balance from-and-to, and the effect on the money account. Three effects, three lines, before the save button — not after it.

## State Patterns

**Offline is not a state.** Every screen behaves identically with no connection. There is no offline banner, no greyed control, no retry prompt. The only acknowledgement is the pending-sync indicator (below). This is the single most important behavioural rule in the product.

**Pending sync.** A persistent, unobtrusive count — *১৪টি এন্ট্রি সিঙ্ক হয়নি* — absent at zero, and a `{colors.money-out}` dot on affected list rows. Tapping opens the sync screen with the queued entries and a manual trigger. The indicator distinguishes *waiting for a connection* from *sync is failing*, and the failing state says what to do.

**Loading.** Screens render from the local database and do not have a loading state. Where server data arrives later it updates in place with no reload and no scroll jump. The only true spinners in the product are: an AI response, a catalogue import, and a restore on a new device — all three long, all three explicitly asked for.

**Empty.** Empty states name the first action and nothing else. No illustration, no explanatory paragraph. A ledger with no entries says *এখনো কোনো লেনদেন নেই* over a `+ বাকি দিলাম` button. The low-stock panel hides entirely rather than showing "no low stock" — a panel that is usually empty teaches the owner to ignore that region.

**Negative and unusual values.** A negative money account balance renders in `{colors.money-out}` with a warning treatment, never hidden and never blocked (FR-68). A negative party balance renders as an advance — *৳৯২০ জমা আছে* — not as a minus sign. Negative stock renders as শেষ with the true number visible on the product detail.

**AI states.** Generated content always sits on `{components.ai-surface}` and always carries a label. A Transaction Draft has no financial effect until saved and says so. A field the AI could not fill is empty and highlighted, never invented. A low-confidence amount blocks save until the owner confirms that field explicitly. On failure or timeout, the equivalent form flow is offered in one tap (FR-106).

**Correction.** The owner sees *সংশোধন* and *বাতিল*; the system writes reversals (PRD FR-36, FR-37, TD §15). The ledger shows the original line, its reversal and the correction — all three. This is surfaced, not hidden, because a traceable correction is what makes a disputed balance defensible.

## Interaction Primitives

- **One tap to record.** From হোম, a quick action opens its flow directly. From a party's detail, the two money actions are primary buttons. Nothing that records money is more than two taps from where the owner already is.
- **Confirmation before consequence, never after.** The from-and-to summary appears above the save button on the same screen. There are no confirmation dialogs for saves — the summary *is* the confirmation. Dialogs are reserved for deletion and for account deletion.
- **Backdating yes, future-dating no,** on every transaction.
- **Sheets, not new screens,** for anything the owner will do and dismiss: reminder drafts, payment-method pickers, share options. Sheets are one level deep.
- **Nothing auto-posts.** Recurring expenses remind; the owner confirms (FR-60). AI drafts; the owner saves (FR-104). Hisab never writes money on its own, and never sends a message on the owner's behalf (FR-89).
- **Undo is not offered.** Corrections are reversals and are permanent record. Offering undo would imply history can be erased, which is exactly the promise the product cannot make.

## Accessibility Floor

Visual contrast is DESIGN.md's; behaviour is here.

- 48dp minimum hit target throughout; 54px for primary actions and 80px for quick actions.
- Every flow in § Key Flows completable one-handed on a 5-inch screen.
- Full layout integrity at the largest system font size — no truncation, no overlap, no clipped Bangla label. Labels shorten before type does.
- Every interactive element has a Bangla accessible label. Icon-only controls (back, search, share) carry labels even though they show no text.
- Colour is never the only carrier of meaning: money in and out differ by sign and position as well as colour; low stock carries a word as well as an amber.
- Screen-reader order follows visual order; the amount is read before its label in summary cards, matching the visual hierarchy.
- Reduced-motion honoured; no animation is load-bearing.

## Inspiration & Anti-patterns

**With the grain of:** a paper khata — ruled lines, running balance in the right-hand column, the position readable at a glance. Receipt printers, for the receipt. Physical cash boxes, for the way money accounts are kept visibly separate.

**Deliberately against:** accounting software (dense tables, English jargon, tabbed forms, a chart of accounts the owner never asked for); consumer fintech (dark chrome, gradients, abstract geometry, charts before numbers, streaks and gamification); and any pattern that makes the owner feel the tool is not for them.

**Specifically rejected:** a dashboard of charts on হোম; category colour-coding; an onboarding carousel; a celebratory animation on saving a sale (the owner does this ninety times a day); and a persistent AI assistant button on every screen — AI is a place the owner goes, not a thing that follows them.

## Open Decisions

**Navigation — closed 2026-08-29.** বিকল্প খ chosen. Both candidates remain on the canvas as the record of what was weighed; ক (five tabs) is the rejected option and should not be reintroduced without revisiting that argument.

**Still to be settled by testing, not by this document:** whether owners read the raised centre button as *record something*. It is the one real risk in বিকল্প খ, and no document can answer it.

**Two things that should be settled by testing, not by this document** (PRD §15 Q3 is now decided, these are not): whether the six quick actions are the right six, and whether the setup flow's skippable opening-balance step (FR-4) is skipped often enough to matter. Both are first-usability-round questions.

## Key Flows

Numbered to mirror PRD §2.3's journeys verbatim — UJ IDs are the same objects. The eight below are the flows whose interaction design carries a PRD success metric or a risk; UJ-4, UJ-7 and UJ-10 are specified by the screens alone.

### UJ-1 — Rahman sets up his shop (SM-1: under 5 minutes to first transaction)

1. Phone number → OTP, six boxes, visible countdown, resend at 60s.
2. Business name and type — one screen, ten type chips, address optional and visibly so.
3. Owner name.
4. **Opening balances** — one row per money account, each empty rather than zero so a blank is distinguishable from a deliberate zero, with a live total.
5. **Climax:** হোম appears with his shop's name and his own numbers. Nothing is sample data.

The skip on step 4 is present but priced: *পরে দিই — তাহলে টাকার হিসাব অসম্পূর্ণ থাকবে*. Skipping is a decision the owner makes knowingly, not a default they fall through.

### UJ-2 — A sale on credit, in under twenty seconds (SM-2)

1. হোম → `+ বিক্রি`.
2. Party picker; two keystrokes find রহিম, his balance shown on the row.
3. Items: product pre-fills price and unit; price overridable on the line without touching the product record; running total always on screen, never behind a summary step.
4. Payment: paid defaults to the total (the cash case) and is reduced to ৫০০; method chips with the last-used pre-selected; **due appears live as ৳৮৬০ before he commits.**
5. **Climax:** save confirms in under 100ms from local storage, and the screen states the outcome — আগের বাকি ৳৩,৫০০ → বর্তমান ৳৪,৩৬০ — which Rahim can read too, and agrees with.
6. Receipt is one tap away, not a step in the flow.

**Edge case:** offline, every beat is identical; the receipt still generates; a pending-sync dot appears on the row and nothing else changes.

### UJ-3 — A payment settles in front of the customer

Party → amount → method → confirm. The confirmation is the whole point and is written as arithmetic the customer can follow: *রহিমের বাকি ৳৪,০৮০ থেকে কমে ৳১,০৮০ হলো*. An overpayment is accepted and renders as an advance, never as an error.

### UJ-5 — Closing the day in thirty seconds

One screen, reachable in one tap from হোম: sales split cash and credit, collection, expenses, damage, estimated profit — then two AI observations grounded in the day's data. Numbers here are identical to the daily report's; if they can ever differ, that is a defect. A quiet day produces a short summary, never a padded one.

### UJ-6 — Chasing ৳৮৫,৪০০ (SM-8)

হোম's receivable figure is the entry point. The list is ordered by amount with an alternative of longest-overdue, each row showing days since last payment and an inline তাগাদা দিন. The draft opens as a sheet with the message pre-written, editable, and the owner sends it from their own WhatsApp or SMS. Customers with reminders off are visibly marked and filterable. Hisab records that a reminder was sent so the owner does not chase the same person twice.

### UJ-8 — Typing a sentence instead of filling a form (SM-5, SM-C3)

1. A sentence in Bangla, English or a mix.
2. **The draft card is the design problem.** Every field is visible and individually editable, the party's balance before and after is shown, and anything the AI could not determine is empty and highlighted — the payment method in the drawn example is left as *বলা হয়নি — বেছে নিন* rather than guessed.
3. **The card must invite checking, not reflexive tapping.** It is on the AI surface, the save button is not the largest thing on screen, and the unresolved field sits between the owner and the save. SM-C3 exists because a high AI share with a falling confirmation rate means owners are accepting drafts blind — which puts wrong numbers in the ledger, the one failure the product cannot absorb.
4. Two Rahims produce a disambiguation screen showing each candidate's balance. Hisab never picks.
5. Saving produces an ordinary sale, indistinguishable in the ledger.

### UJ-9 — Four hours with no internet

Nothing changes. Fourteen entries record normally. The only difference on any screen is the pending count. When the connection returns the queue drains unattended and the indicator clears without the owner acting. An unresolvable conflict is surfaced as a plain-language choice showing both versions with their amounts, dates and source device — never silently resolved, never dropped.

### Catalogue import (FR-119, risk R-3)

Not a PRD journey, but the flow that decides whether a 400-SKU grocery ever gets a usable catalogue. File → parsed preview stating in plain Bangla what will happen (386 new, 19 already there, 7 unusable) → one choice for duplicates → commit. Bad rows are listed with row number and reason and are skipped, never aborting the file. A plan limit is checked before commit, not per row, and says what the limit is.
