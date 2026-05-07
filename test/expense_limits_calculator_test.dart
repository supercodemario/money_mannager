import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/expense_limits/expense_limits_calculator.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';

void main() {
  test('daysInMonth handles normal and leap February', () {
    expect(ExpenseLimitsCalculator.daysInMonth(DateTime(2026, 1, 1)), 31);
    expect(ExpenseLimitsCalculator.daysInMonth(DateTime(2026, 2, 1)), 28);
    expect(ExpenseLimitsCalculator.daysInMonth(DateTime(2024, 2, 1)), 29);
  });

  test('spendable and daily guidance use floor division', () {
    final pool = ExpenseLimitsCalculator.spendablePoolMinor(
      incomeMinor: 10000,
      savingsMinor: 1200,
      recurringDeductionMinor: 1800,
      excludeRecurring: true,
    );
    expect(pool, 7000);
    expect(
      ExpenseLimitsCalculator.indicativeDailyMinor(poolMinor: pool, daysInMonth: 31),
      225,
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
    expect(jan.indicativeDailyMinor, 100);
    expect(feb.indicativeDailyMinor, 110);
  });
}
