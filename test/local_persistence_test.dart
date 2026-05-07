import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

void main() {
  test('Bootstraps one user profile and attributes inserts', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = CloudSyncController();
    await cloud.initialize();
    final expenses = ExpenseRepository(db, profiles, cloud);

    final p = await profiles.getCurrentProfile();
    expect(p.id, isNotEmpty);
    expect(p.displayName, isNotEmpty);

    final id = await expenses.insertExpense(
      amountMinor: 123,
      currencyCode: 'USD',
      categoryId: 'grocery',
      note: 'milk',
      occurredAt: DateTime(2026, 4, 8, 12, 0),
    );
    expect(id, isNotEmpty);

    final rows = await db.select(db.expenses).get();
    expect(rows, hasLength(1));
    expect(rows.single.createdByUserId, p.id);
    await db.close();
  });
}

