import 'dart:async';

import 'package:drift/drift.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/expense_limits/expense_limits_calculator.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/recurring/recurring_calendar.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

/// Derived indicative limits for UI (guidance only).
class ExpenseLimitsDerived {
  const ExpenseLimitsDerived({
    required this.hasIncome,
    required this.spendablePoolMinor,
    required this.indicativeDailyMinor,
    required this.daysInMonth,
    required this.recurringDeductionMinor,
  });

  final bool hasIncome;
  final int spendablePoolMinor;
  final int indicativeDailyMinor;
  final int daysInMonth;
  final int recurringDeductionMinor;

  static const empty = ExpenseLimitsDerived(
    hasIncome: false,
    spendablePoolMinor: 0,
    indicativeDailyMinor: 0,
    daysInMonth: 30,
    recurringDeductionMinor: 0,
  );

  static ExpenseLimitsDerived compute({
    required ExpenseLimitPreference? prefs,
    required List<RecurringMonthRow> recurringRows,
    required DateTime nowLocal,
  }) {
    final income = prefs?.monthlyIncomeMinor;
    final recurringDeduction = RecurringMonthRow.sumUnpaidSuggestedMinor(
      recurringRows,
    );
    final days = ExpenseLimitsCalculator.daysInMonth(
      DateTime(nowLocal.year, nowLocal.month),
    );

    final pref = prefs;
    if (pref == null || income == null || income <= 0) {
      return ExpenseLimitsDerived(
        hasIncome: false,
        spendablePoolMinor: 0,
        indicativeDailyMinor: 0,
        daysInMonth: days,
        recurringDeductionMinor: recurringDeduction,
      );
    }

    final savings = pref.monthlySavingsMinor ?? 0;
    final exclude = pref.excludeUnpaidRecurring;
    final pool = ExpenseLimitsCalculator.spendablePoolMinor(
      incomeMinor: income,
      savingsMinor: savings,
      recurringDeductionMinor: recurringDeduction,
      excludeRecurring: exclude,
    );
    final daily = ExpenseLimitsCalculator.indicativeDailyMinor(
      poolMinor: pool,
      daysInMonth: days,
    );

    return ExpenseLimitsDerived(
      hasIncome: true,
      spendablePoolMinor: pool,
      indicativeDailyMinor: daily,
      daysInMonth: days,
      recurringDeductionMinor: recurringDeduction,
    );
  }
}

/// True when [prefs] has monthly income or a savings goal set (expense-limits guidance inputs).
bool expenseLimitsHasMonthlyGuidanceConfigured(ExpenseLimitPreference? prefs) {
  if (prefs == null) return false;
  final income = prefs.monthlyIncomeMinor;
  if (income != null && income > 0) return true;
  final savings = prefs.monthlySavingsMinor;
  return savings != null && savings > 0;
}

class ExpenseLimitsRepository {
  ExpenseLimitsRepository(
    this._db,
    this._recurring, {
    required UserProfileRepository profiles,
    required CloudSyncController cloudSync,
    DateTime Function()? nowProvider,
    Duration? monthCheckInterval,
  }) : _profiles = profiles,
       _cloudSync = cloudSync,
       _nowProvider = nowProvider ?? DateTime.now,
       _monthCheckInterval = monthCheckInterval ?? const Duration(minutes: 1);

  final AppDatabase _db;
  final RecurringPaymentRepository _recurring;
  final UserProfileRepository _profiles;
  final CloudSyncController _cloudSync;
  final DateTime Function() _nowProvider;
  final Duration _monthCheckInterval;

  Stream<ExpenseLimitPreference?> watchPreferences(String userId) {
    return (_db.select(
      _db.expenseLimitPreferences,
    )..where((t) => t.userId.equals(userId))).watch().map((rows) {
      if (rows.isEmpty) return null;
      return rows.first;
    });
  }

  Future<ExpenseLimitPreference?> getPreferences(String userId) {
    return (_db.select(
      _db.expenseLimitPreferences,
    )..where((t) => t.userId.equals(userId))).getSingleOrNull();
  }

  Future<void> upsertPreferences({
    required String userId,
    int? monthlyIncomeMinor,
    int? monthlySavingsMinor,
    required bool excludeUnpaidRecurring,
  }) async {
    final now = _nowProvider().millisecondsSinceEpoch;
    final existing = await getPreferences(userId);
    final syncStatus = _cloudSync.syncAllowed
        ? SyncStatusValue.pending
        : SyncStatusValue.localOnly;
    if (existing == null) {
      await _db
          .into(_db.expenseLimitPreferences)
          .insert(
            ExpenseLimitPreferencesCompanion.insert(
              userId: userId,
              monthlyIncomeMinor: Value(monthlyIncomeMinor),
              monthlySavingsMinor: Value(monthlySavingsMinor),
              excludeUnpaidRecurring: Value(excludeUnpaidRecurring),
              updatedAt: now,
              syncStatus: Value(syncStatus),
            ),
          );
    } else {
      await (_db.update(
        _db.expenseLimitPreferences,
      )..where((t) => t.userId.equals(userId))).write(
        ExpenseLimitPreferencesCompanion(
          monthlyIncomeMinor: Value(monthlyIncomeMinor),
          monthlySavingsMinor: Value(monthlySavingsMinor),
          excludeUnpaidRecurring: Value(excludeUnpaidRecurring),
          updatedAt: Value(now),
          syncStatus: Value(syncStatus),
        ),
      );
    }
  }

