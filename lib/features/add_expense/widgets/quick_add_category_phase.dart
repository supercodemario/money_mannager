import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/features/add_expense/data/category_visuals.dart';
import 'package:money_manager/features/add_expense/widgets/quick_add_category_pager.dart';
import 'package:money_manager/share/share.dart';

/// Quick Add body while choosing a category (pager visible).
class QuickAddCategoryPhase extends StatelessWidget {
  const QuickAddCategoryPhase({
    super.key,
    required this.date,
    required this.amountDisplay,
    required this.currencySymbol,
    required this.noteController,
    required this.selectedCategoryId,
    required this.saving,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onEditAmount,
    required this.onSelectCategory,
  });

  final DateTime date;
  final String amountDisplay;
  final String currencySymbol;
  final TextEditingController noteController;
  final String? selectedCategoryId;
  final bool saving;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final VoidCallback onEditAmount;
  final ValueChanged<String> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final services = AppServices.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DateStepperPill(
          dateText: formatDayStepperLabel(date),
          onPrev: onPrevDay,
          onNext: onNextDay,
          prevTooltip: AppStrings.expensesPreviousDayTooltip,
          nextTooltip: AppStrings.expensesNextDayTooltip,
        ),
        const SizedBox(height: AppSpacing.s16),
        Semantics(
          button: true,
          label: AppStrings.editAmount,
          child: InkWell(
            onTap: onEditAmount,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              child: Column(
                children: [
                  Text(
                    AppStrings.quickAddAmountLabel,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencySymbol,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Text(
                        amountDisplay,
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurface,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.xl,
          child: Row(
            children: [
              Icon(Icons.notes, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    hintText: AppStrings.quickAddNotePlaceholder,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          AppStrings.selectCategoryTitle,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.s12),
        Expanded(
          child: StreamBuilder(
            stream: services.categories.watchAll(),
            builder: (context, snap) {
              final categories = (snap.data ?? [])
                  .map(mapDbCategoryToExpenseCategory)
                  .toList(growable: false);
              return QuickAddCategoryPager(
                categories: categories,
                selectedId: selectedCategoryId,
                onSelect: (id) {
                  if (saving) return;
                  onSelectCategory(id);
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: AppSpacing.s16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.s8),
            Flexible(
              child: Text(
                AppStrings.tapCategoryToSaveInstantly,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onEditAmount,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
            ),
            child: Text(
              AppStrings.editAmount,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
