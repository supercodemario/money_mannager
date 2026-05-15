import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';

/// Household id to attach when creating expenses/templates under cloud sync.
///
/// Returns null when [cloud.syncAllowed] is false (offline / unsigned).
Future<String?> resolveHouseholdForNewExpenseWrite(
  CloudSyncController cloud,
) async {
  if (!cloud.syncAllowed) return null;
  await cloud.ensureHouseholdIfNeeded();
  return SyncMetadataStore.getHouseholdId();
}
