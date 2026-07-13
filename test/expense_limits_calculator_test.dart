import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/expense_limits/expense_limits_calculator.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';

void main() {
  test('daysInMonth handles normal and leap February', () {
    expect(ExpenseLimitsCalculator.daysInMonth(DateTime(2026, 1, 1)), 31);
    expect(ExpenseLimitsCalculator.daysInMonth(DateTime(2026, 2, 1)), 28);
    expect(ExpenseLimitsCalculator.daysInMonth(DateTime(2024, 2, 1)), 29);
  });

  test('daysLeftIncludingToday includes today', () {
    expect(
      ExpenseLimitsCalculator.daysLeftIncludingToday(DateTime(2026, 7, 10)),
      22,
    );
    expect(
      ExpenseLimitsCalculator.daysLeftIncludingToday(DateTime(2026, 7, 31)),
      1,
    );
    expect(
      ExpenseLimitsCalculator.daysLeftIncludingToday(DateTime(2026, 6, 10)),
      21,
    );
    // Reject exclude-today divisor for Pace.
    expect(
      ExpenseLimitsCalculator.daysLeftIncludingToday(DateTime(2026, 6, 10)),
      isNot(ExpenseLimitsCalculator.daysAfterToday(DateTime(2026, 6, 10))),
    );
  });

  test('daily plan is pool floor division by month length', () {
    final pool = ExpenseLimitsCalculator.spendablePoolMinor(
      incomeMinor: 10000,
      savingsMinor: 1200,
      recurringDeductionMinor: 1800,
      excludeRecurring: true,
    );
    expect(pool, 7000);
    expect(
      ExpenseLimitsCalculator.dailyPlanMinor(poolMinor: pool, daysInMonth: 31),
      225,
    );
  });

  test('pace snapshot uses days left including today; ignores today spend base', () {
    // Pool 3000, spent before today 1100 → 1900; day 10 of 30 → 21 days left.
    expect(
      ExpenseLimitsCalculator.paceSnapshotMinor(
        poolMinor: 3000,
        spentBeforeTodayMinor: 1100,
        daysLeftIncludingToday: 21,
      ),
      1900 ~/ 21,
    );
    expect(
      ExpenseLimitsCalculator.paceSnapshotMinor(
        poolMinor: 3000,
        spentBeforeTodayMinor: 1100,
        daysLeftIncludingToday: 21,
      ),
      isNot(
        ExpenseLimitsCalculator.paceSnapshotMinor(
          poolMinor: 3000,
          spentBeforeTodayMinor: 1500, // would include today's 400
          daysLeftIncludingToday: 21,
        ),
      ),
    );
    // Must not use exclude-today divisor (20).
    expect(
      ExpenseLimitsCalculator.paceSnapshotMinor(
        poolMinor: 3000,
        spentBeforeTodayMinor: 1100,
        daysLeftIncludingToday: 21,
      ),
      isNot(1900 ~/ 20),
    );
    expect(
      ExpenseLimitsCalculator.dailyPlanMinor(poolMinor: 3000, daysInMonth: 30),
      100,
    );
  });

  test('steady daily spend keeps Pace equal to Daily plan', () {
    // Pool 300, 30 days, plan 10; after 9×10 spent, day 10 → 210/21 = 10.
    expect(
      ExpenseLimitsCalculator.dailyPlanMinor(poolMinor: 300, daysInMonth: 30),
      10,
    );
    expect(
      ExpenseLimitsCalculator.paceSnapshotMinor(
        poolMinor: 300,
        spentBeforeTodayMinor: 90,
        daysLeftIncludingToday: 21,
      ),
      10,
    );
  });

  test('worked example day 12 after overspend on day 11', () {
    // 10/day × 10 days + 20 on day 11 → spent before day 12 = 120; leftover 180; ÷19.
    expect(
      ExpenseLimitsCalculator.paceSnapshotMinor(
        poolMinor: 300,
        spentBeforeTodayMinor: 120,
        daysLeftIncludingToday: 19,
      ),
      180 ~/ 19,
    );
  });

  test('month spent does not change daily plan', () {
    expect(
      ExpenseLimitsCalculator.dailyPlanMinor(poolMinor: 30000, daysInMonth: 30),
      1000,
    );
  });

  test('overspent before today yields zero; last day uses leftover', () {
    expect(
      ExpenseLimitsCalculator.paceSnapshotMinor(
        poolMinor: 1000,
        spentBeforeTodayMinor: 1500,
        daysLeftIncludingToday: 10,
      ),
      0,
    );
    expect(
      ExpenseLimitsCalculator.paceSnapshotMinor(
        poolMinor: 1000,
        spentBeforeTodayMinor: 0,
        daysLeftIncludingToday: 0,
      ),
      0,
    );
    expect(
      ExpenseLimitsCalculator.paceSnapshotMinor(
        poolMinor: 1000,
        spentBeforeTodayMinor: 850,
        daysLeftIncludingToday: 1,
      ),
      150,
    );
  });

  test('splitMonthSpentByLocalDay excludes today from beforeToday', () {
    final now = DateTime(2026, 7, 10, 15);
    final before = DateTime(2026, 7, 9, 12).toUtc().millisecondsSinceEpoch;
    final today = DateTime(2026, 7, 10, 9).toUtc().millisecondsSinceEpoch;
    final split = ExpenseLimitsCalculator.splitMonthSpentByLocalDay(
      expenses: [
        (occurredAtUtcMs: before, amountMinor: 1100),
        (occurredAtUtcMs: today, amountMinor: 400),
      ],
      nowLocal: now,
    );
    expect(split.beforeTodayMinor, 1100);
    expect(split.todayMinor, 400);
  });

  test('derived guidance changes with month boundary day count', () {
    const prefs = ExpenseLimitPreference(
      userId: 'u1',
      monthlyIncomeMinor: 3100,
      monthlySavingsMinor: 0,
      excludeUnpaidRecurring: false,
      updatedAt: 0,
    );

    final jan = ExpenseLimitsDerived.compute(
      prefs: prefs,
      recurringRows: const [],
      nowLocal: DateTime(2026, 1, 31),
    );
    final feb = ExpenseLimitsDerived.compute(
      prefs: prefs,
      recurringRows: const [],
      nowLocal: DateTime(2026, 2, 1),
    );

    expect(jan.daysInMonth, 31);
    expect(feb.daysInMonth, 28);
    expect(jan.dailyPlanMinor, 100);
    expect(feb.dailyPlanMinor, 110);
    expect(jan.paceDailyMinor, 3100); // last day: leftover ÷ 1
    expect(feb.paceDailyMinor, 3100 ~/ 28); // day 1 → 28 days left
  });

  test('unpaid reservation reduces daily plan; paid spend keeps plan from pool', () {
    const prefs = ExpenseLimitPreference(
      userId: 'u1',
      monthlyIncomeMinor: 30000,
      monthlySavingsMinor: 0,
      excludeUnpaidRecurring: true,
      updatedAt: 0,
    );

    final unpaidTemplate = RecurringPayment(
      id: 'r1',
      title: 'Rent',
      amountMinorSuggested: 220,
      currencyCode: 'INR',
      dayOfMonth: 1,
      categoryId: 'c1',
      isEnabled: true,
      isDeleted: false,
      createdAt: 0,
      updatedAt: 0,
    );
    final unpaidRows = [
      RecurringMonthRow(
        template: unpaidTemplate,
        monthKey: '2026-07',
      ),
    ];

    final unpaid = ExpenseLimitsDerived.compute(
      prefs: prefs,
      recurringRows: unpaidRows,
      nowLocal: DateTime(2026, 7, 3),
      monthSpentMinor: 0,
    );
    expect(unpaid.spendablePoolMinor, 29780);
    expect(unpaid.dailyPlanMinor, 29780 ~/ 31);
    // July has 31 days; day 3 → 29 days left including today.
    expect(unpaid.paceDailyMinor, 29780 ~/ 29);

    final paid = ExpenseLimitsDerived.compute(
      prefs: prefs,
      recurringRows: const [],
      nowLocal: DateTime(2026, 7, 3),
      monthSpentMinor: 220,
      spentBeforeTodayMinor: 220,
    );
    expect(paid.spendablePoolMinor, 30000);
    expect(paid.dailyPlanMinor, 30000 ~/ 31);
    expect(paid.paceDailyMinor, (30000 - 220) ~/ 29);
  });
}
