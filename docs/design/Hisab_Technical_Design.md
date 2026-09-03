# Hisab — Full Technical Design Document

**Product:** Hisab  
**Target Market:** Bangladesh  
**Platforms:** Android, iOS, Web Admin  
**Primary Mobile Framework:** Flutter  
**Backend:** NestJS  
**AI Service:** Python/FastAPI  
**Database:** PostgreSQL  
**Architecture:** Offline-first + Modular Monolith  
**Target MVP Timeline:** 3–4 months

---

> ## ⚠️ Read this before using this document
>
> **Status: partially superseded, 2026-09-03.** This document remains the authoritative source for the stack, the module breakdown, the API shapes, the test strategy and most of the schema. It was written before the PRD, the UX spines and the architecture spine, and **four of its decisions have since been overturned**. Where this document and those disagree, **they win**.
>
> | This document says | Superseded by | Where the current decision lives |
> | --- | --- | --- |
> | §13 — every synced entity carries both `id` and `serverId` | **`serverId` is removed.** A client-minted UUIDv7 is the single identity on device and server, and is what every foreign key stores. | Architecture spine **AD-3** |
> | §25 — `SaleItem` carries a scalar `costPrice` | **Superseded.** One sale line can consume several cost layers at different costs, which a scalar cannot represent. Cost is recorded as `LayerConsumption` rows plus `LayerConsumptionAdjustment`. | Architecture spine **AD-7**, **AD-8** |
> | §55 — "the exact inventory costing method should be finalized" | **Decided: FIFO**, with explicit cost layers and consumption rows ordered by `(businessDate, id)`. | Architecture spine **AD-7** |
> | §31/§15 — financial correction semantics | Reinforced and made binding: financial tables are **append-only**; corrections write a reversal plus a new record. No `UPDATE`, no `DELETE`, device or server. | Architecture spine **AD-4** |
>
> Two further decisions this document does not cover, because they did not exist when it was written: money is stored as **integer paisa** and quantity as **integer milli-units** (spine AD-1, AD-2), and receipt numbers are **unique and ascending but not gap-free** (spine AD-15, PRD FR-30).
>
> Current sources of truth: `_bmad-output/planning-artifacts/prds/prd-hisab-dokan-2026-08-29/prd.md`, `_bmad-output/planning-artifacts/architecture/architecture-hisab-dokan-2026-08-29/ARCHITECTURE-SPINE.md`, and the two UX spines under `_bmad-output/planning-artifacts/ux-designs/`.

---


## 1. Executive Summary

Hisab is a Bangladesh-focused business management application designed primarily for small and medium-sized businesses.

The application allows business owners to manage:

- Customers
- Suppliers
- Sales
- Purchases
- Customer dues
- Supplier dues
- Expenses
- Inventory
- Payments
- Receipts
- Reports
- Business cash flow
- AI-assisted business operations

The application should be Bangla-first, extremely simple to use, and capable of working without an internet connection.

The key technical philosophy is:

**Financial transactions must be deterministic and reliable; AI should assist users but should never directly control financial data.**

For example, if a user says:

> "Rahim 1500 টাকার মাল নিয়েছে, 500 টাকা দিয়েছে।"

AI can understand the request, but the actual transaction must still go through the normal Hisab backend validation and database transaction.

---

## 2. Product Goals

### Primary Goals

Hisab should allow a business owner to:

- Record a sale within seconds
- Record credit sales
- Track customer dues
- Record customer payments
- Track supplier dues
- Record purchases
- Track inventory
- Record expenses
- Generate receipts
- View sales and profit
- Work without internet
- Automatically synchronize when internet becomes available
- Ask questions about the business using AI

### Non-Goals for MVP

The MVP should not attempt to become a complete enterprise ERP.

Avoid initially implementing:

- Full accounting ERP
- Complex double-entry accounting
- Payroll
- Manufacturing
- Complex VAT automation
- Advanced procurement
- CRM
- Kubernetes
- Microservices
- Elasticsearch
- Dedicated data warehouse

These can come later.

---

## 3. Target Users

Primary users:

- Grocery shops
- Clothing shops
- Electronics shops
- Restaurants
- Pharmacies
- Cosmetics shops
- Hardware shops
- Mobile/accessories shops
- Small wholesalers
- Facebook/online sellers
- Home-based businesses

The UX should assume that users may have little accounting knowledge.

Therefore:

- Use simple terminology
- Prefer Bangla labels
- Minimize data entry
- Use large touch targets
- Provide guided workflows

---

## 4. High-Level Architecture

