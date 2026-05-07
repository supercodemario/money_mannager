import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

void main() {
  test('Monthly category totals groups by category', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = CloudSyncController();
    await cloud.initialize();
    final repo = ExpenseRepository(db, profiles, cloud);

    // Apr 2026
    await repo.insertExpense(
      amountMinor: 500,
      currencyCode: 'USD',
      categoryId: 'grocery',
      note: null,
      occurredAt: DateTime.utc(2026, 4, 1, 12),
    );
    await repo.insertExpense(
      amountMinor: 700,
      currencyCode: 'USD',
      categoryId: 'grocery',
      note: null,
      occurredAt: DateTime.utc(2026, 4, 2, 12),
    );
    await repo.insertExpense(
      amountMinor: 200,
      currencyCode: 'USD',
      categoryId: 'travel',
      note: null,
      occurredAt: DateTime.utc(2026, 4, 3, 12),
    );

    // May 2026 (should not be counted)
    await repo.insertExpense(
      amountMinor: 999,
      currencyCode: 'USD',
      categoryId: 'grocery',
      note: null,
      occurredAt: DateTime.utc(2026, 5, 1, 12),
    );

    final start = DateTime.utc(2026, 4, 1).millisecondsSinceEpoch;
    final end = DateTime.utc(2026, 5, 1).millisecondsSinceEpoch;

    final totals = await repo.watchMonthlyCategoryTotals(monthStartUtcMs: start, monthEndUtcMs: end).first;
    expect(totals.map((t) => '${t.categoryId}:${t.totalMinor}').toList(), containsAll(['grocery:1200', 'travel:200']));
    await db.close();
  });
}

