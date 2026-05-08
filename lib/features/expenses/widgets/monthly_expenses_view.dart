import 'package:flutter/material.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/features/expenses/widgets/expenses_empty_state.dart';
import 'package:money_manager/share/share.dart';

class MonthlyExpensesView extends StatelessWidget {
  const MonthlyExpensesView({
    super.key,
    required this.repo,
    required this.month,
    required this.categoryById,
  });

  final ExpenseRepository repo;
  final DateTime month;
  final Map<String, ExpenseCategory> categoryById;

  @override
  Widget build(BuildContext context) {
    final startLocal = DateTime(month.year, month.month, 1);
    final endLocal = DateTime(month.year, month.month + 1, 1);
    final startUtcMs = startLocal.toUtc().millisecondsSinceEpoch;
    final endUtcMs = endLocal.toUtc().millisecondsSinceEpoch;

    return StreamBuilder<List<MonthlyCategoryTotal>>(
      stream: repo.watchMonthlyCategoryTotals(monthStartUtcMs: startUtcMs, monthEndUtcMs: endUtcMs),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <MonthlyCategoryTotal>[];
        if (rows.isEmpty) return const ExpensesEmptyState();

        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s8),
          itemBuilder: (context, i) {
            final r = rows[i];
            final c = categoryById[r.categoryId];
            return AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              borderRadius: AppRadius.xl,
              child: Row(
                children: [
                  if (c != null)
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      borderRadius: AppRadius.xl,
                      color: c.backgroundColor,
                      child: Icon(c.icon, color: c.foregroundColor, size: AppSpacing.s20),
                    )
                  else
                    const Icon(Icons.category),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      c?.label ?? r.categoryId,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    formatExpenseMinor(context, r.totalMinor),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
