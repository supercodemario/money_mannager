import 'package:flutter/material.dart';
import 'package:money_manager/features/dashboard/widgets/dashboard_budget_hero.dart';
import 'package:money_manager/features/dashboard/widgets/dashboard_monthly_spending_card.dart';
import 'package:money_manager/features/dashboard/widgets/dashboard_upcoming_bills_card.dart';
import 'package:money_manager/share/share.dart';

/// Main Home tab content: budget hero, monthly spending, upcoming bills.
class DashboardHomeExpenseBody extends StatelessWidget {
  const DashboardHomeExpenseBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: const [
        DashboardBudgetHero(),
        SizedBox(height: AppSpacing.s16),
        DashboardMonthlySpendingCard(),
        SizedBox(height: AppSpacing.s16),
        DashboardUpcomingBillsCard(),
        SizedBox(height: AppSpacing.s48),
      ],
    );
  }
}
