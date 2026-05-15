import 'package:money_manager/data/remote/household_remote_gateway.dart';

class FamilyMembersRepository {
  FamilyMembersRepository(this._gateway);

  final HouseholdRemoteGateway _gateway;

  Future<List<HouseholdMemberRow>> fetchMembers(String householdId) =>
      _gateway.fetchMembers(householdId);

  Future<bool> currentUserIsOwner(String householdId) => _gateway.currentUserIsOwner(householdId);

  Future<bool> isPersonalHousehold(String householdId) =>
      _gateway.isPersonalHousehold(householdId);

  Future<AddHouseholdMemberResult> addMemberAsOwner({
    required String householdId,
    required String inviteeAuthUserId,
  }) =>
      _gateway.addMemberAsOwner(
        householdId: householdId,
        inviteeAuthUserId: inviteeAuthUserId,
      );
}
