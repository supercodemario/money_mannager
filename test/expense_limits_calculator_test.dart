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

  test('daysAfterToday excludes today', () {
    expect(ExpenseLimitsCalculator.daysAfterToday(DateTime(2026, 7, 10)), 21);
    expect(ExpenseLimitsCalculator.daysAfterToday(DateTime(2026, 7, 31)), 0);
    expect(ExpenseLimitsCalculator.daysAfterToday(DateTime(2026, 6, 10)), 20);
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

  test('pace uses remaining and days after today', () {
    // Pool 3000, spent 1100 → remaining 1900; day 10 of 30 → 20 days after today.
    expect(
      ExpenseLimitsCalculator.paceDailyMinor(
        poolMinor: 3000,
        monthSpentMinor: 1100,
        daysAfterToday: 20,
      ),
      95,
    );
    expect(
      ExpenseLimitsCalculator.dailyPlanMinor(poolMinor: 3000, daysInMonth: 30),
      100,
    );
  });

  test('month spent does not change daily plan', () {
    expect(
      ExpenseLimitsCalculator.dailyPlanMinor(poolMinor: 30000, daysInMonth: 30),
      1000,
    );
    expect(
      ExpenseLimitsCalculator.dailyPlanMinor(poolMinor: 30000, daysInMonth: 30),
      ExpenseLimitsCalculator.dailyPlanMinor(poolMinor: 30000, daysInMonth: 30),
    );
  });

  test('overspent or last day yields zero pace', () {
    expect(
      ExpenseLimitsCalculator.paceDailyMinor(
        poolMinor: 1000,
        monthSpentMinor: 1500,
        daysAfterToday: 10,
      ),
      0,
    );
    expect(
      ExpenseLimitsCalculator.paceDailyMinor(
        poolMinor: 1000,
        monthSpentMinor: 0,
        daysAfterToday: 0,
      ),
      0,
    );
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
    expect(jan.paceDailyMinor, 0); // last day
    expect(feb.paceDailyMinor, 3100 ~/ 27); // day 1 → 27 days after
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
    // July has 31 days; day 3 → 28 days after today.
    expect(unpaid.paceDailyMinor, 29780 ~/ 28);

    // Marked paid: leaves unpaid reservation, appears in month spent.
    final paid = ExpenseLimitsDerived.compute(
      prefs: prefs,
      recurringRows: const [],
      nowLocal: DateTime(2026, 7, 3),
      monthSpentMinor: 220,
    );
    expect(paid.spendablePoolMinor, 30000);
    expect(paid.dailyPlanMinor, 30000 ~/ 31);
    expect(paid.paceDailyMinor, (30000 - 220) ~/ 28);
  });
}
