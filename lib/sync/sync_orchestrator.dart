import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/expense_remote_gateway.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';

enum ManualSyncStage {
  preparing,
  pushing,
  pulling,
}

/// Watches Drift for pending rows and performs remote upsert/pull. Not used from UI.
class SyncOrchestrator {
  SyncOrchestrator({
    required AppDatabase db,
    required CloudSyncController cloud,
    required ExpenseRepository expenses,
    ExpenseRemoteGateway? remote,
  })  : _db = db,
        _cloud = cloud,
        _expenses = expenses,
        _remote = remote ?? ExpenseRemoteGateway();

  final AppDatabase _db;
  final CloudSyncController _cloud;
  final ExpenseRepository _expenses;
  final ExpenseRemoteGateway _remote;

  StreamSubscription<List<Expense>>? _pendingSub;
  Timer? _debounce;

  void start() {
    _pendingSub = (_db.select(_db.expenses)..where((e) => e.syncStatus.equals(SyncStatusValue.pending)))
        .watch()
        .listen((_) => _schedule());
    _cloud.addListener(_schedule);
    _schedule();
  }

  void dispose() {
    _debounce?.cancel();
    _pendingSub?.cancel();
    _cloud.removeListener(_schedule);
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => unawaited(_runCycle()));
  }

  Future<void> _runCycle() async {
    await runManualSync();
  }

  Future<void> runManualSync({
    bool includeLocalOnly = false,
    bool includeError = false,
    bool failFast = false,
    void Function(ManualSyncStage stage)? onStage,
  }) async {
    if (!_cloud.syncAllowed) return;
    onStage?.call(ManualSyncStage.preparing);
    if (includeLocalOnly) {
      await _expenses.promoteLocalOnlyToPending();
    }
    if (includeError) {
      await _expenses.retryErroredAsPending();
    }
    try {
      await _cloud.ensureHouseholdIfNeeded();
    } catch (e, st) {
      debugPrint('[sync] ensureHousehold failed: $e\n$st');
      if (failFast) rethrow;
      return;
    }
    final hid = await SyncMetadataStore.getHouseholdId();
    if (hid == null) {
      if (failFast) {
        throw StateError('Sync household not available.');
      }
      return;
    }

    onStage?.call(ManualSyncStage.pushing);
    await _pushPending(hid, failFast: failFast);
    onStage?.call(ManualSyncStage.pulling);
    await _pullRemote(hid);
  }

  Future<void> _pushPending(String householdId, {bool failFast = false}) async {
    final pending = await (_db.select(_db.expenses)..where((e) => e.syncStatus.equals(SyncStatusValue.pending))).get();
    for (final row in pending) {
      try {
        await _remote.upsertExpense(row: row, householdId: householdId);
        await _expenses.markRemoteSynced(row.id);
      } catch (e, st) {
        debugPrint('[sync] push failed ${row.id}: $e\n$st');
        await _expenses.markRemoteError(row.id);
        if (failFast) {
          throw StateError('Failed to sync expense ${row.id}: $e');
        }
      }
    }
  }

  Future<void> _pullRemote(String householdId) async {
    final since = await SyncMetadataStore.getLastExpensePullServerMs();
    final maps = await _remote.fetchExpensesSince(householdId: householdId, sinceUpdatedAtMs: since);
    var maxUpdated = since;
    for (final m in maps) {
      final u = m['updated_at'] as int?;
      if (u != null && u > maxUpdated) maxUpdated = u;
      await _expenses.applyRemoteExpenseRow(m);
    }
    if (maxUpdated > since) {
      await SyncMetadataStore.setLastExpensePullServerMs(maxUpdated);
    }
  }
}