```
                         ┌───────────────────────┐
                         │     Flutter App       │
                         │     Android / iOS     │
                         │                       │
                         │ Riverpod + Drift      │
                         └───────────┬───────────┘
                                     │
                                  HTTPS
                                     │
                              ┌──────▼──────┐
                              │    NestJS   │
                              │ API Server  │
                              └──────┬──────┘
                                     │
               ┌─────────────────────┼───────────────────┐
               │                     │                   │
               ▼                     ▼                   ▼
        ┌────────────┐        ┌────────────┐      ┌─────────────┐
        │ PostgreSQL │        │   Redis    │      │ S3 Storage  │
        └────────────┘        └─────┬──────┘      └─────────────┘
                                    │
                                  BullMQ
                                    │
                            Background Workers

                         ┌─────────────────────┐
                         │ Python AI Service   │
                         │       FastAPI       │
                         └──────────┬──────────┘
                                    │
                              LLM / STT / Vision

                         ┌─────────────────────┐
                         │   Next.js Admin     │
                         └─────────────────────┘
```

---

## 5. Technology Stack

### Mobile

| Component | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State Management | Riverpod |
| Navigation | GoRouter |
| HTTP Client | Dio |
| Models | Freezed |
| JSON | json_serializable |
| Local DB | Drift + SQLite |
| Secure Storage | flutter_secure_storage |
| Connectivity | connectivity_plus |
| Push Notifications | Firebase Cloud Messaging |
| Local Notifications | flutter_local_notifications |

---

## 6. Backend Stack

| Component | Technology |
|---|---|
| Framework | NestJS |
| Language | TypeScript |
| HTTP | Fastify |
| ORM | Prisma |
| Database | PostgreSQL |
| Cache | Redis |
| Background Jobs | BullMQ |
| API Documentation | Swagger/OpenAPI |
| Authentication | JWT + OTP |
| Validation | DTO + class-validator / Zod where useful |

---

## 7. AI Stack

| Component | Technology |
|---|---|
| AI Service | Python |
| API | FastAPI |
| LLM | Provider abstraction |
| Embeddings | Embedding provider |
| Vector DB | PostgreSQL + pgvector |
| Speech-to-Text | STT provider |
| Vision | Vision/OCR provider |

The AI provider should be abstracted so the application isn't tightly coupled to one model vendor.

---

## 8. Admin Stack

- Next.js
- TypeScript
- Tailwind CSS
- TanStack Query

The admin panel is primarily for:

- User management
- Business management
- Support
- Subscriptions
- AI usage
- Knowledge base
- Feature flags
- System monitoring

---

## 9. Flutter Architecture

Use Feature-First Clean Architecture.

```
lib/
│
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── sync/
│   ├── security/
│   └── widgets/
│
└── features/
    ├── auth/
    ├── onboarding/
    ├── dashboard/
    ├── customers/
    ├── suppliers/
    ├── sales/
    ├── purchases/
    ├── products/
    ├── inventory/
    ├── expenses/
    ├── payments/
    ├── reports/
    ├── invoices/
    ├── notifications/
    ├── search/
    ├── ai/
    └── settings/
```

Each feature follows:

```
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

---

## 10. Flutter Data Flow

```
Screen
  ↓
Riverpod Provider
  ↓
Use Case
  ↓
Repository
  ↓
Local / Remote Data Source
  ↓
Drift / REST API
```

The UI should never directly access:

- Dio
- SQLite
- Prisma
- API

All business logic should go through appropriate layers.

---

## 11. Offline-First Architecture

Offline capability is one of the most important technical requirements.

The application should not behave like:

```
UI → API → Database → UI
```

Instead:

```
UI
 ↓
Local Database
 ↓
Immediate UI update
 ↓
Sync Queue
 ↓
Backend
 ↓
PostgreSQL
```

---

## 12. Local Database

Use:

**Drift + SQLite**

Local tables will roughly mirror important server entities.

For example:

- customers
- suppliers
- products
- sales
- sale_items
- purchases
- purchase_items
- payments
- expenses
- inventory
- ledger_entries
- sync_queue

---

## 13. Sync Metadata

Most locally synchronized entities should contain:

- id
- serverId
- createdAt
- updatedAt
- deletedAt
- version
- syncStatus
- lastSyncedAt

Possible statuses:

- PENDING
- SYNCING
- SYNCED
- FAILED
- CONFLICT

---

## 14. Sync Flow

Example: user creates a sale while offline.

```
User
 ↓
Create Sale
 ↓
SQLite
 ↓
UI immediately shows successful sale
 ↓
syncStatus = PENDING
 ↓
Internet becomes available
 ↓
Sync Manager
 ↓
POST /sync
 ↓
NestJS
 ↓
Validate
 ↓
