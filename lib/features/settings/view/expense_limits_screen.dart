import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/expense_limits/expense_limits_calculator.dart';
import 'package:money_manager/data/repositories/expense_limits_repository.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

class ExpenseLimitsScreen extends StatefulWidget {
  const ExpenseLimitsScreen({super.key});

  @override
  State<ExpenseLimitsScreen> createState() => _ExpenseLimitsScreenState();
}

class _ExpenseLimitsScreenState extends State<ExpenseLimitsScreen> {
  final _incomeController = TextEditingController();
  final _savingsController = TextEditingController();
  bool _excludeRecurring = false;
  bool _savingsGoalEnabled = false;
  double _savingsRatePercent = 0;
  bool _loading = true;
  bool _saving = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final services = AppServices.of(context);
    final uid = await services.profiles.getCurrentUserId();
    final prefs = await services.expenseLimits.getPreferences(uid);
    if (!mounted) return;
    setState(() {
      _userId = uid;
      final im = prefs?.monthlyIncomeMinor;
      if (im != null) {
        _incomeController.text = formatExpenseMinorNumericOnly(context, im);
      }
      final sm = prefs?.monthlySavingsMinor;
      if (sm != null) {
        _savingsController.text = formatExpenseMinorNumericOnly(context, sm);
      }
      _savingsGoalEnabled = (sm ?? 0) > 0;
      _excludeRecurring = prefs?.excludeUnpaidRecurring ?? false;
      _syncSavingsRateFromInputs();
      _loading = false;
    });
  }

  int? _parseMoneyInput(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return parseExpenseMinorFromString(context, trimmed);
  }

  void _syncSavingsRateFromInputs() {
    final incomeMinor = _parseMoneyInput(_incomeController.text);
    final savingsMinor = _parseMoneyInput(_savingsController.text);
    if (incomeMinor == null || incomeMinor <= 0 || savingsMinor == null || savingsMinor <= 0) {
      _savingsRatePercent = 0;
      return;
    }
    _savingsRatePercent = ((savingsMinor / incomeMinor) * 100).clamp(0, 50).toDouble();
  }

  int? _previewIncomeMinor() => _parseMoneyInput(_incomeController.text);
  int? _previewSavingsMinorFromPercent() {
    final incomeMinor = _previewIncomeMinor();
    if (incomeMinor == null || incomeMinor <= 0 || !_savingsGoalEnabled) return null;
    return ((incomeMinor * _savingsRatePercent) / 100).round();
  }

  Future<void> _save() async {
    final services = AppServices.of(context);
    final uid = _userId;
    if (uid == null) return;

    final incomeRaw = _incomeController.text.trim();
    int? incomeMinor;
    if (incomeRaw.isNotEmpty) {
      incomeMinor = _parseMoneyInput(incomeRaw);
      if (incomeMinor == null || incomeMinor <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.expenseLimitsValidationIncome)),
        );
        return;
      }
    }

    if (_savingsGoalEnabled && (incomeMinor == null || incomeMinor <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set monthly income first to use savings percentage.')),
      );
      return;
    }
    final savingsMinor = _savingsGoalEnabled ? ((incomeMinor! * _savingsRatePercent) / 100).round() : null;

    setState(() => _saving = true);
    try {
      await services.expenseLimits.upsertPreferences(
        userId: uid,
        monthlyIncomeMinor: incomeMinor,
        monthlySavingsMinor: savingsMinor,
        excludeUnpaidRecurring: _excludeRecurring,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final services = AppServices.of(context);
    final currencySymbol = currentExpenseCurrencySymbol(context);

    if (_loading || _userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.expenseLimitsScreenTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final uid = _userId!;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.expenseLimitsScreenTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s20, AppSpacing.s16, AppSpacing.s24),
          children: [
            Text(
              'Monthly Income',
              style: textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Establish your baseline for the month',
              style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: AppSpacing.s16),
            AppCard(
              borderRadius: AppRadius.xl,
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Monthly Net',
                    style: textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Row(
                    children: [
                      Text(
                        currencySymbol,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: TextField(
                          controller: _incomeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(_syncSavingsRateFromInputs),
                          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: '0.00',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.secondaryContainer),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            StreamBuilder<ExpenseLimitsDerived>(
              stream: services.expenseLimits.watchDerived(uid),
              builder: (context, snap) {
                final d = snap.data;
                final liveIncomeMinor = _previewIncomeMinor();
                final liveDays = d?.daysInMonth ?? ExpenseLimitsCalculator.daysInMonth(DateTime.now());
                final liveRecurringDeductionMinor = d?.recurringDeductionMinor ?? 0;
                final liveSavingsMinor = _previewSavingsMinorFromPercent() ?? 0;
                final hasIncome = liveIncomeMinor != null && liveIncomeMinor > 0;
                final livePoolMinor = hasIncome
                    ? ExpenseLimitsCalculator.spendablePoolMinor(
                        incomeMinor: liveIncomeMinor,
                        savingsMinor: liveSavingsMinor,
                        recurringDeductionMinor: liveRecurringDeductionMinor,
                        excludeRecurring: _excludeRecurring,
                      )
                    : 0;
                final liveDailyMinor =
                    ExpenseLimitsCalculator.indicativeDailyMinor(poolMinor: livePoolMinor, daysInMonth: liveDays);
                return Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.calendar_month_rounded,
                        label: AppStrings.expenseLimitsSpendableMonthlyLabel,
                        value: hasIncome ? formatExpenseMinor(context, livePoolMinor) : AppStrings.expenseLimitsUnsetValue,
                        background: AppColors.secondaryContainer.withValues(alpha: 0.26),
                        iconColor: AppColors.secondary,
                        valueColor: AppColors.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.today_rounded,
                        label: AppStrings.expenseLimitsIndicativeDailyLabel,
                        value: hasIncome ? formatExpenseMinor(context, liveDailyMinor) : AppStrings.expenseLimitsUnsetValue,
                        background: AppColors.primaryContainer.withValues(alpha: 0.26),
                        iconColor: AppColors.primary,
                        valueColor: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.s16),
            AppCard(
              borderRadius: AppRadius.xl,
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: AppSpacing.s40,
                        width: AppSpacing.s40,
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(AppSpacing.s12),
                        ),
                        child: const Icon(Icons.savings_rounded, color: AppColors.tertiary),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Savings Goal',
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Pay yourself first',
                              style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            Row(
                              children: [
                                Switch.adaptive(
                                  value: _savingsGoalEnabled,
                                  onChanged: _saving
                                      ? null
                                      : (v) => setState(() {
                                          _savingsGoalEnabled = v;
                                          if (!v) {
                                            _savingsController.clear();
                                            _savingsRatePercent = 0;
                                          }
                                        }),
                                ),
                                Text(
                                  _savingsGoalEnabled ? 'ACTIVE' : 'INACTIVE',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: _savingsGoalEnabled ? AppColors.secondary : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currencySymbol,
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.tertiary.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s4),
                              Text(
                                () {
                                  final monthlySavingsMinor = _previewSavingsMinorFromPercent();
                                  if (monthlySavingsMinor == null) return AppStrings.expenseLimitsUnsetValue;
                                  return formatExpenseMinorNumericOnly(context, monthlySavingsMinor);
                                }(),
                                style: textTheme.headlineSmall?.copyWith(
                                  color: AppColors.tertiary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s2),
                          Text(
                            'PER MONTH',
                            style: textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                              color: AppColors.tertiary.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  if (_savingsGoalEnabled) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Savings Rate',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.tertiary,
                          ),
                        ),
                        Text(
                          '${_savingsRatePercent.round()}%',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _savingsRatePercent.clamp(0, 50).toDouble(),
                      min: 0,
                      max: 50,
                      divisions: 50,
                      activeColor: AppColors.tertiary,
                      onChanged: _saving
                          ? null
                          : (value) {
                              final incomeMinor = _previewIncomeMinor();
                              if (incomeMinor == null || incomeMinor <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Set monthly income first to use savings percentage.'),
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                _savingsRatePercent = value;
                              });
                            },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0%', style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                        Text('50%', style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            AppCard(
              borderRadius: AppRadius.xl,
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  Container(
                    height: AppSpacing.s40,
                    width: AppSpacing.s40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppSpacing.s12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.expenseLimitsExcludeRecurringLabel,
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          AppStrings.expenseLimitsExcludeRecurringSubtitle,
                          style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _excludeRecurring,
                    onChanged: _saving ? null : (v) => setState(() => _excludeRecurring = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: AppSpacing.s16,
                      width: AppSpacing.s16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_rounded),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.s20)),
                backgroundColor: AppColors.secondary,
              ),
              label: const Text(AppStrings.expenseLimitsSave),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              AppStrings.expenseLimitsGuidanceFootnote,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.background,
    required this.iconColor,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color background;
  final Color iconColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      borderRadius: AppRadius.xl,
      color: background,
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: AspectRatio(
        aspectRatio: 1.1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: AppSpacing.s32,
              width: AppSpacing.s32,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSpacing.s12),
              ),
              child: Icon(icon, color: iconColor, size: AppSpacing.s20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  value,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: valueColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
