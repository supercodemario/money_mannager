import 'dart:async';

import 'package:drift/drift.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/expense_limits/expense_limits_calculator.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/recurring/recurring_calendar.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';

/// Derived indicative limits for UI (guidance only).
class ExpenseLimitsDerived {
  const ExpenseLimitsDerived({
    required this.hasIncome,
    required this.spendablePoolMinor,
    required this.monthSpentMinor,
    required this.spentBeforeTodayMinor,
    required this.todaySpentMinor,
    required this.dailyPlanMinor,
    required this.paceDailyMinor,
    required this.lockedPaceMinor,
    required this.daysInMonth,
    required this.recurringDeductionMinor,
  });

  final bool hasIncome;
  final int spendablePoolMinor;
  final int monthSpentMinor;

  /// Month spent excluding today's local-date expenses (snapshot write input).
  final int spentBeforeTodayMinor;

  /// Sum of expenses on the current local calendar day.
  final int todaySpentMinor;
  final int dailyPlanMinor;

  /// Pace write formula from [spentBeforeTodayMinor] (not for Home display).
  final int paceDailyMinor;

  /// Immutable Pace for today from [DailyPaceSnapshots] (0 if none / unset).
  final int lockedPaceMinor;
  final int daysInMonth;
  final int recurringDeductionMinor;

  static const empty = ExpenseLimitsDerived(
    hasIncome: false,
    spendablePoolMinor: 0,
    monthSpentMinor: 0,
    spentBeforeTodayMinor: 0,
    todaySpentMinor: 0,
    dailyPlanMinor: 0,
    paceDailyMinor: 0,
    lockedPaceMinor: 0,
    daysInMonth: 30,
    recurringDeductionMinor: 0,
  );

