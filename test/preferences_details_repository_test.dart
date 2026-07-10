import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/data/repositories/user_preferences_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/features/settings/settings-preferences/data/preferences_details_repository.dart';
import 'package:money_manager/features/settings/settings-preferences/models/preferences_details_state/preferences_details_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadSnapshot uses regional defaults when no prefs row', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = CloudSyncController();
    await cloud.initialize();
    final repo = PreferencesDetailsRepository(
      preferences: UserPreferencesRepository(db),
      profiles: profiles,
      cloudSync: cloud,
      household: HouseholdRemoteGateway(),
    );

    final snapshot = await repo.loadSnapshot();

    expect(snapshot.currency, PreferencesDetailsState.defaultCurrency);
    expect(snapshot.language, PreferencesDetailsState.defaultLanguage);
    expect(snapshot.numberFormat, PreferencesDetailsState.defaultNumberFormat);
    expect(snapshot.households, isEmpty);

    await db.close();
  });

  test('loadSnapshot reads saved regional preferences', () async {
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final prefsRepo = UserPreferencesRepository(db);
    final uid = await profiles.getCurrentUserId();
    await prefsRepo.upsertForUser(
      userId: uid,
      currencyCode: 'EUR',
      languageCode: 'fr',
      numberFormat: 'eu',
    );

    final cloud = CloudSyncController();
    await cloud.initialize();
    final repo = PreferencesDetailsRepository(
      preferences: prefsRepo,
      profiles: profiles,
      cloudSync: cloud,
      household: HouseholdRemoteGateway(),
    );

    final snapshot = await repo.loadSnapshot();

    expect(snapshot.currency, 'EUR');
    expect(snapshot.language, 'fr');
    expect(snapshot.numberFormat, 'eu');

    await db.close();
  });

  test('resolveDefaultHouseholdId picks personal household when stored id missing', () {
    const households = [
      HouseholdSummaryRow(
        householdId: 'shared-1',
        name: 'Family',
        myRole: 'member',
        kind: HouseholdKind.shared,
      ),
      HouseholdSummaryRow(
        householdId: 'personal-1',
        name: 'Self',
        myRole: 'owner',
        kind: HouseholdKind.personal,
      ),
    ];

    final resolved = resolveDefaultHouseholdId(
      storedId: null,
      households: households,
    );

    expect(resolved, 'personal-1');
  });

  test('resolveDefaultHouseholdId clears invalid stored id then picks first', () {
    const households = [
      HouseholdSummaryRow(
        householdId: 'only-shared',
        name: 'Team',
        myRole: 'member',
      ),
    ];

    final resolved = resolveDefaultHouseholdId(
      storedId: 'stale-id',
      households: households,
    );

    expect(resolved, 'only-shared');
  });

  test('loadSnapshot marks persisted default when auto-resolved', () async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.memory();
    final profiles = UserProfileRepository(db);
    final cloud = _SyncAllowedCloudSyncController();
    await cloud.initialize();

    final repo = PreferencesDetailsRepository(
      preferences: UserPreferencesRepository(db),
      profiles: profiles,
      cloudSync: cloud,
      household: _FakeHouseholdGateway(),
    );

    final snapshot = await repo.loadSnapshot();

    expect(snapshot.defaultHouseholdId, 'personal-1');
    expect(snapshot.persistedDefaultHouseholdId, 'personal-1');

    await db.close();
  });
}

class _SyncAllowedCloudSyncController extends CloudSyncController {
  @override
  bool get syncAllowed => true;

  @override
  Future<String?> ensurePersonalHousehold() async => 'personal-1';
}

class _FakeHouseholdGateway extends HouseholdRemoteGateway {
  @override
  Future<List<HouseholdSummaryRow>> fetchHouseholdsForCurrentUser() async {
    return const [
      HouseholdSummaryRow(
        householdId: 'personal-1',
        name: 'Self',
        myRole: 'owner',
        kind: HouseholdKind.personal,
      ),
    ];
  }
}
