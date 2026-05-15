import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/core/navigation/household_flow_navigation.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/features/family_list/data/family_list_repository.dart';
import 'package:money_manager/features/family_list/models/family_list_state/family_list_state.dart';
import 'package:money_manager/share/share.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FamilyListCubit extends Cubit<FamilyListState> {
  FamilyListCubit(this._repo, this._cloudSync, this._nav) : super(const FamilyListState());

  final FamilyListRepository _repo;
  final CloudSyncController _cloudSync;
  final HouseholdFlowNavigation _nav;

  Future<void> load() async {
    emit(const FamilyListState(phase: FamilyListPhase.loading));
    if (!_cloudSync.syncAllowed) {
      emit(const FamilyListState(phase: FamilyListPhase.signedOut));
      return;
    }
    try {
      final list = await _repo.fetchHouseholds();
      final syncId = await _repo.currentSyncHouseholdId();
      emit(
        FamilyListState(
          phase: FamilyListPhase.loaded,
          households: list,
          syncHouseholdId: syncId,
        ),
      );
    } catch (e, st) {
      logAppError('family_list.load', e, st);
      emit(const FamilyListState(phase: FamilyListPhase.loadError));
    }
  }

  Future<void> openCreateFamily(BuildContext context) async {
    if (!_cloudSync.syncAllowed) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.familyDetailsSignInRequired)),
      );
      return;
    }
    await _nav.pushCreateFamily(context);
    await load();
  }

  void showQrFor(BuildContext context, HouseholdSummaryRow h) {
    if (h.isPersonal) return;
    _nav.showHouseholdQrDialog(
      context,
      householdId: h.householdId,
      householdName: h.name,
    );
  }

  Future<void> openMembers(BuildContext context, HouseholdSummaryRow row) async {
    await _nav.pushFamilyMembers(
      context,
      householdId: row.householdId,
      householdName: row.name,
    );
    await load();
  }

  Future<void> scanToJoin(BuildContext context) async {
    if (!_cloudSync.syncAllowed) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.familyDetailsSignInRequired)),
      );
      return;
    }

    final scanned = await _nav.pushHouseholdScanJoinHousehold(context);
    if (!context.mounted || scanned == null || scanned.isEmpty) return;

    final hid = scanned.trim();
    if (!isCanonicalUuidString(hid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.familyScanInvalidCode)),
      );
      return;
    }

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null && hid == uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.familyJoinCannotUseOwnUserId)),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    final preview = await _repo.fetchFamilyInvitePreview(hid);
    if (preview != null) {
      if (uid != null && preview.creatorId == uid) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.familyScanOwnPendingInvite)),
        );
        return;
      }
      if (!context.mounted) return;
      final accepted = await _nav.pushJoinFamilyConfirm(context, preview);
      if (!context.mounted) return;
      if (accepted == true) {
        final name = await _repo.fetchHouseholdDisplayName(hid) ?? preview.displayName;
        if (!context.mounted) return;
        await _nav.pushFamilyMembers(
          context,
          householdId: hid,
          householdName: name,
        );
        if (context.mounted) await load();
      }
      return;
    }

    final fresh = await _repo.fetchHouseholds();
    HouseholdSummaryRow? already;
    for (final h in fresh) {
      if (h.householdId == hid) {
        already = h;
        break;
      }
    }
    if (already != null) {
      final row = already;
      if (row.isPersonal) {
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.familyPersonalNoInvite)),
        );
        return;
      }
      final members = await _repo.fetchMembers(row.householdId);
      final selfUid = Supabase.instance.client.auth.currentUser?.id;
      if (members.length == 1 && selfUid != null && members.single.userId == selfUid) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.familyJoinSoloOwnHouseholdQrInvalid)),
        );
        return;
      }
      if (!context.mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text(AppStrings.familyJoinAlreadyIn)));
      if (!context.mounted) return;
      await _nav.pushFamilyMembers(
        context,
        householdId: row.householdId,
        householdName: row.name,
      );
      if (context.mounted) await load();
      return;
    }

    final joinResult = await _repo.joinHouseholdAsMember(hid);
    if (!context.mounted) return;

    if (joinResult == JoinHouseholdResult.success || joinResult == JoinHouseholdResult.alreadyMember) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            joinResult == JoinHouseholdResult.success
                ? AppStrings.familyJoinSuccess
                : AppStrings.familyJoinAlreadyIn,
          ),
        ),
      );
      final name = await _repo.fetchHouseholdDisplayName(hid) ?? 'Household';
      if (!context.mounted) return;
      await _nav.pushFamilyMembers(
        context,
        householdId: hid,
        householdName: name,
      );
      if (context.mounted) await load();
      return;
    }

    if (joinResult == JoinHouseholdResult.invalidHousehold) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.familyJoinInvalidHousehold)),
      );
      return;
    }
    if (joinResult == JoinHouseholdResult.notAuthenticated) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.familyDetailsSignInRequired)),
      );
      return;
    }
    if (joinResult == JoinHouseholdResult.selfCodeNotAllowed) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.familyJoinCannotUseOwnUserId)),
      );
      return;
    }
    if (joinResult == JoinHouseholdResult.personalHouseholdNotJoinable) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.familyPersonalNoInvite)),
      );
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.familyJoinGenericError)),
    );
  }
}
