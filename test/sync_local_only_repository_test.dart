import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

class _FakeCloudSyncController extends CloudSyncController {
  _FakeCloudSyncController(this.allowed);

  bool allowed;

  @override
  bool get syncAllowed => allowed;
}

void main() {
  test('Expense insert uses local_only while sync is unavailable', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _FakeCloudSyncController(false);
    final expenses = ExpenseRepository(db, profiles, cloud);

    await expenses.insertExpense(
      amountMinor: 2500,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime(2026, 4, 24, 12),
    );

    final rows = await db.select(db.expenses).get();
    expect(rows, hasLength(1));
    expect(rows.single.syncStatus, SyncStatusValue.localOnly);
    await db.close();
  });

  test('local_only rows can be promoted to pending', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _FakeCloudSyncController(false);
    final expenses = ExpenseRepository(db, profiles, cloud);

    await expenses.insertExpense(
      amountMinor: 900,
      currencyCode: 'USD',
      categoryId: 'fuel',
      occurredAt: DateTime(2026, 4, 24, 18),
    );
    final promoted = await expenses.promoteLocalOnlyToPending();
    expect(promoted, 1);

    final rows = await db.select(db.expenses).get();
    expect(rows.single.syncStatus, SyncStatusValue.pending);
    await db.close();
  });

  test('countUnsynced includes local_only, pending, and error', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _FakeCloudSyncController(false);
    final expenses = ExpenseRepository(db, profiles, cloud);

    final id = await expenses.insertExpense(
      amountMinor: 330,
      currencyCode: 'USD',
      categoryId: 'bill',
      occurredAt: DateTime(2026, 4, 25, 10),
    );
    await expenses.promoteLocalOnlyToPending();
    await expenses.markRemoteError(id);

    final unsynced = await expenses.countUnsynced();
    expect(unsynced, 1);
    await db.close();
  });
}
