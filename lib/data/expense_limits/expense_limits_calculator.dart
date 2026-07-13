import 'dart:math' as math;

/// Pure helpers for indicative spend guidance (non-enforcing).
class ExpenseLimitsCalculator {
  ExpenseLimitsCalculator._();

  /// Days in [month] (local), 28–31.
  static int daysInMonth(DateTime month) {
    final y = month.year;
    final m = month.month;
    return DateTime(y, m + 1, 0).day;
  }

  /// Days strictly after [nowLocal]'s calendar day in that month (`D - dayOfMonth`).
  static int daysAfterToday(DateTime nowLocal) {
    final d = daysInMonth(DateTime(nowLocal.year, nowLocal.month));
    return math.max(0, d - nowLocal.day);
  }

  /// `max(0, income - savings - (excludeRecurring ? recurringDeduction : 0))`.
  static int spendablePoolMinor({
    required int incomeMinor,
    required int savingsMinor,
    required int recurringDeductionMinor,
    required bool excludeRecurring,
  }) {
    final r = excludeRecurring ? recurringDeductionMinor : 0;
    return math.max(0, incomeMinor - savingsMinor - r);
  }

  /// Remaining guidance: pool minus current-month spent (may be negative when overspent).
  static int remainingMinor({
    required int poolMinor,
    required int monthSpentMinor,
  }) {
    return poolMinor - monthSpentMinor;
  }

  /// Fixed Daily plan: `pool ~/ daysInMonth` (ignores spent).
  static int dailyPlanMinor({
    required int poolMinor,
    required int daysInMonth,
  }) {
    if (daysInMonth <= 0 || poolMinor <= 0) return 0;
    return poolMinor ~/ daysInMonth;
  }

  /// Pace / day: `remaining ~/ daysAfterToday` (excludes today); 0 when remaining ≤ 0 or no days left.
  static int paceDailyMinor({
    required int poolMinor,
    required int monthSpentMinor,
    required int daysAfterToday,
  }) {
    if (daysAfterToday <= 0) return 0;
    final remaining = remainingMinor(
      poolMinor: poolMinor,
      monthSpentMinor: monthSpentMinor,
    );
    if (remaining <= 0) return 0;
    return remaining ~/ daysAfterToday;
  }
}
