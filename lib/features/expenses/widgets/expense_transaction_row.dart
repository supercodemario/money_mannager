import 'package:flutter/material.dart';
import 'package:money_manager/data/local/app_database.dart' hide ExpenseCategory;
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

class ExpenseTransactionRow extends StatelessWidget {
  const ExpenseTransactionRow({
    super.key,
    required this.expense,
    required this.category,
    required this.creatorUserId,
    required this.creatorDisplayName,
  });

  final Expense expense;
  final ExpenseCategory? category;
  final String creatorUserId;
  final String creatorDisplayName;

  @override
  Widget build(BuildContext context) {
    final local = DateTime.fromMillisecondsSinceEpoch(expense.occurredAt, isUtc: true).toLocal();
    final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final note = expense.note?.trim();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      borderRadius: AppRadius.xl,
      child: Row(
        children: [
          if (category != null)
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s12),
              borderRadius: AppRadius.xl,
              color: category!.backgroundColor,
              child: Icon(category!.icon, color: category!.foregroundColor, size: AppSpacing.s20),
            )
          else
            const Icon(Icons.category),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category?.label ?? expense.categoryId,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s2),
                  Text(note, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                ],
                const SizedBox(height: AppSpacing.s6),
                Row(
                  children: [
                    MemberAvatar(userId: creatorUserId, size: AppSpacing.s20),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        '${AppStrings.expenseRecordedBy} · $creatorDisplayName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatExpenseMinor(context, expense.amountMinor),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(time, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
