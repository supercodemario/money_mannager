import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/app/app_router.dart';
import 'package:money_manager/core/navigation/household_flow_navigation.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/features/household_qr_share/view/household_qr_share_dialog.dart';
import 'package:money_manager/share/share.dart';

class AppHouseholdFlowNavigation implements HouseholdFlowNavigation {
  @override
  Future<void> pushCreateFamily(BuildContext context) {
    return context.router.push<void>(CreateFamilyRoute());
  }

  @override
  Future<String?> pushHouseholdScanJoinHousehold(BuildContext context) {
    return context.router.push<String>(
      HouseholdScanRoute(
        appBarTitle: AppStrings.familyJoinHouseholdScanTitle,
        scannerHint: AppStrings.familyJoinHouseholdScanHint,
        webLeadParagraph: AppStrings.familyJoinHouseholdWebLead,
        pasteSheetTitle: AppStrings.familyJoinHouseholdPasteSheetTitle,
        pasteFieldLabel: AppStrings.familyJoinPasteHouseholdLabel,
      ),
    );
  }

  @override
  Future<String?> pushHouseholdScanDefault(BuildContext context) {
    return context.router.push<String>(HouseholdScanRoute());
  }

  @override
  Future<bool?> pushJoinFamilyConfirm(BuildContext context, FamilyInvitePreview preview) {
    return context.router.push<bool>(JoinFamilyConfirmRoute(preview: preview));
  }

  @override
  Future<void> pushFamilyMembers(
    BuildContext context, {
    required String householdId,
    required String householdName,
  }) {
    return context.router.push<void>(
      FamilyMembersRoute(
        householdId: householdId,
        householdName: householdName,
      ),
    );
  }

  @override
  Future<void> showHouseholdQrDialog(
    BuildContext context, {
    required String householdId,
    required String householdName,
  }) {
    return showHouseholdQrShareDialog(
      context,
      householdId: householdId,
      householdName: householdName,
    );
  }
}
