import 'package:money_manager/data/remote/household_remote_gateway.dart';

enum PreferencesDetailsPhase { loading, ready, error }

class PreferencesDetailsState {
  const PreferencesDetailsState({
    this.phase = PreferencesDetailsPhase.loading,
    this.userId,
    this.currency = PreferencesDetailsState.defaultCurrency,
    this.language = PreferencesDetailsState.defaultLanguage,
    this.numberFormat = PreferencesDetailsState.defaultNumberFormat,
    this.households = const [],
    this.defaultHouseholdId,
    this.saving = false,
    this.householdSaveError,
  });

  static const defaultCurrency = 'USD';
  static const defaultLanguage = 'en';
  static const defaultNumberFormat = 'us';

  static const currencies = ['USD', 'EUR', 'INR'];
  static const languages = ['en', 'es', 'fr'];
  static const numberFormats = ['us', 'eu', 'in'];

  final PreferencesDetailsPhase phase;
  final String? userId;
  final String currency;
  final String language;
  final String numberFormat;
  final List<HouseholdSummaryRow> households;
  final String? defaultHouseholdId;
  final bool saving;
  final String? householdSaveError;

  PreferencesDetailsState copyWith({
    PreferencesDetailsPhase? phase,
    String? userId,
    String? currency,
    String? language,
    String? numberFormat,
    List<HouseholdSummaryRow>? households,
    String? defaultHouseholdId,
    bool? saving,
    String? householdSaveError,
    bool clearHouseholdSaveError = false,
  }) {
    return PreferencesDetailsState(
      phase: phase ?? this.phase,
      userId: userId ?? this.userId,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      numberFormat: numberFormat ?? this.numberFormat,
      households: households ?? this.households,
      defaultHouseholdId: defaultHouseholdId ?? this.defaultHouseholdId,
      saving: saving ?? this.saving,
      householdSaveError: clearHouseholdSaveError
          ? null
          : (householdSaveError ?? this.householdSaveError),
    );
  }
}
