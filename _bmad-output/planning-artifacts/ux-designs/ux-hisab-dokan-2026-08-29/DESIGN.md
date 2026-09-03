---
name: Hisab
description: Bangla-first business management for Bangladeshi small shops. Warm paper ledger, ink text, money largest on screen. Material 3, heavily themed.
status: final
created: 2026-08-29
updated: 2026-08-29
sources:
  - _bmad-output/planning-artifacts/prds/prd-hisab-dokan-2026-08-29/prd.md
  - _bmad-output/planning-artifacts/prds/prd-hisab-dokan-2026-08-29/addendum.md
colors:
  paper: '#FAF5EA'
  paper-sunk: '#F1E7D3'
  surface: '#FFFDF8'
  rule: '#E4D9C2'
  ink: '#2B2419'
  ink-muted: '#7C6F5B'
  ink-faint: '#B9AC94'
  accent: '#1F5D46'
  money-in: '#1F5D46'
  money-out: '#9C4221'
  warn: '#8A6516'
  warn-surface: '#F6EAD2'
  warn-rule: '#E3CFA4'
  ai-surface: '#EBF1EC'
  ai-rule: '#C9DCCE'
typography:
  display:
    family: 'Noto Serif Bengali'
    fallback: 'Georgia, serif'
    weights: '600, 700'
    note: 'Ledger headings, screen titles, receipts. Never body copy.'
  ui:
    family: 'Hind Siliguri'
    fallback: 'system-ui, sans-serif'
    weights: '400, 500, 600, 700'
    note: 'Everything else, including every number. Tabular figures always.'
  scale:
    amount-xl: '36px / 700 / -0.02em'
    amount-lg: '26px / 700'
    amount-md: '19px / 700'
    amount-sm: '15px / 700'
    title: '18px / 600 / display'
    body: '15px / 400'
    label: '12px / 500 / ink-muted'
    meta: '12.5px / 400 / ink-muted'
rounded:
  sm: 6px
  chip: 999px
  md: 12px
  lg: 14px
  sheet: 20px
spacing:
  '1': 4px
  '2': 8px
  '3': 12px
  '4': 16px
  '5': 22px
  '6': 32px
components:
  button-primary: 'height 54px, radius 13px, accent fill, 16.5px/600'
  button-secondary: 'height 54px, radius 13px, 1.5px accent border, transparent fill'
  button-tertiary: 'height 54px, radius 13px, paper-sunk fill, ink text'
  quick-action: 'min-height 80px, radius 14px, surface fill, 1px rule, icon 24px accent over 13.5px/600 label'
  field: 'radius 12px, surface fill, 1px rule, 11/13px padding, label 12px over value 17px/600'
  chip: 'radius 999px, paper-sunk fill, 12px/600, 5/11px padding; selected = accent fill'
  card: 'radius 14px, surface fill, 1px rule, 14px padding'
  ledger-row: 'grid 52px 1fr 78px 82px, 11/16px padding, 1px rule below, 13px'
  app-bar: 'height 58px, paper fill, 1px rule below, title 18px/600 display'
  bottom-nav: 'height 66px, surface fill, 1px rule above, icon 21px over 11px label'
  disclosure-banner: 'radius 12px, warn-surface fill, 1px warn-rule, 13px, icon + text'
  ai-surface: 'radius 14px, ai-surface fill, 1px ai-rule'
---

# Hisab — Design Spine

Visual identity. Behaviour lives in [EXPERIENCE.md](./EXPERIENCE.md); where a mock and this document disagree, this document wins.

Visual counterpart: the **Design system** page of the canvas in `.working/DesignSystem.dc.html`.

## Brand & Style

Hisab replaces a paper khata, and it looks like it knows that. The ground is warm off-white the colour of a ledger page; the text is ink; the lines between rows are ruled lines, not UI chrome. A shop owner who has kept accounts in a notebook for nine years should feel the app is on the same side as the notebook — safer, not more modern.

That is a deliberate rejection of the two obvious alternatives. It is not enterprise accounting software: no dense tables, no English jargon, no tabbed forms, nothing that says *this is for educated city people and not for me*. And it is not a fintech app: no dark chrome, no gradient meshes, no abstract geometry, no charts leading the page. Charts are what you show after someone asks why; the number and the sentence come first.

One rule governs every screen: **money is the largest thing on it.** The figure comes before its label, before the chart, before the navigation. Everything else in the visual system exists to keep that figure legible at arm's length, in daylight, held one-handed, with a customer waiting.

