import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/features/family_members/data/family_members_repository.dart';
import 'package:money_manager/features/family_members/models/family_members_state/family_members_state.dart';

class FamilyMembersCubit extends Cubit<FamilyMembersState> {
  FamilyMembersCubit(this._repo, {required this.householdId})
      : super(const FamilyMembersState());

  final FamilyMembersRepository _repo;
  final String householdId;

  Future<void> load() async {
    emit(const FamilyMembersState(phase: FamilyMembersPhase.loading));
    try {
      final members = await _repo.fetchMembers(householdId);
      final isOwner = await _repo.currentUserIsOwner(householdId);
      final isPersonal = await _repo.isPersonalHousehold(householdId);
      emit(
        FamilyMembersState(
          phase: FamilyMembersPhase.ready,
          members: members,
          isOwner: isOwner,
          isPersonal: isPersonal,
        ),
      );
    } catch (e, st) {
      logAppError('family_members.load', e, st);
      emit(state.copyWith(phase: FamilyMembersPhase.error));
    }
  }

  Future<AddHouseholdMemberResult> addMember(String inviteeAuthUserId) {
    if (state.isPersonal) {
      return Future.value(AddHouseholdMemberResult.personalHouseholdNotShareable);
    }
    return _repo.addMemberAsOwner(
      householdId: householdId,
      inviteeAuthUserId: inviteeAuthUserId,
    );
  }
}
