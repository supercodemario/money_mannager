import 'package:drift/drift.dart';
import 'package:money_manager/data/local/app_database.dart';
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
  RecurringPaymentRepository(this._db, this._expenses);

  final AppDatabase _db;
  final ExpenseRepository _expenses;

  Future<String> insertTemplate({
    required String title,
    required String categoryId,
    required int amountMinorSuggested,
    required String currencyCode,
    required int dayOfMonth,
    String? endMonthKey,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = const Uuid().v4();
    await _db.into(_db.recurringPayments).insert(
          RecurringPaymentsCompanion.insert(
            id: id,
            title: title.trim(),
            categoryId: categoryId,
            amountMinorSuggested: amountMinorSuggested,
            currencyCode: currencyCode,
            dayOfMonth: dayOfMonth.clamp(1, 31),
            endMonthKey: endMonthKey != null ? Value(endMonthKey) : const Value.absent(),
            isEnabled: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<RecurringPayment?> getTemplateById(String id) {
    return (_db.select(_db.recurringPayments)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> setSchedulingEnabled(String templateId, bool enabled) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.recurringPayments)..where((t) => t.id.equals(templateId))).write(
          RecurringPaymentsCompanion(
            isEnabled: Value(enabled),
            updatedAt: Value(now),
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
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.recurringPayments)..where((t) => t.id.equals(id))).write(
          RecurringPaymentsCompanion(
            title: Value(title.trim()),
            categoryId: Value(categoryId),
            amountMinorSuggested: Value(amountMinorSuggested),
            currencyCode: Value(currencyCode),
            dayOfMonth: Value(dayOfMonth.clamp(1, 31)),
            endMonthKey: Value(endMonthKey),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> deleteTemplate(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.recurringPaymentOccurrences)..where((t) => t.recurringPaymentId.equals(id))).go();
      await (_db.update(_db.expenses)..where((t) => t.recurringPaymentId.equals(id))).write(
            const ExpensesCompanion(recurringPaymentId: Value(null)),
          );
      await (_db.delete(_db.recurringPayments)..where((t) => t.id.equals(id))).go();
    });
  }

  /// All templates (enabled and disabled), ordered for settings management.
  Stream<List<RecurringPayment>> watchAllTemplates() {
    return (_db.select(_db.recurringPayments)
          ..orderBy([
            (t) => OrderingTerm(expression: t.isEnabled, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.title),
          ]))
        .watch();
  }

  /// Count of templates with scheduling enabled (shown on Expenses / Home).
  Stream<int> watchEnabledTemplateCount() {
    return watchAllTemplates().map((list) => list.where((t) => t.isEnabled).length);
  }

  /// Watches enabled templates with optional occurrence for [monthKey] (`YYYY-MM`).
  Stream<List<RecurringMonthRow>> watchRowsForMonth(String monthKey) {
    final templates = _db.select(_db.recurringPayments)
      ..where((t) => t.isEnabled.equals(true))
      ..where((t) => t.endMonthKey.isNull() | t.endMonthKey.isBiggerOrEqualValue(monthKey));
    final q = templates.join([
      leftOuterJoin(
        _db.recurringPaymentOccurrences,
        _db.recurringPaymentOccurrences.recurringPaymentId.equalsExp(_db.recurringPayments.id) &
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
  Stream<({List<RecurringMonthRow> overdue, List<RecurringMonthRow> upcoming})> watchHomeSections() {
    final now = DateTime.now();
    final mk = monthKeyForDate(now);
    return watchRowsForMonth(mk).map((rows) {
      final overdue = <RecurringMonthRow>[];
      final upcoming = <RecurringMonthRow>[];
      for (final r in rows) {
        if (r.isPaid) continue;
        if (isUnpaidOverdueCurrentMonth(templateDayOfMonth: r.template.dayOfMonth, nowLocal: now)) {
          overdue.add(r);
        } else if (isUnpaidUpcomingCurrentMonth(templateDayOfMonth: r.template.dayOfMonth, nowLocal: now)) {
          upcoming.add(r);
        }
      }
      int byDue(RecurringMonthRow a, RecurringMonthRow b) => a.effectiveDueDay.compareTo(b.effectiveDueDay);
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
    final existing = await (_db.select(_db.recurringPaymentOccurrences)
          ..where(
            (o) => o.recurringPaymentId.equals(recurringPaymentId) & o.monthKey.equals(monthKey),
          ))
        .getSingleOrNull();
    if (existing?.expenseId != null) {
      throw StateError('Already paid for this month');
    }

    final template = await (_db.select(_db.recurringPayments)..where((t) => t.id.equals(recurringPaymentId))).getSingle();

    final expenseId = await _expenses.insertExpense(
      amountMinor: amountMinor,
      currencyCode: template.currencyCode,
      categoryId: template.categoryId,
      note: note ?? template.title,
      occurredAt: occurredAtLocal,
      recurringPaymentId: recurringPaymentId,
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    if (existing == null) {
      await _db.into(_db.recurringPaymentOccurrences).insert(
            RecurringPaymentOccurrencesCompanion.insert(
              id: const Uuid().v4(),
              recurringPaymentId: recurringPaymentId,
              monthKey: monthKey,
              expenseId: Value(expenseId),
              createdAt: now,
            ),
          );
    } else {
      await (_db.update(_db.recurringPaymentOccurrences)..where((o) => o.id.equals(existing.id))).write(
            RecurringPaymentOccurrencesCompanion(
              expenseId: Value(expenseId),
            ),
          );
    }
  }
}
