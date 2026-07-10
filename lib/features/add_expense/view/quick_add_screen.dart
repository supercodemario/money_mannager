import 'package:auto_route/auto_route.dart';
import 'package:money_manager/core/navigation/app_route_pop.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/features/add_expense/data/category_visuals.dart';
import 'package:money_manager/features/add_expense/widgets/quick_add_category_pager.dart';
import 'package:money_manager/features/add_expense/widgets/quick_add_keypad.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

enum _QuickAddMode { amount, category }

@RoutePage()
class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  _QuickAddMode _mode = _QuickAddMode.amount;
  DateTime _date = DateTime.now();
  String _amountInt = '0';
  String _amountFrac = '';
  bool _hasDot = false;
  String? _selectedCategoryId;
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _amountPositive {
    final v = double.tryParse(_amountDisplay);
    return v != null && v > 0;
  }

  void _goToCategoryMode() {
    if (!_amountPositive) return;
    setState(() => _mode = _QuickAddMode.category);
  }

  void _goToAmountMode() {
    setState(() {
      _mode = _QuickAddMode.amount;
      _selectedCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final inCategoryMode = _mode == _QuickAddMode.category;
    final services = AppServices.of(context);
    final currencySymbol = currentExpenseCurrencySymbol(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _handleClose,
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        ),
        title: const Text(AppStrings.newExpenseTitle),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check_circle),
            tooltip: AppStrings.saveExpense,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DateStepperPill(
                        dateText: formatDayStepperLabel(_date),
                        onPrev: () => setState(() => _date = _date.subtract(const Duration(days: 1))),
                        onNext: () => setState(() => _date = _date.add(const Duration(days: 1))),
                        prevTooltip: AppStrings.expensesPreviousDayTooltip,
                        nextTooltip: AppStrings.expensesNextDayTooltip,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Semantics(
                        button: inCategoryMode,
                        label: inCategoryMode ? AppStrings.editAmount : null,
                        child: InkWell(
                          onTap: inCategoryMode ? _goToAmountMode : null,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.quickAddAmountLabel,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.0,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencySymbol,
                                      style: textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.s4),
                                    Text(
                                      _amountDisplay,
                                      style: textTheme.displaySmall?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.onSurface,
                                        letterSpacing: -1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
                        color: AppColors.surfaceContainerLow,
                        borderRadius: AppRadius.xl,
                        child: Row(
                          children: [
                            Icon(Icons.notes, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                decoration: InputDecoration(
                                  hintText: AppStrings.quickAddNotePlaceholder,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (inCategoryMode) ...[
                        const SizedBox(height: AppSpacing.s16),
                        Text(
                          AppStrings.selectCategoryTitle,
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        StreamBuilder(
                          stream: services.categories.watchAll(),
                          builder: (context, snap) {
                            final categories =
                                (snap.data ?? []).map(mapDbCategoryToExpenseCategory).toList(growable: false);
                            return QuickAddCategoryPager(
                              categories: categories,
                              selectedId: _selectedCategoryId,
                              onSelect: (id) async {
                                if (_saving) return;
                                setState(() => _selectedCategoryId = id);
                                await _save();
                              },
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info, size: AppSpacing.s16, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.s8),
                            Flexible(
                              child: Text(
                                AppStrings.tapCategoryToSaveInstantly,
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !inCategoryMode,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: QuickAddKeypad(
                  onDigit: _appendDigit,
                  onDot: _appendDot,
                  onBackspace: _backspace,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              if (!inCategoryMode)
                FilledButton(
                  onPressed: _amountPositive ? _goToCategoryMode : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                    foregroundColor: AppColors.onSurface,
                    disabledBackgroundColor: AppColors.surfaceContainerHigh,
                    disabledForegroundColor: AppColors.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  ),
                  child: Text(
                    AppStrings.selectCategoryTitle,
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _goToAmountMode,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                    ),
                    child: Text(
                      AppStrings.editAmount,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleClose() {
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
      return;
    }
    context.popRoute();
  }

  Future<void> _save() async {
    if (!_amountPositive || _selectedCategoryId == null) return;
    final currencyCode = RegionalFormattingScope.of(context).currencyCode;
    setState(() => _saving = true);
    try {
      final services = AppServices.of(context);
      final cents = _parseAmountToMinorUnits(_amountDisplay);
      if (cents == null || cents <= 0) return;
      final category = await services.categories.getById(_selectedCategoryId!);
      await services.expenses.insertExpense(
        amountMinor: cents,
        currencyCode: currencyCode,
        categoryId: _selectedCategoryId!,
        budgetBucket: category?.bucket,
        note: _noteController.text,
        occurredAt: _date,
      );
      if (!mounted) return;
      context.popRoute();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int? _parseAmountToMinorUnits(String amount) {
    final v = double.tryParse(amount);
    if (v == null) return null;
    return (v * 100).round();
  }

  String get _amountDisplay {
    final intPart = _amountInt.isEmpty ? '0' : _amountInt;
    final frac = _amountFrac.padRight(2, '0');
    return '$intPart.$frac';
  }

  void _appendDigit(String d) {
    setState(() {
      if (!_hasDot) {
        _amountInt = _amountInt == '0' ? d : '$_amountInt$d';
        _amountInt = _amountInt.replaceFirst(RegExp(r'^0+'), '');
        if (_amountInt.isEmpty) _amountInt = '0';
        return;
      }

      if (_amountFrac.length >= 2) return;
      _amountFrac = '$_amountFrac$d';
    });
  }

  void _appendDot() {
    setState(() {
      if (_hasDot) return;
      _hasDot = true;
    });
  }

  void _backspace() {
    setState(() {
      if (_hasDot) {
        if (_amountFrac.isNotEmpty) {
          _amountFrac = _amountFrac.substring(0, _amountFrac.length - 1);
          return;
        }
        _hasDot = false;
        return;
      }

      if (_amountInt.length <= 1) {
        _amountInt = '0';
        return;
      }
      _amountInt = _amountInt.substring(0, _amountInt.length - 1);
    });
  }
}
