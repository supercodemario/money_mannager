import 'package:money_manager/data/remote/household_remote_gateway.dart';

class CreateFamilyRepository {
  CreateFamilyRepository(this._gateway);

  final HouseholdRemoteGateway _gateway;

  Future<void> registerFamilyInvite({
    required String inviteId,
    required String displayName,
  }) =>
      _gateway.registerFamilyInvite(inviteId: inviteId, displayName: displayName);

  Future<void> updateFamilyInviteName({
    required String inviteId,
    required String displayName,
  }) =>
      _gateway.updateFamilyInviteName(inviteId: inviteId, displayName: displayName);

  Future<void> cancelFamilyInvite(String inviteId) => _gateway.cancelFamilyInvite(inviteId);
}
