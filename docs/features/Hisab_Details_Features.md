# Hisab — Detailed Feature Specification

## 1. Target Users

Primary users:

- Grocery shops
- Clothing shops
- Electronics shops
- Restaurants
- Pharmacies
- Hardware shops
- Cosmetics shops
- Mobile/accessories shops
- Small wholesalers
- Facebook/online sellers
- Home-based businesses

The app should work for someone who isn't comfortable with accounting software.

Instead of:

> Accounts Receivable

Use:

> যার কাছে টাকা পাবেন

Instead of:

> Accounts Payable

Use:

> যাকে টাকা দিতে হবে

---

## 2. Core MVP Features

The product is divided into these modules:

- Business setup
- Dashboard
- Customer management
- Customer ledger / বাকি হিসাব
- Supplier management
- Sales
- Purchases
- Expenses
- Products & inventory
- Payments
- Invoices/receipts
- Reports
- Notifications/reminders
- Search
- Backup/sync
- Multi-user access
- Subscription

---

## 3. Business Setup

When the owner first opens the app:

### Step 1 — Business name

> ব্যবসার নাম কী?

Example: Rahman Grocery

### Step 2 — Business type

- Grocery
- Clothing
- Electronics
- Restaurant
- Pharmacy
- Hardware
- Online Business
- Other

### Step 3 — Currency

Default:

৳ BDT

### Step 4 — Business address

Optional.

### Step 5 — Owner information

- Name
- Phone
- Email

### Step 6 — Opening balance

Example:

> আজ ব্যবসায় মোট কত টাকা আছে?

- Cash: ৳50,000
- Bank: ৳100,000
- bKash: ৳25,000
- Nagad: ৳10,000

---

## 4. Home Dashboard

This should be extremely simple.

```
Good Morning 👋

Rahman Grocery

Today's Sales
৳24,850

Today's Collection
৳18,200

Today's Expense
৳4,350

Today's Profit
৳6,300
```

Then:

```
আপনার কাছ থেকে পাবেন
৳85,400

আপনাকে দিতে হবে
৳42,300
```

And:

```
Low Stock
⚠ Rice 25kg
⚠ Soybean Oil 5L
⚠ Sugar 1kg
```

---

## 5. Quick Actions

The home screen should have large buttons:

- **+ বিক্রি**
- **+ টাকা পেলাম**
- **+ টাকা দিলাম**
- **+ বাকি দিলাম**
- **+ খরচ**
- **+ পণ্য যোগ**

This is important.

A দোকান owner should be able to record a transaction in 5–10 seconds.

---

## 6. Customer Management

Customer profile:

```
Rahim Ahmed

Phone:
017XXXXXXXX

Total Due:
৳12,500

Last Transaction:
Yesterday
```

Actions:

- [ + Sale ]
- [ টাকা পেলাম ]
- [ হিসাব দেখুন ]
- [ WhatsApp/SMS ]

---

## 7. Customer Ledger — Core Feature

This is the heart of Hisab.

Example:

**Rahim Ahmed**

| Date | Description | Debit | Credit | Balance |
|---|---|---|---|---|
| Aug 20 | Grocery | ৳2,500 | — | ৳2,500 |
| Aug 21 | Payment | — | ৳1,000 | ৳1,500 |
| Aug 22 | Grocery | ৳3,000 | — | ৳4,500 |

At the top:

> Rahim owes you ৳4,500

---

## 8. "বাকি দিলাম"

Extremely simple flow.

Owner taps:

**বাকি দিলাম**

Select customer:

**Rahim**

Enter:

```
Amount:
৳2,500

Description:
Grocery items
```

Save.

Hisab updates:

> Rahim-এর বাকি: ৳7,000

---

## 9. "টাকা পেলাম"

Customer pays.

```
Rahim
Paid: ৳3,000
```

Payment method:

- Cash
- bKash
- Nagad
- Bank
- Other

Then:

> Rahim-এর বাকি ৳4,000 কমে গেল।

---

## 10. Payment Methods

Bangladesh-specific support:

- Cash
- bKash
- Nagad
- Rocket
- Bank
- Card
- Other

You don't necessarily need payment-provider APIs in MVP.

Initially these are simply payment method records.

Later:

**Direct bKash/Nagad integration**

could become a major feature.

---

## 11. Supplier Management

Similar to customers.

Example:

```
Karim Wholesale
আপনাকে দিতে হবে

৳35,500
```

Ledger:

```
Purchase       ৳20,000
Payment        ৳10,000
Purchase       ৳25,500

Outstanding    ৳35,500
```

---

## 12. Sales

Sales can be:

### Cash Sale

