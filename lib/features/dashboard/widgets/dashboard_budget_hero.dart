import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

class DashboardBudgetHero extends StatefulWidget {
  const DashboardBudgetHero({
    super.key,
    required this.privacyEnabled,
    required this.temporarilyRevealed,
    this.onToggleReveal,
  });

  final bool privacyEnabled;
  final bool temporarilyRevealed;
  final VoidCallback? onToggleReveal;

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
          return _HeroColumn(
            textTheme: textTheme,
            budgetValue: AppStrings.expenseLimitsUnsetValue,
            privacyEnabled: widget.privacyEnabled,
            temporarilyRevealed: widget.temporarilyRevealed,
            onToggleReveal: widget.onToggleReveal,
          );
        }

        final uid = userSnap.data!;
        return StreamBuilder<ExpenseLimitPreference?>(
          stream: AppServices.of(context).expenseLimits.watchPreferences(uid),
          builder: (context, prefSnap) {
            final incomeMinor = prefSnap.data?.monthlyIncomeMinor;
            final budgetValue = (incomeMinor != null && incomeMinor > 0)
                ? privacyAwareExpenseAmount(
                    context,
                    incomeMinor,
                    privacyEnabled: widget.privacyEnabled,
                    temporarilyRevealed: widget.temporarilyRevealed,
                  )
                : AppStrings.expenseLimitsUnsetValue;

            return _HeroColumn(
              textTheme: textTheme,
              budgetValue: budgetValue,
              privacyEnabled: widget.privacyEnabled,
              temporarilyRevealed: widget.temporarilyRevealed,
              onToggleReveal: widget.onToggleReveal,
            );
          },
        );
      },
    );
  }
}

class _HeroColumn extends StatelessWidget {
  const _HeroColumn({
    required this.textTheme,
    required this.budgetValue,
    required this.privacyEnabled,
    required this.temporarilyRevealed,
    this.onToggleReveal,
  });

  final TextTheme textTheme;
  final String budgetValue;
  final bool privacyEnabled;
  final bool temporarilyRevealed;
  final VoidCallback? onToggleReveal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.totalFamilyBudgetLabel,
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            if (privacyEnabled && onToggleReveal != null)
              IconButton(
                onPressed: onToggleReveal,
                tooltip: temporarilyRevealed
                    ? AppStrings.privacyHideBalancesSemantics
                    : AppStrings.privacyShowBalancesSemantics,
                icon: Icon(
                  temporarilyRevealed
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
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
  }
}
