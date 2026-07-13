import 'package:auto_route/auto_route.dart';
import 'package:money_manager/core/navigation/app_route_pop.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/recurring/recurring_calendar.dart';
import 'package:money_manager/features/add_expense/data/default_expense_categories.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';
import 'package:money_manager/sync/manual_sync_helper.dart';

@RoutePage()
class AddRecurringPaymentScreen extends StatefulWidget {
  const AddRecurringPaymentScreen({super.key, this.editingTemplateId});

  /// When set, fields load from this template and save updates it instead of inserting.
  final String? editingTemplateId;

  @override
  State<AddRecurringPaymentScreen> createState() => _AddRecurringPaymentScreenState();
}

class _AddRecurringPaymentScreenState extends State<AddRecurringPaymentScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocus = FocusNode();
  late DateTime _dueDate;
  String _categoryId = defaultExpenseCategories().first.id;
  bool _autoRecurring = true;
  DateTime? _endMonthDate;
  bool _saving = false;
  bool _loadingEdit = false;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _dueDate = DateTime(n.year, n.month, n.day);
    if (widget.editingTemplateId != null) {
      _loadingEdit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEditingTemplate());
    }
  }

  Future<void> _loadEditingTemplate() async {
    final id = widget.editingTemplateId;
    if (id == null) return;
    final repo = AppServices.of(context).recurring;
    final row = await repo.getTemplateById(id);
    if (!mounted) return;
    if (row == null) {
      setState(() => _loadingEdit = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.recurringValidationTitle)),
      );
      context.popRoute();
      return;
    }
    final cats = defaultExpenseCategories();
    setState(() {
      _loadingEdit = false;
      _titleController.text = row.title;
      _amountController.text = formatExpenseMinorNumericOnly(context, row.amountMinorSuggested);
      _categoryId = cats.any((c) => c.id == row.categoryId) ? row.categoryId : cats.first.id;
      _dueDate = DateTime(2020, 1, effectiveDueDayInMonth(2020, 1, row.dayOfMonth));
      if (row.endMonthKey != null) {
        _autoRecurring = false;
        _endMonthDate = firstDayOfMonthKey(row.endMonthKey!);
      } else {
        _autoRecurring = true;
        _endMonthDate = null;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.recurringValidationTitle)),
      );
      return;
    }
    final minor = parseExpenseMinorFromString(context, _amountController.text);
    if (minor == null || minor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.recurringValidationAmount)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final services = AppServices.of(context);
      final repo = services.recurring;
      final currencyCode = RegionalFormattingScope.of(context).currencyCode;
      final endMonthKey = _autoRecurring || _endMonthDate == null ? null : monthKeyForDate(_endMonthDate!);
      final editId = widget.editingTemplateId;
      if (editId != null) {
        await repo.updateTemplate(
          id: editId,
          title: title,
          categoryId: _categoryId,
          amountMinorSuggested: minor,
          currencyCode: currencyCode,
          dayOfMonth: _dueDate.day,
          endMonthKey: endMonthKey,
        );
      } else {
        await repo.insertTemplate(
          title: title,
          categoryId: _categoryId,
          amountMinorSuggested: minor,
          currencyCode: currencyCode,
          dayOfMonth: _dueDate.day,
          endMonthKey: endMonthKey,
        );
      }
      await ManualSyncHelper.pushPendingRecurringPaymentsIfAllowed(services);
      if (mounted) context.popRoute();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _focusAmount() {
    if (_saving) return;
    _amountFocus.requestFocus();
  }

  Future<void> _pickDueDay() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null && mounted) setState(() => _dueDate = d);
  }

  Future<void> _pickEndMonth() async {
    final base = _endMonthDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    final d = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null && mounted) setState(() => _endMonthDate = DateTime(d.year, d.month, 1));
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingEdit) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.popRoute(),
          ),
          title: const Text(AppStrings.recurringEditTitle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final categories = defaultExpenseCategories();
    final textTheme = Theme.of(context).textTheme;
    final currencySymbol = currentExpenseCurrencySymbol(context);
    final isEdit = widget.editingTemplateId != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.popRoute(),
        ),
        title: Text(isEdit ? AppStrings.recurringEditTitle : AppStrings.recurringAddTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            Semantics(
              label: AppStrings.recurringConfirmAmountHint,
              textField: true,
              child: InkWell(
                onTap: _focusAmount,
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
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: TextField(
                          focusNode: _amountFocus,
                          controller: _amountController,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.onSurface,
                            letterSpacing: -1.0,
                          ),
                          decoration: InputDecoration(
                            prefixText: '$currencySymbol ',
                            prefixStyle: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                            hintText: AppStrings.amountPlaceholder,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: AppStrings.recurringTitleLabel,
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.s16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: AppStrings.recurringCategoryLabel,
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categoryId,
                  isExpanded: true,
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(
                        value: c.id,
                        child: _CategoryDropdownRow(category: c),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _categoryId = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              AppStrings.recurringDueDateSectionTitle,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              AppStrings.recurringPickDueDay,
              style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.s12),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s12),
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.xl,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.calendar_today_outlined, color: AppColors.onSurfaceVariant),
                title: const Text(AppStrings.recurringDueDayLabel),
                subtitle: Text(AppStrings.recurringDueEachMonthSummary(_dueDate.day)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _saving ? null : _pickDueDay,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.recurringAutoRecurringLabel),
              subtitle: const Text(AppStrings.recurringAutoRecurringHint),
              value: _autoRecurring,
              onChanged: _saving
                  ? null
                  : (v) => setState(() {
                        _autoRecurring = v;
                        if (v) _endMonthDate = null;
                      }),
            ),
            if (!_autoRecurring) ...[
              const SizedBox(height: AppSpacing.s8),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s12),
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.xl,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.event_busy, color: AppColors.onSurfaceVariant),
                  title: const Text(AppStrings.recurringEndMonthLabel),
                  subtitle: Text(
                    _endMonthDate == null ? AppStrings.recurringEndMonthHint : monthKeyForDate(_endMonthDate!),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _saving ? null : _pickEndMonth,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: AppSpacing.s20,
                      width: AppSpacing.s20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.recurringSaveTemplate),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDropdownRow extends StatelessWidget {
  const _CategoryDropdownRow({required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: category.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s8),
            child: Icon(category.icon, color: category.foregroundColor, size: AppSpacing.s16),
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Text(category.label),
      ],
    );
  }
}