  Stream<List<ExpenseLimitPreference>> watchPendingSync() {
    return (_db.select(
      _db.expenseLimitPreferences,
    )..where((t) => t.syncStatus.equals(SyncStatusValue.pending))).watch();
  }

  Future<List<ExpenseLimitPreference>> getPendingSync() {
    return (_db.select(
      _db.expenseLimitPreferences,
    )..where((t) => t.syncStatus.equals(SyncStatusValue.pending))).get();
  }

  Future<int> countBySyncStatuses(Set<String> statuses) async {
    if (statuses.isEmpty) return 0;
    final q = _db.selectOnly(_db.expenseLimitPreferences)
      ..addColumns([_db.expenseLimitPreferences.userId.count()])
      ..where(
        _db.expenseLimitPreferences.syncStatus.isIn(
          statuses.toList(growable: false),
        ),
      );
    final row = await q.getSingle();
    return row.read(_db.expenseLimitPreferences.userId.count()) ?? 0;
  }

  Future<int> countUnsynced() {
    return countBySyncStatuses({
      SyncStatusValue.localOnly,
      SyncStatusValue.pending,
      SyncStatusValue.error,
    });
  }

  Future<int> promoteLocalOnlyToPending() async {
    return (_db.update(
      _db.expenseLimitPreferences,
    )..where((t) => t.syncStatus.equals(SyncStatusValue.localOnly))).write(
      const ExpenseLimitPreferencesCompanion(
        syncStatus: Value(SyncStatusValue.pending),
      ),
    );
  }

  Future<int> retryErroredAsPending() async {
    return (_db.update(
      _db.expenseLimitPreferences,
    )..where((t) => t.syncStatus.equals(SyncStatusValue.error))).write(
      const ExpenseLimitPreferencesCompanion(
        syncStatus: Value(SyncStatusValue.pending),
      ),
    );
  }

  Future<void> markRemoteSynced({
    required String userId,
    required String authUserId,
  }) async {
    final now = _nowProvider().millisecondsSinceEpoch;
    await (_db.update(
      _db.expenseLimitPreferences,
    )..where((t) => t.userId.equals(userId))).write(
      ExpenseLimitPreferencesCompanion(
        remoteId: Value(authUserId),
        syncStatus: const Value(SyncStatusValue.synced),
        serverUpdatedAt: Value(now),
      ),
    );
  }

  Future<void> markRemoteError(String userId) async {
    await (_db.update(
      _db.expenseLimitPreferences,
    )..where((t) => t.userId.equals(userId))).write(
      const ExpenseLimitPreferencesCompanion(
        syncStatus: Value(SyncStatusValue.error),
      ),
    );
  }

  /// Merges a remote profile row (PostgREST snake_case keys) into Drift using LWW vs local [updated_at].
  Future<void> applyRemoteProfileRow(Map<String, dynamic> m) async {
    final remoteUpdated = m['updated_at'] as int;
    final localUserId = await _profiles.getCurrentUserId();
    final existing = await getPreferences(localUserId);
    if (existing != null && existing.updatedAt > remoteUpdated) {
      return;
    }

    final companion = ExpenseLimitPreferencesCompanion(
      userId: Value(localUserId),
      monthlyIncomeMinor: Value(m['monthly_income_minor'] as int?),
      monthlySavingsMinor: Value(m['monthly_savings_minor'] as int?),
      excludeUnpaidRecurring: Value(
        m['exclude_unpaid_recurring'] as bool? ?? false,
      ),
      updatedAt: Value(remoteUpdated),
      remoteId: Value(m['auth_user_id'] as String?),
      syncStatus: const Value(SyncStatusValue.synced),
      serverUpdatedAt: Value(m['server_updated_at'] as int? ?? remoteUpdated),
    );

    if (existing == null) {
      await _db.into(_db.expenseLimitPreferences).insert(companion);
    } else {
      await (_db.update(
        _db.expenseLimitPreferences,
      )..where((t) => t.userId.equals(localUserId))).write(companion);
    }
  }

  /// Recomputes when preferences change, recurring rows change, or local month rolls over.
  Stream<ExpenseLimitsDerived> watchDerived(String userId) {
    return Stream.multi((controller) {
      ExpenseLimitPreference? prefs;
      List<RecurringMonthRow> rows = [];
      String? activeMonthKey;
      StreamSubscription<List<RecurringMonthRow>>? recurringSub;

      void emit() {
        controller.add(
          ExpenseLimitsDerived.compute(
            prefs: prefs,
            recurringRows: rows,
            nowLocal: _nowProvider(),
          ),
        );
      }

      Future<void> refreshRecurringSubscription() async {
        final monthKey = monthKeyForDate(_nowProvider());
        if (activeMonthKey == monthKey && recurringSub != null) return;

        activeMonthKey = monthKey;
        rows = [];
        await recurringSub?.cancel();
        recurringSub = _recurring.watchRowsForMonth(monthKey).listen((r) {
          rows = r;
          emit();
        }, onError: controller.addError);
        emit();
      }

      final prefsSub = watchPreferences(userId).listen((p) {
        prefs = p;
        emit();
      }, onError: controller.addError);

      unawaited(refreshRecurringSubscription());

      final monthTimer = Timer.periodic(_monthCheckInterval, (_) {
        unawaited(refreshRecurringSubscription());
      });

      controller.onCancel = () async {
        monthTimer.cancel();
        await prefsSub.cancel();
        await recurringSub?.cancel();
      };
    });
  }
}
