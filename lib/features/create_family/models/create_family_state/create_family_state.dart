class CreateFamilyState {
  const CreateFamilyState({
    required this.inviteId,
    this.registered = false,
    this.busy = false,
    this.errorText,
  });

  factory CreateFamilyState.initial(String inviteId) => CreateFamilyState(inviteId: inviteId);

  final String inviteId;
  final bool registered;
  final bool busy;
  final String? errorText;

  CreateFamilyState copyWith({
    String? inviteId,
    bool? registered,
    bool? busy,
    String? errorText,
    bool clearError = false,
  }) {
    return CreateFamilyState(
      inviteId: inviteId ?? this.inviteId,
      registered: registered ?? this.registered,
      busy: busy ?? this.busy,
      errorText: clearError ? null : (errorText ?? this.errorText),
    );
  }
}
