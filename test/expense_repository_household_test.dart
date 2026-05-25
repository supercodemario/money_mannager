import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SyncAllowedCloud extends CloudSyncController {
  @override
  bool get syncAllowed => true;

  @override
  Future<void> ensureDefaultExpenseHouseholdPreference() async {
    await SyncMetadataStore.setDefaultExpenseHouseholdId('household-attach-test');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('insertExpense stores householdId when cloud sync is allowed', () async {
    final cloud = _SyncAllowedCloud();
    final db = AppDatabase.memory();
    await db.ensureReady();
    final profiles = UserProfileRepository(db);
    final repo = ExpenseRepository(db, profiles, cloud);

    final id = await repo.insertExpense(
      amountMinor: 100,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: DateTime.utc(2026, 5, 15),
    );

    final row = await (db.select(db.expenses)..where((e) => e.id.equals(id)))
        .getSingle();
    expect(row.householdId, 'household-attach-test');
  });
}
