import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MembershipCloud extends CloudSyncController {
  _MembershipCloud(this._member);

  final bool? _member;

  @override
  bool get syncAllowed => true;

  @override
  Future<bool?> checkHouseholdMembership(String householdId) async => _member;

  @override
  Future<void> ensureDefaultExpenseHouseholdPreference() async {
    final preferred = await SyncMetadataStore.getDefaultExpenseHouseholdId();
    if (preferred != null) {
      final member = await checkHouseholdMembership(preferred);
      if (member == true) return;
      if (member == null) return;
      await SyncMetadataStore.clearDefaultExpenseHouseholdId();
    }
    await SyncMetadataStore.setDefaultExpenseHouseholdId('personal-fallback');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('setDefaultExpenseHousehold returns false when not a member', () async {
    final cloud = _MembershipCloud(false);

    final ok = await cloud.setDefaultExpenseHousehold('family-1');

    expect(ok, isFalse);
    expect(await SyncMetadataStore.getDefaultExpenseHouseholdId(), isNull);
  });

  test('setDefaultExpenseHousehold persists when member', () async {
    final cloud = _MembershipCloud(true);

    final ok = await cloud.setDefaultExpenseHousehold('family-1');

    expect(ok, isTrue);
    expect(await SyncMetadataStore.getDefaultExpenseHouseholdId(), 'family-1');
  });

  test('setDefaultExpenseHousehold returns false when membership unknown', () async {
    final cloud = _MembershipCloud(null);

    final ok = await cloud.setDefaultExpenseHousehold('family-1');

    expect(ok, isFalse);
    expect(await SyncMetadataStore.getDefaultExpenseHouseholdId(), isNull);
  });

  test('ensureDefaultExpenseHouseholdPreference keeps stored id when membership unknown', () async {
    await SyncMetadataStore.setDefaultExpenseHouseholdId('family-1');
    final cloud = _MembershipCloud(null);

    await cloud.ensureDefaultExpenseHouseholdPreference();

    expect(await SyncMetadataStore.getDefaultExpenseHouseholdId(), 'family-1');
  });
}
