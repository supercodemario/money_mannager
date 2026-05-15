import 'package:flutter/material.dart';
import 'package:money_manager/core/navigation/household_flow_navigation.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/features/create_family/view/create_family_screen.dart';
import 'package:money_manager/features/family_members/view/family_members_screen.dart';
import 'package:money_manager/features/household_qr_share/view/household_qr_share_dialog.dart';
import 'package:money_manager/features/household_scan/view/household_scan_screen.dart';
import 'package:money_manager/features/join_family_confirm/view/join_family_confirm_screen.dart';
import 'package:money_manager/share/share.dart';

class AppHouseholdFlowNavigation implements HouseholdFlowNavigation {
  @override
  Future<void> pushCreateFamily(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const CreateFamilyScreen()),
    );
  }

  @override
  Future<String?> pushHouseholdScanJoinHousehold(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const HouseholdScanScreen(
          appBarTitle: AppStrings.familyJoinHouseholdScanTitle,
          scannerHint: AppStrings.familyJoinHouseholdScanHint,
          webLeadParagraph: AppStrings.familyJoinHouseholdWebLead,
          pasteSheetTitle: AppStrings.familyJoinHouseholdPasteSheetTitle,
          pasteFieldLabel: AppStrings.familyJoinPasteHouseholdLabel,
        ),
      ),
    );
  }

  @override
  Future<String?> pushHouseholdScanDefault(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const HouseholdScanScreen()),
    );
  }

  @override
  Future<bool?> pushJoinFamilyConfirm(BuildContext context, FamilyInvitePreview preview) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => JoinFamilyConfirmScreen(preview: preview)),
    );
  }

  @override
  Future<void> pushFamilyMembers(
    BuildContext context, {
    required String householdId,
    required String householdName,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FamilyMembersScreen(
          householdId: householdId,
          householdName: householdName,
        ),
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
