import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/expense_profile_remote_gateway.dart';
import 'package:money_manager/data/remote/expense_remote_gateway.dart';
import 'package:money_manager/data/remote/recurring_remote_gateway.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/sync/connectivity_gate.dart';

enum ManualSyncStage { preparing, pushing, pulling }

enum ManualSyncMode { pushThenPull, pullOnly }

/// Watches Drift for pending expense rows and performs remote sync. Not used from UI.
///
/// **Automatic cycle** ([runAutoExpenseSync]): pending expenses only, OS connectivity
/// required, no pull. Triggered by pending expense watch, session ready, connectivity.
///
/// **Manual cycle** ([runManualSync]): full push-then-pull for expenses, recurring,
/// and expense profile — used from settings, post-login, and logout preflight.
/// Recurring/profile pending rows are not uploaded by the automatic cycle.
class SyncOrchestrator {
  SyncOrchestrator({
    required AppDatabase db,
    required CloudSyncController cloud,
    required ExpenseRepository expenses,
    required ExpenseLimitsRepository expenseLimits,
    required RecurringPaymentRepository recurring,
    ExpenseRemoteGateway? remote,
    ExpenseProfileRemoteGateway? profileRemote,
    RecurringRemoteGateway? recurringRemote,
    ConnectivityReader? connectivity,
  }) : _db = db,
       _cloud = cloud,
       _expenses = expenses,
       _expenseLimits = expenseLimits,
       _recurring = recurring,
       _remote = remote ?? ExpenseRemoteGateway(),
       _profileRemote = profileRemote ?? ExpenseProfileRemoteGateway(),
       _recurringRemote = recurringRemote ?? RecurringRemoteGateway(),
       _connectivity = connectivity ?? ConnectivityGate();

  final AppDatabase _db;
  final CloudSyncController _cloud;
  final ExpenseRepository _expenses;
  final ExpenseLimitsRepository _expenseLimits;
  final RecurringPaymentRepository _recurring;
  final ExpenseRemoteGateway _remote;
  final ExpenseProfileRemoteGateway _profileRemote;
  final RecurringRemoteGateway _recurringRemote;
  final ConnectivityReader _connectivity;

  StreamSubscription<List<Expense>>? _pendingSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _debounce;
  Future<void> _syncQueue = Future<void>.value();
  bool? _wasOnline;

  void start() {
    _pendingSub =
        (_db.select(_db.expenses)
              ..where((e) => e.syncStatus.equals(SyncStatusValue.pending)))
            .watch()
            .listen((_) => _scheduleAuto());
    _cloud.addListener(_scheduleAuto);
    final connectivityStream = _connectivity.onConnectivityChanged;
    if (connectivityStream != null) {
      _connectivitySub = connectivityStream.listen(_onConnectivityChanged);
    }
    _scheduleAuto();
  }

  void dispose() {
    _debounce?.cancel();
    _pendingSub?.cancel();
    _connectivitySub?.cancel();
    _cloud.removeListener(_scheduleAuto);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final online = ConnectivityGate.isOnlineResults(results);
    final wasOffline = _wasOnline == false;
    _wasOnline = online;
    if (online && wasOffline && _cloud.syncAllowed) {
      _scheduleAuto();
    }
  }

