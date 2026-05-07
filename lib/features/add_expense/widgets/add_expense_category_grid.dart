import 'package:flutter/material.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/share/share.dart';

/// Grid of category tiles for selecting an expense category.
class AddExpenseCategoryGrid extends StatelessWidget {
  const AddExpenseCategoryGrid({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<ExpenseCategory> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.s12,
        crossAxisSpacing: AppSpacing.s12,
      ),
      itemBuilder: (context, i) {
        final c = categories[i];
        final selected = c.id == selectedId;
        return AddExpenseCategoryTile(
          category: c,
          selected: selected,
          onTap: () => onSelect(c.id),
        );
      },
    );
  }
}

/// Single category icon + label tile.
class AddExpenseCategoryTile extends StatelessWidget {
  const AddExpenseCategoryTile({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkResponse(
      onTap: onTap,
      radius: AppSpacing.s32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: category.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.onSurface.withValues(alpha: 0.06),
                        blurRadius: AppSpacing.s24,
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s12),
              child: Icon(category.icon, color: category.foregroundColor, size: AppSpacing.s24),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            category.label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
