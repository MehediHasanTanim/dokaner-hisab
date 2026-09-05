// The four tables Epic 1 needs. Not one more.
//
// AR-17 / the epic context: create ONLY User, Business, MoneyAccount and
// MoneyMovement — not the full schema upfront. Every later table (Customer,
// Product, Sale, LedgerEntry, StockMovement, CostLayer...) arrives with the
// story that needs it, applying the same mixins from `columns.dart` and taking
// its line in `classification.dart`.
//
// What is deliberately absent, and must stay absent:
//
//   * No `openingBalancePaisa`, anywhere (AD-19). An opening balance is a
//     MoneyMovement of type `opening`.
//   * No balance column on MoneyAccount (AD-19). A balance is
//     `SUM(money_movements.amount_paisa)` computed at read time and nothing
//     else. A stored balance is a path to change money with no reversal and no
//     trace, and it goes stale the moment a row is backdated.
//   * No `serverId` (AD-3). One identity per record.
//   * No currency column on Business. Currency is BDT, displayed and not
//     editable in MVP; a column would imply a choice that does not exist.
//   * No unique constraint anywhere except the primary key (AD-10). A unique
//     index on a financial table aborts a sync envelope and makes the device
//     retry it forever.
//   * No `double`. Money is integer paisa (AD-1), quantity is integer
//     milli-units (AD-2).

import 'package:drift/drift.dart';

import 'columns.dart';

/// The fixed PRD list of business types (FR-2).
///
/// Stored as the enum's `name`, so a new type is a new value with no migration.
enum BusinessType {
  grocery,
  clothing,
  electronics,
  restaurant,
  pharmacy,
  hardware,
  cosmetics,
  mobileAndAccessories,
  wholesale,
  onlineBusiness,
  other,
}

/// The five places a shop's money sits (FR-4, FR-12, PRD glossary).
///
/// The PRD fixes these five and says nothing about owner-added accounts, so
/// nothing here creates one and nothing here forbids one later: the table holds
/// a type and a display name, which is the shape that takes a sixth account
/// without a migration. This story does not decide whether that ever happens.
enum MoneyAccountType { cash, bkash, nagad, rocket, bank }

/// Why a MoneyMovement exists.
///
/// **Only `opening` is defined, on purpose.** It is the one value Epic 1 can
/// state from the requirements (FR-4, AD-19). Later stories add the values they
/// need — a customer payment, a supplier payment, an expense, an account
/// transfer — and because the column is TEXT holding the enum's `name`, adding
/// a value costs no migration. Inventing `payment`/`expense`/`transfer` now
/// would be guessing at the shape of stories that have not been specified, and
/// a wrong guess here is inherited by every table in every later epic.
enum MoneyMovementType {
  /// FR-4's Opening Balance: the money the shop already had on the day the
  /// owner set Hisab up. It counts toward a Money Account balance and never
  /// toward Sales, Expense or Profit.
  opening,
}

/// The owner. Reference data (AD-9): a name and an email are editable.
///
/// One row per signed-in owner on this device. The phone number comes from the
/// authenticated session (FR-3) and is not re-entered.
@DataClassName('User')
class Users extends Table with HisabRow, Timestamped, Mutable {
  /// The authenticated Bangladeshi mobile number, `+8801XXXXXXXXX` (FR-1).
  TextColumn get phone => text().withLength(min: 8, max: 20)();

  /// Required. Drives the Home greeting (FR-3).
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Optional, format-validated at entry, used only for recovery and for
  /// receipts the owner chooses to email (FR-3).
  TextColumn get email => text().nullable()();

  /// AD-11 — the Business this owner belongs to.
  ///
  /// NULLABLE, and this is the one place tenancy is not yet known: Story 1.5
  /// signs the owner in before Story 1.7 creates the Business, so between those
  /// two screens a User row exists with no Business. It is set once, when the
  /// Business is created, and never widened afterwards. Every query that reads
  /// shop data still scopes on a non-null businessId — this column is the
  /// owner's membership, not a query filter.
  TextColumn get businessId =>
      text().withLength(min: 36, max: 36).nullable()();
}

