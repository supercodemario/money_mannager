import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

void main() {
  test('watchExpensesInRangeWithCreator joins creator display name', () async {
    final cloud = CloudSyncController();
    await cloud.initialize();

    final db = AppDatabase.memory();
    await db.ensureReady();
    final profiles = UserProfileRepository(db);
    final profile = await profiles.getCurrentProfile();
    final repo = ExpenseRepository(db, profiles, cloud);

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    await repo.insertExpense(
      amountMinor: 50,
      currencyCode: 'USD',
      categoryId: 'grocery',
      occurredAt: now,
    );

    final list = await repo
        .watchExpensesInRangeWithCreator(
          startUtcMs: start.toUtc().millisecondsSinceEpoch,
          endUtcMs: end.toUtc().millisecondsSinceEpoch,
        )
        .first;

    expect(list, hasLength(1));
    expect(list.single.creatorDisplayName, profile.displayName);
    expect(list.single.creatorUserId, profile.id);
    expect(list.single.expense.createdByUserId, profile.id);
  });

  test(
    'applyRemoteExpenseRow maps distinct auth_user_id to distinct creator profiles',
    () async {
      final cloud = CloudSyncController();
      await cloud.initialize();

      final db = AppDatabase.memory();
      await db.ensureReady();
      final profiles = UserProfileRepository(db);
      final repo = ExpenseRepository(db, profiles, cloud);

      final base = DateTime.utc(2026, 6, 1).millisecondsSinceEpoch;

      Future<void> pullRemote(String expenseId, String authUid) async {
        await repo.applyRemoteExpenseRow({
          'id': expenseId,
          'amount_minor': 10,
          'currency_code': 'USD',
          'category_id': 'grocery',
          'budget_bucket': null,
          'note': null,
          'occurred_at': base,
          'created_at': base,
          'updated_at': base,
          'recurring_payment_id': null,
          'remote_id': expenseId,
          'server_updated_at': base,
          'auth_user_id': authUid,
        });
      }

      await pullRemote(
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        '11111111-1111-1111-1111-111111111111',
      );
      await pullRemote(
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        '22222222-2222-2222-2222-222222222222',
      );

      final rows = await db.select(db.expenses).get();
      expect(rows, hasLength(2));
      expect(rows.map((e) => e.createdByUserId).toSet(), hasLength(2));

      final remoteIds =
          (await db.select(db.userProfiles).get())
              .map((p) => p.remoteId)
              .whereType<String>()
              .toSet();
      expect(remoteIds, contains('11111111-1111-1111-1111-111111111111'));
      expect(remoteIds, contains('22222222-2222-2222-2222-222222222222'));
    },
  );
}
