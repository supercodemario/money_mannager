import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/app/app_router.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/local/app_database.dart';
import 'package:money_manager/data/local/onboarding_preferences.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/features/dashboard/widgets/dashboard_home_expense_body.dart';
import 'package:money_manager/features/dashboard/widgets/dashboard_home_tutorial_body.dart';
import 'package:money_manager/share/share.dart';

/// Home tab: [HomeRatioAppBar] + first-run tutorial or the expense dashboard.
///
/// Tutorial is hidden when onboarding was completed, or when the user has added
/// any expense, or configured monthly income / savings in expense limits.
class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key, required this.onOpenAddExpense});

  final VoidCallback onOpenAddExpense;

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  bool _loadingInitial = true;

  bool _onboardingComplete = false;
  bool _hasExpense = false;
  bool _hasMonthlyGuidance = false;

  StreamSubscription<bool>? _expenseSub;
  StreamSubscription<ExpenseLimitPreference?>? _limitsSub;

  bool get _showExpenseHome =>
      _onboardingComplete || _hasExpense || _hasMonthlyGuidance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _expenseSub?.cancel();
    _limitsSub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final services = AppServices.of(context);
    final uid = await services.profiles.getCurrentUserId();
    final completed = await OnboardingPreferences.isGetStartedCompleted();
    final limitPrefs = await services.expenseLimits.getPreferences(uid);
    final hasExp = await services.expenses.hasAnyExpenseForUser(uid);
    final hasMonthly = expenseLimitsHasMonthlyGuidanceConfigured(limitPrefs);
    if (!mounted) return;
    setState(() {
      _onboardingComplete = completed;
      _hasExpense = hasExp;
      _hasMonthlyGuidance = hasMonthly;
      _loadingInitial = false;
    });

    _expenseSub = services.expenses.watchHasAnyExpenseForUser(uid).listen((has) {
      if (!mounted) return;
      setState(() => _hasExpense = has);
    });
    _limitsSub = services.expenseLimits.watchPreferences(uid).listen((p) {
      if (!mounted) return;
      setState(() => _hasMonthlyGuidance = expenseLimitsHasMonthlyGuidanceConfigured(p));
    });
  }

  void _openExpenseLimits() {
    context.router.push<void>(const ExpenseLimitsRoute());
  }

  @override
  Widget build(BuildContext context) {
    final showExpenseHome = !_loadingInitial && _showExpenseHome;

    return Scaffold(
      floatingActionButton: showExpenseHome
          ? FloatingActionButton(
              onPressed: widget.onOpenAddExpense,
              tooltip: AppStrings.quickAddExpenseFabTooltip,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: AppSpacing.s4,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: HomeRatioAppBar.build(context),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loadingInitial) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_showExpenseHome) {
      return const DashboardHomeExpenseBody();
    }
    return DashboardHomeTutorialBody(
      onSetExpenseLimits: _openExpenseLimits,
      onAddFirstExpense: widget.onOpenAddExpense,
    );
  }
}