/// The shop. Reference data (AD-9): name, type and address are all editable.
///
/// Exactly one Business per owner (FR-2). This table does NOT use
/// [BusinessScoped]: its own `id` is the business id every other table stores,
/// and a second column holding the same value could only ever disagree with
/// itself. `tool/check_data_access.dart` knows about this one exception by name.
@DataClassName('Business')
class Businesses extends Table with HisabRow, Timestamped, Mutable {
  /// 1-100 characters, required (FR-2).
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// One of the fixed PRD list.
  TextColumn get type => textEnum<BusinessType>()();

  /// Optional free text. Appears on receipts when present (FR-2).
  TextColumn get address => text().nullable()();

  /// The owner who created it. On creation the User is assigned the Owner role
  /// for this Business (FR-2); roles themselves are not modelled in Epic 1.
  TextColumn get ownerUserId => text().withLength(min: 36, max: 36)();
}

/// A place the Business's money sits. Reference data — AD-19 says so in as many
/// words, and that is why there is no balance column here.
///
/// Nothing in this story writes a row. The five accounts are seeded by the
/// story that creates a Business, and the opening balances by FR-4's screen.
@DataClassName('MoneyAccount')
class MoneyAccounts extends Table
    with HisabRow, BusinessScoped, Timestamped, Mutable {
  /// Cash, bKash, Nagad, Rocket or Bank.
  TextColumn get type => textEnum<MoneyAccountType>()();

  /// What the owner sees. Held separately from [type] so the label can be
  /// translated, or an owner-named account added, without the type meaning
  /// something new.
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// An account the owner has stopped using. Hidden from entry screens; its
  /// movements stay in the ledger, because deleting them would change history.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  // NO balance column. AD-19: a Money Account's balance is
  // `SUM(money_movements.amount_paisa)` and nothing else. See
  // `MoneyMovementRepository.balancePaisa`.
}

/// Every taka that enters or leaves an account. FINANCIAL — append-only (AD-4).
///
/// The database installs BEFORE UPDATE and BEFORE DELETE triggers on this table
/// (see `database.dart`); an attempt to change a written row aborts. A
/// correction is a reversal row plus a new row, in one transaction.
@DataClassName('MoneyMovement')
class MoneyMovements extends Table
    with HisabRow, BusinessScoped, Timestamped, BusinessDated, AppendOnly {
  /// The account this moved through.
  TextColumn get moneyAccountId =>
      text().withLength(min: 36, max: 36).references(MoneyAccounts, #id)();

  /// AD-1 — integer paisa, SIGNED. Money in is positive, money out is
  /// negative, and a balance is the plain sum. A separate `direction` column
  /// would let a sign and a direction disagree; here the sign IS the direction.
  ///
  /// (AD-20 requires a non-negative amount plus a direction on LedgerEntry,
  /// which is a different table for a different reason: a party ledger is read
  /// from the Business's perspective and a debit is not a negative credit. A
  /// money account has one perspective, so it needs one number.)
  IntColumn get amountPaisa => integer()();

  /// Why this movement exists. Only `opening` is defined in Epic 1.
  TextColumn get type => textEnum<MoneyMovementType>()();

  /// AD-4 — set on a REVERSING row, pointing back at the row it undoes.
  ///
  /// The direction of this link is deliberate and is a recorded divergence from
  /// AD-15's wording for `Sale`. The reversal carries `reversesId`; the
  /// original carries nothing. Marking the original as reversed would mean
  /// UPDATEing a financial row, which AD-4 forbids and the triggers on this
  /// table physically prevent. "Was this reversed?" is therefore a read-time
  /// lookup — `WHERE reverses_id = ?` — not a stored flag. Epic 4 will meet the
  /// same question on Sale and should meet it as a known decision.
  ///
  /// Not a foreign key by declaration: the row it points at is in this same
  /// append-only table and can never be deleted, so the constraint would only
  /// add an index and a way for a sync envelope to abort (AD-10's corollary).
  TextColumn get reversesId =>
      text().withLength(min: 36, max: 36).nullable()();

  /// Free text the owner may attach. Never parsed, never summed.
  TextColumn get note => text().nullable()();
}