PostgreSQL transaction
 ↓
Return canonical server record
 ↓
SQLite updated
 ↓
syncStatus = SYNCED
```

---

## 15. Sync Conflicts

Financial transactions should generally be treated as immutable.

Instead of:

**Edit Sale**

prefer:

```
Original Sale
     ↓
Reversal
     ↓
Corrected Sale
```

This dramatically reduces synchronization problems.

For normal editable data such as customer names:

- version number
- updatedAt
- conflict resolution policy

can be used.

---

## 16. Backend Architecture

The backend should initially be a modular monolith.

```
src/
├── auth/
├── users/
├── businesses/
├── customers/
├── suppliers/
├── products/
├── inventory/
├── sales/
├── purchases/
├── expenses/
├── payments/
├── ledger/
├── reports/
├── notifications/
├── subscriptions/
├── sync/
├── files/
├── ai/
├── admin/
└── common/
```

This is preferable to microservices for a 3–4 month MVP.

---

## 17. Backend Modules

### Auth

Responsibilities:

- Registration
- OTP
- Login
- Refresh token
- Logout
- Device/session management

### Business

- Business creation
- Business profile
- Business settings
- Members
- Roles

### Customer

- CRUD
- Search
- Balance
- Ledger

### Supplier

- CRUD
- Search
- Balance
- Ledger

### Product

- Product CRUD
- Categories
- Units
- Pricing
- Barcode

### Inventory

- Stock
- Stock movements
- Adjustments
- Low-stock detection

### Sales

- Sales
- Credit sales
- Payments
- Returns
- Receipts

### Purchases

- Purchases
- Supplier payments
- Returns

### Expenses

- Expenses
- Categories
- Payment method

### Reports

- Sales
- Expenses
- Profit
- Receivables
- Payables
- Inventory

### AI

- AI assistant
- Transaction extraction
- Business queries
- AI summaries

---

## 18. Database Architecture

PostgreSQL is the single source of truth.

High-level relationship:

```
User
 │
 └── BusinessMember
        │
        ▼
     Business
        │
 ┌──────┼───────────┬──────────┐
 ▼      ▼           ▼          ▼
Customer Supplier  Product    User
 │        │          │
 ▼        ▼          ▼
Ledger   Ledger   Inventory
 │
 ▼
Transactions
```

---

## 19. User Table

```
User
----
id
phone
email
name
status
createdAt
updatedAt
```

---

## 20. Business Table

```
Business
--------
id
name
type
phone
address
currency
timezone
createdAt
updatedAt
```

---

## 21. BusinessMember

```
BusinessMember
--------------
id
businessId
userId
role
status
createdAt
```

Roles:

- OWNER
- MANAGER
- CASHIER
- ACCOUNTANT

---

## 22. Customer

```
Customer
--------
id
businessId
name
phone
address
notes
openingBalance
status
createdAt
updatedAt
```

---

## 23. Supplier

```
Supplier
--------
id
businessId
name
phone
address
notes
openingBalance
status
createdAt
updatedAt
```

---

## 24. Product

```
Product
-------
id
businessId
name
sku
barcode
categoryId
unit
purchasePrice
sellingPrice
minimumStock
isActive
createdAt
updatedAt
```

---

## 25. Sales

### Sale

```
Sale
----
id
businessId
customerId
invoiceNumber
saleDate
subtotal
discount
total
paidAmount
dueAmount
paymentStatus
status
createdBy
createdAt
updatedAt
```

### SaleItem

```
SaleItem
--------
id
saleId
productId
quantity
unitPrice
discount
total
costPrice
```

`costPrice` should be stored at the time of sale so historical profit remains accurate.

---

## 26. Purchases

### Purchase

```
Purchase
--------
id
businessId
supplierId
purchaseNumber
purchaseDate
subtotal
discount
total
paidAmount
dueAmount
status
createdBy
createdAt
updatedAt
```

### PurchaseItem

```
PurchaseItem
------------
id
purchaseId
productId
quantity
unitCost
total
```

---

## 27. Inventory

### InventoryBalance

```
InventoryBalance
----------------
id
businessId
productId
quantity
reservedQuantity
averageCost
updatedAt
```

### InventoryMovement

```
InventoryMovement
-----------------
id
businessId
productId
type
quantity
referenceType
referenceId
unitCost
createdBy
createdAt
```

Types:

- PURCHASE
- SALE
- SALE_RETURN
- PURCHASE_RETURN
- DAMAGE
- ADJUSTMENT
- TRANSFER_IN
- TRANSFER_OUT

---

## 28. Ledger

Ledger should be the source of truth for customer/supplier balances.

```
LedgerEntry
-----------
id
businessId
accountType
customerId
supplierId
referenceType
referenceId
debit
credit
description
transactionDate
createdAt
```

Example:

```
Credit Sale             +1500
Customer Payment         -500
-----------------------------
Outstanding             +1000
```

---

## 29. Expense

```
Expense
-------
id
businessId
categoryId
amount
paymentMethod
description
expenseDate
createdBy
createdAt
updatedAt
```

---

## 30. Payment

```
Payment
-------
id
businessId
partyType
customerId
supplierId
amount
paymentMethod
reference
paymentDate
createdBy
createdAt
```

Payment methods:

- CASH
- BKASH
- NAGAD
- ROCKET
- BANK
- CARD
- OTHER

---

## 31. Financial Transaction Integrity

A sale should execute inside a PostgreSQL transaction:

```
BEGIN

