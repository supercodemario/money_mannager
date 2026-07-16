import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/core/navigation/app_route_pop.dart';
import 'package:money_manager/features/add_expense/widgets/quick_add_amount_phase.dart';
import 'package:money_manager/features/add_expense/widgets/quick_add_category_phase.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

enum _QuickAddMode { amount, category }

@RoutePage()
class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({
    super.key,
    this.onClose,
    this.initialAmountMinor,
    this.initialNote,
    this.initialDate,
    this.sourceKey,
  });

  final VoidCallback? onClose;

  /// Prefill amount in minor units (e.g. paise).
  final int? initialAmountMinor;
  final String? initialNote;
  final DateTime? initialDate;

  /// Opaque key returned via [popRoute] after a successful save (e.g. SMS id).
  final String? sourceKey;

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  late _QuickAddMode _mode;
  late DateTime _date;
  late String _amountInt;
  late String _amountFrac;
  late bool _hasDot;
  String? _selectedCategoryId;
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
    final seeded = _seedAmountFromMinor(widget.initialAmountMinor);
    _amountInt = seeded.amountInt;
    _amountFrac = seeded.amountFrac;
    _hasDot = seeded.hasDot;
    // Prefill from SMS: skip keypad and go straight to category pick.
    _mode = seeded.positive ? _QuickAddMode.category : _QuickAddMode.amount;
    final note = widget.initialNote;
    if (note != null && note.isNotEmpty) {
      _noteController.text = note;
    }
  }

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
    final inCategoryMode = _mode == _QuickAddMode.category;
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s16,
          ),
          child: inCategoryMode
              ? QuickAddCategoryPhase(
                  date: _date,
                  amountDisplay: _amountDisplay,
                  currencySymbol: currencySymbol,
                  noteController: _noteController,
                  selectedCategoryId: _selectedCategoryId,
                  saving: _saving,
                  onPrevDay: () => setState(
                    () => _date = _date.subtract(const Duration(days: 1)),
                  ),
                  onNextDay: () => setState(
                    () => _date = _date.add(const Duration(days: 1)),
                  ),
                  onEditAmount: _goToAmountMode,
                  onSelectCategory: (id) async {
                    setState(() => _selectedCategoryId = id);
                    await _save();
                  },
                )
              : QuickAddAmountPhase(
                  date: _date,
                  amountDisplay: _amountDisplay,
                  currencySymbol: currencySymbol,
                  noteController: _noteController,
                  amountPositive: _amountPositive,
                  onPrevDay: () => setState(
                    () => _date = _date.subtract(const Duration(days: 1)),
                  ),
                  onNextDay: () => setState(
                    () => _date = _date.add(const Duration(days: 1)),
                  ),
                  onDigit: _appendDigit,
                  onDot: _appendDot,
                  onBackspace: _backspace,
                  onSelectCategory: _goToCategoryMode,
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
    context.popRoute<String?>();
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
      await context.popRoute<String?>(widget.sourceKey);
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

  static ({String amountInt, String amountFrac, bool hasDot, bool positive})
      _seedAmountFromMinor(int? minor) {
    if (minor == null || minor <= 0) {
      return (amountInt: '0', amountFrac: '', hasDot: false, positive: false);
    }
    final whole = minor ~/ 100;
    final frac = minor % 100;
    if (frac == 0) {
      return (
        amountInt: whole.toString(),
        amountFrac: '',
        hasDot: false,
        positive: true,
      );
    }
    return (
      amountInt: whole.toString(),
      amountFrac: frac.toString().padLeft(2, '0'),
      hasDot: true,
      positive: true,
    );
  }
}
