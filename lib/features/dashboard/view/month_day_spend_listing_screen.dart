import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/app/app_router.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/expense_limits/expense_limits_calculator.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

class _DaySpendSplit {
  const _DaySpendSplit({
    required this.totalMinor,
    required this.dailyMinor,
    required this.recurringMinor,
  });

  final int totalMinor;
  final int dailyMinor;
  final int recurringMinor;
}

@RoutePage()
class MonthDaySpendListingScreen extends StatefulWidget {
  const MonthDaySpendListingScreen({super.key});

  @override
  State<MonthDaySpendListingScreen> createState() =>
      _MonthDaySpendListingScreenState();
}

class _MonthDaySpendListingScreenState
    extends State<MonthDaySpendListingScreen> {
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

  Map<int, _DaySpendSplit> _splitSpentByDay(List<Expense> expenses) {
    final totals = <int, int>{};
    final recurring = <int, int>{};
    for (final e in expenses) {
      final local = DateTime.fromMillisecondsSinceEpoch(
        e.occurredAt,
        isUtc: true,
      ).toLocal();
      final day = local.day;
      totals[day] = (totals[day] ?? 0) + e.amountMinor;
      if (e.recurringPaymentId != null) {
        recurring[day] = (recurring[day] ?? 0) + e.amountMinor;
      }
    }

    final out = <int, _DaySpendSplit>{};
    for (final entry in totals.entries) {
      final day = entry.key;
      final total = entry.value;
      final rec = recurring[day] ?? 0;
      out[day] = _DaySpendSplit(
        totalMinor: total,
        dailyMinor: total - rec,
        recurringMinor: rec,
      );
    }
    return out;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userIdFuture ??= AppServices.of(context).profiles.getCurrentUserId();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final monthLabel = DateFormat.yMMMM().format(DateTime(now.year, now.month));
    final days = ExpenseLimitsCalculator.daysInMonth(
      DateTime(now.year, now.month),
    );
    final range = _currentMonthRangeUtcMs();

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.monthDaySpendListingTitle)),
      body: FutureBuilder<String>(
        future: _userIdFuture,
        builder: (context, userSnap) {
          if (!userSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final uid = userSnap.data!;
          return StreamBuilder<ExpenseLimitsDerived>(
            stream: AppServices.of(context).expenseLimits.watchDerived(uid),
            builder: (context, derivedSnap) {
              final d = derivedSnap.data;
              final hasLimits = d != null && d.hasIncome;
              final plan = hasLimits ? d.dailyPlanMinor : 0;

              return StreamBuilder<List<DailyPaceSnapshot>>(
                stream: AppServices.of(context)
                    .expenseLimits
                    .watchPaceSnapshotsForMonth(
                      userId: uid,
                      monthLocal: DateTime(now.year, now.month),
                    ),
                builder: (context, paceSnap) {
                  final paceByDay = <int, int>{};
                  for (final row in paceSnap.data ?? const <DailyPaceSnapshot>[]) {
                    final parts = row.localDate.split('-');
                    if (parts.length == 3) {
                      final day = int.tryParse(parts[2]);
                      if (day != null) paceByDay[day] = row.paceMinor;
                    }
                  }

                  return StreamBuilder<List<Expense>>(
                stream: AppServices.of(context).expenses.watchExpensesInRange(
                      startUtcMs: range.monthStartUtcMs,
                      endUtcMs: range.monthEndUtcMs,
                    ),
                builder: (context, expenseSnap) {
                  final spentByDay =
                      _splitSpentByDay(expenseSnap.data ?? const []);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s16,
                          AppSpacing.s12,
                          AppSpacing.s16,
                          AppSpacing.s8,
                        ),
                        child: Text(
                          monthLabel,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!hasLimits)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16,
                          ),
                          child: Text(
                            AppStrings.expenseLimitsUnsetHint,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: AppSpacing.s8,
                            crossAxisSpacing: AppSpacing.s8,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: days,
                          itemBuilder: (context, index) {
                            final day = index + 1;
                            final split = spentByDay[day] ??
                                const _DaySpendSplit(
                                  totalMinor: 0,
                                  dailyMinor: 0,
                                  recurringMinor: 0,
                                );
                            final dayDate = DateTime(now.year, now.month, day);
                            final dayTitle = DateFormat.d().format(dayDate);
                            final hasRecurring = split.recurringMinor > 0;
                            final lockedPace = paceByDay[day];
                            final threshold = lockedPace != null && lockedPace > 0
                                ? lockedPace
                                : (hasLimits ? plan : null);
                            final dailyColor = SpendVsPlanColors.resolve(
                              planMinor: threshold,
                              dailyMinor: split.dailyMinor,
                              dayLocal: dayDate,
                              nowLocal: now,
                            );
                            final thresholdLabel = lockedPace != null
                                ? AppStrings.monthDaySpendPaceLabel
                                : AppStrings.monthDaySpendPlanLabel;
                            final thresholdValue = lockedPace ?? plan;

                            return Material(
                              color: AppColors.surfaceContainerLowest
                                  .withValues(alpha: 0),
                              child: InkWell(
                                onTap: () {
                                  context.router.push<void>(
                                    DaySpendDetailRoute(day: dayDate),
                                  );
                                },
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r12),
                                child: AppCard(
                                  padding:
                                      const EdgeInsets.all(AppSpacing.s8),
                                  borderRadius: AppRadius.r12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        dayTitle,
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.s4),
                                      Text(
                                        '$thresholdLabel ${hasLimits ? formatExpenseMinor(context, thresholdValue) : AppStrings.expenseLimitsUnsetValue}',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: lockedPace != null
                                              ? SpendVsPlanColors.pace
                                              : SpendVsPlanColors.plan,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${AppStrings.monthDaySpendActualLabel} ${formatExpenseMinor(context, split.totalMinor)}',
                                        style: textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: SpendVsPlanColors.totalSpent,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${AppStrings.monthDaySpendDailyExpenseLabel} ${formatExpenseMinor(context, split.dailyMinor)}',
                                        style: textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: dailyColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (hasRecurring) ...[
                                        const SizedBox(height: AppSpacing.s2),
                                        Text(
                                          '${AppStrings.monthDaySpendRecurringAmountLabel} ${formatExpenseMinor(context, split.recurringMinor)}',
                                          style:
                                              textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: SpendVsPlanColors.recurring,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
                },
              );
            },
          );
        },
      ),
    );
  }
}
