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

  /// Floor division; zero if pool or days non-positive.
  static int indicativeDailyMinor({required int poolMinor, required int daysInMonth}) {
    if (daysInMonth <= 0 || poolMinor <= 0) return 0;
    return poolMinor ~/ daysInMonth;
  }
}
