// Money movements: the only way a taka is recorded, corrected or counted.
//
// AR-29 — repositories are the sole database surface. No widget, no notifier
// and no service reaches Drift; they reach this class through a provider, and
// `tool/check_data_access.dart` fails the build on a `package:drift` import
// outside `lib/data/`.
//
// Everything here obeys two rules that the rest of the product then inherits:
//
//   * **Append-only (AD-4).** There is no `update` and no `delete` method, and
//     if one were added the database's triggers would abort it anyway. A
//     correction is [correctOpeningBalance]: a reversal row plus a new row, in
//     one transaction, with the original untouched.
//   * **No stored balance (AD-19).** [balancePaisa] sums the movements every
//     time it is asked. There is nowhere for a balance to go stale, and no
//     column an accidental write could change money through.
//
// Nothing here formats a figure. Money crosses this boundary as integer paisa
// and is rendered by `lib/format/` at the display edge (AD-1, UX-DR4).

import 'package:drift/drift.dart';

import '../business_date.dart';
import '../db/database.dart';
import '../db/tables.dart';
import '../ids.dart';

/// The two rows a correction writes, returned together so the caller never has
/// to go looking for the half it did not get.
class OpeningBalanceCorrection {
  const OpeningBalanceCorrection({
    required this.reversal,
    required this.replacement,
  });

  /// The row that undoes the original: the same magnitude, opposite sign,
  /// carrying `reversesId`.
  final MoneyMovement reversal;

  /// The row that states the corrected figure.
  final MoneyMovement replacement;
}

/// Raised when a caller tries to correct a movement that is already corrected.
///
/// Reversing a reversal chain twice would double the undo, and the resulting
/// balance would be wrong by the original amount with nothing in the data to
/// say which of the two reversals was the mistake.
class AlreadyReversedException implements Exception {
  const AlreadyReversedException(this.movementId);

  final String movementId;

  @override
  String toString() =>
      'AlreadyReversedException: movement $movementId has already been '
      'reversed. Read the current figure and correct that instead.';
}

class MoneyMovementRepository {
  const MoneyMovementRepository(this._db);

  final HisabDatabase _db;

  /// Records one movement.
  ///
  /// [amountPaisa] is signed: money in is positive, money out is negative.
  /// [at] is the UTC instant, defaulting to now; the business date is derived
  /// from it ONCE, here, and stored (AD-14) — no later reader recomputes it.
  Future<MoneyMovement> record({
    required String businessId,
    required String moneyAccountId,
    required int amountPaisa,
    required MoneyMovementType type,
    DateTime? at,
    String? note,
    String? reversesId,
  }) async {
    final DateTime instant = (at ?? DateTime.now()).toUtc();
    final String id = HisabIds.newId();

    await _db.into(_db.moneyMovements).insert(
      MoneyMovementsCompanion.insert(
        id: id,
        businessId: businessId,
        createdAtUtc: instant,
        businessDate: BusinessDate.of(instant),
        moneyAccountId: moneyAccountId,
        amountPaisa: amountPaisa,
        type: type,
        reversesId: Value<String?>(reversesId),
        note: Value<String?>(note),
      ),
    );

    return byId(id);
  }

  /// FR-4 — the opening balance the owner entered at setup.
  ///
  /// A blank field writes NOTHING. The caller skips this method for an account
  /// the owner left empty: a blank is not a zero, and a zero-paisa opening
  /// movement would claim the owner said the account was empty when they said
  /// nothing at all.
  Future<MoneyMovement> recordOpeningBalance({
    required String businessId,
    required String moneyAccountId,
    required int amountPaisa,
    DateTime? at,
  }) {
    return record(
      businessId: businessId,
      moneyAccountId: moneyAccountId,
      amountPaisa: amountPaisa,
      type: MoneyMovementType.opening,
      at: at,
    );
  }