Create Sale
Create Sale Items
Update Inventory
Create Customer Ledger Entry
Create Payment
Create Payment Ledger Entry

COMMIT
```

If anything fails:

```
ROLLBACK
```

This prevents situations like:

Sale exists but inventory was not reduced.

---

## 32. Idempotency

Mobile applications can retry requests because of poor network conditions.

Therefore critical endpoints should support:

```
Idempotency-Key: device123-sale-987
```

If the same request is received twice:

```
Request 1 → Create sale
Request 2 → Return existing sale
```

rather than creating two sales.

---

## 33. REST API Design

Base URL:

```
/api/v1
```

Endpoints:

- `/api/v1/auth`
- `/api/v1/businesses`
- `/api/v1/customers`
- `/api/v1/suppliers`
- `/api/v1/products`
- `/api/v1/inventory`
- `/api/v1/sales`
- `/api/v1/purchases`
- `/api/v1/expenses`
- `/api/v1/payments`
- `/api/v1/ledger`
- `/api/v1/reports`
- `/api/v1/notifications`
- `/api/v1/ai`
- `/api/v1/sync`

---

## 34. Example Sales API

`POST /api/v1/sales`

Request:

```json
{
  "customerId": "cus_123",
  "items": [
    {
      "productId": "prod_123",
      "quantity": 2,
      "unitPrice": 350
    }
  ],
  "paidAmount": 500,
  "paymentMethod": "CASH"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "id": "sale_123",
    "invoiceNumber": "INV-1001",
    "total": 700,
    "paidAmount": 500,
    "dueAmount": 200
  }
}
```

---

## 35. API Error Format

```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_STOCK",
    "message": "Insufficient stock"
  }
}
```

Use stable error codes so Flutter can handle errors reliably.

---

## 36. Authentication

Recommended:

```
Phone Number
      ↓
OTP
      ↓
Verification
      ↓
Access Token
+
Refresh Token
```

Security:

- Short-lived access token
- Refresh token rotation
- Secure mobile storage
- OTP rate limiting
- Device/session management

---

## 37. Authorization

Example:

```
OWNER
 ├── Everything
 │
MANAGER
 ├── Sales
 ├── Inventory
 ├── Reports
 │
CASHIER
 ├── Sales
 └── Payments
 │
ACCOUNTANT
 ├── Expenses
 ├── Reports
 └── Ledger
```

Eventually permissions should be granular:

- `sales:create`
- `sales:void`
- `inventory:view`
- `inventory:manage`
- `reports:view`
- `users:manage`

---

## 38. AI Architecture

AI should be implemented as a separate Python service.

```
Flutter
   ↓
NestJS
   ↓
AI Service
   ↓
┌──────────────────────┐
│ Intent Detection     │
│ Transaction Extract  │
│ Query Planning       │
│ RAG                  │
│ Prompt Builder       │
└──────────────────────┘
   ↓
LLM
```

---

## 39. AI Transaction Processing

Example input:

> "Rahim 1500 টাকার মাল নিয়েছে, 500 টাকা দিয়েছে।"

AI extracts:

```json
{
  "intent": "CREATE_SALE",
  "customerName": "Rahim",
  "total": 1500,
  "paid": 500,
  "due": 1000
}
```

Then:

```
AI
 ↓
Customer Resolution
 ↓
Validation
 ↓
Preview
 ↓
User Confirmation
 ↓
NestJS
 ↓
Database
```

AI never directly executes SQL.

---

## 40. AI Business Questions

Example:

> "এই মাসে সবচেয়ে বেশি বিক্রি কোন পণ্য?"

Do not answer this from RAG.

Instead:

```
Question
 ↓
Intent Detection
 ↓
Query Planner
 ↓
Validated SQL/Query
 ↓
PostgreSQL
 ↓
Actual Result
 ↓
