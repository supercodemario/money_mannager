import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/categories/category_bucket.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/category_repository.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

void main() {
  test('Default categories are seeded with allowed bucket values', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await db.ensureReady();

    final rows = await db.select(db.expenseCategories).get();
    expect(rows, isNotEmpty);
    for (final r in rows) {
      expect(
        categoryBucketFromDb(r.bucket),
        isIn(CategoryBucket.values),
      );
    }
  });

  test('updateBucket changes classification used by subsequent expense inserts', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await db.ensureReady();

    final profiles = UserProfileRepository(db);
    final categories = CategoryRepository(db);
    final cloud = CloudSyncController();
    await cloud.initialize();
    final expenses = ExpenseRepository(db, profiles, cloud);

    const groceryId = 'grocery';
    final before = await categories.getById(groceryId);
    expect(before, isNotNull);
    expect(before!.bucket, 'needs');

    await categories.updateBucket(groceryId, CategoryBucket.savingsDebt);

    final after = await categories.getById(groceryId);
    expect(after!.bucket, 'savings_debt');

    await expenses.insertExpense(
      amountMinor: 100,
      currencyCode: 'USD',
      categoryId: groceryId,
      budgetBucket: after.bucket,
      occurredAt: DateTime(2026, 4, 10),
    );

    final expRows = await db.select(db.expenses).get();
    expect(expRows.single.budgetBucket, 'savings_debt');
  });
}
