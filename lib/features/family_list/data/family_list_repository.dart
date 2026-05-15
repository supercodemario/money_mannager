import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';

class FamilyListRepository {
  FamilyListRepository(this._gateway);

  final HouseholdRemoteGateway _gateway;

  Future<List<HouseholdSummaryRow>> fetchHouseholds() => _gateway.fetchHouseholdsForCurrentUser();

  Future<String?> currentSyncHouseholdId() =>
      SyncMetadataStore.getDefaultExpenseHouseholdId();

  Future<FamilyInvitePreview?> fetchFamilyInvitePreview(String inviteHouseholdId) =>
      _gateway.fetchFamilyInvitePreview(inviteHouseholdId);

  Future<String?> fetchHouseholdDisplayName(String householdId) =>
      _gateway.fetchHouseholdDisplayName(householdId);

  Future<List<HouseholdMemberRow>> fetchMembers(String householdId) => _gateway.fetchMembers(householdId);

  Future<JoinHouseholdResult> joinHouseholdAsMember(String householdId) =>
      _gateway.joinHouseholdAsMember(householdId);
}
