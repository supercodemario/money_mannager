import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

void main() {
  test('watchCategoryExpensesInMonthWithCreator filters by category', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = CloudSyncController();
    await cloud.initialize();
    final repo = ExpenseRepository(db, profiles, cloud);

    final month = DateTime(2026, 4);
    final startLocal = DateTime(month.year, month.month, 1);
    final endLocal = DateTime(month.year, month.month + 1, 1);
    final startUtcMs = startLocal.toUtc().millisecondsSinceEpoch;
    final endUtcMs = endLocal.toUtc().millisecondsSinceEpoch;

    await repo.insertExpense(
      amountMinor: 100,
      currencyCode: 'USD',
      categoryId: 'grocery',
      note: 'a',
      occurredAt: DateTime.utc(2026, 4, 2, 12),
    );
    await repo.insertExpense(
      amountMinor: 200,
      currencyCode: 'USD',
      categoryId: 'travel',
      note: null,
      occurredAt: DateTime.utc(2026, 4, 3, 12),
    );

    final list = await repo
        .watchCategoryExpensesInMonthWithCreator(
          categoryId: 'grocery',
          startUtcMs: startUtcMs,
          endUtcMs: endUtcMs,
        )
        .first;

    expect(list.length, 1);
    expect(list.single.expense.amountMinor, 100);
    expect(list.single.expense.categoryId, 'grocery');

    await db.close();
  });

  test('watchCategoryDailyTotalsInMonth aggregates by local day', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = CloudSyncController();
    await cloud.initialize();
    final repo = ExpenseRepository(db, profiles, cloud);

    final month = DateTime(2026, 4);
    final startLocal = DateTime(month.year, month.month, 1);
    final endLocal = DateTime(month.year, month.month + 1, 1);
    final startUtcMs = startLocal.toUtc().millisecondsSinceEpoch;
    final endUtcMs = endLocal.toUtc().millisecondsSinceEpoch;

    await repo.insertExpense(
      amountMinor: 50,
      currencyCode: 'USD',
      categoryId: 'grocery',
      note: null,
      occurredAt: DateTime.utc(2026, 4, 10, 8),
    );
    await repo.insertExpense(
      amountMinor: 70,
      currencyCode: 'USD',
      categoryId: 'grocery',
      note: null,
      occurredAt: DateTime.utc(2026, 4, 10, 18),
    );
    await repo.insertExpense(
      amountMinor: 30,
      currencyCode: 'USD',
      categoryId: 'grocery',
      note: null,
      occurredAt: DateTime.utc(2026, 4, 11, 12),
    );

    final days = await repo
        .watchCategoryDailyTotalsInMonth(
          categoryId: 'grocery',
          monthLocal: month,
          startUtcMs: startUtcMs,
          endUtcMs: endUtcMs,
        )
        .first;

    expect(days.length, DateTime(2026, 5, 0).day);
    expect(days[9].dayOfMonth, 10);
    expect(days[9].totalMinor, 120);
    expect(days[10].dayOfMonth, 11);
    expect(days[10].totalMinor, 30);

    await db.close();
  });
}
