import 'package:flutter/material.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

class CategoryMonthExpenseCard extends StatelessWidget {
  const CategoryMonthExpenseCard({
    super.key,
    required this.expense,
    required this.creatorDisplayName,
    required this.familyLabel,
  });

  final Expense expense;
  final String creatorDisplayName;
  final String familyLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final local = DateTime.fromMillisecondsSinceEpoch(expense.occurredAt, isUtc: true).toLocal();
    final dateLabel = formatExpenseDetailDateLabel(local);
    final note = expense.note?.trim();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      borderRadius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  formatExpenseMinor(context, expense.amountMinor),
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                dateLabel,
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '${AppStrings.expensePaidByLabel} · $creatorDisplayName',
            style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            '${AppStrings.expenseFamilyLabel} · $familyLabel',
            style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s8),
            Text(
              note,
              style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