  /// FR-113 — the owner changes an opening balance they already entered.
  ///
  /// Writes a reversal of the original plus a new movement, in ONE transaction,
  /// and leaves the original row exactly as it was written. Both rows carry the
  /// same business date as the original, so the correction lands on the day the
  /// money was said to be there rather than on the day the owner noticed the
  /// mistake.
  Future<OpeningBalanceCorrection> correctOpeningBalance({
    required String movementId,
    required int newAmountPaisa,
    DateTime? at,
  }) {
    return _db.transaction(() async {
      final MoneyMovement original = await byId(movementId);
      if (original.type != MoneyMovementType.opening) {
        throw ArgumentError.value(
          movementId,
          'movementId',
          'is not an opening balance',
        );
      }
      if (await isReversed(movementId)) {
        throw AlreadyReversedException(movementId);
      }

      final DateTime instant = (at ?? DateTime.now()).toUtc();

      final MoneyMovement reversal = await _insertOn(
        original: original,
        amountPaisa: -original.amountPaisa,
        instant: instant,
        reversesId: original.id,
      );
      final MoneyMovement replacement = await _insertOn(
        original: original,
        amountPaisa: newAmountPaisa,
        instant: instant,
        reversesId: null,
      );

      return OpeningBalanceCorrection(
        reversal: reversal,
        replacement: replacement,
      );
    });
  }

  Future<MoneyMovement> _insertOn({
    required MoneyMovement original,
    required int amountPaisa,
    required DateTime instant,
    required String? reversesId,
  }) async {
    final String id = HisabIds.newId();
    await _db.into(_db.moneyMovements).insert(
      MoneyMovementsCompanion.insert(
        id: id,
        businessId: original.businessId,
        createdAtUtc: instant,
        // The original's business date, not today's: a correction restates what
        // was true on that day (AD-14).
        businessDate: original.businessDate,
        moneyAccountId: original.moneyAccountId,
        amountPaisa: amountPaisa,
        type: original.type,
        reversesId: Value<String?>(reversesId),
      ),
    );
    return byId(id);
  }

  /// AD-19 — the account's balance, in paisa, computed now.
  ///
  /// `SUM(amount_paisa)` and nothing else. Written as SQL rather than pulled
  /// into Dart because the sum belongs in the database: a hundred thousand
  /// movements must not become a hundred thousand rows crossing the boundary
  /// so Dart can add them up.
  ///
  /// An account with no movements is 0, not null — the shop has no money in it,
  /// which is a figure, not a missing answer.
  Future<int> balancePaisa(String moneyAccountId) async {
    final QueryRow row = await _db
        .customSelect(
          'SELECT COALESCE(SUM(amount_paisa), 0) AS balance_paisa '
          'FROM money_movements WHERE money_account_id = ?',
          variables: [Variable<String>(moneyAccountId)],
          readsFrom: {_db.moneyMovements},
        )
        .getSingle();
    return row.read<int>('balance_paisa');
  }

  /// The same sum across every account of one Business — FR-12's total.
  Future<int> totalBalancePaisa(String businessId) async {
    final QueryRow row = await _db
        .customSelect(
          'SELECT COALESCE(SUM(amount_paisa), 0) AS balance_paisa '
          'FROM money_movements WHERE business_id = ?',
          variables: [Variable<String>(businessId)],
          readsFrom: {_db.moneyMovements},
        )
        .getSingle();
    return row.read<int>('balance_paisa');
  }

  /// One account's history, in the product's canonical order.
  ///
  /// `(businessDate, id)` — the owner-stated day first, then the UUIDv7, which
  /// is time-ordered, so two movements on the same day come back in the order
  /// they were entered. The same ordering rule AD-7 uses for FIFO consumption,
  /// for the same reason: two devices must compute it identically.
  Future<List<MoneyMovement>> forAccount(String moneyAccountId) {
    return (_db.select(_db.moneyMovements)
          ..where((t) => t.moneyAccountId.equals(moneyAccountId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.businessDate),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .get();
  }

  /// A live view of one account's history, for a screen that must update the
  /// moment a movement is written.
  Stream<List<MoneyMovement>> watchAccount(String moneyAccountId) {
    return (_db.select(_db.moneyMovements)
          ..where((t) => t.moneyAccountId.equals(moneyAccountId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.businessDate),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .watch();
  }

  /// One movement, by id.
  Future<MoneyMovement> byId(String id) {
    return (_db.select(_db.moneyMovements)
          ..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// "Has this been reversed?" — a lookup, not a stored flag.
  ///
  /// The reversing row points back at the original with `reversesId`. Nothing
  /// is ever written onto the original, because writing onto it would be an
  /// UPDATE on a financial row (AD-4). This is the read that replaces the
  /// `reversedById` column AD-15 names for `Sale`; Epic 4 meets the same
  /// question, and the divergence is recorded in the story spec rather than
  /// discovered there.
  Future<bool> isReversed(String movementId) async {
    final List<MoneyMovement> reversals =
        await (_db.select(_db.moneyMovements)
              ..where((t) => t.reversesId.equals(movementId))
              ..limit(1))
            .get();
    return reversals.isNotEmpty;
  }
}
