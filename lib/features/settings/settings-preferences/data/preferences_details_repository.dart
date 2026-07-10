import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/data/repositories/user_preferences_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/features/settings/settings-preferences/models/preferences_details_state/preferences_details_state.dart';

class PreferencesDetailsSnapshot {
  const PreferencesDetailsSnapshot({
    required this.userId,
    required this.currency,
    required this.language,
    required this.numberFormat,
    required this.households,
    this.defaultHouseholdId,
    this.persistedDefaultHouseholdId,
  });

  final String userId;
  final String currency;
  final String language;
  final String numberFormat;
  final List<HouseholdSummaryRow> households;
  final String? defaultHouseholdId;

  /// When non-null, caller should persist via [CloudSyncController.setDefaultExpenseHousehold].
  final String? persistedDefaultHouseholdId;
}

class PreferencesDetailsRepository {
  PreferencesDetailsRepository({
    required UserPreferencesRepository preferences,
    required UserProfileRepository profiles,
    required CloudSyncController cloudSync,
    required HouseholdRemoteGateway household,
  }) : _preferences = preferences,
       _profiles = profiles,
       _cloudSync = cloudSync,
       _household = household;

  final UserPreferencesRepository _preferences;
  final UserProfileRepository _profiles;
  final CloudSyncController _cloudSync;
  final HouseholdRemoteGateway _household;

  Future<PreferencesDetailsSnapshot> loadSnapshot() async {
    final uid = await _profiles.getCurrentUserId();
    final prefs = await _preferences.getForUser(uid);

    var households = const <HouseholdSummaryRow>[];
    String? defaultHouseholdId;
    String? persistedDefaultHouseholdId;

    if (_cloudSync.syncAllowed) {
      await _cloudSync.ensurePersonalHousehold();
      households = await _household.fetchHouseholdsForCurrentUser();
      final storedId = await SyncMetadataStore.getDefaultExpenseHouseholdId();
      final resolved = resolveDefaultHouseholdId(
        storedId: storedId,
        households: households,
      );
      defaultHouseholdId = resolved;
      if (resolved != null &&
          resolved != storedId &&
          households.isNotEmpty) {
        persistedDefaultHouseholdId = resolved;
      }
    }

    return PreferencesDetailsSnapshot(
      userId: uid,
      currency: prefs?.currencyCode ?? PreferencesDetailsState.defaultCurrency,
      language: prefs?.languageCode ?? PreferencesDetailsState.defaultLanguage,
      numberFormat:
          prefs?.numberFormat ?? PreferencesDetailsState.defaultNumberFormat,
      households: households,
      defaultHouseholdId: defaultHouseholdId,
      persistedDefaultHouseholdId: persistedDefaultHouseholdId,
    );
  }

  Future<void> upsertRegional({
    required String userId,
    required String currencyCode,
    required String languageCode,
    required String numberFormat,
  }) {
    return _preferences.upsertForUser(
      userId: userId,
      currencyCode: currencyCode,
      languageCode: languageCode,
      numberFormat: numberFormat,
    );
  }

  Future<bool> setDefaultHousehold(String householdId) {
    return _cloudSync.setDefaultExpenseHousehold(householdId);
  }

  Future<String?> getStoredDefaultHouseholdId() {
    return SyncMetadataStore.getDefaultExpenseHouseholdId();
  }

  Future<bool> persistResolvedDefaultIfNeeded(String? householdId) async {
    if (householdId == null) return false;
    return _cloudSync.setDefaultExpenseHousehold(householdId);
  }
}

/// Pure policy from preferences details load — exposed for tests.
String? resolveDefaultHouseholdId({
  required String? storedId,
  required List<HouseholdSummaryRow> households,
}) {
  var defaultHouseholdId = storedId;
  if (defaultHouseholdId != null &&
      households.every((h) => h.householdId != defaultHouseholdId)) {
    defaultHouseholdId = null;
  }
  if (defaultHouseholdId == null && households.isNotEmpty) {
    final self = households.where((h) => h.isPersonal).toList();
    defaultHouseholdId = self.isNotEmpty
        ? self.first.householdId
        : households.first.householdId;
  }
  return defaultHouseholdId;
}
