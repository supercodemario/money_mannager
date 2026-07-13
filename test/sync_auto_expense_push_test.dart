import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:money_manager/sync/connectivity_gate.dart';
import 'package:money_manager/sync/sync_orchestrator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AlwaysAllowedCloudSyncController extends CloudSyncController {
  @override
  bool get syncAllowed => true;

  @override
  Future<void> ensureDefaultExpenseHouseholdPreference() async {
    await SyncMetadataStore.setDefaultExpenseHouseholdId('hid-test');
  }

  @override
  Future<bool?> checkHouseholdMembership(String householdId) async => true;
}

class _DeniedCloudSyncController extends CloudSyncController {
  @override
  bool get syncAllowed => false;
}

class _FixedConnectivity implements ConnectivityReader {
  _FixedConnectivity(this._online);

  final bool _online;

  @override
  Future<bool> get isOnline async => _online;

  @override
  Stream<List<ConnectivityResult>>? get onConnectivityChanged => null;
}

class _RecordingExpenseRemoteGateway extends ExpenseRemoteGateway {
  _RecordingExpenseRemoteGateway(this.calls);

  final List<String> calls;

  @override
  Future<void> upsertExpense({required Expense row}) async {
    calls.add('push');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchExpensesSince({
    required int sinceUpdatedAtMs,
  }) async {
    calls.add('pull');
    return const [];
  }
}

class _RecordingExpenseProfileRemoteGateway
    extends ExpenseProfileRemoteGateway {
  int fetchCalls = 0;

  @override
  Future<Map<String, dynamic>?> fetchProfile() async {
    fetchCalls++;
    return null;
  }
}

class _RecordingRecurringRemoteGateway extends RecurringRemoteGateway {
  @override
  Future<List<Map<String, dynamic>>> fetchTemplatesSince({
    required int sinceUpdatedAtMs,
  }) async =>
      const [];

  @override
  Future<Map<String, dynamic>?> fetchTemplateById(String id) async => null;

  @override
  Future<List<Map<String, dynamic>>> fetchOccurrencesSince({
    required int sinceUpdatedAtMs,
  }) async =>
      const [];
}

ExpenseLimitsRepository _expenseLimitsRepository({
  required AppDatabase db,
  required UserProfileRepository profiles,
  required CloudSyncController cloud,
  required ExpenseRepository expenses,
  required RecurringPaymentRepository recurring,
}) {
  return ExpenseLimitsRepository(
    db,
    recurring,
    expenses,
    profiles: profiles,
    cloudSync: cloud,
  );
}

Future<SyncOrchestrator> _orchestrator({
  required AppDatabase db,
  required ExpenseRepository expenses,
  required CloudSyncController cloud,
  required List<String> expenseCalls,
  required ConnectivityReader connectivity,
}) async {
  final profiles = UserProfileRepository(db);
  final recurring = RecurringPaymentRepository(db, expenses, cloud);
  final expenseLimits = _expenseLimitsRepository(
    db: db,
    profiles: profiles,
    cloud: cloud,
    expenses: expenses,
    recurring: recurring,
  );
  return SyncOrchestrator(
    db: db,
    cloud: cloud,
    expenses: expenses,
    expenseLimits: expenseLimits,
    recurring: recurring,
    remote: _RecordingExpenseRemoteGateway(expenseCalls),
    profileRemote: _RecordingExpenseProfileRemoteGateway(),
    recurringRemote: _RecordingRecurringRemoteGateway(),
    connectivity: connectivity,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'default_expense_household_id': 'hid-test',
      'sync_last_expense_pull_ms': 0,
    });
  });

  test('Auto sync pushes expenses and does not pull', () async {
    final calls = <String>[];
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _AlwaysAllowedCloudSyncController();
    final expenses = ExpenseRepository(db, profiles, cloud);
    final orchestrator = await _orchestrator(
      db: db,
      expenses: expenses,
      cloud: cloud,
      expenseCalls: calls,
      connectivity: _FixedConnectivity(true),
    );

    await expenses.insertExpense(
      amountMinor: 500,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime(2026, 4, 25, 12),
    );

    await orchestrator.runAutoExpenseSync();

    expect(calls, ['push']);

    final row = await (db.select(db.expenses)..limit(1)).getSingle();
    expect(row.syncStatus, SyncStatusValue.synced);

    await SyncMetadataStore.clearAll();
    await db.close();
  });

  test('Auto sync skipped when offline keeps pending', () async {
    final calls = <String>[];
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _AlwaysAllowedCloudSyncController();
    final expenses = ExpenseRepository(db, profiles, cloud);
    final orchestrator = await _orchestrator(
      db: db,
      expenses: expenses,
      cloud: cloud,
      expenseCalls: calls,
      connectivity: _FixedConnectivity(false),
    );

    await expenses.insertExpense(
      amountMinor: 500,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime(2026, 4, 25, 12),
    );

    await orchestrator.runAutoExpenseSync();

    expect(calls, isEmpty);

    final row = await (db.select(db.expenses)..limit(1)).getSingle();
    expect(row.syncStatus, SyncStatusValue.pending);

    await SyncMetadataStore.clearAll();
    await db.close();
  });

  test('Auto sync does nothing when not logged in', () async {
    final calls = <String>[];
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _DeniedCloudSyncController();
    final expenses = ExpenseRepository(db, profiles, cloud);
    final orchestrator = await _orchestrator(
      db: db,
      expenses: expenses,
      cloud: cloud,
      expenseCalls: calls,
      connectivity: _FixedConnectivity(true),
    );

    await expenses.insertExpense(
      amountMinor: 500,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime(2026, 4, 25, 12),
    );

    await orchestrator.runAutoExpenseSync();

    expect(calls, isEmpty);

    final row = await (db.select(db.expenses)..limit(1)).getSingle();
    expect(row.syncStatus, SyncStatusValue.localOnly);

    await SyncMetadataStore.clearAll();
    await db.close();
  });

  test('Manual sync still runs full push-then-pull', () async {
    final calls = <String>[];
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _AlwaysAllowedCloudSyncController();
    final expenses = ExpenseRepository(db, profiles, cloud);
    await expenses.insertExpense(
      amountMinor: 500,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime(2026, 4, 25, 12),
    );

    final profileRemote = _RecordingExpenseProfileRemoteGateway();
    final recurring = RecurringPaymentRepository(db, expenses, cloud);
    final fullOrchestrator = SyncOrchestrator(
      db: db,
      cloud: cloud,
      expenses: expenses,
      expenseLimits: _expenseLimitsRepository(
        db: db,
        profiles: profiles,
        cloud: cloud,
        expenses: expenses,
        recurring: recurring,
      ),
      recurring: recurring,
      remote: _RecordingExpenseRemoteGateway(calls),
      profileRemote: profileRemote,
      recurringRemote: _RecordingRecurringRemoteGateway(),
      connectivity: _FixedConnectivity(true),
    );

    final stages = <ManualSyncStage>[];
    await fullOrchestrator.runManualSync(failFast: true, onStage: stages.add);

    expect(stages, [
      ManualSyncStage.preparing,
      ManualSyncStage.pushing,
      ManualSyncStage.pulling,
    ]);
    expect(calls, ['push', 'pull']);
    expect(profileRemote.fetchCalls, 1);

    await SyncMetadataStore.clearAll();
    await db.close();
  });
}
