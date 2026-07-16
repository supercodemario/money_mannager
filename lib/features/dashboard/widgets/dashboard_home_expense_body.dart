import 'dart:io';

import 'package:flutter/material.dart';
import 'package:money_manager/features/dashboard/widgets/dashboard_budget_hero.dart';
import 'package:money_manager/features/dashboard/widgets/dashboard_monthly_spending_card.dart';
import 'package:money_manager/features/dashboard/widgets/dashboard_upcoming_bills_card.dart';
import 'package:money_manager/features/sms_payments/view/payment_sms_section.dart';
import 'package:money_manager/share/share.dart';

/// Main Home tab content: budget hero, monthly spending, payment SMS (Android), upcoming bills.
class DashboardHomeExpenseBody extends StatelessWidget {
  const DashboardHomeExpenseBody({
    super.key,
    required this.privacyEnabled,
    required this.temporarilyRevealed,
    this.onToggleReveal,
    required this.onAddExpenseFromSms,
    this.isActive = true,
  });

  final bool privacyEnabled;
  final bool temporarilyRevealed;
  final VoidCallback? onToggleReveal;
  final Future<String?> Function(ExpensePrefill prefill) onAddExpenseFromSms;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        DashboardBudgetHero(
          privacyEnabled: privacyEnabled,
          temporarilyRevealed: temporarilyRevealed,
          onToggleReveal: onToggleReveal,
        ),
        const SizedBox(height: AppSpacing.s16),
        DashboardMonthlySpendingCard(
          privacyEnabled: privacyEnabled,
          temporarilyRevealed: temporarilyRevealed,
        ),
        if (Platform.isAndroid) ...[
          const SizedBox(height: AppSpacing.s16),
          PaymentSmsSection(
            onAddToExpense: onAddExpenseFromSms,
            isActive: isActive,
          ),
        ],
        const SizedBox(height: AppSpacing.s16),
        const DashboardUpcomingBillsCard(),
        const SizedBox(height: AppSpacing.s48),
      ],
    );
  }
}