LLM Explanation
```

This ensures the answer is based on real business data.

---

## 41. RAG Architecture

RAG should be used primarily for static knowledge.

Examples:

- How to use Hisab
- Accounting concepts
- FAQs
- Help documentation
- Business tips
- Feature explanations

Pipeline:

```
Documents
 ↓
Chunking
 ↓
Embedding
 ↓
pgvector
 ↓
Similarity Search
 ↓
Relevant Context
 ↓
LLM
```

---

## 42. Why Not Use RAG for Financial Data?

Suppose the user asks:

> "How much does Rahim owe me?"

RAG might return outdated information.

Instead:

```
User
 ↓
Business Query
 ↓
PostgreSQL
 ↓
Current Ledger
 ↓
AI Explanation
```

Therefore:

- **RAG = knowledge**
- **PostgreSQL = business truth**

---

## 43. AI Guardrails

AI must:

- Never invent amounts
- Never invent customers
- Never modify financial data silently
- Never bypass validation
- Never execute unconfirmed transactions
- Return structured data
- Ask clarification when ambiguous

Example:

> "I found three customers named Rahim. Which Rahim do you mean?"

---

## 44. Voice Hisab

Advanced feature:

```
Voice
 ↓
Speech-to-Text
 ↓
Bangla/Banglish Text
 ↓
Intent Extraction
 ↓
Transaction Preview
 ↓
Confirmation
 ↓
Backend
```

Example:

> "রহিমকে এক হাজার টাকার মাল দিলাম, ৩০০ টাকা দিয়েছে।"

AI converts it into structured data.

---

## 45. Redis

Redis should be used for:

- Cache
- OTP throttling
- Rate limiting
- Temporary state
- AI usage limits
- Distributed locks

It should not be the financial source of truth.

---

## 46. BullMQ

BullMQ handles asynchronous tasks:

```
Sale Created
      │
      ├── Generate Receipt
      ├── Update Analytics
      ├── Send Notification
      └── Update AI Summary
```

Other jobs:

- Payment reminders
- Daily summaries
- PDF generation
- Export
- AI processing
- Notifications

---

## 47. File Storage

Use S3-compatible storage for:

- Business logo
- Product images
- Invoice PDFs
- Export files
- Attachments

PostgreSQL stores:

- objectKey
- mimeType
- size
- createdAt

Use signed URLs for private files.

---

## 48. Notifications

Use:

**Firebase Cloud Messaging**

Examples:

- Customer payment due
- Low stock
- Supplier payment reminder
- Daily business summary
- Daily closing reminder

For local reminders:

**flutter_local_notifications**

---

## 49. Search

MVP search should use PostgreSQL.

Use:

- Full-text search
- Trigram search

Search entities:

- Customer
- Supplier
- Product
- Invoice
- Transaction

Avoid Elasticsearch initially.

---

## 50. Admin Dashboard

Next.js admin dashboard:

```
Dashboard
├── Users
├── Businesses
├── Subscriptions
├── AI Usage
├── Support
├── Reports
├── Knowledge Base
├── Notifications
├── Feature Flags
└── System Health
```

---

## 51. Multi-Tenancy

Each business is a tenant.

Every business-owned table should contain:

`businessId`

Example:

- `customers.businessId`
- `products.businessId`
- `sales.businessId`
- `expenses.businessId`
- `payments.businessId`

Every query must be scoped:

```sql
WHERE businessId = currentBusinessId
```

This is extremely important to prevent cross-business data leakage.

---

## 52. Security

Required:

- HTTPS
- JWT
- Secure token storage
- OTP throttling
- API rate limiting
- RBAC
- Input validation
- File validation
- Audit logs
- Database backups
- Secure secrets management
- Device/session management

---

## 53. Audit Logs

Important actions should be logged.

```
AuditLog
--------
id
businessId
userId
action
entityType
entityId
before
after
timestamp
deviceId
ip
```

Examples:

- SALE_CREATED
- SALE_VOIDED
- PAYMENT_CREATED
- PRODUCT_UPDATED
- USER_ROLE_CHANGED

Financial records should generally be reversed rather than physically deleted.

---

## 54. Reporting

MVP reports:

### Sales

- Today
- This Week
- This Month
- Custom Date

### Expenses

- By Category
- By Date

### Profit

- Revenue
- COGS
- Gross Profit
- Expenses
- Estimated Net Profit

### Due

- Customer Receivables
- Supplier Payables

### Inventory

- Stock
- Low Stock
- Inventory Value

---

## 55. Profit Calculation

Basic calculation:

```
Revenue
= Selling Price × Quantity
COGS
= Historical Cost × Quantity
Gross Profit
= Revenue - COGS
Net Profit
= Gross Profit - Expenses
```

The exact inventory costing method should be finalized before production reporting.

Possible methods:

- FIFO
- Weighted Average

---

## 56. MVP Screens

### Authentication

- Splash
- Login
- OTP
- Business Setup

### Dashboard

- Today's Sales
- Today's Expenses
- Customer Due
- Supplier Due
- Cash Balance
- Low Stock
- Quick Actions

### Customers

- Customer List
- Customer Details
- Customer Ledger
- Add Payment

### Suppliers

- Supplier List
- Supplier Details
- Supplier Ledger
- Add Payment

### Sales

- Sales List
- New Sale
- Sale Details
- Receipt

### Purchases

- Purchase List
- New Purchase
- Purchase Details

### Products

- Product List
- Add Product
- Product Details
- Stock

### Expenses

- Expense List
- Add Expense

### Reports

- Sales
- Expenses
- Profit
- Customer Due
- Supplier Due
- Inventory

### AI

- Ask Hisab
- Transaction Assistant

---

## 57. Main User Flow — Sale

```
Dashboard
     ↓
