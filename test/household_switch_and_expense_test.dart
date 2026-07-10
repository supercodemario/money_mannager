import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_preferences_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/features/settings/settings-preferences/bloc/preferences_details_cubit.dart';
import 'package:money_manager/features/settings/settings-preferences/data/preferences_details_repository.dart';
import 'package:money_manager/share/tokens/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cloud fake for self ↔ family switch flows.
class _SwitchableCloud extends CloudSyncController {
  _SwitchableCloud(this._membershipById);

  final Map<String, bool?> _membershipById;
  int ensureCalls = 0;

  @override
  bool get syncAllowed => true;

  @override
  Future<bool?> checkHouseholdMembership(String householdId) async {
    return _membershipById[householdId];
  }

  @override
  Future<void> ensureDefaultExpenseHouseholdPreference() async {
    ensureCalls++;
    final preferred = await SyncMetadataStore.getDefaultExpenseHouseholdId();
    if (preferred != null) {
      final member = await checkHouseholdMembership(preferred);
      if (member == true) return;
      if (member == null) return;
      await SyncMetadataStore.clearDefaultExpenseHouseholdId();
    }
    await SyncMetadataStore.setDefaultExpenseHouseholdId('personal-1');
  }

  @override
  Future<String?> ensurePersonalHousehold() async => 'personal-1';
}

class _TwoHouseholdGateway extends HouseholdRemoteGateway {
  @override
  Future<List<HouseholdSummaryRow>> fetchHouseholdsForCurrentUser() async {
    return const [
      HouseholdSummaryRow(
        householdId: 'personal-1',
        name: 'Self',
        myRole: 'owner',
        kind: HouseholdKind.personal,
      ),
      HouseholdSummaryRow(
        householdId: 'family-1',
        name: 'Family',
        myRole: 'member',
        kind: HouseholdKind.shared,
      ),
    ];
  }
}

Future<({ExpenseRepository repo, AppDatabase db})> _expenseRepo(
  _SwitchableCloud cloud,
) async {
  final db = AppDatabase.memory();
  await db.ensureReady();
  final profiles = UserProfileRepository(db);
  return (repo: ExpenseRepository(db, profiles, cloud), db: db);
}

Future<String> _readHouseholdId(AppDatabase db, String expenseId) async {
  final row = await (db.select(db.expenses)..where((e) => e.id.equals(expenseId)))
      .getSingle();
  return row.householdId!;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('switch default household then add expense', () {
    test('expense uses self then family after successful switch', () async {
      final cloud = _SwitchableCloud({
        'personal-1': true,
        'family-1': true,
      });
      await SyncMetadataStore.setDefaultExpenseHouseholdId('personal-1');
      final (:repo, :db) = await _expenseRepo(cloud);

      final selfExpenseId = await repo.insertExpense(
        amountMinor: 100,
        currencyCode: 'USD',
        categoryId: 'grocery',
        occurredAt: DateTime.utc(2026, 5, 20),
      );
      expect(await _readHouseholdId(db, selfExpenseId), 'personal-1');
      expect(cloud.ensureCalls, 0);

      final switched = await cloud.setDefaultExpenseHousehold('family-1');
      expect(switched, isTrue);
      expect(await SyncMetadataStore.getDefaultExpenseHouseholdId(), 'family-1');

      final familyExpenseId = await repo.insertExpense(
        amountMinor: 200,
        currencyCode: 'USD',
        categoryId: 'grocery',
        occurredAt: DateTime.utc(2026, 5, 21),
      );
      expect(await _readHouseholdId(db, familyExpenseId), 'family-1');
      expect(cloud.ensureCalls, 0);

      await db.close();
    });

    test('failed switch to family keeps next expense on self', () async {
      final cloud = _SwitchableCloud({
        'personal-1': true,
        'family-1': false,
      });
      await SyncMetadataStore.setDefaultExpenseHouseholdId('personal-1');
      final (:repo, :db) = await _expenseRepo(cloud);

      final failed = await cloud.setDefaultExpenseHousehold('family-1');
      expect(failed, isFalse);
      expect(await SyncMetadataStore.getDefaultExpenseHouseholdId(), 'personal-1');

      final id = await repo.insertExpense(
        amountMinor: 50,
        currencyCode: 'USD',
        categoryId: 'grocery',
        occurredAt: DateTime.utc(2026, 5, 22),
      );
      expect(await _readHouseholdId(db, id), 'personal-1');

      await db.close();
    });

    test('preferences repository setDefaultHousehold persists family id', () async {
      final cloud = _SwitchableCloud({
        'personal-1': true,
        'family-1': true,
      });
      await SyncMetadataStore.setDefaultExpenseHouseholdId('personal-1');
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final repo = PreferencesDetailsRepository(
        preferences: UserPreferencesRepository(db),
        profiles: profiles,
        cloudSync: cloud,
        household: _TwoHouseholdGateway(),
      );

      final ok = await repo.setDefaultHousehold('family-1');
      expect(ok, isTrue);
      expect(await repo.getStoredDefaultHouseholdId(), 'family-1');

      await db.close();
    });

    test('preferences repository setDefaultHousehold returns false when not member', () async {
      final cloud = _SwitchableCloud({
        'personal-1': true,
        'family-1': false,
      });
      await SyncMetadataStore.setDefaultExpenseHouseholdId('personal-1');
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final repo = PreferencesDetailsRepository(
        preferences: UserPreferencesRepository(db),
        profiles: profiles,
        cloudSync: cloud,
        household: _TwoHouseholdGateway(),
      );

      final ok = await repo.setDefaultHousehold('family-1');
      expect(ok, isFalse);
      expect(await repo.getStoredDefaultHouseholdId(), 'personal-1');

      await db.close();
    });
  });

  group('preferences cubit household switch', () {
    test('cubit reverts dropdown when save fails', () async {
      final cloud = _SwitchableCloud({
        'personal-1': true,
        'family-1': false,
      });
      await SyncMetadataStore.setDefaultExpenseHouseholdId('personal-1');
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final repo = PreferencesDetailsRepository(
        preferences: UserPreferencesRepository(db),
        profiles: profiles,
        cloudSync: cloud,
        household: _TwoHouseholdGateway(),
      );
      final cubit = PreferencesDetailsCubit(repo);

      await cubit.load();
      expect(cubit.state.defaultHouseholdId, 'personal-1');

      await cubit.setDefaultHousehold('family-1');
      expect(cubit.state.defaultHouseholdId, 'personal-1');
      expect(
        cubit.state.householdSaveError,
        AppStrings.preferencesDefaultHouseholdSaveFailed,
      );

      await cubit.close();
      await db.close();
    });

    test('cubit updates dropdown when switch to family succeeds', () async {
      final cloud = _SwitchableCloud({
        'personal-1': true,
        'family-1': true,
      });
      await SyncMetadataStore.setDefaultExpenseHouseholdId('personal-1');
      final db = AppDatabase.memory();
      final profiles = UserProfileRepository(db);
      final repo = PreferencesDetailsRepository(
        preferences: UserPreferencesRepository(db),
        profiles: profiles,
        cloudSync: cloud,
        household: _TwoHouseholdGateway(),
      );
      final cubit = PreferencesDetailsCubit(repo);

      await cubit.load();
      await cubit.setDefaultHousehold('family-1');

      expect(cubit.state.defaultHouseholdId, 'family-1');
      expect(cubit.state.householdSaveError, isNull);

      await cubit.close();
      await db.close();
    });
  });

}
