import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/recurring/recurring_calendar.dart';
import 'package:money_manager/data/repositories/recurring_payment_repository.dart';
import 'package:money_manager/features/add_expense/data/default_expense_categories.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/features/expenses/widgets/recurring_mark_paid_sheet.dart';
import 'package:money_manager/share/share.dart';

class DashboardUpcomingBillsCard extends StatelessWidget {
  const DashboardUpcomingBillsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final recurring = AppServices.of(context).recurring;
    final categories = defaultExpenseCategories();
    final categoryById = {for (final c in categories) c.id: c};
    final monthKey = monthKeyForDate(DateTime.now());

    return AppCard(
      child: StreamBuilder<({List<RecurringMonthRow> overdue, List<RecurringMonthRow> upcoming})>(
        stream: recurring.watchHomeSections(),
        builder: (context, snapshot) {
          final overdue = snapshot.data?.overdue ?? const [];
          final upcoming = snapshot.data?.upcoming ?? const [];
          final textTheme = Theme.of(context).textTheme;

          if (overdue.isEmpty && upcoming.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.upcomingBills, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  AppStrings.recurringHomeEmpty,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.upcomingBills, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.s16),
              if (overdue.isNotEmpty) ...[
                Text(
                  AppStrings.recurringOverdue,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                for (final r in overdue)
                  _DashboardRecurringRow(
                    row: r,
                    category: categoryById[r.template.categoryId],
                    onMarkPaid: () => showMarkRecurringPaidSheet(
                      context,
                      repo: recurring,
                      row: r,
                      monthKey: monthKey,
                    ),
                  ),
                if (upcoming.isNotEmpty) const SizedBox(height: AppSpacing.s16),
              ],
              if (upcoming.isNotEmpty) ...[
                Text(
                  AppStrings.recurringUpcoming,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.s8),
                for (final r in upcoming)
                  _DashboardRecurringRow(
                    row: r,
                    category: categoryById[r.template.categoryId],
                    onMarkPaid: () => showMarkRecurringPaidSheet(
                      context,
                      repo: recurring,
                      row: r,
                      monthKey: monthKey,
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DashboardRecurringRow extends StatelessWidget {
  const _DashboardRecurringRow({
    required this.row,
    required this.category,
    required this.onMarkPaid,
  });

  final RecurringMonthRow row;
  final ExpenseCategory? category;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final icon = category?.icon ?? Icons.receipt_long;
    final iconBg = category?.backgroundColor ?? AppColors.surfaceContainerHigh;
    final iconFg = category?.foregroundColor ?? AppColors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: InkWell(
        onTap: onMarkPaid,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s12),
                child: Icon(icon, color: iconFg),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.template.title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    '${AppStrings.recurringDuePrefix} ${row.effectiveDueDay}',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    AppStrings.recurringMarkPaid,
                    style: textTheme.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Text(
              formatExpenseMinor(context, row.template.amountMinorSuggested),
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