+ বিক্রি
     ↓
Select Customer
     ↓
Add Products
     ↓
Quantity
     ↓
Price
     ↓
Discount
     ↓
Total
     ↓
Payment
     ↓
Save
     ↓
Receipt
```

Offline:

```
Save → Local DB → Receipt → Sync Later
```

---

## 58. Customer Payment Flow

```
Customer
 ↓
Customer Details
 ↓
টাকা পেলাম
 ↓
Amount
 ↓
Payment Method
 ↓
Confirm
 ↓
Ledger Updated
 ↓
Sync
```

---

## 59. AI Transaction Flow

```
User
 ↓
Text / Voice
 ↓
AI
 ↓
Intent
 ↓
Customer/Product Resolution
 ↓
Validation
 ↓
Transaction Preview
 ↓
User Confirmation
 ↓
NestJS
 ↓
PostgreSQL Transaction
 ↓
Success
```

---

## 60. CI/CD

GitHub Actions:

```
Pull Request
 ↓
Lint
 ↓
Unit Tests
 ↓
Integration Tests
 ↓
Build
 ↓
Docker Image
 ↓
Deploy
```

Flutter:

```
Flutter Analyze
 ↓
Flutter Test
 ↓
Android Build
 ↓
iOS Build
 ↓
TestFlight / Play Store
```

---

## 61. Environments

Maintain:

- Development
- Staging
- Production

Each should have separate:

- Database
- Redis
- Storage
- API credentials
- AI credentials
- Firebase credentials

Never use production credentials during development.

---

## 62. Backup Strategy

PostgreSQL:

- Automated backups
- Point-in-time recovery if supported
- Backup retention
- Off-site backup
- Restore testing

Suggested initial targets:

- **RPO:** 15–60 minutes
- **RTO:** 1–4 hours

Exact targets depend on infrastructure and budget.

---

## 63. Observability

Use:

**Sentry**

Log:

- requestId
- userId
- businessId
- endpoint
- duration
- statusCode
- errorCode

Monitor:

- API latency
- Error rate
- Database latency
- Queue depth
- AI latency
- AI cost
- Sync failure rate
- Authentication failures

---

## 64. Performance Targets

Initial targets:

| Metric | Target |
|---|---|
| API p95 | <500ms |
| Local transaction response | <100ms perceived |
| Search | <300ms |
| Dashboard | <1 sec where practical |
| AI response | ~2–4 sec where practical |

Most importantly:

Recording a basic transaction should not depend on network availability.

---

## 65. Repository Structure

A monorepo is recommended:

```
hisab/
│
├── apps/
│   ├── mobile/
│   ├── api/
│   ├── ai-service/
│   └── admin/
│
├── packages/
│   ├── api-contracts/
│   ├── shared-types/
│   └── design-tokens/
│
├── infrastructure/
│   ├── docker/
│   ├── terraform/
│   └── environments/
│
├── docs/
│   ├── architecture/
│   ├── api/
│   ├── database/
│   └── product/
│
└── .github/
    └── workflows/
