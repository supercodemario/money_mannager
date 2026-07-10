import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/sync/expense_household_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCloud extends CloudSyncController {
  _FakeCloud({
    required this.allowed,
    this.membership,
    this.ensureCalls = 0,
  });

  final bool allowed;
  final bool? membership;
  int ensureCalls;

  @override
  bool get syncAllowed => allowed;

  @override
  Future<bool?> checkHouseholdMembership(String householdId) async => membership;

  @override
  Future<void> ensureDefaultExpenseHouseholdPreference() async {
    ensureCalls++;
    await SyncMetadataStore.setDefaultExpenseHouseholdId('fallback-personal');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('resolveHouseholdForNewExpenseWrite uses stored id when member', () async {
    await SyncMetadataStore.setDefaultExpenseHouseholdId('family-1');
    final cloud = _FakeCloud(allowed: true, membership: true);

    final id = await resolveHouseholdForNewExpenseWrite(cloud);

    expect(id, 'family-1');
    expect(cloud.ensureCalls, 0);
  });

  test('resolveHouseholdForNewExpenseWrite keeps stored id when membership check fails', () async {
    await SyncMetadataStore.setDefaultExpenseHouseholdId('family-1');
    final cloud = _FakeCloud(allowed: true, membership: null);

    final id = await resolveHouseholdForNewExpenseWrite(cloud);

    expect(id, 'family-1');
    expect(cloud.ensureCalls, 0);
  });

  test('resolveHouseholdForNewExpenseWrite repairs when not a member', () async {
    await SyncMetadataStore.setDefaultExpenseHouseholdId('stale-id');
    final cloud = _FakeCloud(allowed: true, membership: false);

    final id = await resolveHouseholdForNewExpenseWrite(cloud);

    expect(cloud.ensureCalls, 1);
    expect(id, 'fallback-personal');
  });
}
