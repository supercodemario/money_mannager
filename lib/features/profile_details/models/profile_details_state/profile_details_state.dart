import 'package:money_manager/data/local/app_database.dart';

enum ProfileDetailsPhase { loading, ready, error }

class ProfileDetailsState {
  const ProfileDetailsState({
    this.phase = ProfileDetailsPhase.loading,
    this.profile,
    this.busy = false,
  });

  final ProfileDetailsPhase phase;
  final UserProfile? profile;
  final bool busy;

  ProfileDetailsState copyWith({
    ProfileDetailsPhase? phase,
    UserProfile? profile,
    bool? busy,
  }) {
    return ProfileDetailsState(
      phase: phase ?? this.phase,
      profile: profile ?? this.profile,
      busy: busy ?? this.busy,
    );
  }
}
