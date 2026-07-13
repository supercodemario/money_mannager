import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/recurring/recurring_calendar.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/features/expenses/widgets/recurring_mark_paid_sheet.dart';
import 'package:money_manager/share/share.dart';
import 'package:money_manager/sync/manual_sync_helper.dart';

class RecurringExpensesView extends StatelessWidget {
  const RecurringExpensesView({
    super.key,
    required this.repo,
    required this.month,
    required this.categoryById,
  });

  final RecurringPaymentRepository repo;
  final DateTime month;
  final Map<String, ExpenseCategory> categoryById;

  @override
  Widget build(BuildContext context) {
    final monthKey = monthKeyForDate(month);
    final selectedStart = DateTime(month.year, month.month, 1);
    final now = DateTime.now();

    return StreamBuilder<List<RecurringMonthRow>>(
      stream: repo.watchRowsForMonth(monthKey),
      builder: (context, snapshot) {
        final rows = List<RecurringMonthRow>.of(snapshot.data ?? const []);
        rows.sort((a, b) => a.effectiveDueDay.compareTo(b.effectiveDueDay));
        if (rows.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.recurringEmptyTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  AppStrings.recurringEmptySubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s8),
          itemBuilder: (context, i) {
            final r = rows[i];
            final cat = categoryById[r.template.categoryId];
            final overdue = !r.isPaid &&
                isUnpaidOverdueForMonth(
                  selectedMonthStart: selectedStart,
                  templateDayOfMonth: r.template.dayOfMonth,
                  nowLocal: now,
                );
            return AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              borderRadius: AppRadius.xl,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cat != null)
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      borderRadius: AppRadius.xl,
                      color: cat.backgroundColor,
                      child: Icon(cat.icon, color: cat.foregroundColor, size: AppSpacing.s20),
                    )
                  else
                    const Icon(Icons.category),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.template.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          '${AppStrings.recurringDuePrefix} ${r.effectiveDueDay}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: overdue ? AppColors.error : AppColors.onSurfaceVariant,
                                fontWeight: overdue ? FontWeight.w800 : FontWeight.w400,
                              ),
                        ),
                        if (overdue)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.s4),
                            child: Text(
                              AppStrings.recurringOverdue,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatExpenseMinor(context, r.template.amountMinorSuggested),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      if (r.isPaid)
                        Text(
                          AppStrings.recurringPaid,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w800,
                              ),
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => showMarkRecurringPaidSheet(
                                context,
                                repo: repo,
                                row: r,
                                monthKey: monthKey,
                              ),
                              child: const Text(AppStrings.recurringMarkPaid),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: AppStrings.recurringDelete,
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text(AppStrings.recurringDelete),
                                    content: const Text('Remove this recurring payment?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text(AppStrings.cancel),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text(AppStrings.recurringDelete),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await repo.deleteTemplate(r.template.id);
                                  if (context.mounted) {
                                    await ManualSyncHelper
                                        .pushPendingRecurringPaymentsIfAllowed(
                                      AppServices.of(context),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                    ],
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
