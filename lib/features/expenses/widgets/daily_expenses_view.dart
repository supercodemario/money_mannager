import 'package:flutter/material.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/features/expenses/widgets/expense_transaction_row.dart';
import 'package:money_manager/features/expenses/widgets/expenses_empty_state.dart';

class DailyExpensesView extends StatelessWidget {
  const DailyExpensesView({
    super.key,
    required this.repo,
    required this.categoryById,
    required this.selectedDay,
  });

  final ExpenseRepository repo;
  final Map<String, ExpenseCategory> categoryById;

  /// Local calendar day to show (date portion only matters).
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    final start = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final end = start.add(const Duration(days: 1));
    final startUtcMs = start.toUtc().millisecondsSinceEpoch;
    final endUtcMs = end.toUtc().millisecondsSinceEpoch;

    return StreamBuilder<List<ExpenseWithCreator>>(
      stream: repo.watchExpensesInRangeWithCreator(
        startUtcMs: startUtcMs,
        endUtcMs: endUtcMs,
      ),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <ExpenseWithCreator>[];
        if (rows.isEmpty) {
          return const ExpensesEmptyState();
        }

        final sorted = List<ExpenseWithCreator>.of(rows)
          ..sort((a, b) => b.expense.occurredAt.compareTo(a.expense.occurredAt));

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: sorted.length,
          itemBuilder: (context, i) {
            final row = sorted[i];
            return ExpenseTransactionRow(
              expense: row.expense,
              category: categoryById[row.expense.categoryId],
              creatorUserId: row.creatorUserId,
              creatorDisplayName: row.creatorDisplayName,
            );
          },
        );
      },
    );
  }
}