  static ExpenseLimitsDerived compute({
    required ExpenseLimitPreference? prefs,
    required List<RecurringMonthRow> recurringRows,
    required DateTime nowLocal,
    int monthSpentMinor = 0,
    int spentBeforeTodayMinor = 0,
    int todaySpentMinor = 0,
    int lockedPaceMinor = 0,
  }) {
    final income = prefs?.monthlyIncomeMinor;
    final recurringDeduction = RecurringMonthRow.sumUnpaidSuggestedMinor(
      recurringRows,
    );
    final days = ExpenseLimitsCalculator.daysInMonth(
      DateTime(nowLocal.year, nowLocal.month),
    );
    final daysLeft = ExpenseLimitsCalculator.daysLeftIncludingToday(nowLocal);

    final pref = prefs;
    if (pref == null || income == null || income <= 0) {
      return ExpenseLimitsDerived(
        hasIncome: false,
        spendablePoolMinor: 0,
        monthSpentMinor: monthSpentMinor,
        spentBeforeTodayMinor: spentBeforeTodayMinor,
        todaySpentMinor: todaySpentMinor,
        dailyPlanMinor: 0,
        paceDailyMinor: 0,
        lockedPaceMinor: 0,
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
    final plan = ExpenseLimitsCalculator.dailyPlanMinor(
      poolMinor: pool,
      daysInMonth: days,
    );
    final paceWrite = ExpenseLimitsCalculator.paceSnapshotMinor(
      poolMinor: pool,
      spentBeforeTodayMinor: spentBeforeTodayMinor,
      daysLeftIncludingToday: daysLeft,
    );

    return ExpenseLimitsDerived(
      hasIncome: true,
      spendablePoolMinor: pool,
      monthSpentMinor: monthSpentMinor,
      spentBeforeTodayMinor: spentBeforeTodayMinor,
      todaySpentMinor: todaySpentMinor,
      dailyPlanMinor: plan,
      paceDailyMinor: paceWrite,
      lockedPaceMinor: lockedPaceMinor,
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
    this._recurring,
    this._expenses, {
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
  final ExpenseRepository _expenses;
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

  Future<DailyPaceSnapshot?> getPaceSnapshot({
    required String userId,
    required String localDate,
  }) async {
    final rows =
        await (_db.select(_db.dailyPaceSnapshots)
              ..where(
                (t) => t.userId.equals(userId) & t.localDate.equals(localDate),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();
    if (rows.isEmpty) return null;
    if (rows.length > 1) {
      // Concurrent ensures can create duplicates if the unique index was missing.
      for (final dup in rows.skip(1)) {
        await (_db.delete(
          _db.dailyPaceSnapshots,
        )..where((t) => t.id.equals(dup.id))).go();
      }
    }
    return rows.first;
  }

  Stream<DailyPaceSnapshot?> watchPaceSnapshot({
    required String userId,
    required String localDate,
  }) {
    return (_db.select(_db.dailyPaceSnapshots)
          ..where(
            (t) => t.userId.equals(userId) & t.localDate.equals(localDate),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<List<DailyPaceSnapshot>> listPaceSnapshotsInRange({
    required String userId,
    required String startLocalDateInclusive,
    required String endLocalDateInclusive,
  }) {
    return (_db.select(_db.dailyPaceSnapshots)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.localDate.isBiggerOrEqualValue(startLocalDateInclusive) &
                t.localDate.isSmallerOrEqualValue(endLocalDateInclusive),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.localDate)]))
        .get();
  }

  Stream<List<DailyPaceSnapshot>> watchPaceSnapshotsForMonth({
    required String userId,
    required DateTime monthLocal,
  }) {
    final days = ExpenseLimitsCalculator.daysInMonth(monthLocal);
    final y = monthLocal.year;
    final m = monthLocal.month.toString().padLeft(2, '0');
    final start = '$y-$m-01';
    final end = '$y-$m-${days.toString().padLeft(2, '0')}';
    return (_db.select(_db.dailyPaceSnapshots)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.localDate.isBiggerOrEqualValue(start) &
                t.localDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.localDate)]))
        .watch();
  }

  final Map<String, Future<DailyPaceSnapshot>> _ensurePaceInFlight = {};

  /// Inserts today's Pace snapshot if missing. Never updates an existing row.
  Future<DailyPaceSnapshot> ensureTodayPaceSnapshot({
    required String userId,
    required DateTime nowLocal,
    required int poolMinor,
    required int spentBeforeTodayMinor,
  }) {
    final localDate = ExpenseLimitsCalculator.localDateKey(nowLocal);
    final key = '$userId|$localDate';
    final inFlight = _ensurePaceInFlight[key];
    if (inFlight != null) return inFlight;

    final future = _ensureTodayPaceSnapshotUnlocked(
      userId: userId,
      nowLocal: nowLocal,
      localDate: localDate,
      poolMinor: poolMinor,
      spentBeforeTodayMinor: spentBeforeTodayMinor,
    ).whenComplete(() {
      _ensurePaceInFlight.remove(key);
    });
    _ensurePaceInFlight[key] = future;
    return future;
  }

  Future<DailyPaceSnapshot> _ensureTodayPaceSnapshotUnlocked({
    required String userId,
    required DateTime nowLocal,
    required String localDate,
    required int poolMinor,
    required int spentBeforeTodayMinor,
  }) async {
    final existing = await getPaceSnapshot(
      userId: userId,
      localDate: localDate,
    );
    // Repair false lock created before month expenses loaded (spentBeforeToday was 0).
    if (existing != null) {
      if (existing.spentBeforeTodayMinor == 0 && spentBeforeTodayMinor > 0) {
        await (_db.delete(
          _db.dailyPaceSnapshots,
        )..where((t) => t.id.equals(existing.id))).go();
      } else {
        return existing;
      }
    }

    final daysLeft = ExpenseLimitsCalculator.daysLeftIncludingToday(nowLocal);
    final pace = ExpenseLimitsCalculator.paceSnapshotMinor(
      poolMinor: poolMinor,
      spentBeforeTodayMinor: spentBeforeTodayMinor,
      daysLeftIncludingToday: daysLeft,
    );
    final createdAt = _nowProvider().millisecondsSinceEpoch;
    try {
      final id = await _db
          .into(_db.dailyPaceSnapshots)
          .insert(
            DailyPaceSnapshotsCompanion.insert(
              userId: userId,
              localDate: localDate,
              paceMinor: pace,
              poolMinor: poolMinor,
              spentBeforeTodayMinor: spentBeforeTodayMinor,
              daysAfterToday: daysLeft,
              createdAtMs: createdAt,
            ),
          );
      return DailyPaceSnapshot(
        id: id,
        userId: userId,
        localDate: localDate,
        paceMinor: pace,
        poolMinor: poolMinor,
        spentBeforeTodayMinor: spentBeforeTodayMinor,
        daysAfterToday: daysLeft,
        createdAtMs: createdAt,
      );
    } catch (_) {
      final afterRace = await getPaceSnapshot(
        userId: userId,
        localDate: localDate,
      );
      if (afterRace != null) return afterRace;
      rethrow;
    }
  }

  /// Recomputes when preferences, recurring rows, month spent, or local month change.
  Stream<ExpenseLimitsDerived> watchDerived(String userId) {
    return Stream.multi((controller) {
      ExpenseLimitPreference? prefs;
      List<RecurringMonthRow> rows = [];
      List<Expense> monthExpenses = [];
      var lockedPaceMinor = 0;
      var expensesReady = false;
      var recurringReady = false;
      String? activeMonthKey;
      StreamSubscription<List<RecurringMonthRow>>? recurringSub;
      StreamSubscription<List<Expense>>? spentSub;

      void emit() {
        final now = _nowProvider();
        final split = ExpenseLimitsCalculator.splitMonthSpentByLocalDay(
          expenses: monthExpenses.map(
            (e) => (occurredAtUtcMs: e.occurredAt, amountMinor: e.amountMinor),
          ),
          nowLocal: now,
        );
        final monthSpent = split.beforeTodayMinor + split.todayMinor;
        controller.add(
          ExpenseLimitsDerived.compute(
            prefs: prefs,
            recurringRows: rows,
            nowLocal: now,
            monthSpentMinor: monthSpent,
            spentBeforeTodayMinor: split.beforeTodayMinor,
            todaySpentMinor: split.todayMinor,
            lockedPaceMinor: lockedPaceMinor,
          ),
        );
      }

      Future<void> ensureLockedPace() async {
        final now = _nowProvider();
        final income = prefs?.monthlyIncomeMinor;
        if (prefs == null || income == null || income <= 0) {
          lockedPaceMinor = 0;
          emit();
          return;
        }

        // Wait until month expense + recurring streams have emitted once so Pace
        // is not locked with spentBeforeToday = 0 while data is still loading.
        if (!expensesReady || !recurringReady) {
          emit();
          return;
        }

        final split = ExpenseLimitsCalculator.splitMonthSpentByLocalDay(
          expenses: monthExpenses.map(
            (e) => (occurredAtUtcMs: e.occurredAt, amountMinor: e.amountMinor),
          ),
          nowLocal: now,
        );
        final recurringDeduction = RecurringMonthRow.sumUnpaidSuggestedMinor(
          rows,
        );
        final pool = ExpenseLimitsCalculator.spendablePoolMinor(
          incomeMinor: income,
          savingsMinor: prefs!.monthlySavingsMinor ?? 0,
          recurringDeductionMinor: recurringDeduction,
          excludeRecurring: prefs!.excludeUnpaidRecurring,
        );

        try {
          final row = await ensureTodayPaceSnapshot(
            userId: userId,
            nowLocal: now,
            poolMinor: pool,
            spentBeforeTodayMinor: split.beforeTodayMinor,
          );
          lockedPaceMinor = row.paceMinor;
        } catch (_) {
          lockedPaceMinor = 0;
        }
        emit();
      }

      ({int startUtcMs, int endUtcMs}) monthRangeUtcMs(DateTime nowLocal) {
        final startLocal = DateTime(nowLocal.year, nowLocal.month, 1);
        final endLocal = DateTime(nowLocal.year, nowLocal.month + 1, 1);
        return (
          startUtcMs: startLocal.toUtc().millisecondsSinceEpoch,
          endUtcMs: endLocal.toUtc().millisecondsSinceEpoch,
        );
      }

      Future<void> refreshMonthSubscriptions() async {
        final now = _nowProvider();
        final monthKey = monthKeyForDate(now);
        if (activeMonthKey == monthKey &&
            recurringSub != null &&
            spentSub != null) {
          return;
        }

        activeMonthKey = monthKey;
        rows = [];
        monthExpenses = [];
        lockedPaceMinor = 0;
        expensesReady = false;
        recurringReady = false;
        await recurringSub?.cancel();
        await spentSub?.cancel();

        recurringSub = _recurring.watchRowsForMonth(monthKey).listen((r) {
          rows = r;
          recurringReady = true;
          unawaited(ensureLockedPace());
        }, onError: controller.addError);

        final range = monthRangeUtcMs(now);
        spentSub = _expenses
            .watchExpensesInRange(
              startUtcMs: range.startUtcMs,
              endUtcMs: range.endUtcMs,
            )
            .listen((expenses) {
              monthExpenses = expenses;
              expensesReady = true;
              // Do not rewrite an existing snapshot when spend updates (except
              // repair of a false zero spentBeforeToday lock — see ensure).
              unawaited(ensureLockedPace());
            }, onError: controller.addError);
        emit();
      }

      final prefsSub = watchPreferences(userId).listen((p) {
        prefs = p;
        unawaited(ensureLockedPace());
      }, onError: controller.addError);

      unawaited(refreshMonthSubscriptions());

      final monthTimer = Timer.periodic(_monthCheckInterval, (_) {
        unawaited(refreshMonthSubscriptions());
      });

      controller.onCancel = () async {
        monthTimer.cancel();
        await prefsSub.cancel();
        await recurringSub?.cancel();
        await spentSub?.cancel();
      };
    });
  }
}
