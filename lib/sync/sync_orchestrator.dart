import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/expense_remote_gateway.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';

enum ManualSyncStage { preparing, pushing, pulling }

enum ManualSyncMode { pushThenPull, pullOnly }

/// Watches Drift for pending rows and performs remote upsert/pull. Not used from UI.
class SyncOrchestrator {
  SyncOrchestrator({
    required AppDatabase db,
    required CloudSyncController cloud,
    required ExpenseRepository expenses,
    ExpenseRemoteGateway? remote,
  }) : _db = db,
       _cloud = cloud,
       _expenses = expenses,
       _remote = remote ?? ExpenseRemoteGateway();

  final AppDatabase _db;
  final CloudSyncController _cloud;
  final ExpenseRepository _expenses;
  final ExpenseRemoteGateway _remote;

  StreamSubscription<List<Expense>>? _pendingSub;
  Timer? _debounce;
  Future<void> _syncQueue = Future<void>.value();

  void start() {
    _pendingSub =
        (_db.select(_db.expenses)
              ..where((e) => e.syncStatus.equals(SyncStatusValue.pending)))
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
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => unawaited(_runCycle()),
    );
  }

  Future<void> _runCycle() async {
    await runManualSync();
  }

  /// Returns remote expense row count for the signed-in household.
  /// Returns null when sync cannot run or household cannot be resolved.
  Future<int?> getRemoteExpenseCount() async {
    if (!_cloud.syncAllowed) return null;
    try {
      await _cloud.ensureHouseholdIfNeeded();
      final hid = await SyncMetadataStore.getHouseholdId();
      if (hid == null) return null;
      return await _remote.countExpenses(householdId: hid);
    } catch (e, st) {
      debugPrint('[sync] preview count failed: $e\n$st');
      return null;
    }
  }

  /// Runs one sync cycle serialized with other sync calls.
  ///
  /// - [ManualSyncMode.pushThenPull] emits stages: preparing -> pushing -> pulling.
  /// - [ManualSyncMode.pullOnly] emits stages: preparing -> pulling.
  Future<void> runManualSync({
    bool includeLocalOnly = false,
    bool includeError = false,
    bool failFast = false,
    ManualSyncMode mode = ManualSyncMode.pushThenPull,
    void Function(ManualSyncStage stage)? onStage,
  }) {
    final completer = Completer<void>();
    _syncQueue = _syncQueue.catchError((_) {}).then((_) async {
      try {
        await _runManualSyncNow(
          includeLocalOnly: includeLocalOnly,
          includeError: includeError,
          failFast: failFast,
          mode: mode,
          onStage: onStage,
        );
        completer.complete();
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  Future<void> _runManualSyncNow({
    required bool includeLocalOnly,
    required bool includeError,
    required bool failFast,
    required ManualSyncMode mode,
    required void Function(ManualSyncStage stage)? onStage,
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

    if (mode == ManualSyncMode.pushThenPull) {
      onStage?.call(ManualSyncStage.pushing);
      await _pushPending(hid, failFast: failFast);
    }
    onStage?.call(ManualSyncStage.pulling);
    await _pullRemote(hid);
  }

  Future<void> _pushPending(String householdId, {bool failFast = false}) async {
    final pending = await (_db.select(
      _db.expenses,
    )..where((e) => e.syncStatus.equals(SyncStatusValue.pending))).get();
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
    final maps = await _remote.fetchExpensesSince(
      householdId: householdId,
      sinceUpdatedAtMs: since,
    );
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