```

---

## 66. Development Standards

### Flutter

- Strict linting
- Immutable models
- Feature-first architecture
- No business logic inside widgets
- Repository abstraction
- Riverpod for dependency/state management

### NestJS

- Strict TypeScript
- DTO validation
- Thin controllers
- Business logic in services/domain layer
- Prisma repository/data-access patterns
- Unit and integration tests

### Python

- Type hints
- Pydantic
- FastAPI
- Structured logging
- Automated tests

---

## 67. Testing Strategy

### Flutter

- Unit Tests
- Repository Tests
- Provider Tests
- Widget Tests
- Integration Tests

### Backend

- Unit Tests
- Service Tests
- Controller Tests
- Integration Tests
- Database Tests
- Authorization Tests

### AI

Test:

- Bangla
- Banglish
- English
- Mixed language
- Ambiguous names
- Missing values
- Incorrect values
- Duplicate customers

---

## 68. Critical Financial Tests

Must test:

- Normal Sale
- Credit Sale
- Partial Payment
- Full Payment
- Customer Payment
- Purchase
- Supplier Payment
- Sale Return
- Purchase Return
- Stock Adjustment
- Offline Sale
- Offline Payment
- Sync Retry
- Duplicate Sync
- Concurrent Updates

These tests are more important than cosmetic features.

---

## 69. Subscription Architecture

Entities:

- Plan
- Subscription
- SubscriptionEvent
- UsageRecord

Potential usage limits:

- Number of Customers
- Number of Products
- Number of Transactions
- AI Usage
- Storage
- Users
- Branches

Subscription enforcement should happen on the backend.

---

## 70. Feature Flags

Feature flags:

- AI_ASSISTANT
- VOICE_HISAB
- BARCODE
- MULTI_BRANCH
- COURIER_INTEGRATION
- DIGITAL_PAYMENTS
- ADVANCED_REPORTS

This allows gradual rollout.

---

## 71. Analytics

Track product events:

- app_opened
- business_created
- customer_created
- sale_created
- payment_recorded
- expense_created
- product_created
- purchase_created
- report_viewed
- ai_question
- ai_transaction_extraction
- voice_transaction
- receipt_shared
- subscription_started
- subscription_cancelled

Do not send unnecessary sensitive financial data to analytics systems.

---

## 72. 16-Week MVP Development Plan

### Weeks 1–2 — Foundation

**Backend**

- NestJS setup
- PostgreSQL
- Prisma
- Authentication
- Business model
- CI/CD

**Flutter**

- Flutter project
- Riverpod
- GoRouter
- Design system
- Drift
- API client

**UX**

- Navigation
- Core screens
- Dashboard prototype

---

## 73. Weeks 3–4 — Customers & Suppliers

Implement:

- Customer CRUD
- Supplier CRUD
- Search
- Customer ledger
- Supplier ledger
- Payments
- Opening balance

---

## 74. Weeks 5–7 — Sales & Purchases

Implement:

- New sale
- Sale details
- Credit sale
- Payments
- Purchase
- Purchase details
- Returns
- Receipt basics
- Financial transactions

This is one of the most important phases.

---

## 75. Weeks 8–9 — Inventory

Implement:

- Product CRUD
- Categories
- Stock
- Stock movements
- Purchase stock
- Sale stock deduction
- Returns
- Low-stock alerts

---

## 76. Weeks 10–11 — Expenses & Reports

Implement:

- Expenses
- Expense categories
- Dashboard
- Sales reports
- Expense reports
- Profit
- Customer dues
- Supplier dues
- Inventory reports

---

## 77. Weeks 12–13 — Offline Sync

Implement:

- Drift schema
- Local repositories
- Sync queue
- Retry
- Network detection
- Idempotency
- Conflict handling
- Server versioning

This should be treated as a core engineering phase rather than a final add-on.

---

## 78. Week 14 — Receipts & Notifications

Implement:

- PDF receipts
- Share receipt
- Push notifications
- Due reminders
- Low-stock notifications

---

## 79. Week 15 — AI

Implement:

- Python AI service
- Ask Hisab
- Business query assistant
- Natural-language transaction extraction
- Structured AI responses
- Guardrails
- Confirmation workflow

---

## 80. Week 16 — Hardening

Focus on:

- Security
- Performance
- QA
- Offline edge cases
- Database testing
- Monitoring
- Backup/restore
- App Store preparation
- Play Store preparation

---

## 81. Recommended Team

For a realistic 3–4 month MVP:

### 1. Flutter Developer

Responsible for:

- Mobile architecture
- UI
- Offline database
- Sync
- API integration

### 2. Backend Developer

Responsible for:

- NestJS
- PostgreSQL
- Prisma
- APIs
- Authentication
- Financial logic

### 3. Full-stack/AI Developer

Responsible for:

- Python
- FastAPI
- LLM integration
- RAG
- Admin
- AI workflows

### 4. UI/UX Designer

Part-time can be sufficient initially.

### 5. QA Engineer

Especially important from the sales/inventory phase onward.

### 6. Product/Engineering Lead

Owns:

- Requirements
- Architecture
- Product decisions
- Sprint planning
- Technical quality

---

## 82. Infrastructure Recommendation

### Option A — AWS

```
CloudFront
     ↓