  void _scheduleAuto() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => unawaited(_runAutoCycle()),
    );
  }

  Future<void> _runAutoCycle() async {
    try {
      await runAutoExpenseSync();
    } catch (e, st) {
      logAppError('sync.auto_expense_cycle', e, st);
    }
  }

  /// Returns remote expense row count visible to the signed-in user (all member households).
  /// Returns null when sync cannot run.
  Future<int?> getRemoteExpenseCount() async {
    if (!_cloud.syncAllowed) return null;
    try {
      return await _remote.countExpenses();
    } catch (e, st) {
      logAppError('sync.remote_expense_count', e, st);
      return null;
    }
  }

  /// Uploads pending expenses when session and OS connectivity allow. No pull.
  Future<void> runAutoExpenseSync() {
    final completer = Completer<void>();
    _syncQueue = _syncQueue.catchError((Object e, StackTrace st) {
      logAppError('sync.queue_prev', e, st);
    }).then((_) async {
      try {
        await _runAutoExpenseSyncNow();
        completer.complete();
      } catch (e, st) {
        logAppError('sync.auto_expense_sync', e, st);
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  Future<void> _runAutoExpenseSyncNow() async {
    if (!_cloud.syncAllowed) return;
    final online = await _connectivity.isOnline;
    _wasOnline = online;
    if (!online) return;

    try {
      await _cloud.ensureDefaultExpenseHouseholdPreference();
    } catch (e, st) {
      logAppError('sync.ensure_default_household', e, st);
    }

    await _pushPending(failFast: false);
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
    _syncQueue = _syncQueue.catchError((Object e, StackTrace st) {
      logAppError('sync.queue_prev', e, st);
    }).then((_) async {
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
        logAppError('sync.manual_sync', e, st);
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
      await _expenseLimits.promoteLocalOnlyToPending();
      await _recurring.promoteLocalOnlyToPending();
    }
    if (includeError) {
      await _expenses.retryErroredAsPending();
      await _expenseLimits.retryErroredAsPending();
      await _recurring.retryErroredAsPending();
    }
    try {
      await _cloud.ensureDefaultExpenseHouseholdPreference();
    } catch (e, st) {
      logAppError('sync.ensure_default_household', e, st);
      if (failFast) rethrow;
    }

    if (mode == ManualSyncMode.pushThenPull) {
      onStage?.call(ManualSyncStage.pushing);
      await _pushPendingProfiles(failFast: failFast);
      await _pushPendingRecurringTemplates(failFast: failFast);
      await _pushPending(failFast: failFast);
      await _pushPendingRecurringOccurrences(failFast: failFast);
    }
    onStage?.call(ManualSyncStage.pulling);
    await _pullRemote(failFast: failFast);
  }

  Future<void> _pushPending({bool failFast = false}) async {
    final pending = await (_db.select(
      _db.expenses,
    )..where((e) => e.syncStatus.equals(SyncStatusValue.pending))).get();
    for (final row in pending) {
      if (row.householdId == null || row.householdId!.isEmpty) {
        logAppError(
          'sync.push_expense',
          StateError('Pending expense ${row.id} missing household_id'),
          StackTrace.current,
        );
        await _expenses.markRemoteError(row.id);
        if (failFast) {
          throw StateError('Pending expense ${row.id} missing household_id');
        }
        continue;
      }
      try {
        await _remote.upsertExpense(row: row);
        await _expenses.markRemoteSynced(row.id);
      } catch (e, st) {
        logAppError('sync.push_expense', e, st);
        await _expenses.markRemoteError(row.id);
        if (failFast) {
          throw StateError('Failed to sync expense ${row.id}: $e');
        }
      }
    }
  }

  Future<void> _pushPendingProfiles({bool failFast = false}) async {
    final pending = await _expenseLimits.getPendingSync();
    for (final row in pending) {
      try {
        await _profileRemote.upsertProfile(row);
        await _expenseLimits.markRemoteSynced(
          userId: row.userId,
          authUserId: _profileRemote.currentAuthUserId,
        );
      } catch (e, st) {
        logAppError('sync.push_profile', e, st);
        await _expenseLimits.markRemoteError(row.userId);
        if (failFast) {
          throw StateError('Failed to sync expense profile ${row.userId}: $e');
        }
      }
    }
  }

  Future<void> _pushPendingRecurringTemplates({bool failFast = false}) async {
    final pending = await _recurring.getPendingTemplates();
    for (final row in pending) {
      if (row.householdId == null || row.householdId!.isEmpty) {
        logAppError(
          'sync.push_recurring_template',
          StateError('Pending template ${row.id} missing household_id'),
          StackTrace.current,
        );
        await _recurring.markTemplateRemoteError(row.id);
        if (failFast) {
          throw StateError('Pending template ${row.id} missing household_id');
        }
        continue;
      }
      try {
        await _recurringRemote.upsertTemplate(row: row);
        await _recurring.markTemplateRemoteSynced(row.id);
      } catch (e, st) {
        logAppError('sync.push_recurring_template', e, st);
        await _recurring.markTemplateRemoteError(row.id);
        if (failFast) {
          throw StateError('Failed to sync recurring template ${row.id}: $e');
        }
      }
    }
  }

  Future<void> _pushPendingRecurringOccurrences({bool failFast = false}) async {
    final pending = await _recurring.getPendingOccurrences();
    for (final row in pending) {
      final template = await _recurring.getTemplateById(row.recurringPaymentId);
      final householdId = template?.householdId;
      if (householdId == null || householdId.isEmpty) {
        logAppError(
          'sync.push_recurring_occurrence',
          StateError(
            'Occurrence ${row.id} missing household_id on template ${row.recurringPaymentId}',
          ),
          StackTrace.current,
        );
        await _recurring.markOccurrenceRemoteError(row.id);
        if (failFast) {
          throw StateError('Occurrence ${row.id} missing template household_id');
        }
        continue;
      }
      try {
        await _recurringRemote.upsertOccurrence(
          row: row,
          householdId: householdId,
        );
        await _recurring.markOccurrenceRemoteSynced(row.id);
      } catch (e, st) {
        logAppError('sync.push_recurring_occurrence', e, st);
        await _recurring.markOccurrenceRemoteError(row.id);
        if (failFast) {
          throw StateError('Failed to sync recurring occurrence ${row.id}: $e');
        }
      }
    }
  }

  Future<void> _pullRemote({bool failFast = false}) async {
    try {
      final profile = await _profileRemote.fetchProfile();
      if (profile != null) {
        await _expenseLimits.applyRemoteProfileRow(profile);
      }
    } catch (e, st) {
      logAppError('sync.pull_profile', e, st);
      if (failFast) rethrow;
    }

    try {
      final since =
          await SyncMetadataStore.getLastRecurringTemplatePullServerMs();
      final maps = await _recurringRemote.fetchTemplatesSince(
        sinceUpdatedAtMs: since,
      );
      var maxUpdated = since;
      for (final m in maps) {
        final u = m['updated_at'] as int?;
        if (u != null && u > maxUpdated) maxUpdated = u;
        await _recurring.applyRemoteTemplateRow(m);
      }
      if (maxUpdated > since) {
        await SyncMetadataStore.setLastRecurringTemplatePullServerMs(
          maxUpdated,
        );
      }
    } catch (e, st) {
      logAppError('sync.pull_recurring_templates', e, st);
      if (failFast) rethrow;
    }

    try {
      final since = await SyncMetadataStore.getLastExpensePullServerMs();
      final maps = await _remote.fetchExpensesSince(sinceUpdatedAtMs: since);
      var maxUpdated = since;
      for (final m in maps) {
        final u = m['updated_at'] as int?;
        if (u != null && u > maxUpdated) maxUpdated = u;
        await _expenses.applyRemoteExpenseRow(m);
      }
      if (maxUpdated > since) {
        await SyncMetadataStore.setLastExpensePullServerMs(maxUpdated);
      }
    } catch (e, st) {
      logAppError('sync.pull_expenses', e, st);
      if (failFast) rethrow;
    }

    try {
      final since =
          await SyncMetadataStore.getLastRecurringOccurrencePullServerMs();
      final maps = await _recurringRemote.fetchOccurrencesSince(
        sinceUpdatedAtMs: since,
      );
      var maxUpdated = since;
      for (final m in maps) {
        final u = m['updated_at'] as int?;
        if (u != null && u > maxUpdated) maxUpdated = u;
        final applied = await _recurring.applyRemoteOccurrenceRow(m);
        if (!applied) {
          developer.log(
            '[sync] recurring occurrence skipped due to missing dependency: ${m['id']}',
            name: 'sync',
          );
        }
      }
      if (maxUpdated > since) {
        await SyncMetadataStore.setLastRecurringOccurrencePullServerMs(
          maxUpdated,
        );
      }
    } catch (e, st) {
      logAppError('sync.pull_recurring_occurrences', e, st);
      if (failFast) rethrow;
    }
  }
}
