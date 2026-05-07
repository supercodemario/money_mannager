import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/expense_profile_remote_gateway.dart';
import 'package:money_manager/data/remote/expense_remote_gateway.dart';
import 'package:money_manager/data/remote/recurring_remote_gateway.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/sync/sync_orchestrator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AlwaysAllowedCloudSyncController extends CloudSyncController {
  @override
  bool get syncAllowed => true;

  @override
  Future<void> ensureHouseholdIfNeeded() async {}
}

class _RecordingExpenseRemoteGateway extends ExpenseRemoteGateway {
  _RecordingExpenseRemoteGateway(this.calls);

  final List<String> calls;
  List<Map<String, dynamic>> remoteRows = const [];

  @override
  Future<void> upsertExpense({
    required Expense row,
    required String householdId,
  }) async {
    calls.add('push');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchExpensesSince({
    required String householdId,
    required int sinceUpdatedAtMs,
  }) async {
    calls.add('pull');
    return remoteRows;
  }
}

class _RecordingExpenseProfileRemoteGateway
    extends ExpenseProfileRemoteGateway {
  _RecordingExpenseProfileRemoteGateway({this.remoteProfile});

  final Map<String, dynamic>? remoteProfile;
  final pushedProfiles = <ExpenseLimitPreference>[];
  int fetchCalls = 0;

  @override
  String get currentAuthUserId => 'auth-user-1';

  @override
  Future<void> upsertProfile(ExpenseLimitPreference row) async {
    pushedProfiles.add(row);
  }

  @override
  Future<Map<String, dynamic>?> fetchProfile() async {
    fetchCalls++;
    return remoteProfile;
  }
}

class _RecordingRecurringRemoteGateway extends RecurringRemoteGateway {
  _RecordingRecurringRemoteGateway({this.calls});

  final List<String>? calls;
  final pushedTemplates = <RecurringPayment>[];
  final pushedOccurrences = <RecurringPaymentOccurrence>[];
  List<Map<String, dynamic>> remoteTemplates = const [];
  List<Map<String, dynamic>> remoteOccurrences = const [];

  @override
  Future<void> upsertTemplate({
    required RecurringPayment row,
    required String householdId,
  }) async {
    calls?.add('push-template');
    pushedTemplates.add(row);
  }