Load Balancer
     ↓
ECS/Fargate
 ├── NestJS
 └── FastAPI
     ↓
RDS PostgreSQL
     +
ElastiCache Redis
     +
S3
```

### Option B — Lower Initial Cost

```
DigitalOcean
 ├── Container/App
 ├── Managed PostgreSQL
 ├── Managed Redis
 └── Spaces
```

For MVP, I would favor managed infrastructure and avoid Kubernetes.

---

## 83. Scaling Strategy

### Stage 1 — MVP

- NestJS Modular Monolith
- PostgreSQL
- Redis
- Python AI Service

### Stage 2 — Growth

Add:

- Read replicas
- More background workers
- Better caching
- Query optimization
- Analytics database
- Dedicated AI workers

### Stage 3 — Large Scale

Potentially extract:

- AI Service
- Notification Service
- Reporting Service
- Search Service
- Sync Service

Do not split these into microservices prematurely.

---

## 84. Key Technical Risks

### Risk 1 — Incorrect Financial Data

Mitigation:

- PostgreSQL transactions
- Ledger
- Immutable transactions
- Automated tests

### Risk 2 — Offline Sync

Mitigation:

- Idempotency
- Versioning
- Sync queue
- Immutable financial transactions

### Risk 3 — AI Hallucination

Mitigation:

- Structured output
- Database grounding
- Confirmation
- Guardrails

### Risk 4 — Bangla/Banglish Recognition

Mitigation:

- Build a real Bangla/Banglish test dataset
- Evaluate STT models
- Support user correction
- Track failed AI interpretations

### Risk 5 — Infrastructure Complexity

Mitigation:

- Modular monolith
- Managed PostgreSQL
- Managed Redis
- Docker
- No Kubernetes initially

---

## 85. Architecture Decision Summary

| Area | Decision |
|---|---|
| Mobile | Flutter |
| State Management | Riverpod |
| Navigation | GoRouter |
| Local DB | Drift + SQLite |
| HTTP | Dio |
| Models | Freezed |
| Backend | NestJS |
| HTTP Server | Fastify |
| ORM | Prisma |
| Database | PostgreSQL |
| Cache | Redis |
| Jobs | BullMQ |
| AI | Python + FastAPI |
| RAG | pgvector |
| Admin | Next.js |
| API | REST |
| Streaming | SSE where useful |
| Auth | Phone OTP + JWT |
| Storage | S3 |
| Push | FCM |
| Monitoring | Sentry |
| CI/CD | GitHub Actions |
| Deployment | Docker |
| Architecture | Modular Monolith |
| Mobile Strategy | Offline-first |

---

## 86. Final Architecture

```
                         HISAB
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
      Flutter           Next.js          AI Service
      Mobile             Admin           Python/FastAPI
          │                │                │
          └──────────┬─────┴────────────────┘
                     │
                     ▼
               NestJS Backend
                     │
        ┌────────────┼─────────────┐
        │            │             │
        ▼            ▼             ▼
   PostgreSQL      Redis          S3
   Financial      Cache/Jobs     Files
   Truth
        │
        ▼
   Business Data
        │
        ├── Customers
        ├── Suppliers
        ├── Sales
        ├── Purchases
        ├── Inventory
        ├── Expenses
        ├── Payments
        ├── Ledgers
        └── Reports
```

---

## 87. Most Important Design Principle

The most important architectural decision for Hisab is this:

```
                 AI
                  │
                  ▼
           Understand Intent
                  │
                  ▼
          Structured Request
                  │
                  ▼
              Validate
                  │
                  ▼
          Business Rules
                  │
                  ▼
          User Confirmation
                  │
                  ▼
          NestJS Transaction
                  │
                  ▼
             PostgreSQL
```

Never:

```
User → AI → Database
```

This separation will allow Hisab to provide powerful AI functionality while keeping financial information trustworthy.

---

## 88. Final Product Philosophy

Hisab should not try to become a complicated ERP.

Its competitive advantage should be:

> "Business হিসাব রাখুন সহজে — even without internet, and let AI help you understand your business."

The technology should therefore prioritize:

- Offline-first operation
- Financial correctness
- Extremely fast transaction entry
- Bangla/Banglish usability
- Reliable synchronization
- Deterministic backend logic
- AI-assisted workflows
- Simple infrastructure
- Scalable architecture
- A clear path toward advanced AI and multi-branch business management

This architecture is realistic for a 3–4 month MVP and gives Hisab a clean path from a small-business ledger app into a much broader AI-powered business operating system for Bangladeshi SMEs.
