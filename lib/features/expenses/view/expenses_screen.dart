import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/features/add_expense/data/default_expense_categories.dart';
import 'package:money_manager/features/expenses/view/add_recurring_payment_screen.dart';
import 'package:money_manager/features/expenses/widgets/daily_expenses_view.dart';
import 'package:money_manager/features/expenses/widgets/monthly_expenses_view.dart';
import 'package:money_manager/features/expenses/widgets/recurring_expenses_view.dart';
import 'package:money_manager/share/share.dart';

enum ExpensesMode { daily, monthly, recurring }

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  ExpensesMode _mode = ExpensesMode.daily;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final categories = defaultExpenseCategories();
    final categoryById = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navExpenses),
      ),
      floatingActionButton: _mode == ExpensesMode.recurring
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => const AddRecurringPaymentScreen(),
                  ),
                );
              },
              tooltip: AppStrings.recurringAddTitle,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: AppSpacing.s4,
              child: const Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ExpensesModePillTabs(
              mode: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
            const SizedBox(height: AppSpacing.s16),
            if (_mode == ExpensesMode.daily) ...[
              DateStepperPill(
                expandWidth: true,
                dateText: formatDayStepperLabel(_selectedDay),
                onPrev: () => setState(() => _selectedDay = _selectedDay.subtract(const Duration(days: 1))),
                onNext: () => setState(() => _selectedDay = _selectedDay.add(const Duration(days: 1))),
                prevTooltip: AppStrings.expensesPreviousDayTooltip,
                nextTooltip: AppStrings.expensesNextDayTooltip,
              ),
              const SizedBox(height: AppSpacing.s12),
            ],
            if (_mode == ExpensesMode.monthly || _mode == ExpensesMode.recurring) ...[
              DateStepperPill(
                expandWidth: true,
                leadingIcon: Icons.calendar_month,
                dateText: formatMonthStepperLabel(_month),
                onPrev: () => setState(() => _month = DateTime(_month.year, _month.month - 1, 1)),
                onNext: () => setState(() => _month = DateTime(_month.year, _month.month + 1, 1)),
                prevTooltip: AppStrings.expensesPreviousMonthTooltip,
                nextTooltip: AppStrings.expensesNextMonthTooltip,
              ),
              const SizedBox(height: AppSpacing.s12),
            ],
            Expanded(
              child: switch (_mode) {
                ExpensesMode.daily => DailyExpensesView(
                    repo: services.expenses,
                    categoryById: categoryById,
                    selectedDay: _selectedDay,
                  ),
                ExpensesMode.monthly => MonthlyExpensesView(
                    repo: services.expenses,
                    month: _month,
                    categoryById: categoryById,
                  ),
                ExpensesMode.recurring => RecurringExpensesView(
                    repo: services.recurring,
                    month: _month,
                    categoryById: categoryById,
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Stitch “Streamlined Expenses”: gray track (`p-1 rounded-full`) + sliding pill
/// with selected label contrast (not Material [SegmentedButton] segment fills).
class _ExpensesModePillTabs extends StatelessWidget {
  const _ExpensesModePillTabs({required this.mode, required this.onChanged});

  final ExpensesMode mode;
  final ValueChanged<ExpensesMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final index = mode.index;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.streamlinedExpensesTabTrackTint,
            borderRadius: BorderRadius.circular(AppSpacing.s32),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: LayoutBuilder(
              builder: (context, innerConstraints) {
                final innerW = innerConstraints.maxWidth;
                final pillW = innerW / 3;

                return SizedBox(
                  height: AppSpacing.s40,
                  width: innerW,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: index * pillW,
                        top: 0,
                        bottom: 0,
                        width: pillW,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(AppSpacing.s32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.onSurface.withValues(alpha: 0.08),
                                blurRadius: AppSpacing.s4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(
                              child: _PillTabLabel(
                                label: AppStrings.expensesDaily,
                                selected: mode == ExpensesMode.daily,
                                onTap: () => onChanged(ExpensesMode.daily),
                                textStyle: labelStyle,
                              ),
                            ),
                            Expanded(
                              child: _PillTabLabel(
                                label: AppStrings.expensesMonthly,
                                selected: mode == ExpensesMode.monthly,
                                onTap: () => onChanged(ExpensesMode.monthly),
                                textStyle: labelStyle,
                              ),
                            ),
                            Expanded(
                              child: _PillTabLabel(
                                label: AppStrings.expensesRecurring,
                                selected: mode == ExpensesMode.recurring,
                                onTap: () => onChanged(ExpensesMode.recurring),
                                textStyle: labelStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PillTabLabel extends StatelessWidget {
  const _PillTabLabel({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.textStyle,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.surfaceContainerLowest : AppColors.onSurfaceVariant;

    return Material(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.s32),
        splashColor: AppColors.onSurface.withValues(alpha: 0.06),
        highlightColor: AppColors.onSurface.withValues(alpha: 0.04),
        child: Padding(
          // Stitch: py-2.5
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: textStyle?.copyWith(color: fg),
            ),
          ),
        ),
      ),
    );
  }
}