- Product
- Quantity
- Price
- Discount
- Payment

Example:

```
Rice 5kg
2 × ৳350

Oil 2L
1 × ৳380

Total
৳1,080

Payment:
Cash ৳1,080
```

---

## 13. Credit Sale

Same sale:

```
Total: ৳1,080

Paid: ৳500

Due: ৳580
```

The customer's ledger automatically updates.

This is important:

**Sales and ledger should not be separate systems.**

A sale should automatically create the appropriate ledger transaction.

---

## 14. Product Management

Product fields:

- Product name
- SKU
- Barcode
- Category
- Purchase price
- Selling price
- Current stock
- Minimum stock
- Unit
- Supplier

Units:

- Piece
- Kg
- Gram
- Liter
- Box
- Packet
- Dozen
- Meter

---

## 15. Inventory

Dashboard:

```
Inventory

Total Products
428

Stock Value
৳845,200

Low Stock
17

Out of Stock
5
```

Product:

```
Rice 5kg

Stock
43 bags

Purchase price
৳320

Selling price
৳350

Stock value
৳13,760
```

---

## 16. Stock Movement

Every inventory change should have a reason.

Example:

```
Aug 20
+50 Purchase

Aug 21
-3 Sale

Aug 22
-2 Sale

Current:
45
```

Types:

- Purchase
- Sale
- Return
- Damage
- Manual adjustment

---

## 17. Purchase Management

Owner buys goods from supplier.

```
Supplier:
Karim Wholesale

Products:

Rice 5kg
100 × ৳320

Oil 5L
50 × ৳850

Total:
৳74,500

Paid:
৳40,000

Due:
৳34,500
```

Automatically:

- Increase inventory
- Increase supplier payable
- Record payment

---

## 18. Expense Management

Categories:

- Rent
- Electricity
- Gas
- Internet
- Employee salary
- Transport
- Packaging
- Maintenance
- Marketing
- Food
- Other

Example:

```
Electricity Bill

Amount:
৳8,500

Payment:
Cash

Date:
23 Aug 2026
```

---

## 19. Recurring Expenses

Useful for:

- Rent
- Internet
- Salary
- Software subscription
- Utility bills

Example:

> Shop Rent — ৳25,000/month

Hisab reminds:

> Shop rent due in 3 days.

---

## 20. Daily Sales Summary

At the end of the day:

```
Today's Business

Sales
৳54,500

Cash Sales
৳32,000

Credit Sales
৳22,500

Collected
৳18,000

Expenses
৳6,500

Estimated Profit
৳11,200
```

---

## 21. Profit & Loss

Simple business owner-friendly report:

```
August 2026

Sales
৳850,000

Cost of Goods
৳650,000

Gross Profit
৳200,000

Expenses
৳85,000

Net Profit
৳115,000
```

Don't overwhelm users with accounting terminology.

Provide:

> এই মাসে আপনার লাভ ≈ ৳১১৫,০০০

---

## 22. Sales Reports

Filters:

- Today
- Yesterday
- This week
- This month
- Custom date

Show:

- Total sales
- Number of transactions
- Average sale
- Cash sales
- Credit sales
- Returns

---

## 23. Product Performance

Example:

```
Top Selling Products

1. Rice 5kg
Sales: ৳85,000

2. Soybean Oil 5L
Sales: ৳72,500

3. Sugar 1kg
Sales: ৳51,300
```

This helps owners understand what actually sells.

---

## 24. Customer Reports

Example:

```
Top Customers

Rahim
৳85,000

Karim
৳62,500

Jamal
৳45,200
```

Also:

Customers with outstanding balances

---

## 25. Due Payment Reminder

This could become a major feature.

Example:

> Rahim Ahmed-এর ৳5,500 বাকি আছে।

Buttons:

- [ Send Reminder ]
- [ টাকা পেলাম ]

Reminder could generate:

> ভাই, আপনার কাছে ৳5,500 বাকি আছে। সুবিধামতো পরিশোধ করবেন। ধন্যবাদ।

Initially:

- Copy/share
- SMS
- WhatsApp

Later:

- Automated SMS
- WhatsApp Business API

---

## 26. Payment Reminder Schedule

For each customer:

Reminder:

- Don't remind
- Every 7 days (default)
- Every 15 days
- Every 30 days

Owner can disable reminders for trusted customers.

---

## 27. Invoice / Receipt

Generate a simple Bangla receipt:

```
--------------------------------
       Rahman Grocery
       Mirpur, Dhaka

Receipt #INV-000182

23 Aug 2026

Rice 5kg        2 × 350 = 700
Oil 2L          1 × 380 = 380

-------------------------------
Total                   ৳1,080
Paid                    ৳500
Due                     ৳580
-------------------------------

Thank you!
--------------------------------
```

