import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/features/auth/account_session_flow.dart';
import 'package:money_manager/sync/manual_sync_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors [signOutWithSyncBeforeLogout] pre-sync gate (unsynced + resolvable household).
Future<bool> shouldShowPreLogoutSync(AppServices services) async {
  final unsynced = await services.expenses.countUnsynced();
  if (unsynced == 0) return false;
  return ManualSyncHelper.canRunHouseholdScopedSync(services);
}

class _FakeCloudSyncController extends CloudSyncController {
  _FakeCloudSyncController({this.provisionPersonalHousehold = false});

  /// When true, [ensureHouseholdIfNeeded] simulates a resolved personal household.
  final bool provisionPersonalHousehold;
  var signOutCalled = 0;

  @override
  bool get syncAllowed => true;

  @override
  Future<void> ensureHouseholdIfNeeded() async {
    if (!provisionPersonalHousehold) return;
    const personalId = 'personal-household-test';
    await SyncMetadataStore.setHouseholdId(personalId);
    await SyncMetadataStore.setDefaultExpenseHouseholdId(personalId);
  }

  @override
  Future<void> signOut() async {
    signOutCalled += 1;
    await SyncMetadataStore.clearAll();
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('pre-logout sync gate', () {
    late AppDatabase db;
    late _FakeCloudSyncController cloud;
    late AppServices services;
    late ExpenseRepository expenses;

    setUp(() {
      db = AppDatabase.memory();
      cloud = _FakeCloudSyncController();
      services = AppServices(
        db: db,
        cloudSync: cloud,
        child: const SizedBox.shrink(),
      );
      expenses = ExpenseRepository(db, UserProfileRepository(db), cloud);
    });

    tearDown(() async {
      await SyncMetadataStore.clearAll();
      await db.close();
    });

    Future<void> insertPendingExpense() => expenses.insertExpense(
      amountMinor: 5000,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime.now(),
    );

    test(
      'is false when unsynced but no household is resolvable (legacy no-family case)',
      () async {
        await insertPendingExpense();
        expect(await expenses.countUnsynced(), 1);
        expect(await shouldShowPreLogoutSync(services), isFalse);
      },
    );

    test(
      'is true when unsynced and personal household is resolved',
      () async {
        cloud = _FakeCloudSyncController(provisionPersonalHousehold: true);
        services = AppServices(
          db: db,
          cloudSync: cloud,
          child: const SizedBox.shrink(),
        );
        expenses = ExpenseRepository(db, UserProfileRepository(db), cloud);

        await insertPendingExpense();
        expect(await expenses.countUnsynced(), 1);
        expect(await shouldShowPreLogoutSync(services), isTrue);

        final row = await (db.select(db.expenses)..limit(1)).getSingle();
        expect(row.householdId, 'personal-household-test');
      },
    );

    test(
      'is false when household resolves but nothing is unsynced',
      () async {
        cloud = _FakeCloudSyncController(provisionPersonalHousehold: true);
        services = AppServices(
          db: db,
          cloudSync: cloud,
          child: const SizedBox.shrink(),
        );
        expenses = ExpenseRepository(db, UserProfileRepository(db), cloud);

        await cloud.ensureHouseholdIfNeeded();
        expect(await expenses.countUnsynced(), 0);
        expect(await shouldShowPreLogoutSync(services), isFalse);
      },
    );
  });

  group('logout without pre-sync screen', () {
    test(
      'wipes local data when gate is false (unsynced, no household)',
      () async {
        final db = AppDatabase.memory();
        final cloud = _FakeCloudSyncController();
        addTearDown(() async {
          await SyncMetadataStore.clearAll();
          await db.close();
        });

        final services = AppServices(
          db: db,
          cloudSync: cloud,
          child: const SizedBox.shrink(),
        );
        final expenses = ExpenseRepository(db, UserProfileRepository(db), cloud);
        await expenses.insertExpense(
          amountMinor: 5000,
          currencyCode: 'USD',
          categoryId: 'grocery',
          occurredAt: DateTime.now(),
        );

        expect(await shouldShowPreLogoutSync(services), isFalse);

        await performLogoutAndWipe(services, cloud);

        expect(cloud.signOutCalled, 1);
        expect(await expenses.countUnsynced(), 0);
      },
    );
  });

  group('logout with pre-sync screen', () {
    test(
      'gate is true so UI would show SyncBeforeLogoutScreen (see sync_before_logout_screen_test)',
      () async {
        final db = AppDatabase.memory();
        final cloud = _FakeCloudSyncController(provisionPersonalHousehold: true);
        addTearDown(() async {
          await SyncMetadataStore.clearAll();
          await db.close();
        });

        final services = AppServices(
          db: db,
          cloudSync: cloud,
          child: const SizedBox.shrink(),
        );
        final expenses = ExpenseRepository(db, UserProfileRepository(db), cloud);
        await expenses.insertExpense(
          amountMinor: 5000,
          currencyCode: 'USD',
          categoryId: 'grocery',
          occurredAt: DateTime.now(),
        );

        expect(await shouldShowPreLogoutSync(services), isTrue);
        expect(cloud.signOutCalled, 0);
      },
    );
  });
}
