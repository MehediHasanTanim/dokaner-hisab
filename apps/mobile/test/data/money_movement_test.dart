// Money movements: the append-only rule, and the balance that is never stored.
//
// This is the financial suite for Story 1.4, and AR-28 makes the financial
// suite a release gate on every epic. Everything asserted here is inherited by
// Sale, Purchase, Payment, Expense and LedgerEntry in later epics, so a
// regression here is not a Story 1.4 bug — it is a bug in every table that
// comes after it.
//
// The scenarios are the story's edge-case matrix, in its order.

import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/data/business_date.dart';
import 'package:hisab/data/db/database.dart';
import 'package:hisab/data/db/tables.dart';
import 'package:hisab/data/repositories/business_repository.dart';
import 'package:hisab/data/repositories/money_account_repository.dart';
import 'package:hisab/data/repositories/money_movement_repository.dart';
import 'package:hisab/data/repositories/user_repository.dart';

import 'support/database.dart';

/// The instant every fixture is written at: 17:00 UTC, which is 23:00 in
/// Dhaka — the same business day, and far enough from the boundary that a slow
/// test machine cannot roll it over.
final DateTime kSetupInstant = DateTime.utc(2026, 9, 5, 17);

void main() {
  late HisabDatabase db;
  late MoneyAccountRepository accounts;
  late MoneyMovementRepository movements;
  late Business business;
  late MoneyAccount cash;
  late MoneyAccount bkash;

  setUp(() async {
    db = await openTestDatabase();
    accounts = MoneyAccountRepository(db);
    movements = MoneyMovementRepository(db);

    final User owner = await UserRepository(db).create(
      phone: '+8801712345678',
      name: 'Rahman',
      at: kSetupInstant,
    );
    business = await BusinessRepository(db).create(
      name: 'Rahman Grocery',
      type: BusinessType.grocery,
      ownerUserId: owner.id,
      at: kSetupInstant,
    );
    cash = await accounts.create(
      businessId: business.id,
      type: MoneyAccountType.cash,
      name: 'Cash',
      at: kSetupInstant,
    );
    bkash = await accounts.create(
      businessId: business.id,
      type: MoneyAccountType.bkash,
      name: 'bKash',
      at: kSetupInstant,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('FR-4 — the opening balance is a movement, not a column', () {
    test('5,000 taka on Cash writes one movement of 500000 paisa', () async {
      final MoneyMovement opening = await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );

      expect(opening.amountPaisa, 500000);
      expect(opening.type, MoneyMovementType.opening);
      expect(opening.reversesId, isNull);
      expect(opening.businessId, business.id);
      expect(opening.createdAtUtc.isUtc, isTrue);
      expect(opening.businessDate, BusinessDate.of(kSetupInstant));
      expect(await movements.forAccount(cash.id), hasLength(1));
      expect(await movements.balancePaisa(cash.id), 500000);
    });

    test('an account the owner left blank gets no row at all', () async {
      await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );

      expect(
        await movements.forAccount(bkash.id),
        isEmpty,
        reason: 'a blank is not a zero — a zero-paisa opening movement would '
            'claim the owner said the account was empty',
      );
      expect(
        await movements.balancePaisa(bkash.id),
        0,
        reason: 'no movements is a balance of zero, not a missing answer',
      );
    });

    test('the business date comes from the instant, not from today', () async {
      final MoneyMovement evening = await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 100,
        at: DateTime.utc(2026, 9, 5, 23),
      );
      expect(
        evening.businessDate,
        '2026-09-06',
        reason: '23:00 UTC is already the 6th in Dhaka (AD-14)',
      );
    });
  });

  group('AD-19 — a balance is a sum, computed now', () {
    test('three movements on one account sum to its balance', () async {
      await movements.record(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        type: MoneyMovementType.opening,
        at: kSetupInstant,
      );
      await movements.record(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 125050,
        type: MoneyMovementType.opening,
        at: kSetupInstant.add(const Duration(minutes: 1)),
      );
      await movements.record(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: -75000,
        type: MoneyMovementType.opening,
        at: kSetupInstant.add(const Duration(minutes: 2)),
      );

      expect(await movements.balancePaisa(cash.id), 550050);
    });

    test('the sign carries the direction, so money out subtracts', () async {
      await movements.record(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: -25000,
        type: MoneyMovementType.opening,
        at: kSetupInstant,
      );
      expect(await movements.balancePaisa(cash.id), -25000);
    });

    test('accounts do not leak into each other', () async {
      await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );
      await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: bkash.id,
        amountPaisa: 250000,
        at: kSetupInstant,
      );

      expect(await movements.balancePaisa(cash.id), 500000);
      expect(await movements.balancePaisa(bkash.id), 250000);
      expect(
        await movements.totalBalancePaisa(business.id),
        750000,
        reason: "FR-12's money total is the same sum, one level up",
      );
    });
  });

  group('FR-113 — correcting an opening balance is a reversal plus a new row',
      () {
    test('5,000 corrected to 4,000 leaves three rows and a 400000 balance',
        () async {
      final MoneyMovement original = await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );

      final OpeningBalanceCorrection correction = await movements
          .correctOpeningBalance(
            movementId: original.id,
            newAmountPaisa: 400000,
            at: kSetupInstant.add(const Duration(days: 1)),
          );

      expect(correction.reversal.amountPaisa, -500000);
      expect(correction.reversal.reversesId, original.id);
      expect(correction.replacement.amountPaisa, 400000);
      expect(correction.replacement.reversesId, isNull);

      expect(await movements.forAccount(cash.id), hasLength(3));
      expect(await movements.balancePaisa(cash.id), 400000);
    });

    test('the original row is not touched', () async {
      final MoneyMovement original = await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );

      await movements.correctOpeningBalance(
        movementId: original.id,
        newAmountPaisa: 400000,
        at: kSetupInstant.add(const Duration(days: 1)),
      );

      final MoneyMovement reread = await movements.byId(original.id);
      expect(reread.amountPaisa, 500000);
      expect(reread.createdAtUtc, original.createdAtUtc);
      expect(reread.businessDate, original.businessDate);
      expect(reread.reversesId, isNull);
    });

    test('both new rows keep the original business date', () async {
      final MoneyMovement original = await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );

      final OpeningBalanceCorrection correction = await movements
          .correctOpeningBalance(
            movementId: original.id,
            newAmountPaisa: 400000,
            at: kSetupInstant.add(const Duration(days: 30)),
          );

      expect(correction.reversal.businessDate, original.businessDate);
      expect(
        correction.replacement.businessDate,
        original.businessDate,
        reason:
            'a correction restates what was true on that day; it does not move '
            'the money to the day the owner noticed',
      );
    });

    test('"was this reversed?" is a lookup, not a column', () async {
      final MoneyMovement original = await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );

      expect(await movements.isReversed(original.id), isFalse);
      await movements.correctOpeningBalance(
        movementId: original.id,
        newAmountPaisa: 400000,
        at: kSetupInstant,
      );
      expect(await movements.isReversed(original.id), isTrue);
    });

    test('the same movement cannot be reversed twice', () async {
      final MoneyMovement original = await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );
      await movements.correctOpeningBalance(
        movementId: original.id,
        newAmountPaisa: 400000,
        at: kSetupInstant,
      );

      await expectLater(
        movements.correctOpeningBalance(
          movementId: original.id,
          newAmountPaisa: 300000,
          at: kSetupInstant,
        ),
        throwsA(isA<AlreadyReversedException>()),
      );
      expect(
        await movements.balancePaisa(cash.id),
        400000,
        reason: 'the rejected correction wrote nothing',
      );
    });
  });

  group('ordering is (businessDate, id)', () {
    test('two movements on the same business day keep entry order', () async {
      final List<String> entered = <String>[];
      for (int i = 0; i < 4; i++) {
        final MoneyMovement m = await movements.record(
          businessId: business.id,
          moneyAccountId: cash.id,
          amountPaisa: 1000 * (i + 1),
          type: MoneyMovementType.opening,
          at: kSetupInstant,
        );
        entered.add(m.id);
        // UUIDv7 orders by millisecond; two ids minted inside the same
        // millisecond are not guaranteed to be ordered relative to each other,
        // so the fixture spaces them the way real entry does.
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }

      final List<MoneyMovement> ordered = await movements.forAccount(cash.id);
      expect(ordered.map((MoneyMovement m) => m.id).toList(), entered);
      expect(
        ordered.map((MoneyMovement m) => m.businessDate).toSet(),
        <String>{BusinessDate.of(kSetupInstant)},
      );
    });

    test('an earlier business day comes first, whenever it was entered',
        () async {
      // Entered first, dated today.
      final MoneyMovement today = await movements.record(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 200,
        type: MoneyMovementType.opening,
        at: kSetupInstant,
      );
      await Future<void>.delayed(const Duration(milliseconds: 2));
      // Entered second — so it holds the LARGER UUIDv7 — but backdated two
      // days, which is what decides where it sorts.
      final MoneyMovement backdated = await movements.record(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 100,
        type: MoneyMovementType.opening,
        at: kSetupInstant.subtract(const Duration(days: 2)),
      );
      expect(backdated.id.compareTo(today.id), greaterThan(0));

      final List<MoneyMovement> ordered = await movements.forAccount(cash.id);
      expect(ordered.map((MoneyMovement m) => m.id).toList(), <String>[
        backdated.id,
        today.id,
      ], reason: 'the owner-stated day leads; the id is only the tiebreak');
    });
  });

  group('AD-4 — the database refuses to change a financial row', () {
    test('a raw UPDATE on money_movements is aborted', () async {
      await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );

      await expectLater(
        db.customStatement('UPDATE money_movements SET amount_paisa = 1'),
        throwsA(
          predicate<Object>(
            isAppendOnlyViolation,
            'is the append-only guard, not some other database error',
          ),
        ),
      );
      expect(
        await movements.balancePaisa(cash.id),
        500000,
        reason: 'the aborted statement changed nothing',
      );
    });

    test('a raw DELETE on money_movements is aborted', () async {
      await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );

      await expectLater(
        db.customStatement('DELETE FROM money_movements'),
        throwsA(predicate<Object>(isAppendOnlyViolation)),
      );
      expect(await movements.forAccount(cash.id), hasLength(1));
    });

    test('the guard names the table and says what to do instead', () async {
      await movements.recordOpeningBalance(
        businessId: business.id,
        moneyAccountId: cash.id,
        amountPaisa: 500000,
        at: kSetupInstant,
      );

      Object? caught;
      try {
        await db.customStatement(
          'UPDATE money_movements SET amount_paisa = 1',
        );
      } on Object catch (error) {
        caught = error;
      }
      expect(caught, isNotNull);
      expect(caught.toString(), contains('money_movements'));
      expect(caught.toString(), contains('reversal'));
    });

    test('a reference table CAN be updated — it is meant to change', () async {
      await accounts.rename(id: cash.id, name: 'Counter cash', at: kSetupInstant);
      expect((await accounts.byId(cash.id)).name, 'Counter cash');

      await accounts.setArchived(
        id: bkash.id,
        isArchived: true,
        at: kSetupInstant,
      );
      expect((await accounts.byId(bkash.id)).isArchived, isTrue);
      expect(await accounts.activeForBusiness(business.id), hasLength(1));
    });
  });
}