Export/share as:

- PDF
- Image
- WhatsApp
- Messenger
- Print

---

## 28. Barcode Scanning

For products with barcodes:

**[ Scan Barcode ]**

Scan → find product → sale.

This should be Phase 2 unless your target stores heavily depend on barcode inventory.

---

## 29. Search

Global search:

🔍 Search

Can find:

- Customers
- Suppliers
- Products
- Invoice numbers
- Transactions

Example:

> "Rahim"

returns:

- Rahim Ahmed
- Rahim Store
- Rahim Supplier

---

## 30. Returns

### Sales return

- Customer
- Invoice
- Product
- Quantity
- Reason

Automatically:

- Increase inventory
- Reduce sales
- Adjust customer balance

### Purchase return

- Reduce inventory
- Adjust supplier balance

---

## 31. Cash / Wallet Management

Show business money by source:

```
Cash
৳85,000

bKash
৳32,500

Nagad
৳12,000

Bank
৳150,000

Total
৳279,500
```

This is particularly useful for Bangladeshi businesses.

---

## 32. Cash Transfer

Example:

Owner transfers:

**Cash → Bank**

৳20,000

This shouldn't count as revenue or expense.

Same for:

**Cash → bKash**

---

## 33. Business Dashboard — Advanced

Eventually:

```
┌──────────────────────────────┐
│ Today's Sales      ৳54,500   │
│                              │
│ Profit             ৳11,200   │
│                              │
│ You'll Receive     ৳85,400   │
│ You'll Pay         ৳42,300   │
│                              │
│ Stock Value       ৳845,200   │
│                              │
│ ⚠ 17 Low Stock Products      │
│ ⚠ 8 Customer Payments Due    │
└──────────────────────────────┘
```

---

## 34. AI Features

This is where Hisab could become much more interesting.

Don't make AI the core MVP dependency.

First build reliable accounting.

Then introduce:

**AI Business Assistant**

Owner asks:

> "এই মাসে আমার সবচেয়ে বেশি বিক্রি কোন পণ্যে?"

AI:

> Rice 5kg was your highest-selling product with ৳85,000 in sales.

### Ask About Business

- "এই মাসে লাভ কেমন?"
- "কার কাছে সবচেয়ে বেশি টাকা পাব?"
- "গত মাসের তুলনায় বিক্রি কেমন?"
- "কোন পণ্য কম বিক্রি হচ্ছে?"
- "আমার সবচেয়ে বেশি খরচ কোথায়?"
- "আগামী সপ্তাহে কোন পণ্য কিনতে হতে পারে?"

---

## 35. AI Daily Summary

Every evening:

```
আজকের ব্যবসার সারাংশ

বিক্রি: ৳54,500
খরচ: ৳6,500
সংগ্রহ: ৳18,000
নতুন বাকি: ৳22,500

আজ Rice 5kg সবচেয়ে বেশি বিক্রি হয়েছে।

⚠ আগামী ৩–৪ দিনের মধ্যে Oil 5L-এর stock শেষ হতে পারে।
```

This is much more useful than simply showing charts.

---

## 36. AI Cash Flow Prediction

Later:

AI looks at:

- Historical sales
- Expenses
- Customer dues
- Supplier dues
- Recurring costs

and says:

> "আগামী ১০ দিনে আপনার আনুমানিক ৳75,000 cash requirement হতে পারে।"

This would be a premium feature.

---

## 37. AI Natural Language Entry

Potentially a killer feature.

Owner types:

> "Rahim 3টা rice 5kg নিল, মোট 1050 টাকা, 500 টাকা দিল।"

AI converts it into:

```
Customer: Rahim
Product: Rice 5kg
Quantity: 3
Total: ৳1,050
Paid: ৳500
Due: ৳550
```

Then asks:

> Save this transaction?

**[Confirm]**

This could make Hisab dramatically faster.

---

## 38. Voice-Based Hisab

Eventually:

> 🎤 "Rahim আজকে দুই হাজার টাকার মাল নিয়েছে, এক হাজার টাকা দিয়েছে।"

AI:

```
Rahim
Sale: ৳2,000
Paid: ৳1,000
Due: ৳1,000

Save?
```

This is potentially a huge Bangladesh-specific differentiator, especially for users uncomfortable with typing.

---

## 39. Multi-User

Business owner can add employees.

Example:

**Owner**

Full access.

**Manager**

Sales + inventory.

**Cashier**

Sales only.

**Accountant**

Reports + expenses.

Permissions:

