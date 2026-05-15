import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/sync/manual_sync_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCloudSyncController extends CloudSyncController {
  _FakeCloudSyncController({this.allowed = true});

  final bool allowed;

  @override
  bool get syncAllowed => allowed;

  @override
  Future<void> ensureDefaultExpenseHouseholdPreference() async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('canRunCloudSync is false when not signed in', () async {
    final db = AppDatabase.memory();
    final cloud = _FakeCloudSyncController(allowed: false);
    addTearDown(db.close);

    final services = AppServices(
      db: db,
      cloudSync: cloud,
      child: const SizedBox.shrink(),
    );

    expect(await ManualSyncHelper.canRunCloudSync(services), isFalse);
  });

  test('canRunCloudSync is true when session allows sync', () async {
    final db = AppDatabase.memory();
    final cloud = _FakeCloudSyncController();
    addTearDown(db.close);

    final services = AppServices(
      db: db,
      cloudSync: cloud,
      child: const SizedBox.shrink(),
    );

    expect(await ManualSyncHelper.canRunCloudSync(services), isTrue);
  });
}
