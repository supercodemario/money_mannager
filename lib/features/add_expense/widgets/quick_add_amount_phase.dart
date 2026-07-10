import 'package:flutter/material.dart';
import 'package:money_manager/features/add_expense/widgets/quick_add_keypad.dart';
import 'package:money_manager/share/share.dart';

/// Quick Add body while entering the amount (keypad visible).
class QuickAddAmountPhase extends StatelessWidget {
  const QuickAddAmountPhase({
    super.key,
    required this.date,
    required this.amountDisplay,
    required this.currencySymbol,
    required this.noteController,
    required this.amountPositive,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onDigit,
    required this.onDot,
    required this.onBackspace,
    required this.onSelectCategory,
  });

  final DateTime date;
  final String amountDisplay;
  final String currencySymbol;
  final TextEditingController noteController;
  final bool amountPositive;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final ValueChanged<String> onDigit;
  final VoidCallback onDot;
  final VoidCallback onBackspace;
  final VoidCallback onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
        Padding(
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
        const Spacer(),
        QuickAddKeypad(
          onDigit: onDigit,
          onDot: onDot,
          onBackspace: onBackspace,
        ),
        const SizedBox(height: AppSpacing.s12),
        FilledButton(
          onPressed: amountPositive ? onSelectCategory : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerLow,
            foregroundColor: AppColors.onSurface,
            disabledBackgroundColor: AppColors.surfaceContainerHigh,
            disabledForegroundColor: AppColors.onSurfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
          ),
          child: Text(
            AppStrings.selectCategoryTitle,
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
