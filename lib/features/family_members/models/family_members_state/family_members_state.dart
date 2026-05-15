import 'package:money_manager/data/remote/household_remote_gateway.dart';

enum FamilyMembersPhase { loading, error, ready }

class FamilyMembersState {
  const FamilyMembersState({
    this.phase = FamilyMembersPhase.loading,
    this.members = const [],
    this.isOwner = false,
    this.isPersonal = false,
  });

  final FamilyMembersPhase phase;
  final List<HouseholdMemberRow> members;
  final bool isOwner;
  final bool isPersonal;

  FamilyMembersState copyWith({
    FamilyMembersPhase? phase,
    List<HouseholdMemberRow>? members,
    bool? isOwner,
    bool? isPersonal,
  }) {
    return FamilyMembersState(
      phase: phase ?? this.phase,
      members: members ?? this.members,
      isOwner: isOwner ?? this.isOwner,
      isPersonal: isPersonal ?? this.isPersonal,
    );
  }
}
