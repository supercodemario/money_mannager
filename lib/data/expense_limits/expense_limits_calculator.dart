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

  /// Local calendar day key `yyyy-MM-dd`.
  static String localDateKey(DateTime local) {
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Days from [nowLocal] through end of month (`D − dayOfMonth + 1`).
  ///
  /// Used as the Pace divisor so Pace answers “how much can I spend **today**?”
  static int daysLeftIncludingToday(DateTime nowLocal) {
    final d = daysInMonth(DateTime(nowLocal.year, nowLocal.month));
    return math.max(0, d - nowLocal.day + 1);
  }

  /// Days strictly after [nowLocal] (`D − dayOfMonth`). Prefer [daysLeftIncludingToday] for Pace.
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

  /// Locked Pace write value: `(pool − spentBeforeToday) ~/ daysLeftIncludingToday`.
  ///
  /// Pass [spentBeforeTodayMinor] (exclude today's local-date expenses). Pass
  /// [daysLeftIncludingToday] from [daysLeftIncludingToday] helper.
  static int paceSnapshotMinor({
    required int poolMinor,
    required int spentBeforeTodayMinor,
    required int daysLeftIncludingToday,
  }) {
    if (daysLeftIncludingToday <= 0) return 0;
    final remaining = remainingMinor(
      poolMinor: poolMinor,
      monthSpentMinor: spentBeforeTodayMinor,
    );
    if (remaining <= 0) return 0;
    return remaining ~/ daysLeftIncludingToday;
  }

  /// Alias for [paceSnapshotMinor] (older call sites used [monthSpentMinor] as leftover base).
  static int paceDailyMinor({
    required int poolMinor,
    required int monthSpentMinor,
    required int daysLeftIncludingToday,
  }) {
    return paceSnapshotMinor(
      poolMinor: poolMinor,
      spentBeforeTodayMinor: monthSpentMinor,
      daysLeftIncludingToday: daysLeftIncludingToday,
    );
  }

  /// Splits month expenses into spent before [nowLocal]'s local day vs today.
  static ({int beforeTodayMinor, int todayMinor}) splitMonthSpentByLocalDay({
    required Iterable<({int occurredAtUtcMs, int amountMinor})> expenses,
    required DateTime nowLocal,
  }) {
    final today = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    var before = 0;
    var todaySum = 0;
    for (final e in expenses) {
      final local = DateTime.fromMillisecondsSinceEpoch(
        e.occurredAtUtcMs,
        isUtc: true,
      ).toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (day.isBefore(today)) {
        before += e.amountMinor;
      } else if (day == today) {
        todaySum += e.amountMinor;
      }
    }
    return (beforeTodayMinor: before, todayMinor: todaySum);
  }
}
