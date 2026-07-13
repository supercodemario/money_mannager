import 'package:drift/drift.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/user_profile_repository.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/share/tokens/app_strings.dart';
import 'package:money_manager/sync/expense_household_scope.dart';
import 'package:uuid/uuid.dart';

/// One expense with the creator profile resolved for list UI (left join).
class ExpenseWithCreator {
  const ExpenseWithCreator({
    required this.expense,
    required this.creatorUserId,
    required this.creatorDisplayName,
  });

  final Expense expense;
  final String creatorUserId;
  final String creatorDisplayName;
}

class MonthlyCategoryTotal {
  const MonthlyCategoryTotal({
    required this.categoryId,
    required this.totalMinor,
  });

  final String categoryId;
  final int totalMinor;
}

/// One calendar day within a month and total spend for a category (minor units).
class CategoryDayTotal {
  const CategoryDayTotal({
    required this.dayOfMonth,
    required this.totalMinor,
  });

  final int dayOfMonth;
  final int totalMinor;
}

class ExpenseRepository {
  ExpenseRepository(this._db, this._profiles, this._cloudSync);

  final AppDatabase _db;
  final UserProfileRepository _profiles;
  final CloudSyncController _cloudSync;

  Future<String> insertExpense({
    required int amountMinor,
    required String currencyCode,
    required String categoryId,
    String? budgetBucket,
    String? note,
    required DateTime occurredAt,
    String? recurringPaymentId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final userId = await _profiles.getCurrentUserId();
    final id = const Uuid().v4();
    final householdId = await resolveHouseholdForNewExpenseWrite(_cloudSync);

    await _db
        .into(_db.expenses)
        .insert(
          ExpensesCompanion.insert(
            id: id,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            categoryId: categoryId,
            budgetBucket: Value(budgetBucket),
            note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
            occurredAt: occurredAt.toUtc().millisecondsSinceEpoch,
            createdAt: now,
            updatedAt: now,
            createdByUserId: userId,
            recurringPaymentId: recurringPaymentId != null
                ? Value(recurringPaymentId)
                : const Value.absent(),
            householdId: householdId != null
                ? Value(householdId)
                : const Value.absent(),
            syncStatus: _cloudSync.syncAllowed
                ? Value(SyncStatusValue.pending)
                : const Value(SyncStatusValue.localOnly),
          ),
        );

    return id;
  }

  Stream<List<Expense>> watchRecent({int limit = 50}) {
    return (_db.select(_db.expenses)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  /// Whether [userId] has recorded at least one expense.
  Future<bool> hasAnyExpenseForUser(String userId) async {
    final row =
        await (_db.select(_db.expenses)
              ..where((t) => t.createdByUserId.equals(userId))
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  /// Emits whether [userId] has any expense whenever the expenses table changes.
  Stream<bool> watchHasAnyExpenseForUser(String userId) {
    return (_db.select(_db.expenses)
          ..where((t) => t.createdByUserId.equals(userId))
          ..limit(1))
        .watch()
        .map((rows) => rows.isNotEmpty);
  }

  Stream<List<Expense>> watchExpensesInRange({
    required int startUtcMs,
    required int endUtcMs,
    int? limit,
  }) {
    final q = _db.select(_db.expenses)
      ..where((t) => t.occurredAt.isBetweenValues(startUtcMs, endUtcMs))
      ..orderBy([
        (t) => OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc),
      ]);
    if (limit != null) q.limit(limit);
    return q.watch();
  }

  /// Same window as [watchExpensesInRange], with creator profile in one query.
  Stream<List<ExpenseWithCreator>> watchExpensesInRangeWithCreator({
    required int startUtcMs,
    required int endUtcMs,
    int? limit,
  }) {
    final expenses = _db.select(_db.expenses)
      ..where((t) => t.occurredAt.isBetweenValues(startUtcMs, endUtcMs))
      ..orderBy([
        (t) => OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc),
      ]);
    if (limit != null) expenses.limit(limit);

    final q = expenses.join([
      leftOuterJoin(
        _db.userProfiles,
        _db.userProfiles.id.equalsExp(_db.expenses.createdByUserId),
      ),
    ]);

    return q.watch().map(
      (rows) => rows
          .map((row) {
            final expense = row.readTable(_db.expenses);
            final profile = row.readTableOrNull(_db.userProfiles);
            final creatorId = profile?.id ?? expense.createdByUserId;
            final name =
                profile?.displayName ?? AppStrings.expenseUnknownMember;
            return ExpenseWithCreator(
              expense: expense,
              creatorUserId: creatorId,
              creatorDisplayName: name,
            );
          })
          .toList(growable: false),
    );
  }

  /// Expenses in `[startUtcMs, endUtcMs)` for [categoryId] with creator profile join.
  Stream<List<ExpenseWithCreator>> watchCategoryExpensesInMonthWithCreator({
    required String categoryId,
    required int startUtcMs,
    required int endUtcMs,
    int? limit,
  }) {
    final expenses = _db.select(_db.expenses)
      ..where((t) =>
          t.occurredAt.isBetweenValues(startUtcMs, endUtcMs) &
          t.categoryId.equals(categoryId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc),
      ]);
    if (limit != null) expenses.limit(limit);

    final q = expenses.join([
      leftOuterJoin(
        _db.userProfiles,
        _db.userProfiles.id.equalsExp(_db.expenses.createdByUserId),
      ),
    ]);

    return q.watch().map(
      (rows) => rows
          .map((row) {
            final expense = row.readTable(_db.expenses);
            final profile = row.readTableOrNull(_db.userProfiles);
            final creatorId = profile?.id ?? expense.createdByUserId;
            final name =
                profile?.displayName ?? AppStrings.expenseUnknownMember;
            return ExpenseWithCreator(
              expense: expense,
              creatorUserId: creatorId,
              creatorDisplayName: name,
            );
          })
          .toList(growable: false),
    );
  }

  /// Per-local-calendar-day totals for [categoryId] in the month of [monthLocal] (year + month).
  Stream<List<CategoryDayTotal>> watchCategoryDailyTotalsInMonth({
    required String categoryId,
    required DateTime monthLocal,
    required int startUtcMs,
    required int endUtcMs,
  }) {
    return watchCategoryExpensesInMonthWithCreator(
      categoryId: categoryId,
      startUtcMs: startUtcMs,
      endUtcMs: endUtcMs,
    ).map((rows) => _aggregateCategoryDailyTotals(monthLocal, rows));
  }

  static List<CategoryDayTotal> _aggregateCategoryDailyTotals(
    DateTime monthLocal,
    List<ExpenseWithCreator> rows,
  ) {
    final y = monthLocal.year;
    final m = monthLocal.month;
    final lastDay = DateTime(y, m + 1, 0).day;
    final totals = List<int>.filled(lastDay, 0);
    for (final row in rows) {
      final local = DateTime.fromMillisecondsSinceEpoch(
        row.expense.occurredAt,
        isUtc: true,
      ).toLocal();
      if (local.year == y && local.month == m) {
        final day = local.day;
        if (day >= 1 && day <= lastDay) {
          totals[day - 1] += row.expense.amountMinor;
        }
      }
    }
    return List.generate(
      lastDay,
      (i) => CategoryDayTotal(dayOfMonth: i + 1, totalMinor: totals[i]),
      growable: false,
    );
  }

  Stream<List<MonthlyCategoryTotal>> watchMonthlyCategoryTotals({
    required int monthStartUtcMs,
    required int monthEndUtcMs,
  }) {
    return _db
        .customSelect(
          '''
SELECT category_id AS category_id, SUM(amount_minor) AS total_minor
FROM expenses
WHERE occurred_at >= ? AND occurred_at < ?
GROUP BY category_id
ORDER BY total_minor DESC
''',
          variables: [
            Variable.withInt(monthStartUtcMs),
            Variable.withInt(monthEndUtcMs),
          ],
          readsFrom: {_db.expenses},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => MonthlyCategoryTotal(
                  categoryId: r.read<String>('category_id'),
                  totalMinor: r.read<int>('total_minor'),
                ),
              )
              .toList(growable: false),
        );
  }

  /// Called by [SyncOrchestrator] after a successful remote upsert.
  Future<void> markRemoteSynced(String expenseId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(
      _db.expenses,
    )..where((e) => e.id.equals(expenseId))).write(
      ExpensesCompanion(
        remoteId: Value(expenseId),
        syncStatus: const Value(SyncStatusValue.synced),
        serverUpdatedAt: Value(now),
      ),
    );
  }