The voice that goes with it — plain Bangla, outcome stated in the owner's own words — is specified in EXPERIENCE.md § Voice and Tone.

## Colors

A warm neutral ground with two ink accents and one reserved warning colour. Nothing decorative.

- **Paper (`#FAF5EA`)** is the ground everywhere. Warm enough to read as paper rather than as an off-white UI, desaturated enough not to tint the money on top of it.
- **Paper-sunk (`#F1E7D3`)** marks recessed bands — table headers, chips, summary strips under an app bar. It is the only "second surface"; there is no third.
- **Surface (`#FFFDF8`)** is what cards and rows sit on, a shade lighter than paper so a card lifts by tone rather than by shadow.
- **Rule (`#E4D9C2`)** draws every line in the product — card borders, row separators, ledger rules, the line under an app bar. One line weight, one colour, everywhere. It is the single most repeated element in the design and doing it well is most of the work.
- **Ink (`#2B2419`)** is text and, above all, money. Warm near-black, never pure black.
- **Ink-muted (`#7C6F5B`)** is labels, timestamps, secondary lines. **Ink-faint (`#B9AC94`)** is placeholder text only.
- **Accent / money-in (`#1F5D46`)** is one colour doing two jobs that never conflict: primary actions, and money coming in. A deep ledger green, ink-like rather than brand-like.
- **Money-out (`#9C4221`)** is dues owed, money leaving, and destructive actions. Terracotta, matched to the accent in lightness and chroma so neither dominates when both appear in the same ledger.
- **Warn (`#8A6516`)** on `warn-surface #F6EAD2` is reserved almost entirely for stock — low stock, out of stock, an overdue customer, a disclosure the owner needs to read. Because it is reserved, it works.
- **AI surface (`#EBF1EC` on `#C9DCCE`)** is a green-tinted card used for one purpose: marking something as generated by Hisab rather than recorded by the owner. See EXPERIENCE.md § State Patterns.

Colour carries exactly one meaning each — in, out, warning, AI — and never decorates. A shop owner learns four colours in a day and then reads the whole product by them.

**Avoid:** red error fills (this is a ledger, not a form; `money-out` is the strongest red the product owns), gradients of any kind, saturated brand colour, colour-coded categories, and any use of accent green that is not an action or money arriving.

## Typography

Two families, both with full Bangla coverage, both loaded as bundled faces rather than system fonts — Bangla conjuncts do not render reliably from system fonts on either platform, and the same faces must render in generated PDF receipts (PRD §4.11 NFRs).

**Noto Serif Bengali** (600/700) sets ledger headings, screen titles and receipts. The serif is what makes a screen read as a khata rather than an app; it is also why receipts look like documents. It never sets body copy and never appears below 17px.

**Hind Siliguri** (400–700) sets everything else, including every number. Tabular figures are on globally, without exception, so that a column of amounts in a ledger lines up — a ledger where the digits wander is a ledger the owner will not trust.

The scale is short on purpose: four amount sizes, one title, one body, two label sizes. Amounts get their own ramp because they are the content. There are no display sizes above `amount-xl` and no all-caps labels except the ledger table header.

**Numerals follow the language setting** (PRD FR-8). In Bangla, Bangla digits with lakh grouping — ৳১,০৮,৫০০, never ৳১০৮,৫০০. In English, Western digits with Western grouping. The stored value is script-independent; only rendering changes. Input is the exception and accepts both scripts in either mode, because the keypad belongs to the device.

## Layout & Spacing

Scale: 4 / 8 / 12 / 16 / 22 / 32. Screen margin is 16. Cards are 14 inside. Gaps between stacked cards are 12; between a label and its value, 4.

Single column, always. Two-column grids appear only for paired summary figures and for the quick-action tiles (three across). There is no third level of nesting: a card never contains a card.

Every screen is: app bar (58px, fixed) · scrolling body · optional fixed action bar (54px button in 14/16 padding). The action bar is fixed because the primary action must be reachable with a thumb without scrolling to the end of a form.

## Elevation & Depth

Effectively none. Cards separate from the ground by tone and by a 1px rule, never by shadow. The design is paper; paper does not float.

Two exceptions, both literal rather than decorative: a bottom sheet casts a soft upward shadow because it genuinely sits over the page, and the central action button in navigation option খ carries a small shadow because it must read as raised above the tab bar. Nothing else in the product has a shadow.

