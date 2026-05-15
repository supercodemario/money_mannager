import 'package:money_manager/data/remote/household_remote_gateway.dart';

class JoinFamilyConfirmRepository {
  JoinFamilyConfirmRepository(this._gateway);

  final HouseholdRemoteGateway _gateway;

  Future<AcceptFamilyInviteResult> accept(String householdId) =>
      _gateway.acceptFamilyInvite(householdId);
}
