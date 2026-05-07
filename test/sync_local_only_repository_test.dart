import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

class _FakeCloudSyncController extends CloudSyncController {
  _FakeCloudSyncController(this.allowed);

  bool allowed;

  @override
  bool get syncAllowed => allowed;
}

ExpenseLimitsRepository _expenseLimitsRepository({
  required AppDatabase db,
  required UserProfileRepository profiles,
  required CloudSyncController cloud,
  DateTime Function()? nowProvider,
}) {
  final expenses = ExpenseRepository(db, profiles, cloud);
  final recurring = RecurringPaymentRepository(db, expenses);
  return ExpenseLimitsRepository(
    db,
    recurring,
    profiles: profiles,
    cloudSync: cloud,
    nowProvider: nowProvider,
  );
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

  test(
    'Expense profile save uses local_only while sync is unavailable',
    () async {
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _FakeCloudSyncController(false);
      final limits = _expenseLimitsRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
      );
      final uid = await profiles.getCurrentUserId();

      await limits.upsertPreferences(
        userId: uid,
        monthlyIncomeMinor: 100000,
        monthlySavingsMinor: 10000,
        excludeUnpaidRecurring: true,
      );

      final row = await limits.getPreferences(uid);
      expect(row?.syncStatus, SyncStatusValue.localOnly);
      await db.close();
    },
  );

  test('Expense profile save uses pending while sync is available', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _FakeCloudSyncController(true);
    final limits = _expenseLimitsRepository(
      db: db,
      profiles: profiles,
      cloud: cloud,
    );
    final uid = await profiles.getCurrentUserId();

    await limits.upsertPreferences(
      userId: uid,
      monthlyIncomeMinor: 100000,
      monthlySavingsMinor: null,
      excludeUnpaidRecurring: false,
    );

    final row = await limits.getPreferences(uid);
    expect(row?.syncStatus, SyncStatusValue.pending);
    await db.close();
  });

  test(
    'Expense profile local_only and error rows can be promoted to pending',
    () async {
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _FakeCloudSyncController(false);
      final limits = _expenseLimitsRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
      );
      final uid = await profiles.getCurrentUserId();

      await limits.upsertPreferences(
        userId: uid,
        monthlyIncomeMinor: 90000,
        monthlySavingsMinor: null,
        excludeUnpaidRecurring: false,
      );

      expect(await limits.promoteLocalOnlyToPending(), 1);
      expect(
        (await limits.getPreferences(uid))?.syncStatus,
        SyncStatusValue.pending,
      );

      await limits.markRemoteError(uid);
      expect(await limits.retryErroredAsPending(), 1);
      expect(
        (await limits.getPreferences(uid))?.syncStatus,
        SyncStatusValue.pending,
      );

      await limits.markRemoteSynced(userId: uid, authUserId: 'auth-user-1');
      final synced = await limits.getPreferences(uid);
      expect(synced?.syncStatus, SyncStatusValue.synced);
      expect(synced?.remoteId, 'auth-user-1');
      await db.close();
    },
  );

  test('Expense profile remote merge uses last-write-wins', () async {
    var now = DateTime.fromMillisecondsSinceEpoch(1000);
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _FakeCloudSyncController(false);
    final limits = _expenseLimitsRepository(
      db: db,
      profiles: profiles,
      cloud: cloud,
      nowProvider: () => now,
    );
    final uid = await profiles.getCurrentUserId();

    await limits.upsertPreferences(
      userId: uid,
      monthlyIncomeMinor: 100000,
      monthlySavingsMinor: null,
      excludeUnpaidRecurring: false,
    );

    await limits.applyRemoteProfileRow({
      'auth_user_id': 'auth-user-1',
      'monthly_income_minor': 120000,
      'monthly_savings_minor': 20000,
      'exclude_unpaid_recurring': true,
      'updated_at': 900,
      'server_updated_at': 900,
    });
    expect((await limits.getPreferences(uid))?.monthlyIncomeMinor, 100000);

    now = DateTime.fromMillisecondsSinceEpoch(2000);
    await limits.applyRemoteProfileRow({
      'auth_user_id': 'auth-user-1',
      'monthly_income_minor': 120000,
      'monthly_savings_minor': 20000,
      'exclude_unpaid_recurring': true,
      'updated_at': 1500,
      'server_updated_at': 1500,
    });

    final row = await limits.getPreferences(uid);
    expect(row?.monthlyIncomeMinor, 120000);
    expect(row?.monthlySavingsMinor, 20000);
    expect(row?.excludeUnpaidRecurring, isTrue);
    expect(row?.syncStatus, SyncStatusValue.synced);
    await db.close();
  });
}
