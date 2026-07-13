import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/expense_limits/expense_limits_calculator.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

void main() {
  late AppDatabase db;
  late ExpenseLimitsRepository limits;
  late DateTime now;

  setUp(() async {
    db = AppDatabase.memory();
    await db.ensureReady();
    now = DateTime(2026, 7, 10, 12);
    final cloud = CloudSyncController();
    final profiles = UserProfileRepository(db);
    final expenses = ExpenseRepository(db, profiles, cloud);
    final recurring = RecurringPaymentRepository(db, expenses, cloud);
    limits = ExpenseLimitsRepository(
      db,
      recurring,
      expenses,
      profiles: profiles,
      cloudSync: cloud,
      nowProvider: () => now,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('ensureTodayPaceSnapshot is immutable and uses days left including today', () async {
    final profiles = UserProfileRepository(db);
    final uid = await profiles.getCurrentUserId();

    final first = await limits.ensureTodayPaceSnapshot(
      userId: uid,
      nowLocal: now,
      poolMinor: 3000,
      spentBeforeTodayMinor: 1100,
    );
    // July 2026 has 31 days; day 10 → 22 days left including today.
    expect(first.paceMinor, 1900 ~/ 22);
    expect(first.daysAfterToday, 22);
    expect(first.localDate, ExpenseLimitsCalculator.localDateKey(now));

    final second = await limits.ensureTodayPaceSnapshot(
      userId: uid,
      nowLocal: now,
      poolMinor: 9999,
      spentBeforeTodayMinor: 0,
    );
    expect(second.id, first.id);
    expect(second.paceMinor, first.paceMinor);
    expect(second.poolMinor, first.poolMinor);
    expect(second.spentBeforeTodayMinor, 1100);
  });

  test('ensureTodayPaceSnapshot on last day uses leftover', () async {
    now = DateTime(2026, 7, 31, 12);
    final uid = await UserProfileRepository(db).getCurrentUserId();
    final row = await limits.ensureTodayPaceSnapshot(
      userId: uid,
      nowLocal: now,
      poolMinor: 3000,
      spentBeforeTodayMinor: 0,
    );
    expect(row.daysAfterToday, 1);
    expect(row.paceMinor, 3000);
  });

  test('concurrent ensureTodayPaceSnapshot does not throw or duplicate', () async {
    final uid = await UserProfileRepository(db).getCurrentUserId();
    final results = await Future.wait([
      for (var i = 0; i < 8; i++)
        limits.ensureTodayPaceSnapshot(
          userId: uid,
          nowLocal: now,
          poolMinor: 3000 + i,
          spentBeforeTodayMinor: 100,
        ),
    ]);
    expect(results.map((r) => r.id).toSet().length, 1);
    expect(results.every((r) => r.paceMinor == results.first.paceMinor), isTrue);

    final rows = await (db.select(db.dailyPaceSnapshots)..where(
          (t) =>
              t.userId.equals(uid) &
              t.localDate.equals(ExpenseLimitsCalculator.localDateKey(now)),
        ))
        .get();
    expect(rows.length, 1);
  });

  test('repairs false zero spentBeforeToday lock once expenses are known', () async {
    final uid = await UserProfileRepository(db).getCurrentUserId();
    final bad = await limits.ensureTodayPaceSnapshot(
      userId: uid,
      nowLocal: now,
      poolMinor: 3000,
      spentBeforeTodayMinor: 0,
    );
    expect(bad.paceMinor, 3000 ~/ 22);

    final fixed = await limits.ensureTodayPaceSnapshot(
      userId: uid,
      nowLocal: now,
      poolMinor: 3000,
      spentBeforeTodayMinor: 1100,
    );
    expect(fixed.paceMinor, 1900 ~/ 22);
    expect(fixed.spentBeforeTodayMinor, 1100);
    expect(fixed.id, isNot(bad.id));
  });
}
