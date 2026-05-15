import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/sync/sync_orchestrator.dart';

/// Counts and remote size used to drive [ManualSyncMode] and post-login UI.
class ManualSyncPreview {
  const ManualSyncPreview({
    required this.localOnly,
    required this.unsynced,
    required this.localTotal,
    this.remoteRows,
  });

  final int localOnly;
  final int unsynced;
  final int localTotal;
  final int? remoteRows;
}

/// Shared manual sync entry points for UI flows (auth, settings, logout).
class ManualSyncHelper {
  ManualSyncHelper._();

  static SyncOrchestrator _orchestrator(AppServices services) {
    return SyncOrchestrator(
      db: services.db,
      cloud: services.cloudSync,
      expenses: services.expenses,
      expenseLimits: services.expenseLimits,
      recurring: services.recurring,
    );
  }

  static ManualSyncMode modeFromUnsynced(int unsynced) =>
      unsynced > 0 ? ManualSyncMode.pushThenPull : ManualSyncMode.pullOnly;

  /// True when cloud sync can run (signed in, Supabase ready).
  static Future<bool> canRunCloudSync(AppServices services) async {
    return services.cloudSync.syncAllowed;
  }

  /// @deprecated Use [canRunCloudSync].
  static Future<bool> canRunHouseholdScopedSync(AppServices services) =>
      canRunCloudSync(services);

  /// Expenses + profiles + recurring: same basis as auth post-login / refresh.
  static Future<ManualSyncPreview> loadAggregatePreview(
    AppServices services,
  ) async {
    final expenseLocalOnly = await services.expenses.countBySyncStatuses({
      SyncStatusValue.localOnly,
    });
    final profileLocalOnly = await services.expenseLimits.countBySyncStatuses({
      SyncStatusValue.localOnly,
    });
    final recurringLocalOnly = await services.recurring.countBySyncStatuses({
      SyncStatusValue.localOnly,
    });
    final localOnly = expenseLocalOnly + profileLocalOnly + recurringLocalOnly;
    final expenseUnsynced = await services.expenses.countUnsynced();
    final profileUnsynced = await services.expenseLimits.countUnsynced();
    final recurringUnsynced = await services.recurring.countUnsynced();
    final unsynced = expenseUnsynced + profileUnsynced + recurringUnsynced;
    final localTotal =
        await services.expenses.countAllRows() +
        await services.recurring.countAllRows();
    final remoteRows = await _orchestrator(services).getRemoteExpenseCount();
    return ManualSyncPreview(
      localOnly: localOnly,
      unsynced: unsynced,
      localTotal: localTotal,
      remoteRows: remoteRows,
    );
  }

  /// Recurring templates only (e.g. settings cloud sync affordance).
  static Future<ManualSyncPreview> loadRecurringSyncPreview(
    AppServices services,
  ) async {
    final unsynced = await services.recurring.countUnsynced();
    final localOnly = await services.recurring.countBySyncStatuses({
      SyncStatusValue.localOnly,
    });
    final localTotal = await services.recurring.countAllRows();
    return ManualSyncPreview(
      localOnly: localOnly,
      unsynced: unsynced,
      localTotal: localTotal,
      remoteRows: null,
    );
  }

  static Future<void> runManualSync(
    AppServices services, {
    required bool includeLocalOnly,
    required bool includeError,
    ManualSyncMode mode = ManualSyncMode.pushThenPull,
    bool markBootstrapCompleteOnSuccess = false,
    void Function(ManualSyncStage stage)? onStage,
  }) async {
    await _orchestrator(services).runManualSync(
      includeLocalOnly: includeLocalOnly,
      includeError: includeError,
      mode: mode,
      failFast: true,
      onStage: onStage,
    );
    if (markBootstrapCompleteOnSuccess) {
      await SyncMetadataStore.setPostAuthBootstrapCompleted(true);
    }
  }

  /// Push local changes then pull; used before logout when unsynced rows exist.
  static Future<void> runLogoutManualSync(
    AppServices services, {
    ManualSyncMode mode = ManualSyncMode.pushThenPull,
    void Function(ManualSyncStage stage)? onStage,
  }) {
    return runManualSync(
      services,
      includeLocalOnly: true,
      includeError: true,
      mode: mode,
      onStage: onStage,
    );
  }
}