  @override
  Future<void> upsertOccurrence({
    required RecurringPaymentOccurrence row,
    required String householdId,
  }) async {
    calls?.add('push-occurrence');
    pushedOccurrences.add(row);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTemplatesSince({
    required String householdId,
    required int sinceUpdatedAtMs,
  }) async {
    calls?.add('pull-template');
    return remoteTemplates;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchOccurrencesSince({
    required String householdId,
    required int sinceUpdatedAtMs,
  }) async {
    calls?.add('pull-occurrence');
    return remoteOccurrences;
  }
}

class _FailingExpenseProfileRemoteGateway extends ExpenseProfileRemoteGateway {
  int fetchCalls = 0;

  @override
  String get currentAuthUserId => 'auth-user-1';

  @override
  Future<void> upsertProfile(ExpenseLimitPreference row) async {}

  @override
  Future<Map<String, dynamic>?> fetchProfile() async {
    fetchCalls++;
    throw StateError('profile table missing');
  }
}

class _SerializedRemoteGateway extends ExpenseRemoteGateway {
  _SerializedRemoteGateway(this.maxConcurrentObserved);

  final ValueNotifier<int> maxConcurrentObserved;
  int _active = 0;
  int pullCalls = 0;

  @override
  Future<void> upsertExpense({
    required Expense row,
    required String householdId,
  }) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchExpensesSince({
    required String householdId,
    required int sinceUpdatedAtMs,
  }) async {
    pullCalls++;
    _active++;
    if (_active > maxConcurrentObserved.value) {
      maxConcurrentObserved.value = _active;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _active--;
    return const [];
  }
}

ExpenseLimitsRepository _expenseLimitsRepository({
  required AppDatabase db,
  required UserProfileRepository profiles,
  required CloudSyncController cloud,
}) {
  final expenses = ExpenseRepository(db, profiles, cloud);
  final recurring = RecurringPaymentRepository(db, expenses, cloud);
  return ExpenseLimitsRepository(
    db,
    recurring,
    profiles: profiles,
    cloudSync: cloud,
  );
}

void main() {
  test('Manual sync preserves push-before-pull ordering', () async {
    SharedPreferences.setMockInitialValues({
      'sync_household_id': 'hid-test',
      'sync_last_expense_pull_ms': 0,
    });
    final calls = <String>[];
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _AlwaysAllowedCloudSyncController();
    final expenses = ExpenseRepository(db, profiles, cloud);
    final recurring = RecurringPaymentRepository(db, expenses, cloud);
    final expenseLimits = _expenseLimitsRepository(
      db: db,
      profiles: profiles,
      cloud: cloud,
    );
    final remote = _RecordingExpenseRemoteGateway(calls);
    final profileRemote = _RecordingExpenseProfileRemoteGateway();
    final orchestrator = SyncOrchestrator(
      db: db,
      cloud: cloud,
      expenses: expenses,
      expenseLimits: expenseLimits,
      recurring: recurring,
      remote: remote,
      profileRemote: profileRemote,
      recurringRemote: _RecordingRecurringRemoteGateway(),
    );

    await expenses.insertExpense(
      amountMinor: 500,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime(2026, 4, 25, 12),
    );

    final stages = <ManualSyncStage>[];
    await orchestrator.runManualSync(failFast: true, onStage: stages.add);

    expect(stages, [
      ManualSyncStage.preparing,
      ManualSyncStage.pushing,
      ManualSyncStage.pulling,
    ]);
    expect(calls, ['push', 'pull']);

    await SyncMetadataStore.clearAll();
    await db.close();
  });

  test('Manual pull-only sync skips push and keeps stage order', () async {
    SharedPreferences.setMockInitialValues({
      'sync_household_id': 'hid-test',
      'sync_last_expense_pull_ms': 0,
    });
    final calls = <String>[];
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _AlwaysAllowedCloudSyncController();
    final expenses = ExpenseRepository(db, profiles, cloud);
    final recurring = RecurringPaymentRepository(db, expenses, cloud);
    final expenseLimits = _expenseLimitsRepository(
      db: db,
      profiles: profiles,
      cloud: cloud,
    );
    final remote = _RecordingExpenseRemoteGateway(calls);
    final profileRemote = _RecordingExpenseProfileRemoteGateway();
    final orchestrator = SyncOrchestrator(
      db: db,
      cloud: cloud,
      expenses: expenses,
      expenseLimits: expenseLimits,
      recurring: recurring,
      remote: remote,
      profileRemote: profileRemote,
      recurringRemote: _RecordingRecurringRemoteGateway(),
    );

    await expenses.insertExpense(
      amountMinor: 500,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime(2026, 4, 25, 12),
    );

    final stages = <ManualSyncStage>[];
    await orchestrator.runManualSync(
      mode: ManualSyncMode.pullOnly,
      failFast: true,
      onStage: stages.add,
    );

    expect(stages, [ManualSyncStage.preparing, ManualSyncStage.pulling]);
    expect(calls, ['pull']);

    await SyncMetadataStore.clearAll();
    await db.close();
  });

  test(
    'Manual sync pushes recurring templates before expenses and occurrences after expenses',
    () async {
      SharedPreferences.setMockInitialValues({
        'sync_household_id': 'hid-test',
        'sync_last_expense_pull_ms': 0,
      });
      final calls = <String>[];
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _AlwaysAllowedCloudSyncController();
      final expenses = ExpenseRepository(db, profiles, cloud);
      final recurring = RecurringPaymentRepository(db, expenses, cloud);
      final expenseLimits = _expenseLimitsRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
      );
      final remote = _RecordingExpenseRemoteGateway(calls);
      final recurringRemote = _RecordingRecurringRemoteGateway(calls: calls);
      final orchestrator = SyncOrchestrator(
        db: db,
        cloud: cloud,
        expenses: expenses,
        expenseLimits: expenseLimits,
        recurring: recurring,
        remote: remote,
        profileRemote: _RecordingExpenseProfileRemoteGateway(),
        recurringRemote: recurringRemote,
      );

      final templateId = await recurring.insertTemplate(
        title: 'Rent',
        categoryId: 'house',
        amountMinorSuggested: 90000,
        currencyCode: 'USD',
        dayOfMonth: 1,
      );
      await recurring.markPaidForMonth(
        recurringPaymentId: templateId,
        monthKey: '2026-05',
        amountMinor: 90000,
        occurredAtLocal: DateTime(2026, 5, 1),
      );

      await orchestrator.runManualSync(failFast: true);

      expect(calls, [
        'push-template',
        'push',
        'push-occurrence',
        'pull-template',
        'pull',
        'pull-occurrence',
      ]);
      expect(recurringRemote.pushedTemplates, hasLength(1));
      expect(recurringRemote.pushedOccurrences, hasLength(1));

      await SyncMetadataStore.clearAll();
      await db.close();
    },
  );

  test(
    'Manual pull restores recurring templates before expenses and occurrences',
    () async {
      SharedPreferences.setMockInitialValues({
        'sync_household_id': 'hid-test',
        'sync_last_expense_pull_ms': 0,
      });
      final calls = <String>[];
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _AlwaysAllowedCloudSyncController();
      final expenses = ExpenseRepository(db, profiles, cloud);
      final recurring = RecurringPaymentRepository(db, expenses, cloud);
      final expenseLimits = _expenseLimitsRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
      );
      final remote = _RecordingExpenseRemoteGateway(calls)
        ..remoteRows = [
          {
            'id': '22222222-2222-2222-2222-222222222222',
            'amount_minor': 90000,
            'currency_code': 'USD',
            'category_id': 'house',
            'budget_bucket': null,
            'note': 'Rent',
            'occurred_at': 1777593600000,
            'created_at': 1777593600000,
            'updated_at': 1777593600000,
            'recurring_payment_id': '11111111-1111-1111-1111-111111111111',
            'remote_id': '22222222-2222-2222-2222-222222222222',
            'server_updated_at': 1777593600000,
          },
        ];
      final recurringRemote = _RecordingRecurringRemoteGateway(calls: calls)
        ..remoteTemplates = [
          {
            'id': '11111111-1111-1111-1111-111111111111',
            'title': 'Rent',
            'category_id': 'house',
            'amount_minor_suggested': 90000,
            'currency_code': 'USD',
            'day_of_month': 1,
            'end_month_key': null,
            'is_enabled': true,
            'is_deleted': false,
            'created_at': 1777593600000,
            'updated_at': 1777593600000,
            'remote_id': '11111111-1111-1111-1111-111111111111',
            'server_updated_at': 1777593600000,
          },
        ]
        ..remoteOccurrences = [
          {
            'id': '33333333-3333-3333-3333-333333333333',
            'recurring_payment_id': '11111111-1111-1111-1111-111111111111',
            'month_key': '2026-05',
            'expense_id': '22222222-2222-2222-2222-222222222222',
            'is_deleted': false,
            'created_at': 1777593600000,
            'updated_at': 1777593600000,
            'remote_id': '33333333-3333-3333-3333-333333333333',
            'server_updated_at': 1777593600000,
          },
        ];
      final orchestrator = SyncOrchestrator(
        db: db,
        cloud: cloud,
        expenses: expenses,
        expenseLimits: expenseLimits,
        recurring: recurring,
        remote: remote,
        profileRemote: _RecordingExpenseProfileRemoteGateway(),
        recurringRemote: recurringRemote,
      );

      await orchestrator.runManualSync(
        mode: ManualSyncMode.pullOnly,
        failFast: true,
      );

      expect(calls, ['pull-template', 'pull', 'pull-occurrence']);
      expect(await db.select(db.recurringPayments).get(), hasLength(1));
      expect(await db.select(db.expenses).get(), hasLength(1));
      final occurrences = await db.select(db.recurringPaymentOccurrences).get();
      expect(occurrences, hasLength(1));
      expect(
        occurrences.single.expenseId,
        '22222222-2222-2222-2222-222222222222',
      );

      await SyncMetadataStore.clearAll();
      await db.close();
    },
  );

  test(
    'manual sync calls are serialized to one in-flight run at a time',
    () async {
      SharedPreferences.setMockInitialValues({
        'sync_household_id': 'hid-test',
        'sync_last_expense_pull_ms': 0,
      });
      final maxConcurrent = ValueNotifier<int>(0);
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _AlwaysAllowedCloudSyncController();
      final expenses = ExpenseRepository(db, profiles, cloud);
      final recurring = RecurringPaymentRepository(db, expenses, cloud);
      final expenseLimits = _expenseLimitsRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
      );
      final remote = _SerializedRemoteGateway(maxConcurrent);
      final profileRemote = _RecordingExpenseProfileRemoteGateway();
      final orchestrator = SyncOrchestrator(
        db: db,
        cloud: cloud,
        expenses: expenses,
        expenseLimits: expenseLimits,
        recurring: recurring,
        remote: remote,
        profileRemote: profileRemote,
        recurringRemote: _RecordingRecurringRemoteGateway(),
      );

      await Future.wait<void>([
        orchestrator.runManualSync(
          mode: ManualSyncMode.pullOnly,
          failFast: true,
        ),
        orchestrator.runManualSync(
          mode: ManualSyncMode.pullOnly,
          failFast: true,
        ),
      ]);

      expect(remote.pullCalls, 2);
      expect(maxConcurrent.value, 1);

      await SyncMetadataStore.clearAll();
      await db.close();
    },
  );

