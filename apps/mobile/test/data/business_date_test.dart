// The business day boundary, at the two places it can go wrong.
//
// AD-14: a figure belongs to the day it was Asia/Dhaka when it happened, not
// the day it was UTC. Dhaka is six hours ahead, so every UTC evening is already
// the next day in the shop, and a naive `DateTime.now().toIso8601String()`
// would file six hours of every day's takings under yesterday.
//
// These are the two rows of the story's edge-case matrix plus the midnights
// either side of them, because a boundary is only ever wrong at the boundary.

import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/data/business_date.dart';

void main() {
  group('a UTC instant becomes the day it was in Dhaka', () {
    test('23:00 UTC is already tomorrow in the shop', () {
      expect(
        BusinessDate.of(DateTime.utc(2026, 9, 5, 23)),
        '2026-09-06',
        reason: '05:00 on the 6th in Dhaka',
      );
    });

    test('17:00 UTC is still today in the shop', () {
      expect(
        BusinessDate.of(DateTime.utc(2026, 9, 5, 17)),
        '2026-09-05',
        reason: '23:00 on the 5th in Dhaka',
      );
    });

    test('the boundary itself: 18:00 UTC is Dhaka midnight', () {
      expect(BusinessDate.of(DateTime.utc(2026, 9, 5, 17, 59, 59)), '2026-09-05');
      expect(BusinessDate.of(DateTime.utc(2026, 9, 5, 18)), '2026-09-06');
      expect(BusinessDate.of(DateTime.utc(2026, 9, 5, 18, 0, 1)), '2026-09-06');
    });

    test('UTC midnight is 06:00 in the shop, the same day', () {
      expect(BusinessDate.of(DateTime.utc(2026, 9, 6)), '2026-09-06');
    });

    test('a local DateTime for the same instant gives the same answer', () {
      final DateTime instant = DateTime.utc(2026, 9, 5, 23);
      expect(
        BusinessDate.of(instant.toLocal()),
        BusinessDate.of(instant),
        reason:
            'the conversion normalises to UTC first, so the device timezone '
            'cannot change which day a figure lands on',
      );
    });

    test('month, year and leap-day rollovers', () {
      expect(BusinessDate.of(DateTime.utc(2026, 8, 31, 18)), '2026-09-01');
      expect(BusinessDate.of(DateTime.utc(2026, 12, 31, 18)), '2027-01-01');
      expect(BusinessDate.of(DateTime.utc(2028, 2, 28, 18)), '2028-02-29');
    });

    test('the stored shape is exactly ten characters, zero-padded', () {
      final String early = BusinessDate.of(DateTime.utc(2026, 1, 2, 12));
      expect(early, '2026-01-02');
      expect(early.length, BusinessDate.length);
    });
  });

  group('validation', () {
    test('accepts a real calendar day', () {
      expect(BusinessDate.isValid('2026-09-05'), isTrue);
      expect(BusinessDate.isValid('2028-02-29'), isTrue);
    });

    test('rejects a shape that is not YYYY-MM-DD', () {
      expect(BusinessDate.isValid('2026-9-5'), isFalse);
      expect(BusinessDate.isValid('2026-09-05T00:00:00Z'), isFalse);
      expect(BusinessDate.isValid(''), isFalse);
    });

    test('rejects a day that does not exist', () {
      expect(
        BusinessDate.isValid('2026-02-30'),
        isFalse,
        reason: 'DateTime would roll this into March and the row would claim a '
            'day the owner never had',
      );
      expect(BusinessDate.isValid('2026-13-01'), isFalse);
      expect(BusinessDate.isValid('2027-02-29'), isFalse);
    });
  });

  group('a business day as a UTC range', () {
    test('starts at Dhaka midnight, which is 18:00 the previous UTC day', () {
      expect(
        BusinessDate.startOfDayUtc('2026-09-06'),
        DateTime.utc(2026, 9, 5, 18),
      );
    });

    test('round-trips: the start of a day is in that day', () {
      const String day = '2026-09-06';
      expect(BusinessDate.of(BusinessDate.startOfDayUtc(day)), day);
    });

    test('the last instant of a day is still in it', () {
      const String day = '2026-09-06';
      final DateTime lastMoment = BusinessDate.startOfDayUtc(
        BusinessDate.nextDay(day),
      ).subtract(const Duration(milliseconds: 1));
      expect(BusinessDate.of(lastMoment), day);
    });

    test('nextDay crosses a month and a year', () {
      expect(BusinessDate.nextDay('2026-09-05'), '2026-09-06');
      expect(BusinessDate.nextDay('2026-09-30'), '2026-10-01');
      expect(BusinessDate.nextDay('2026-12-31'), '2027-01-01');
      expect(BusinessDate.nextDay('2028-02-28'), '2028-02-29');
    });

    test('rejects a malformed date rather than guessing', () {
      expect(() => BusinessDate.startOfDayUtc('05-09-2026'), throwsArgumentError);
    });
  });

  group('the offset is the documented one', () {
    test('Asia/Dhaka is UTC+6, with no daylight saving', () {
      expect(
        BusinessDate.dhakaOffset,
        const Duration(hours: 6),
        reason:
            'hard-coded on purpose — Bangladesh has had one offset since 2010. '
            'This is the assertion that fails first if the product ever leaves '
            'Bangladesh; see the caveat at the top of business_date.dart',
      );
    });

    test('every hour of a day lands on one of two adjacent business days', () {
      final DateTime start = DateTime.utc(2026, 9, 5);
      final Set<String> days = <String>{};
      for (int hour = 0; hour < 24; hour++) {
        days.add(BusinessDate.of(start.add(Duration(hours: hour))));
      }
      expect(days, <String>{'2026-09-05', '2026-09-06'});
    });
  });
}
