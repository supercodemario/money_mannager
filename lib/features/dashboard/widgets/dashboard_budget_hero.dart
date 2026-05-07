import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

class DashboardBudgetHero extends StatefulWidget {
  const DashboardBudgetHero({super.key});

  @override
  State<DashboardBudgetHero> createState() => _DashboardBudgetHeroState();
}

class _DashboardBudgetHeroState extends State<DashboardBudgetHero> {
  Future<String>? _userIdFuture;

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.totalFamilyBudgetLabel,
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                AppStrings.expenseLimitsUnsetValue,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          );
        }

        final uid = userSnap.data!;
        return StreamBuilder<ExpenseLimitPreference?>(
          stream: AppServices.of(context).expenseLimits.watchPreferences(uid),
          builder: (context, prefSnap) {
            final incomeMinor = prefSnap.data?.monthlyIncomeMinor;
            final budgetValue = (incomeMinor != null && incomeMinor > 0)
                ? formatExpenseUsdMinor(incomeMinor)
                : AppStrings.expenseLimitsUnsetValue;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.totalFamilyBudgetLabel,
                  style: textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  budgetValue,
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