  /// Called by [SyncOrchestrator] when push fails.
  Future<void> markRemoteError(String expenseId) async {
    await (_db.update(
      _db.expenses,
    )..where((e) => e.id.equals(expenseId))).write(
      const ExpensesCompanion(syncStatus: Value(SyncStatusValue.error)),
    );
  }

  Future<int> countBySyncStatuses(Set<String> statuses) async {
    if (statuses.isEmpty) return 0;
    final q = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.id.count()])
      ..where(_db.expenses.syncStatus.isIn(statuses.toList(growable: false)));
    final row = await q.getSingle();
    return row.read(_db.expenses.id.count()) ?? 0;
  }

  Future<int> countUnsynced() {
    return countBySyncStatuses({
      SyncStatusValue.localOnly,
      SyncStatusValue.pending,
      SyncStatusValue.error,
    });
  }

  Future<int> countAllRows() async {
    final q = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.id.count()]);
    final row = await q.getSingle();
    return row.read(_db.expenses.id.count()) ?? 0;
  }

  Future<int> promoteLocalOnlyToPending() async {
    final householdId = await resolveHouseholdForNewExpenseWrite(_cloudSync);
    if (householdId != null) {
      await (_db.update(_db.expenses)..where(
            (e) =>
                e.syncStatus.equals(SyncStatusValue.localOnly) &
                e.householdId.isNull(),
          ))
          .write(ExpensesCompanion(householdId: Value(householdId)));
    }
    return (_db.update(
      _db.expenses,
    )..where((e) => e.syncStatus.equals(SyncStatusValue.localOnly))).write(
      const ExpensesCompanion(syncStatus: Value(SyncStatusValue.pending)),
    );
  }

  Future<int> retryErroredAsPending() async {
    return (_db.update(
      _db.expenses,
    )..where((e) => e.syncStatus.equals(SyncStatusValue.error))).write(
      const ExpensesCompanion(syncStatus: Value(SyncStatusValue.pending)),
    );
  }

  /// Merges a remote row (PostgREST snake_case keys) into Drift using LWW vs local [updated_at].
  Future<void> applyRemoteExpenseRow(Map<String, dynamic> m) async {
    final id = m['id'] as String;
    final remoteUpdated = m['updated_at'] as int;
    final existing = await (_db.select(
      _db.expenses,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (existing != null && existing.updatedAt > remoteUpdated) {
      return;
    }

    var recurring = m['recurring_payment_id'] as String?;
    if (recurring != null && recurring.isNotEmpty) {
      final recurringId = recurring;
      final template = await (_db.select(
        _db.recurringPayments,
      )..where((t) => t.id.equals(recurringId))).getSingleOrNull();
      if (template == null) {
        logAppError(
          'sync.apply_remote_expense',
          StateError(
            'Missing recurring template $recurringId for expense $id; clearing FK',
          ),
          StackTrace.current,
        );
        recurring = null;
      }
    }

    final remoteAuthUserId = m['auth_user_id'] as String?;
    final creatorProfileId = (remoteAuthUserId == null || remoteAuthUserId.isEmpty)
        ? await _profiles.getCurrentUserId()
        : await _profiles.resolveProfileIdForExpenseAuthor(remoteAuthUserId);

    final companion = ExpensesCompanion(
      id: Value(id),
      amountMinor: Value(m['amount_minor'] as int),
      currencyCode: Value(m['currency_code'] as String),
      categoryId: Value(m['category_id'] as String),
      budgetBucket: Value(m['budget_bucket'] as String?),
      note: Value(m['note'] as String?),
      occurredAt: Value(m['occurred_at'] as int),
      createdAt: Value(m['created_at'] as int),
      updatedAt: Value(remoteUpdated),
      createdByUserId: Value(creatorProfileId),
      recurringPaymentId: recurring != null
          ? Value(recurring)
          : const Value(null),
      remoteId: Value(m['remote_id'] as String? ?? id),
      syncStatus: const Value(SyncStatusValue.synced),
      serverUpdatedAt: Value(m['server_updated_at'] as int? ?? remoteUpdated),
      householdId: Value(m['household_id'] as String?),
    );

    if (existing == null) {
      await _db.into(_db.expenses).insert(companion);
    } else {
      await (_db.update(
        _db.expenses,
      )..where((e) => e.id.equals(id))).write(companion);
    }
  }
}
