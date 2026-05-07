import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:money_manager/features/add_expense/view/quick_add_screen.dart';
import 'package:money_manager/features/dashboard/view/dashboard_home_screen.dart';
import 'package:money_manager/features/expenses/view/expenses_screen.dart';
import 'package:money_manager/features/settings/view/settings_screen.dart';
import 'package:money_manager/share/share.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Stack index: Home, Expenses, Insights, Settings (Add opens as a pushed route).
  int _stackIndex = 0;

  void _openQuickAdd() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const QuickAddScreen(),
      ),
    );
  }

  /// Maps bottom-nav slot (0..4) to IndexedStack index; slot 2 is Add (push, no stack change).
  void _onBottomNavTap(int bottomIndex) {
    if (bottomIndex == 2) {
      _openQuickAdd();
      return;
    }
    final stackIndex = bottomIndex < 2 ? bottomIndex : bottomIndex - 1;
    setState(() => _stackIndex = stackIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _stackIndex,
        children: [
          DashboardHomeScreen(
            onOpenAddExpense: _openQuickAdd,
          ),
          _stackIndex == 1 ? const ExpensesScreen() : const SizedBox.shrink(),
          const _PlaceholderScreen(title: AppStrings.navInsights),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _bottomNavIndexFromStack(_stackIndex),
        onChange: _onBottomNavTap,
      ),
    );
  }

  int _bottomNavIndexFromStack(int stackIndex) {
    if (stackIndex <= 1) return stackIndex;
    return stackIndex + 1;
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onChange});

  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppRadius.xl),
        topRight: Radius.circular(AppRadius.xl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppSpacing.s20, sigmaY: AppSpacing.s20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.06),
                blurRadius: AppSpacing.s40,
                offset: const Offset(0, -AppSpacing.s12),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    selected: index == 0,
                    label: AppStrings.navHome,
                    icon: Icons.home_outlined,
                    onTap: () => onChange(0),
                  ),
                  _NavItem(
                    selected: index == 1,
                    label: AppStrings.navExpenses,
                    icon: Icons.receipt_long_outlined,
                    onTap: () => onChange(1),
                  ),
                  _NavItem(
                    selected: index == 2,
                    label: AppStrings.navAdd,
                    icon: Icons.add_circle,
                    onTap: () => onChange(2),
                    isAdd: true,
                  ),
                  _NavItem(
                    selected: index == 3,
                    label: AppStrings.navInsights,
                    icon: Icons.insights_outlined,
                    onTap: () => onChange(3),
                  ),
                  _NavItem(
                    selected: index == 4,
                    label: AppStrings.navSettings,
                    icon: Icons.settings_outlined,
                    onTap: () => onChange(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isAdd = false,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isAdd;

  /// Same gradient + padding as the original Home selection; reused for every
  /// non–Add tab when selected.
  static Widget _selectedTile({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.r12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.primaryContainer],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final inactiveColor = AppColors.onSurfaceVariant;

    final bool showTile = selected && !isAdd;
    // Dark ink on the green → light-blue gradient (readable on both stops).
    final Color fg = isAdd
        ? AppColors.primary
        : showTile
            ? AppColors.onPrimaryContainer
            : inactiveColor;

    final Widget iconWidget = Icon(
      icon,
      size: isAdd ? AppSpacing.s32 : AppSpacing.s24,
      color: fg,
    );

    final labelWidget = Text(
      label,
      style: textTheme.labelSmall?.copyWith(
        fontWeight: selected && !isAdd ? FontWeight.w700 : FontWeight.w600,
        color: isAdd ? inactiveColor : fg,
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(height: AppSpacing.s2),
        labelWidget,
      ],
    );

    final Widget child = showTile
        ? _NavItem._selectedTile(child: content)
        : Padding(
            padding: const EdgeInsets.all(AppSpacing.s8),
            child: content,
          );

    return InkResponse(
      onTap: onTap,
      radius: AppSpacing.s32,
      child: child,
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}