  test(
    'Manual sync uploads pending expense profile and marks it synced',
    () async {
      SharedPreferences.setMockInitialValues({
        'sync_household_id': 'hid-test',
        'sync_last_expense_pull_ms': 0,
      });
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _AlwaysAllowedCloudSyncController();
      final expenses = ExpenseRepository(db, profiles, cloud);
      final recurring = RecurringPaymentRepository(db, expenses, cloud);
      final expenseLimits = _expenseLimitsRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
      );
      final remote = _RecordingExpenseRemoteGateway(<String>[]);
      final profileRemote = _RecordingExpenseProfileRemoteGateway();
      final orchestrator = SyncOrchestrator(
        db: db,
        cloud: cloud,
        expenses: expenses,
        expenseLimits: expenseLimits,
        recurring: recurring,
        remote: remote,
        profileRemote: profileRemote,
        recurringRemote: _RecordingRecurringRemoteGateway(),
      );
      final uid = await profiles.getCurrentUserId();

      await expenseLimits.upsertPreferences(
        userId: uid,
        monthlyIncomeMinor: 100000,
        monthlySavingsMinor: 10000,
        excludeUnpaidRecurring: true,
      );

      await orchestrator.runManualSync(failFast: true);

      expect(profileRemote.pushedProfiles, hasLength(1));
      final row = await expenseLimits.getPreferences(uid);
      expect(row?.syncStatus, SyncStatusValue.synced);
      expect(row?.remoteId, 'auth-user-1');

      await SyncMetadataStore.clearAll();
      await db.close();
    },
  );

