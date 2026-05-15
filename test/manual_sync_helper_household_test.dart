import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/sync/manual_sync_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCloudSyncController extends CloudSyncController {
  @override
  bool get syncAllowed => true;

  @override
  Future<void> ensureHouseholdIfNeeded() async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('canRunHouseholdScopedSync is false when household id is missing', () async {
    final db = AppDatabase.memory();
    final cloud = _FakeCloudSyncController();
    addTearDown(db.close);

    final services = AppServices(
      db: db,
      cloudSync: cloud,
      child: const SizedBox.shrink(),
    );

    final canSync = await ManualSyncHelper.canRunHouseholdScopedSync(services);
    expect(canSync, isFalse);
    expect(await SyncMetadataStore.getHouseholdId(), isNull);
  });

  test('canRunHouseholdScopedSync is true when household id is set', () async {
    final db = AppDatabase.memory();
    final cloud = _FakeCloudSyncController();
    addTearDown(db.close);

    await SyncMetadataStore.setHouseholdId('personal-household-id');

    final services = AppServices(
      db: db,
      cloudSync: cloud,
      child: const SizedBox.shrink(),
    );

    final canSync = await ManualSyncHelper.canRunHouseholdScopedSync(services);
    expect(canSync, isTrue);
  });
}
