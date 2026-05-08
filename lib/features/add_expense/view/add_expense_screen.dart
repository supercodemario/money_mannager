import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/features/add_expense/data/category_visuals.dart';
import 'package:money_manager/features/add_expense/widgets/add_expense_bento_field.dart';
import 'package:money_manager/features/add_expense/widgets/add_expense_category_grid.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  String? _selectedCategoryId;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final services = AppServices.of(context);
    final currencySymbol = currentExpenseCurrencySymbol(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _handleClose,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(AppStrings.newExpenseTitle),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          const SizedBox(height: AppSpacing.s8),
          Text(
            AppStrings.transactionAmountLabel,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencySymbol,
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    hintText: AppStrings.amountPlaceholder,
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
          const SizedBox(height: AppSpacing.s24),
          Row(
            children: [
              Expanded(
                child: AddExpenseBentoField(
                  label: AppStrings.dateLabel,
                  icon: Icons.calendar_today,
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                      child: Text(
                        _formatDate(_date),
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: AddExpenseBentoField(
                  label: AppStrings.noteLabel,
                  icon: Icons.description_outlined,
                  child: TextField(
                    controller: _noteController,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      hintText: AppStrings.noteHint,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          Text(
            AppStrings.selectCategoryTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.s12),
          StreamBuilder(
            stream: services.categories.watchAll(),
            builder: (context, snap) {
              final categories = (snap.data ?? []).map(mapDbCategoryToExpenseCategory).toList(growable: false);
              return AddExpenseCategoryGrid(
                categories: categories,
                selectedId: _selectedCategoryId,
                onSelect: (id) => setState(() => _selectedCategoryId = id),
              );
            },
          ),
          const SizedBox(height: AppSpacing.s24),
          AppPrimaryButton(
            onPressed: _saving ? null : _save,
            child: const Text(AppStrings.saveExpense),
          ),
          const SizedBox(height: AppSpacing.s12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _handleClose,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLow,
                foregroundColor: AppColors.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              ),
              child: const Text(AppStrings.cancel),
            ),
          ),
          const SizedBox(height: AppSpacing.s32),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _handleClose() {
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
      return;
    }
    Navigator.maybePop(context);
  }

  Future<void> _save() async {
    final categoryId = _selectedCategoryId;
    if (categoryId == null) return;
    final cents = _parseAmountToMinorUnits(_amountController.text);
    if (cents == null || cents <= 0) return;
    final currencyCode = RegionalFormattingScope.of(context).currencyCode;

    setState(() => _saving = true);
    try {
      final services = AppServices.of(context);
      final category = await services.categories.getById(categoryId);
      await services.expenses.insertExpense(
        amountMinor: cents,
        currencyCode: currencyCode,
        categoryId: categoryId,
        budgetBucket: category?.bucket,
        note: _noteController.text,
        occurredAt: _date,
      );
      if (!mounted) return;
      Navigator.maybePop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int? _parseAmountToMinorUnits(String amount) {
    return parseExpenseMinorFromString(context, amount);
  }

  String _formatDate(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$m/$d/${dt.year}';
  }
}
