import 'package:flutter/material.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';

/// Cross-household UI navigation implemented at app composition time so individual
/// household features do not import each other.
abstract class HouseholdFlowNavigation {
  Future<void> pushCreateFamily(BuildContext context);

  Future<String?> pushHouseholdScanJoinHousehold(BuildContext context);

  Future<String?> pushHouseholdScanDefault(BuildContext context);

  Future<bool?> pushJoinFamilyConfirm(BuildContext context, FamilyInvitePreview preview);

  Future<void> pushFamilyMembers(
    BuildContext context, {
    required String householdId,
    required String householdName,
  });

  Future<void> showHouseholdQrDialog(
    BuildContext context, {
    required String householdId,
    required String householdName,
  });
}
