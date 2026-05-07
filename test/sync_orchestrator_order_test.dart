import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/expense_remote_gateway.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
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
  Future<void> upsertExpense({required Expense row, required String householdId}) async {
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
    final remote = _RecordingExpenseRemoteGateway(calls);
    final orchestrator = SyncOrchestrator(
      db: db,
      cloud: cloud,
      expenses: expenses,
      remote: remote,
    );

    await expenses.insertExpense(
      amountMinor: 500,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime(2026, 4, 25, 12),
    );

    final stages = <ManualSyncStage>[];
    await orchestrator.runManualSync(
      failFast: true,
      onStage: stages.add,
    );

    expect(stages, [ManualSyncStage.preparing, ManualSyncStage.pushing, ManualSyncStage.pulling]);
    expect(calls, ['push', 'pull']);

    await SyncMetadataStore.clearAll();
    await db.close();
  });
}
