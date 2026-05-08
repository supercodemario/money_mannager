import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

class DashboardMonthlySpendingCard extends StatefulWidget {
  const DashboardMonthlySpendingCard({super.key});

  @override
  State<DashboardMonthlySpendingCard> createState() => _DashboardMonthlySpendingCardState();
}

class _DashboardMonthlySpendingCardState extends State<DashboardMonthlySpendingCard> {
  Future<String>? _userIdFuture;

  ({int monthStartUtcMs, int monthEndUtcMs}) _currentMonthRangeUtcMs() {
    final now = DateTime.now();
    final startLocal = DateTime(now.year, now.month, 1);
    final endLocal = DateTime(now.year, now.month + 1, 1);
    return (
      monthStartUtcMs: startLocal.toUtc().millisecondsSinceEpoch,
      monthEndUtcMs: endLocal.toUtc().millisecondsSinceEpoch,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userIdFuture ??= AppServices.of(context).profiles.getCurrentUserId();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<String>(
      future: _userIdFuture,
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.monthlySpending, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.s16),
                const Center(child: SizedBox(height: AppSpacing.s24, width: AppSpacing.s24, child: CircularProgressIndicator(strokeWidth: 2))),
              ],
            ),
          );
        }

        final uid = userSnap.data!;

        final monthRange = _currentMonthRangeUtcMs();
        return StreamBuilder<List<Expense>>(
          stream: AppServices.of(context).expenses.watchExpensesInRange(
                startUtcMs: monthRange.monthStartUtcMs,
                endUtcMs: monthRange.monthEndUtcMs,
              ),
          builder: (context, monthlyTotalsSnap) {
            final monthlyTotalExpenseMinor =
                monthlyTotalsSnap.data?.fold<int>(0, (sum, row) => sum + row.amountMinor) ?? 0;
            return StreamBuilder<ExpenseLimitPreference?>(
              stream: AppServices.of(context).expenseLimits.watchPreferences(uid),
              builder: (context, prefSnap) {
                return StreamBuilder<ExpenseLimitsDerived>(
                  stream: AppServices.of(context).expenseLimits.watchDerived(uid),
                  builder: (context, derivedSnap) {
                    final d = derivedSnap.data;
                    final prefs = prefSnap.data;
                    final hasLimits = d != null && d.hasIncome;
                    final remainingMinor = hasLimits ? d.spendablePoolMinor - monthlyTotalExpenseMinor : 0;
                    final overBudget = hasLimits && remainingMinor < 0;
                    final overSpentMinor = overBudget ? remainingMinor.abs() : 0;
                    final remainingValue = hasLimits
                        ? formatExpenseMinor(context, overBudget ? overSpentMinor : remainingMinor)
                        : AppStrings.expenseLimitsUnsetValue;
                    final dailyValue = hasLimits
                        ? formatExpenseMinor(context, d.indicativeDailyMinor)
                        : AppStrings.expenseLimitsUnsetValue;
                    final savingsMinor = prefs?.monthlySavingsMinor;
                    final savingsValue = savingsMinor == null
                        ? AppStrings.expenseLimitsUnsetValue
                        : formatExpenseMinor(context, savingsMinor);
                    final usedPercent = hasLimits && d.spendablePoolMinor > 0
                        ? (monthlyTotalExpenseMinor / d.spendablePoolMinor) * 100
                        : 0.0;
                    final exceedPercent = hasLimits && d.spendablePoolMinor > 0 && overBudget
                        ? (overSpentMinor / d.spendablePoolMinor) * 100
                        : 0.0;
                    final progressValue = hasLimits && d.spendablePoolMinor > 0
                        ? (monthlyTotalExpenseMinor / d.spendablePoolMinor).clamp(0, 1)
                        : 0.0;
                    final progressPercentLabel = '${usedPercent.round()}%';
                    final exceededAmountLabel = overBudget
                        ? '+${formatExpenseMinor(context, overSpentMinor)} (${exceedPercent.round()}%) exceeded'
                        : null;
                    final monthlySpendingSubtitle = hasLimits
                        ? overBudget
                            ? 'You exceeded your monthly spendable guidance by ${exceedPercent.round()}%'
                            : 'You have used $progressPercentLabel of your monthly spendable guidance'
                        : AppStrings.expenseLimitsUnsetHint;

                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.monthlySpending,
                                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: AppSpacing.s4),
                                    Text(
                                      monthlySpendingSubtitle,
                                      style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatExpenseMinor(context, monthlyTotalExpenseMinor),
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: overBudget ? AppColors.error : AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s2),
                                  Text(
                                    AppStrings.spentSoFarLabel,
                                    style: textTheme.labelSmall?.copyWith(
                                      letterSpacing: 1.1,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: DashboardBudgetStatusChip(
                              hasLimits: hasLimits,
                              overBudget: overBudget,
                              textTheme: textTheme,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          Row(
                            children: [
                              Text(
                                AppStrings.monthlyProgressLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                progressPercentLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: overBudget ? AppColors.error : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (exceededAmountLabel != null) ...[
                            const SizedBox(height: AppSpacing.s4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                exceededAmountLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.s6),
                          DashboardSpendingProgressTrack(
                            value: progressValue.toDouble(),
                            overBudget: overBudget,
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          DashboardMonthlyBalanceRow(
                            hasLimits: hasLimits,
                            overBudget: overBudget,
                            remainingValue: remainingValue,
                            textTheme: textTheme,
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          Row(
                            children: [
                              Expanded(
                                child: DashboardStatPill(
                                  label: AppStrings.expenseLimitsIndicativeDailyLabel,
                                  value: dailyValue,
                                  color: hasLimits ? AppColors.primary : AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: DashboardStatPill(
                                  label: AppStrings.savingsLabel,
                                  value: savingsValue,
                                  color: savingsMinor == null ? AppColors.onSurfaceVariant : AppColors.secondary,
                                ),
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
          },
        );
      },
    );
  }
}

class DashboardSpendingProgressTrack extends StatelessWidget {
  const DashboardSpendingProgressTrack({super.key, required this.value, required this.overBudget});

  final double value;
  final bool overBudget;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.s4),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: AppSpacing.s4,
        backgroundColor: overBudget
            ? AppColors.error.withValues(alpha: 0.28)
            : AppColors.surfaceContainerHighest,
        color: overBudget ? AppColors.error : AppColors.secondary,
      ),
    );
  }
}

class DashboardBudgetStatusChip extends StatelessWidget {
  const DashboardBudgetStatusChip({
    super.key,
    required this.hasLimits,
    required this.overBudget,
    required this.textTheme,
  });

  final bool hasLimits;
  final bool overBudget;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final statusBg = !hasLimits
        ? AppColors.surfaceContainerHighest
        : overBudget
            ? AppColors.errorContainer
            : AppColors.secondaryContainer;
    final statusFg = !hasLimits
        ? AppColors.onSurfaceVariant
        : overBudget
            ? AppColors.error
            : AppColors.secondaryDim;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(AppSpacing.s32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              !hasLimits
                  ? Icons.info_outline
                  : overBudget
                      ? Icons.warning_rounded
                      : Icons.trending_up,
              size: AppSpacing.s14,
              color: statusFg,
            ),
            const SizedBox(width: AppSpacing.s6),
            Text(
              !hasLimits
                  ? AppStrings.limitsNotSet
                  : overBudget
                      ? AppStrings.overBudget
                      : AppStrings.onTrack,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: statusFg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMonthlyBalanceRow extends StatelessWidget {
  const DashboardMonthlyBalanceRow({
    super.key,
    required this.hasLimits,
    required this.overBudget,
    required this.remainingValue,
    required this.textTheme,
  });

  final bool hasLimits;
  final bool overBudget;
  final String remainingValue;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          children: [
            Text(
              overBudget ? AppStrings.monthlyOverspentLabel : AppStrings.monthlyRemainingLabel,
              style: textTheme.labelSmall?.copyWith(
                letterSpacing: 1.0,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              remainingValue,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: !hasLimits
                    ? AppColors.onSurfaceVariant
                    : overBudget
                        ? AppColors.error
                        : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardStatPill extends StatelessWidget {
  const DashboardStatPill({super.key, required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
