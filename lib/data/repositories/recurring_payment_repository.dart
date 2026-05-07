import 'package:drift/drift.dart';
import 'package:money_manager/app/cloud_sync_controller.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/remote/sync_constants.dart';
import 'package:money_manager/data/recurring/recurring_calendar.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:uuid/uuid.dart';

/// One recurring template joined with an optional occurrence row for [monthKey].
class RecurringMonthRow {
  RecurringMonthRow({
    required this.template,
    required this.monthKey,
    this.occurrence,
  });

  final RecurringPayment template;
  final String monthKey;
  final RecurringPaymentOccurrence? occurrence;

  bool get isPaid => occurrence?.expenseId != null;

  /// Sum of [template.amountMinorSuggested] for rows that are not paid (enabled templates only come from [watchRowsForMonth]).
  static int sumUnpaidSuggestedMinor(List<RecurringMonthRow> rows) {
    var s = 0;
    for (final r in rows) {
      if (!r.isPaid) s += r.template.amountMinorSuggested;
    }
    return s;
  }

  /// Effective calendar day of due date within the month for [monthKey].
  int get effectiveDueDay {
    final d = firstDayOfMonthKey(monthKey);
    return effectiveDueDayInMonth(d.year, d.month, template.dayOfMonth);
  }
}

class RecurringPaymentRepository {
  RecurringPaymentRepository(
    this._db,
    this._expenses,
    this._cloudSync, {
    DateTime Function()? nowProvider,
  }) : _nowProvider = nowProvider ?? DateTime.now;

  final AppDatabase _db;
  final ExpenseRepository _expenses;
  final CloudSyncController _cloudSync;
  final DateTime Function() _nowProvider;

  String get _writeSyncStatus => _cloudSync.syncAllowed
      ? SyncStatusValue.pending
      : SyncStatusValue.localOnly;

  Future<String> insertTemplate({
    required String title,
    required String categoryId,
    required int amountMinorSuggested,
    required String currencyCode,
    required int dayOfMonth,
    String? endMonthKey,
  }) async {
    final now = _nowProvider().millisecondsSinceEpoch;
    final id = const Uuid().v4();
    await _db
        .into(_db.recurringPayments)
        .insert(
          RecurringPaymentsCompanion.insert(
            id: id,
            title: title.trim(),
            categoryId: categoryId,
            amountMinorSuggested: amountMinorSuggested,
            currencyCode: currencyCode,
            dayOfMonth: dayOfMonth.clamp(1, 31),
            endMonthKey: endMonthKey != null
                ? Value(endMonthKey)
                : const Value.absent(),
            isEnabled: const Value(true),
            isDeleted: const Value(false),
            createdAt: now,
            updatedAt: now,
            syncStatus: Value(_writeSyncStatus),
          ),
        );
    return id;
  }

