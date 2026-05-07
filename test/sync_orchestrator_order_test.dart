import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/expense_profile_remote_gateway.dart';
import 'package:money_manager/data/remote/expense_remote_gateway.dart';
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
    return const [];
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
  final recurring = RecurringPaymentRepository(db, expenses);
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
      remote: remote,
      profileRemote: profileRemote,
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
      remote: remote,
      profileRemote: profileRemote,
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
        remote: remote,
        profileRemote: profileRemote,
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
        remote: remote,
        profileRemote: profileRemote,
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
        remote: remote,
        profileRemote: profileRemote,
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
        remote: remote,
        profileRemote: profileRemote,
      );

      await orchestrator.runManualSync(mode: ManualSyncMode.pullOnly);

      expect(profileRemote.fetchCalls, 1);
      expect(calls, ['pull']);

      await SyncMetadataStore.clearAll();
      await db.close();
    },
  );
}
