import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/features/expenses/widgets/category_month_expense_card.dart';
import 'package:money_manager/features/expenses/widgets/expenses_empty_state.dart';
import 'package:money_manager/features/expenses/widgets/monthly_category_trend_chart.dart';
import 'package:money_manager/share/share.dart';

enum _CategoryDetailTab { transactions, trend }

class MonthlyCategoryDetailScreen extends StatefulWidget {
  const MonthlyCategoryDetailScreen({
    super.key,
    required this.repo,
    required this.categoryId,
    required this.initialMonth,
    this.category,
  });

  final ExpenseRepository repo;
  final String categoryId;
  final DateTime initialMonth;
  final ExpenseCategory? category;

  @override
  State<MonthlyCategoryDetailScreen> createState() => _MonthlyCategoryDetailScreenState();
}

class _MonthlyCategoryDetailScreenState extends State<MonthlyCategoryDetailScreen> {
  late DateTime _month;
  _CategoryDetailTab _tab = _CategoryDetailTab.transactions;
  Map<String, String>? _householdNameById;
  bool _householdLoadAttempted = false;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.initialMonth.year, widget.initialMonth.month);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_householdLoadAttempted) {
      _householdLoadAttempted = true;
      _loadHouseholdNames();
    }
  }

  Future<void> _loadHouseholdNames() async {
    try {
      final rows = await AppServices.of(context).household.fetchHouseholdsForCurrentUser();
      if (!mounted) return;
      setState(() {
        _householdNameById = {for (final r in rows) r.householdId: r.name};
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _householdNameById = const {});
    }
  }

  ({int startUtcMs, int endUtcMs}) _monthRangeUtcMs(DateTime month) {
    final startLocal = DateTime(month.year, month.month, 1);
    final endLocal = DateTime(month.year, month.month + 1, 1);
    return (
      startUtcMs: startLocal.toUtc().millisecondsSinceEpoch,
      endUtcMs: endLocal.toUtc().millisecondsSinceEpoch,
    );
  }

  String _familyLabel(String? householdId) {
    if (householdId == null || householdId.isEmpty) {
      return AppStrings.expenseFamilyUnset;
    }
    final map = _householdNameById;
    if (map == null) return AppStrings.expenseFamilyUnknown;
    final name = map[householdId];
    if (name != null && name.isNotEmpty) return name;
    return AppStrings.expenseFamilyUnknown;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.category?.label ?? widget.categoryId;
    final subtitle = formatMonthStepperLabel(_month);
    final range = _monthRangeUtcMs(_month);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DateStepperPill(
              expandWidth: true,
              leadingIcon: Icons.calendar_month,
              dateText: formatMonthStepperLabel(_month),
              onPrev: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
              onNext: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
              prevTooltip: AppStrings.expensesPreviousMonthTooltip,
              nextTooltip: AppStrings.expensesNextMonthTooltip,
            ),
            const SizedBox(height: AppSpacing.s16),
            _CategoryDetailPillTabs(
              tab: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
            const SizedBox(height: AppSpacing.s12),
            Expanded(
              child: switch (_tab) {
                _CategoryDetailTab.transactions => StreamBuilder<List<ExpenseWithCreator>>(
                    stream: widget.repo.watchCategoryExpensesInMonthWithCreator(
                      categoryId: widget.categoryId,
                      startUtcMs: range.startUtcMs,
                      endUtcMs: range.endUtcMs,
                    ),
                    builder: (context, snapshot) {
                      final rows = snapshot.data ?? const <ExpenseWithCreator>[];
                      if (rows.isEmpty) return const ExpensesEmptyState();
                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: rows.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s8),
                        itemBuilder: (context, i) {
                          final row = rows[i];
                          return CategoryMonthExpenseCard(
                            expense: row.expense,
                            creatorDisplayName: row.creatorDisplayName,
                            familyLabel: _familyLabel(row.expense.householdId),
                          );
                        },
                      );
                    },
                  ),
                _CategoryDetailTab.trend => StreamBuilder<List<CategoryDayTotal>>(
                    stream: widget.repo.watchCategoryDailyTotalsInMonth(
                      categoryId: widget.categoryId,
                      monthLocal: _month,
                      startUtcMs: range.startUtcMs,
                      endUtcMs: range.endUtcMs,
                    ),
                    builder: (context, snapshot) {
                      final totals = snapshot.data ?? const <CategoryDayTotal>[];
                      return MonthlyCategoryTrendChart(dailyTotals: totals);
                    },
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDetailPillTabs extends StatelessWidget {
  const _CategoryDetailPillTabs({
    required this.tab,
    required this.onChanged,
  });

  final _CategoryDetailTab tab;
  final ValueChanged<_CategoryDetailTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );
    final index = tab.index;

    return LayoutBuilder(
      builder: (context, constraints) {
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
                final pillW = innerW / 2;

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
                              child: _DetailPillTabLabel(
                                label: AppStrings.expenseCategoryDetailTransactionsTab,
                                selected: tab == _CategoryDetailTab.transactions,
                                onTap: () => onChanged(_CategoryDetailTab.transactions),
                                textStyle: labelStyle,
                              ),
                            ),
                            Expanded(
                              child: _DetailPillTabLabel(
                                label: AppStrings.expenseCategoryDetailTrendTab,
                                selected: tab == _CategoryDetailTab.trend,
                                onTap: () => onChanged(_CategoryDetailTab.trend),
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

class _DetailPillTabLabel extends StatelessWidget {
  const _DetailPillTabLabel({
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