## Shapes

Radii are gentle and consistent: 12px on fields and banners, 14px on cards and quick actions, 13px on buttons, 20px on sheet tops, 999px on chips. Receipts are the deliberate outlier at 6px — a receipt should read as a printed slip, not as a card.

Icons are line drawings on a 24px grid at 1.7–1.8 stroke, and they are literal: a shop, a person, a bag, a book, a cart. No emoji anywhere, no abstract fintech marks. Where an icon would be ambiguous, use a label instead.

## Components

Specs are in the frontmatter; the notes that matter:

**Buttons.** 54px is the floor for a primary action, above the 48dp accessibility minimum, because these are pressed one-handed at speed. Three levels only — primary (accent fill), secondary (accent outline), tertiary (paper-sunk). Destructive actions are tertiary with `money-out` text; there is no red button in the product.

**Quick actions** are the highest-traffic component. 80px minimum, three across, icon over label, and the label never truncates at the largest system font size — this constrains the wording as much as the type size, which is why they are two words at most.

**Fields** show label above value, with the value at 17px/600 — large, because a shop owner checks the number they just typed while a customer watches. Amount fields go to 26–34px and take the accent colour while being entered.

**Chips** carry payment methods, categories, date ranges and filters. Selected state is an accent fill, never a border change, because a border change is invisible at arm's length.

**The ledger row** is the component everything else serves: date, description, credit, running balance. Fixed grid so columns align down the page, credits in `money-in`, the final balance heavier than the rest. Get this row right and the product works.

**Disclosure banner** carries the sentences the product is obliged to say — *this sale has no items, so stock will not change and profit cannot be computed for it*. It uses the warning palette and appears inline where the consequence occurs, never as a footnote.

**AI surface** marks anything Hisab generated. Distinct fill, distinct border, always labelled. A viewer must never mistake an AI draft for a saved transaction.

## App Icon

**Decided: খাতা — the ledger.** Chosen by Tanim from four directions drawn on the canvas's *App icon* page (খাতা, ৳, জমা-খরচ, হ), each masked three ways, shown at 48px and 32px, and reduced to the Android notification silhouette.

The mark is a closed book seen front-on with a heavy spine band and two ruled lines. The spine is what earns it: it gives the silhouette an asymmetry that survives circular, squircle and square masking, so it never collapses into a plain rounded square the way a centred symbol does.

The known cost, accepted: a book is the most crowded metaphor on any app store. Mitigation is the ground colour and the spine's weight, not the metaphor — and it is worth checking on a real home screen beside a notes app and a reader before the first store build.

Fixed regardless of which wins:

- Ground is `{colors.accent}`, mark is `{colors.paper}`. Deep green is deliberate on a Bangladeshi home screen: bKash is pink and Nagad is orange, and Hisab should read as the calm one rather than compete.
- Android ships two layers on a 108dp canvas with everything meaningful inside the central **66dp safe circle**; iOS ships one opaque 1024px square with **no pre-rounded corners**. Two builds, not one export.
- The notification icon is a flat white silhouette — any mark whose meaning depends on a colour difference fails there and is disqualified.
- The wordmark **হিসাব** stays out of the icon. Bangla text is unreadable at 48px, and shop owners find apps by shape and colour.
- Two of the four directions render with a live webfont on the canvas. A shipped icon never depends on a font: the glyph is traced to outlines and redrawn by hand, because a type designer's ৳ or হ is optimised for a paragraph, not for 48 pixels.

## Do's and Don'ts

**Do**

- State the outcome in the owner's words: *রহিমের বাকি ৳৪,০৮০ থেকে কমে ৳১,০৮০ হলো*.
- Make money the largest element on any screen it appears on.
- Use one line weight and one line colour for every rule in the product.
- Keep hit targets at 48dp minimum, primary actions at 54px.
- Disclose what a number excludes in the same breath as the number.
- Let colour mean exactly one thing.

**Don't**

- Never write receivable, payable, debit, credit or ledger in English on a user-facing surface.
- Never lead with a chart.
- No gradients, no shadows for hierarchy, no emoji as iconography, no saturated brand colour.
- Never present an estimate as a fact — লাভ is always আনুমানিক.
- Never let an AI-generated surface look like a recorded one.
- Never let a Bangla label truncate; shorten the words instead of the type.
