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
  final recurring = RecurringPaymentRepository(db, expenses, cloud);
  return ExpenseLimitsRepository(
    db,
    recurring,
    profiles: profiles,
    cloudSync: cloud,
    nowProvider: nowProvider,
  );
}

RecurringPaymentRepository _recurringRepository({
  required AppDatabase db,
  required UserProfileRepository profiles,
  required CloudSyncController cloud,
  DateTime Function()? nowProvider,
}) {
  final expenses = ExpenseRepository(db, profiles, cloud);
  return RecurringPaymentRepository(
    db,
    expenses,
    cloud,
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

  test(
    'Recurring template save uses local_only while sync is unavailable',
    () async {
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _FakeCloudSyncController(false);
      final recurring = _recurringRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
      );

      await recurring.insertTemplate(
        title: 'Rent',
        categoryId: 'house',
        amountMinorSuggested: 90000,
        currencyCode: 'USD',
        dayOfMonth: 1,
      );

      final rows = await db.select(db.recurringPayments).get();
      expect(rows.single.syncStatus, SyncStatusValue.localOnly);
      await db.close();
    },
  );

  test(
    'Recurring template save uses pending while sync is available',
    () async {
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _FakeCloudSyncController(true);
      final recurring = _recurringRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
      );

      await recurring.insertTemplate(
        title: 'Rent',
        categoryId: 'house',
        amountMinorSuggested: 90000,
        currencyCode: 'USD',
        dayOfMonth: 1,
      );

      final rows = await db.select(db.recurringPayments).get();
      expect(rows.single.syncStatus, SyncStatusValue.pending);
      await db.close();
    },
  );

  test('Recurring occurrence save follows sync availability', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final signedOut = _FakeCloudSyncController(false);
    final recurring = _recurringRepository(
      db: db,
      profiles: profiles,
      cloud: signedOut,
    );

    final templateId = await recurring.insertTemplate(
      title: 'Internet',
      categoryId: 'bill',
      amountMinorSuggested: 7000,
      currencyCode: 'USD',
      dayOfMonth: 5,
    );
    await recurring.markPaidForMonth(
      recurringPaymentId: templateId,
      monthKey: '2026-05',
      amountMinor: 7000,
      occurredAtLocal: DateTime(2026, 5, 5),
    );

    var rows = await db.select(db.recurringPaymentOccurrences).get();
    expect(rows.single.syncStatus, SyncStatusValue.localOnly);

    signedOut.allowed = true;
    final templateId2 = await recurring.insertTemplate(
      title: 'Phone',
      categoryId: 'bill',
      amountMinorSuggested: 2500,
      currencyCode: 'USD',
      dayOfMonth: 10,
    );
    await recurring.markPaidForMonth(
      recurringPaymentId: templateId2,
      monthKey: '2026-05',
      amountMinor: 2500,
      occurredAtLocal: DateTime(2026, 5, 10),
    );

    rows = await db.select(db.recurringPaymentOccurrences).get();
    expect(rows.last.syncStatus, SyncStatusValue.pending);
    await db.close();
  });

  test(
    'Recurring sync transitions and LWW merge work for templates and occurrences',
    () async {
      var now = DateTime.fromMillisecondsSinceEpoch(1000);
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _FakeCloudSyncController(false);
      final recurring = _recurringRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
        nowProvider: () => now,
      );

      final templateId = await recurring.insertTemplate(
        title: 'Gym',
        categoryId: 'health',
        amountMinorSuggested: 3000,
        currencyCode: 'USD',
        dayOfMonth: 15,
      );
      expect(await recurring.promoteLocalOnlyToPending(), 1);
      await recurring.markTemplateRemoteError(templateId);
      expect(await recurring.retryErroredAsPending(), 1);
      await recurring.markTemplateRemoteSynced(templateId);
      expect(
        (await recurring.getTemplateById(templateId))?.syncStatus,
        SyncStatusValue.synced,
      );

      await recurring.applyRemoteTemplateRow({
        'id': templateId,
        'title': 'Old Gym',
        'category_id': 'health',
        'amount_minor_suggested': 1000,
        'currency_code': 'USD',
        'day_of_month': 1,
        'end_month_key': null,
        'is_enabled': true,
        'is_deleted': false,
        'created_at': 1000,
        'updated_at': 900,
        'server_updated_at': 900,
      });
      expect((await recurring.getTemplateById(templateId))?.title, 'Gym');

      now = DateTime.fromMillisecondsSinceEpoch(3000);
      await recurring.applyRemoteTemplateRow({
        'id': templateId,
        'title': 'Fitness',
        'category_id': 'health',
        'amount_minor_suggested': 3500,
        'currency_code': 'USD',
        'day_of_month': 20,
        'end_month_key': null,
        'is_enabled': true,
        'is_deleted': false,
        'created_at': 1000,
        'updated_at': 2500,
        'server_updated_at': 2500,
      });
      expect((await recurring.getTemplateById(templateId))?.title, 'Fitness');

      await recurring.markPaidForMonth(
        recurringPaymentId: templateId,
        monthKey: '2026-05',
        amountMinor: 3500,
        occurredAtLocal: DateTime(2026, 5, 20),
      );
      final occurrence =
          (await db.select(db.recurringPaymentOccurrences).get()).single;
      await recurring.markOccurrenceRemoteError(occurrence.id);
      expect(await recurring.retryErroredAsPending(), 1);
      await recurring.markOccurrenceRemoteSynced(occurrence.id);

      await recurring.applyRemoteOccurrenceRow({
        'id': occurrence.id,
        'recurring_payment_id': templateId,
        'month_key': '2026-05',
        'expense_id': null,
        'is_deleted': false,
        'created_at': occurrence.createdAt,
        'updated_at': occurrence.updatedAt - 1,
        'server_updated_at': occurrence.updatedAt - 1,
      });
      expect(
        (await db.select(db.recurringPaymentOccurrences).get())
            .single
            .expenseId,
        isNotNull,
      );

      await recurring.applyRemoteOccurrenceRow({
        'id': occurrence.id,
        'recurring_payment_id': templateId,
        'month_key': '2026-05',
        'expense_id': null,
        'is_deleted': false,
        'created_at': occurrence.createdAt,
        'updated_at': occurrence.updatedAt + 1000,
        'server_updated_at': occurrence.updatedAt + 1000,
      });
      expect(
        (await db.select(db.recurringPaymentOccurrences).get())
            .single
            .expenseId,
        isNull,
      );
      await db.close();
    },
  );

  test('Remote recurring occurrence skips missing dependencies', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _FakeCloudSyncController(false);
    final recurring = _recurringRepository(
      db: db,
      profiles: profiles,
      cloud: cloud,
    );

    expect(
      await recurring.applyRemoteOccurrenceRow({
        'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'recurring_payment_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        'month_key': '2026-05',
        'expense_id': null,
        'is_deleted': false,
        'created_at': 1000,
        'updated_at': 1000,
        'server_updated_at': 1000,
      }),
      isFalse,
    );

    await recurring.applyRemoteTemplateRow({
      'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'title': 'Rent',
      'category_id': 'house',
      'amount_minor_suggested': 90000,
      'currency_code': 'USD',
      'day_of_month': 1,
      'end_month_key': null,
      'is_enabled': true,
      'is_deleted': false,
      'created_at': 1000,
      'updated_at': 1000,
      'server_updated_at': 1000,
    });

    expect(
      await recurring.applyRemoteOccurrenceRow({
        'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'recurring_payment_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        'month_key': '2026-05',
        'expense_id': 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        'is_deleted': false,
        'created_at': 1000,
        'updated_at': 1000,
        'server_updated_at': 1000,
      }),
      isFalse,
    );

    expect(await db.select(db.recurringPaymentOccurrences).get(), isEmpty);
    await db.close();
  });
}