  test(
    'Manual pull-only sync hydrates remote expense profile with zero expenses',
    () async {
      SharedPreferences.setMockInitialValues({
        'sync_household_id': 'hid-test',
        'sync_last_expense_pull_ms': 0,
      });
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _AlwaysAllowedCloudSyncController();
      final expenses = ExpenseRepository(db, profiles, cloud);
      final recurring = RecurringPaymentRepository(db, expenses, cloud);
      final expenseLimits = _expenseLimitsRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
      );
      final remote = _RecordingExpenseRemoteGateway(<String>[]);
      final profileRemote = _RecordingExpenseProfileRemoteGateway(
        remoteProfile: {
          'auth_user_id': 'auth-user-1',
          'monthly_income_minor': 110000,
          'monthly_savings_minor': 15000,
          'exclude_unpaid_recurring': true,
          'updated_at': 1000,
          'server_updated_at': 1000,
        },
      );
      final orchestrator = SyncOrchestrator(
        db: db,
        cloud: cloud,
        expenses: expenses,
        expenseLimits: expenseLimits,
        recurring: recurring,
        remote: remote,
        profileRemote: profileRemote,
        recurringRemote: _RecordingRecurringRemoteGateway(),
      );
      final uid = await profiles.getCurrentUserId();

      await orchestrator.runManualSync(
        mode: ManualSyncMode.pullOnly,
        failFast: true,
      );

      final row = await expenseLimits.getPreferences(uid);
      expect(profileRemote.fetchCalls, 1);
      expect(row?.monthlyIncomeMinor, 110000);
      expect(row?.monthlySavingsMinor, 15000);
      expect(row?.excludeUnpaidRecurring, isTrue);
      expect(row?.syncStatus, SyncStatusValue.synced);

      await SyncMetadataStore.clearAll();
      await db.close();
    },
  );

  test(
    'Non-failfast pull continues expense pull when profile pull fails',
    () async {
      SharedPreferences.setMockInitialValues({
        'sync_household_id': 'hid-test',
        'sync_last_expense_pull_ms': 0,
      });
      final calls = <String>[];
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final cloud = _AlwaysAllowedCloudSyncController();
      final expenses = ExpenseRepository(db, profiles, cloud);
      final recurring = RecurringPaymentRepository(db, expenses, cloud);
      final expenseLimits = _expenseLimitsRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
      );
      final remote = _RecordingExpenseRemoteGateway(calls);
      final profileRemote = _FailingExpenseProfileRemoteGateway();
      final orchestrator = SyncOrchestrator(
        db: db,
        cloud: cloud,
        expenses: expenses,
        expenseLimits: expenseLimits,
        recurring: recurring,
        remote: remote,
        profileRemote: profileRemote,
        recurringRemote: _RecordingRecurringRemoteGateway(),
      );

      await orchestrator.runManualSync(mode: ManualSyncMode.pullOnly);

      expect(profileRemote.fetchCalls, 1);
      expect(calls, ['pull']);

      await SyncMetadataStore.clearAll();
      await db.close();
    },
  );
}
