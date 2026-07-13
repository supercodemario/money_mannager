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
  const DashboardHomeScreen({
    super.key,
    required this.onOpenAddExpense,
    this.isActive = true,
  });

  final VoidCallback onOpenAddExpense;

  /// False when another bottom-nav tab is selected ([IndexedStack] keeps this alive).
  final bool isActive;

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen>
    with WidgetsBindingObserver {
  bool _loadingInitial = true;

  bool _onboardingComplete = false;
  bool _hasExpense = false;
  bool _hasMonthlyGuidance = false;
  bool _temporarilyRevealed = false;

  StreamSubscription<bool>? _expenseSub;
  StreamSubscription<ExpenseLimitPreference?>? _limitsSub;

  bool get _showExpenseHome =>
      _onboardingComplete || _hasExpense || _hasMonthlyGuidance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void didUpdateWidget(covariant DashboardHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive && !widget.isActive) {
      _clearTemporaryReveal();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _expenseSub?.cancel();
    _limitsSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _clearTemporaryReveal();
    }
  }

  void _clearTemporaryReveal() {
    if (!_temporarilyRevealed) return;
    setState(() => _temporarilyRevealed = false);
  }

  void _toggleTemporaryReveal() {
    setState(() => _temporarilyRevealed = !_temporarilyRevealed);
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
      return ValueListenableBuilder<bool>(
        valueListenable: AppServices.of(context).privacyMode.enabled,
        builder: (context, privacyEnabled, _) {
          return DashboardHomeExpenseBody(
            privacyEnabled: privacyEnabled,
            temporarilyRevealed: privacyEnabled && _temporarilyRevealed,
            onToggleReveal: privacyEnabled ? _toggleTemporaryReveal : null,
          );
        },
      );
    }
    return DashboardHomeTutorialBody(
      onSetExpenseLimits: _openExpenseLimits,
      onAddFirstExpense: widget.onOpenAddExpense,
    );
  }
}
