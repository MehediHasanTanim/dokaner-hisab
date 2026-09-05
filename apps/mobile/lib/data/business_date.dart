// The business day, derived once, at creation.
//
// AD-14: every timestamp is stored UTC, and the day a figure belongs to is
// reckoned against Asia/Dhaka midnight. A transaction's business date is
// derived ONCE when the row is written and stored beside the UTC instant, so
// that a device travelling, a phone whose clock is corrected, or a later change
// of timezone rules cannot silently re-bucket yesterday's sales into today.
//
// That is the whole reason this is a stored column and not a computed one, and
// the whole reason the derivation lives in one function: two call sites is two
// opportunities for one of them to use the device's local time.
//
// ─────────────────────────────────────────────────────────────────────────────
// CAVEAT — THE OFFSET IS HARD-CODED, AND THAT IS A BANGLADESH ASSUMPTION.
//
// Asia/Dhaka is UTC+6 with no daylight saving. Bangladesh ran DST for a single
// experiment in 2009-2010 and abolished it; there has been one offset since.
// So this file implements the conversion by hand rather than pulling in the
// `timezone` package, which would add a tz database, an asset load and an
// initialisation step to compute a constant.
//
// THIS IS WRONG THE DAY THE PRODUCT LEAVES BANGLADESH, and it is wrong the day
// Bangladesh reintroduces DST. Both are the same fix: replace [dhakaOffset]
// with a real tz lookup keyed on the Business's timezone, keep this function
// as the only call site, and re-run the tests in
// `test/data/business_date_test.dart` — the boundary cases there are what will
// tell you the conversion still holds. Historical rows are unaffected, because
// their business date was stored, not computed.
// ─────────────────────────────────────────────────────────────────────────────

/// Converts a UTC instant into the business day it belongs to.
abstract final class BusinessDate {
  /// Asia/Dhaka, fixed. See the caveat at the top of this file.
  static const Duration dhakaOffset = Duration(hours: 6);

  /// The stored shape: a bare `YYYY-MM-DD`, ten characters, no timezone.
  static const int length = 10;

  /// The business date of [instant], as `YYYY-MM-DD`.
  ///
  ///   2026-09-05T23:00Z -> 2026-09-06  (Dhaka is already the next day)
  ///   2026-09-05T17:00Z -> 2026-09-05  (23:00 in Dhaka, still the same day)
  ///
  /// [instant] may be local or UTC; it is normalised before conversion, so a
  /// caller cannot get a different answer by passing a differently-flagged
  /// DateTime for the same moment.
  static String of(DateTime instant) {
    final DateTime dhaka = instant.toUtc().add(dhakaOffset);
    final String year = dhaka.year.toString().padLeft(4, '0');
    final String month = dhaka.month.toString().padLeft(2, '0');
    final String day = dhaka.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// The business date of right now. The only place `DateTime.now()` is read
  /// for this purpose; every repository takes an optional instant so a test
  /// never depends on the wall clock.
  static String today() => of(DateTime.now());

  /// `YYYY-MM-DD`, and a date that actually exists.
  static bool isValid(String value) {
    if (value.length != length) {
      return false;
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return false;
    }
    final int year = int.parse(value.substring(0, 4));
    final int month = int.parse(value.substring(5, 7));
    final int day = int.parse(value.substring(8, 10));
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return false;
    }
    // Round-trips only for a real calendar day: DateTime rolls 2026-02-30 over
    // into March, and the re-render then disagrees with the input.
    final DateTime parsed = DateTime.utc(year, month, day);
    return parsed.month == month && parsed.day == day;
  }

  /// The UTC instant at which [businessDate] begins — Dhaka midnight.
  ///
  /// This is what a report period turns into before it touches a timestamp
  /// column. The half-open range for one business day is
  /// `[startOfDayUtc(d), startOfDayUtc(nextDay(d)))`.
  static DateTime startOfDayUtc(String businessDate) {
    if (!isValid(businessDate)) {
      throw ArgumentError.value(businessDate, 'businessDate', 'not YYYY-MM-DD');
    }
    return DateTime.utc(
      int.parse(businessDate.substring(0, 4)),
      int.parse(businessDate.substring(5, 7)),
      int.parse(businessDate.substring(8, 10)),
    ).subtract(dhakaOffset);
  }

  /// The business date one day after [businessDate].
  static String nextDay(String businessDate) =>
      of(startOfDayUtc(businessDate).add(const Duration(hours: 24)));
}
