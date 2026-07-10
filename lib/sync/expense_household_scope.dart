import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';

/// Household id to attach when creating expenses/templates under cloud sync.
///
/// Returns null when [cloud.syncAllowed] is false (offline / unsigned).
Future<String?> resolveHouseholdForNewExpenseWrite(
  CloudSyncController cloud,
) async {
  if (!cloud.syncAllowed) return null;

  final preferred = await SyncMetadataStore.getDefaultExpenseHouseholdId();
  if (preferred != null && preferred.isNotEmpty) {
    final member = await cloud.checkHouseholdMembership(preferred);
    if (member == true) return preferred;
    if (member == null) return preferred;
    await cloud.ensureDefaultExpenseHouseholdPreference();
    return SyncMetadataStore.getDefaultExpenseHouseholdId();
  }

  await cloud.ensureDefaultExpenseHouseholdPreference();
  return SyncMetadataStore.getDefaultExpenseHouseholdId();
}