- `view_sales`
- `create_sale`
- `edit_sale`
- `delete_sale`
- `view_inventory`
- `manage_inventory`
- `view_reports`
- `manage_expenses`
- `manage_users`

---

## 40. Multi-Branch

Phase 2/3.

Example:

```
Rahman Group

Branch 1 — Mirpur
Branch 2 — Uttara
Branch 3 — Dhanmondi
```

Owner sees:

> Total Sales: ৳2.4M

and branch-specific performance.

---

## 41. Backup & Sync

Very important.

Users should never fear losing their হিসাব.

Features:

- Automatic cloud backup
- Device synchronization
- Restore
- Export
- CSV export
- PDF reports

Also provide:

**Download My Data**

---

## 42. Offline Mode

This is especially important for small businesses.

Basic operations should work without internet:

- View customers
- View products
- Record sales
- Record payments
- Record expenses
- View cached reports

When internet returns:

```
Local Database
      ↓
Sync Queue
      ↓
Backend
```

Use Drift or Isar locally depending on the preferred architecture.

---

## 43. Notifications

Examples:

- 🔔 Rahim's ৳5,000 payment is overdue.
- 🔔 Rice 5kg stock is low.
- 🔔 Monthly rent is due tomorrow.
- 🔔 Today's sales are 20% higher than yesterday.
- 🔔 You haven't recorded today's closing yet.

---

## 44. Business Closing

At the end of the day:

```
Daily Closing

Expected Cash
৳48,500

Actual Cash
৳48,000

Difference
-৳500
```

Owner can add:

> Reason: personal withdrawal

This is useful for shops with cashiers.

---

## 45. Owner Withdrawal

Personal withdrawals should be separate from business expenses.

Example:

Owner took ৳5,000.

Record:

**Owner withdrawal**

rather than:

**Expense**

This makes profit reporting more accurate.

---

## 46. Subscription Model

### Free

- 1 business
- 1 user
- Up to 100 customers
- Basic ledger
- Basic sales
- Basic expenses

### Pro — perhaps ৳199–299/month

- Unlimited customers
- Inventory
- Reports
- Cloud backup
- PDF invoices
- Multiple payment methods
- AI assistant
- Automated reminders

### Business — perhaps ৳499–999/month

- Multiple users
- Multiple branches
- Advanced reports
- AI analytics
- Employee permissions
- Priority support

Pricing should ultimately be validated with real users rather than fixed upfront.

---

## 47. MVP Screen Structure

Keep the first app around 12–15 major screens.

```
Splash
   ↓
Login/Register
   ↓
Business Setup
   ↓
Home
 ┌─┼───────────────┐
 │ │               │
Sales            Hisab
 │                 │
 ├─ Customers       ├─ Customer Ledger
 ├─ Products        ├─ Supplier Ledger
 └─ Purchases       └─ Payments
 │
Expenses
 │
Reports
 │
Profile/Settings
```

Bottom navigation:

**Home | Hisab | Sales | Products | More**

---

## 48. Recommended MVP

Do not build everything above initially.

The first release should contain:

### Core

- Authentication
- Business setup
- Dashboard
- Customer management
- Customer ledger
- Supplier management
- Supplier ledger
- Sales
- Purchases
- Expenses
- Products
- Inventory
- Payments
- Basic reports
- PDF receipt
- Search
- Cloud backup
- Offline transaction recording
- Notifications
- Basic subscription

### AI — limited MVP

Add only:

- Ask Hisab
- AI daily business summary
- Natural-language transaction entry

Prioritize natural-language transaction entry over a generic chatbot.

---

## 49. The Killer User Experience

Imagine a দোকান owner saying:

> 🎤 "Rahim 1500 টাকার মাল নিয়েছে, 500 টাকা দিয়েছে।"

Hisab responds:

```
Rahim

Sale: ৳1,500
Paid: ৳500
New Due: ৳1,000

আগের বাকি: ৳3,500
বর্তমান বাকি: ৳4,500

[ ✅ Save ] [ ✏️ Edit ]
```

One tap.

That's the kind of experience that could make Hisab much faster than traditional accounting apps.

---

## 50. Product Positioning

Avoid positioning it as:

> ❌ Accounting Software

Instead:

> Hisab — আপনার ব্যবসার পুরো হিসাব এক জায়গায়।

And the three main promises:

- **বাকি হিসাব**
- **বিক্রি ও স্টক**
- **লাভ-ক্ষতির হিসাব**

Then AI becomes the differentiator:

> "কথা বলেই হিসাব করুন।"

That combination—Bangla-first UX + offline-first small-business accounting + bKash/Nagad-aware transactions + AI voice/natural-language entry—is where the strongest Bangladesh-specific opportunity sits.
