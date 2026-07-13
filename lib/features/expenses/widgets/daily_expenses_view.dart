import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/features/expenses/widgets/expense_transaction_row.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/features/expenses/widgets/expenses_empty_state.dart';
import 'package:money_manager/share/share.dart';

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
    final services = AppServices.of(context);

    return FutureBuilder<String>(
      future: services.profiles.getCurrentUserId(),
      builder: (context, userSnap) {
        final uid = userSnap.data;
        return StreamBuilder<ExpenseLimitsDerived>(
          stream: uid == null
              ? const Stream.empty()
              : services.expenseLimits.watchDerived(uid),
          builder: (context, derivedSnap) {
            final d = derivedSnap.data;
            final hasLimits = d != null && d.hasIncome;
            final planMinor = hasLimits ? d.dailyPlanMinor : null;

            return StreamBuilder<List<ExpenseWithCreator>>(
              stream: repo.watchExpensesInRangeWithCreator(
                startUtcMs: startUtcMs,
                endUtcMs: endUtcMs,
              ),
              builder: (context, snapshot) {
                final rows = snapshot.data ?? const <ExpenseWithCreator>[];
                var totalMinor = 0;
                var recurringMinor = 0;
                for (final row in rows) {
                  totalMinor += row.expense.amountMinor;
                  if (row.expense.recurringPaymentId != null) {
                    recurringMinor += row.expense.amountMinor;
                  }
                }
                final dailyMinor = totalMinor - recurringMinor;

                final sorted = List<ExpenseWithCreator>.of(rows)
                  ..sort(
                    (a, b) =>
                        b.expense.occurredAt.compareTo(a.expense.occurredAt),
                  );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: sorted.isEmpty
                          ? const ExpensesEmptyState()
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: sorted.length,
                              itemBuilder: (context, i) {
                                final row = sorted[i];
                                return ExpenseTransactionRow(
                                  expense: row.expense,
                                  category:
                                      categoryById[row.expense.categoryId],
                                  creatorUserId: row.creatorUserId,
                                  creatorDisplayName: row.creatorDisplayName,
                                );
                              },
                            ),
                    ),
                    _DaySpendSummaryBanner(
                      planMinor: planMinor,
                      totalSpentMinor: totalMinor,
                      dailyMinor: dailyMinor,
                      recurringMinor: recurringMinor,
                      selectedDay: selectedDay,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DaySpendSummaryBanner extends StatelessWidget {
  const _DaySpendSummaryBanner({
    required this.planMinor,
    required this.totalSpentMinor,
    required this.dailyMinor,
    required this.recurringMinor,
    required this.selectedDay,
  });

  final int? planMinor;
  final int totalSpentMinor;
  final int dailyMinor;
  final int recurringMinor;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final planText = planMinor == null
        ? AppStrings.expenseLimitsUnsetValue
        : formatExpenseMinor(context, planMinor!);
    final hasRecurring = recurringMinor > 0;
    final dailyColor = SpendVsPlanColors.resolve(
      planMinor: planMinor,
      dailyMinor: dailyMinor,
      dayLocal: selectedDay,
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.r12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.monthDaySpendPlanLabel} $planText',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: SpendVsPlanColors.plan,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      '${AppStrings.monthDaySpendActualLabel} ${formatExpenseMinor(context, totalSpentMinor)}',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: SpendVsPlanColors.totalSpent,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AppStrings.monthDaySpendDailyExpenseLabel} ${formatExpenseMinor(context, dailyMinor)}',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: dailyColor,
                    ),
                  ),
                  if (hasRecurring) ...[
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      '${AppStrings.monthDaySpendRecurringAmountLabel} ${formatExpenseMinor(context, recurringMinor)}',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: SpendVsPlanColors.recurring,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
