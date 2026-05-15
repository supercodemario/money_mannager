import 'package:money_manager/data/remote/household_remote_gateway.dart';

enum FamilyListPhase { loading, signedOut, loadError, loaded }

class FamilyListState {
  const FamilyListState({
    this.phase = FamilyListPhase.loading,
    this.households = const [],
    this.syncHouseholdId,
  });

  final FamilyListPhase phase;
  final List<HouseholdSummaryRow> households;
  final String? syncHouseholdId;

  FamilyListState copyWith({
    FamilyListPhase? phase,
    List<HouseholdSummaryRow>? households,
    String? syncHouseholdId,
  }) {
    return FamilyListState(
      phase: phase ?? this.phase,
      households: households ?? this.households,
      syncHouseholdId: syncHouseholdId ?? this.syncHouseholdId,
    );
  }
}