  Future<RecurringPayment?> getTemplateById(String id) {
    return (_db.select(
      _db.recurringPayments,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> setSchedulingEnabled(String templateId, bool enabled) async {
    final now = _nowProvider().millisecondsSinceEpoch;
    await (_db.update(
      _db.recurringPayments,
    )..where((t) => t.id.equals(templateId))).write(
      RecurringPaymentsCompanion(
        isEnabled: Value(enabled),
        updatedAt: Value(now),
        syncStatus: Value(_writeSyncStatus),
      ),
    );
  }

  Future<void> updateTemplate({
    required String id,
    required String title,
    required String categoryId,
    required int amountMinorSuggested,
    required String currencyCode,
    required int dayOfMonth,
    String? endMonthKey,
  }) async {
    final now = _nowProvider().millisecondsSinceEpoch;
    await (_db.update(
      _db.recurringPayments,
    )..where((t) => t.id.equals(id))).write(
      RecurringPaymentsCompanion(
        title: Value(title.trim()),
        categoryId: Value(categoryId),
        amountMinorSuggested: Value(amountMinorSuggested),
        currencyCode: Value(currencyCode),
        dayOfMonth: Value(dayOfMonth.clamp(1, 31)),
        endMonthKey: Value(endMonthKey),
        updatedAt: Value(now),
        syncStatus: Value(_writeSyncStatus),
      ),
    );
  }

  Future<void> deleteTemplate(String id) async {
    final existing = await getTemplateById(id);
    if (existing == null) return;
    final hasRemoteState =
        existing.remoteId != null ||
        {
          SyncStatusValue.pending,
          SyncStatusValue.synced,
          SyncStatusValue.error,
        }.contains(existing.syncStatus);
    if (hasRemoteState) {
      final now = _nowProvider().millisecondsSinceEpoch;
      await _db.transaction(() async {
        await (_db.update(
          _db.recurringPaymentOccurrences,
        )..where((t) => t.recurringPaymentId.equals(id))).write(
          RecurringPaymentOccurrencesCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(now),
            syncStatus: Value(_writeSyncStatus),
          ),
        );
        await (_db.update(
          _db.recurringPayments,
        )..where((t) => t.id.equals(id))).write(
          RecurringPaymentsCompanion(
            isEnabled: const Value(false),
            isDeleted: const Value(true),
            updatedAt: Value(now),
            syncStatus: Value(_writeSyncStatus),
          ),
        );
      });
      return;
    }

    await _db.transaction(() async {
      await (_db.delete(
        _db.recurringPaymentOccurrences,
      )..where((t) => t.recurringPaymentId.equals(id))).go();
      await (_db.update(_db.expenses)
            ..where((t) => t.recurringPaymentId.equals(id)))
          .write(const ExpensesCompanion(recurringPaymentId: Value(null)));
      await (_db.delete(
        _db.recurringPayments,
      )..where((t) => t.id.equals(id))).go();
    });
  }

  /// All templates (enabled and disabled), ordered for settings management.
  Stream<List<RecurringPayment>> watchAllTemplates() {
    return (_db.select(_db.recurringPayments)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.isEnabled, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.title),
          ]))
        .watch();
  }

  /// Count of templates with scheduling enabled (shown on Expenses / Home).
  Stream<int> watchEnabledTemplateCount() {
    return watchAllTemplates().map(
      (list) => list.where((t) => t.isEnabled).length,
    );
  }

  /// Watches enabled templates with optional occurrence for [monthKey] (`YYYY-MM`).
  Stream<List<RecurringMonthRow>> watchRowsForMonth(String monthKey) {
    final templates = _db.select(_db.recurringPayments)
      ..where((t) => t.isEnabled.equals(true))
      ..where((t) => t.isDeleted.equals(false))
      ..where(
        (t) =>
            t.endMonthKey.isNull() |
            t.endMonthKey.isBiggerOrEqualValue(monthKey),
      );
    final q = templates.join([
      leftOuterJoin(
        _db.recurringPaymentOccurrences,
        _db.recurringPaymentOccurrences.recurringPaymentId.equalsExp(
              _db.recurringPayments.id,
            ) &
            _db.recurringPaymentOccurrences.monthKey.equals(monthKey),
      ),
    ]);
    return q.watch().map((rows) {
      return rows
          .map(
            (row) => RecurringMonthRow(
              template: row.readTable(_db.recurringPayments),
              monthKey: monthKey,
              occurrence: row.readTableOrNull(_db.recurringPaymentOccurrences),
            ),
          )
          .toList(growable: false);
    });
  }

  /// Current calendar month, unpaid only, split for home dashboard.
  Stream<({List<RecurringMonthRow> overdue, List<RecurringMonthRow> upcoming})>
  watchHomeSections() {
    final now = _nowProvider();
    final mk = monthKeyForDate(now);
    return watchRowsForMonth(mk).map((rows) {
      final overdue = <RecurringMonthRow>[];
      final upcoming = <RecurringMonthRow>[];
      for (final r in rows) {
        if (r.isPaid) continue;
        if (isUnpaidOverdueCurrentMonth(
          templateDayOfMonth: r.template.dayOfMonth,
          nowLocal: now,
        )) {
          overdue.add(r);
        } else if (isUnpaidUpcomingCurrentMonth(
          templateDayOfMonth: r.template.dayOfMonth,
          nowLocal: now,
        )) {
          upcoming.add(r);
        }
      }
      int byDue(RecurringMonthRow a, RecurringMonthRow b) =>
          a.effectiveDueDay.compareTo(b.effectiveDueDay);
      overdue.sort(byDue);
      upcoming.sort(byDue);
      return (overdue: overdue, upcoming: upcoming);
    });
  }

  /// Inserts expense + occurrence; throws if already paid for this month.
  Future<void> markPaidForMonth({
    required String recurringPaymentId,
    required String monthKey,
    required int amountMinor,
    required DateTime occurredAtLocal,
    String? note,
  }) async {
    final existing =
        await (_db.select(_db.recurringPaymentOccurrences)..where(
              (o) =>
                  o.recurringPaymentId.equals(recurringPaymentId) &
                  o.monthKey.equals(monthKey),
            ))
            .getSingleOrNull();
    if (existing?.expenseId != null) {
      throw StateError('Already paid for this month');
    }

    final template = await (_db.select(
      _db.recurringPayments,
    )..where((t) => t.id.equals(recurringPaymentId))).getSingle();

    final expenseId = await _expenses.insertExpense(
      amountMinor: amountMinor,
      currencyCode: template.currencyCode,
      categoryId: template.categoryId,
      note: note ?? template.title,
      occurredAt: occurredAtLocal,
      recurringPaymentId: recurringPaymentId,
    );

    final now = _nowProvider().millisecondsSinceEpoch;
    if (existing == null) {
      await _db
          .into(_db.recurringPaymentOccurrences)
          .insert(
            RecurringPaymentOccurrencesCompanion.insert(
              id: const Uuid().v4(),
              recurringPaymentId: recurringPaymentId,
              monthKey: monthKey,
              expenseId: Value(expenseId),
              isDeleted: const Value(false),
              createdAt: now,
              updatedAt: Value(now),
              syncStatus: Value(_writeSyncStatus),
            ),
          );
    } else {
      await (_db.update(
        _db.recurringPaymentOccurrences,
      )..where((o) => o.id.equals(existing.id))).write(
        RecurringPaymentOccurrencesCompanion(
          expenseId: Value(expenseId),
          isDeleted: const Value(false),
          updatedAt: Value(now),
          syncStatus: Value(_writeSyncStatus),
        ),
      );
    }
  }

  Stream<List<RecurringPayment>> watchPendingTemplates() {
    return (_db.select(
      _db.recurringPayments,
    )..where((t) => t.syncStatus.equals(SyncStatusValue.pending))).watch();
  }

  Stream<List<RecurringPaymentOccurrence>> watchPendingOccurrences() {
    return (_db.select(
      _db.recurringPaymentOccurrences,
    )..where((t) => t.syncStatus.equals(SyncStatusValue.pending))).watch();
  }

  Future<List<RecurringPayment>> getPendingTemplates() {
    return (_db.select(
      _db.recurringPayments,
    )..where((t) => t.syncStatus.equals(SyncStatusValue.pending))).get();
  }

  Future<List<RecurringPaymentOccurrence>> getPendingOccurrences() {
    return (_db.select(
      _db.recurringPaymentOccurrences,
    )..where((t) => t.syncStatus.equals(SyncStatusValue.pending))).get();
  }

  Future<int> countTemplateStatuses(Set<String> statuses) async {
    if (statuses.isEmpty) return 0;
    final q = _db.selectOnly(_db.recurringPayments)
      ..addColumns([_db.recurringPayments.id.count()])
      ..where(
        _db.recurringPayments.syncStatus.isIn(statuses.toList(growable: false)),
      );
    final row = await q.getSingle();
    return row.read(_db.recurringPayments.id.count()) ?? 0;
  }

  Future<int> countOccurrenceStatuses(Set<String> statuses) async {
    if (statuses.isEmpty) return 0;
    final q = _db.selectOnly(_db.recurringPaymentOccurrences)
      ..addColumns([_db.recurringPaymentOccurrences.id.count()])
      ..where(
        _db.recurringPaymentOccurrences.syncStatus.isIn(
          statuses.toList(growable: false),
        ),
      );
    final row = await q.getSingle();
    return row.read(_db.recurringPaymentOccurrences.id.count()) ?? 0;
  }

  Future<int> countBySyncStatuses(Set<String> statuses) async {
    return await countTemplateStatuses(statuses) +
        await countOccurrenceStatuses(statuses);
  }

  Future<int> countAllRows() async {
    final templateQuery = _db.selectOnly(_db.recurringPayments)
      ..addColumns([_db.recurringPayments.id.count()]);
    final occurrenceQuery = _db.selectOnly(_db.recurringPaymentOccurrences)
      ..addColumns([_db.recurringPaymentOccurrences.id.count()]);
    final templateRow = await templateQuery.getSingle();
    final occurrenceRow = await occurrenceQuery.getSingle();
    return (templateRow.read(_db.recurringPayments.id.count()) ?? 0) +
        (occurrenceRow.read(_db.recurringPaymentOccurrences.id.count()) ?? 0);
  }

  Future<int> countUnsynced() {
    return countBySyncStatuses({
      SyncStatusValue.localOnly,
      SyncStatusValue.pending,
      SyncStatusValue.error,
    });
  }

  Future<int> promoteLocalOnlyToPending() async {
    final templates =
        await (_db.update(
          _db.recurringPayments,
        )..where((t) => t.syncStatus.equals(SyncStatusValue.localOnly))).write(
          const RecurringPaymentsCompanion(
            syncStatus: Value(SyncStatusValue.pending),
          ),
        );
    final occurrences =
        await (_db.update(
          _db.recurringPaymentOccurrences,
        )..where((t) => t.syncStatus.equals(SyncStatusValue.localOnly))).write(
          const RecurringPaymentOccurrencesCompanion(
            syncStatus: Value(SyncStatusValue.pending),
          ),
        );
    return templates + occurrences;
  }

  Future<int> retryErroredAsPending() async {
    final templates =
        await (_db.update(
          _db.recurringPayments,
        )..where((t) => t.syncStatus.equals(SyncStatusValue.error))).write(
          const RecurringPaymentsCompanion(
            syncStatus: Value(SyncStatusValue.pending),
          ),
        );
    final occurrences =
        await (_db.update(
          _db.recurringPaymentOccurrences,
        )..where((t) => t.syncStatus.equals(SyncStatusValue.error))).write(
          const RecurringPaymentOccurrencesCompanion(
            syncStatus: Value(SyncStatusValue.pending),
          ),
        );
    return templates + occurrences;
  }

  Future<void> markTemplateRemoteSynced(String id) async {
    final now = _nowProvider().millisecondsSinceEpoch;
    await (_db.update(
      _db.recurringPayments,
    )..where((t) => t.id.equals(id))).write(
      RecurringPaymentsCompanion(
        remoteId: Value(id),
        syncStatus: const Value(SyncStatusValue.synced),
        serverUpdatedAt: Value(now),
      ),
    );
  }

  Future<void> markOccurrenceRemoteSynced(String id) async {
    final now = _nowProvider().millisecondsSinceEpoch;
    await (_db.update(
      _db.recurringPaymentOccurrences,
    )..where((t) => t.id.equals(id))).write(
      RecurringPaymentOccurrencesCompanion(
        remoteId: Value(id),
        syncStatus: const Value(SyncStatusValue.synced),
        serverUpdatedAt: Value(now),
      ),
    );
  }

  Future<void> markTemplateRemoteError(String id) async {
    await (_db.update(
      _db.recurringPayments,
    )..where((t) => t.id.equals(id))).write(
      const RecurringPaymentsCompanion(
        syncStatus: Value(SyncStatusValue.error),
      ),
    );
  }

  Future<void> markOccurrenceRemoteError(String id) async {
    await (_db.update(
      _db.recurringPaymentOccurrences,
    )..where((t) => t.id.equals(id))).write(
      const RecurringPaymentOccurrencesCompanion(
        syncStatus: Value(SyncStatusValue.error),
      ),
    );
  }

  Future<void> applyRemoteTemplateRow(Map<String, dynamic> m) async {
    final id = m['id'] as String;
    final remoteUpdated = m['updated_at'] as int;
    final existing = await getTemplateById(id);
    if (existing != null && existing.updatedAt > remoteUpdated) return;

    final companion = RecurringPaymentsCompanion(
      id: Value(id),
      title: Value(m['title'] as String),
      categoryId: Value(m['category_id'] as String),
      amountMinorSuggested: Value(m['amount_minor_suggested'] as int),
      currencyCode: Value(m['currency_code'] as String),
      dayOfMonth: Value(m['day_of_month'] as int),
      endMonthKey: Value(m['end_month_key'] as String?),
      isEnabled: Value(m['is_enabled'] as bool? ?? true),
      isDeleted: Value(m['is_deleted'] as bool? ?? false),
      createdAt: Value(m['created_at'] as int),
      updatedAt: Value(remoteUpdated),
      remoteId: Value(m['remote_id'] as String? ?? id),
      syncStatus: const Value(SyncStatusValue.synced),
      serverUpdatedAt: Value(m['server_updated_at'] as int? ?? remoteUpdated),
    );

    if (existing == null) {
      await _db.into(_db.recurringPayments).insert(companion);
    } else {
      await (_db.update(
        _db.recurringPayments,
      )..where((t) => t.id.equals(id))).write(companion);
    }
  }

  Future<bool> applyRemoteOccurrenceRow(Map<String, dynamic> m) async {
    final id = m['id'] as String;
    final templateId = m['recurring_payment_id'] as String;
    final expenseId = m['expense_id'] as String?;
    final template = await getTemplateById(templateId);
    if (template == null) return false;
    if (expenseId != null) {
      final expense = await (_db.select(
        _db.expenses,
      )..where((e) => e.id.equals(expenseId))).getSingleOrNull();
      if (expense == null) return false;
    }

    final remoteUpdated = m['updated_at'] as int;
    final existing = await (_db.select(
      _db.recurringPaymentOccurrences,
    )..where((o) => o.id.equals(id))).getSingleOrNull();
    if (existing != null && existing.updatedAt > remoteUpdated) return true;

    final companion = RecurringPaymentOccurrencesCompanion(
      id: Value(id),
      recurringPaymentId: Value(templateId),
      monthKey: Value(m['month_key'] as String),
      expenseId: Value(expenseId),
      isDeleted: Value(m['is_deleted'] as bool? ?? false),
      createdAt: Value(m['created_at'] as int),
      updatedAt: Value(remoteUpdated),
      remoteId: Value(m['remote_id'] as String? ?? id),
      syncStatus: const Value(SyncStatusValue.synced),
      serverUpdatedAt: Value(m['server_updated_at'] as int? ?? remoteUpdated),
    );

    if (existing == null) {
      await _db.into(_db.recurringPaymentOccurrences).insert(companion);
    } else {
      await (_db.update(
        _db.recurringPaymentOccurrences,
      )..where((o) => o.id.equals(id))).write(companion);
    }
    return true;
  }
}
