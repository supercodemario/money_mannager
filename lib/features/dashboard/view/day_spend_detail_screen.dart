import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/features/add_expense/data/default_expense_categories.dart';
import 'package:money_manager/features/expenses/widgets/daily_expenses_view.dart';
import 'package:money_manager/share/share.dart';

@RoutePage()
class DaySpendDetailScreen extends StatefulWidget {
  const DaySpendDetailScreen({
    super.key,
    required this.day,
  });

  /// Local calendar day whose expenses are shown initially.
  final DateTime day;

  @override
  State<DaySpendDetailScreen> createState() => _DaySpendDetailScreenState();
}

class _DaySpendDetailScreenState extends State<DaySpendDetailScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(widget.day.year, widget.day.month, widget.day.day);
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final categories = defaultExpenseCategories();
    final categoryById = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.monthDaySpendListingTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DateStepperPill(
              expandWidth: true,
              dateText: formatDayStepperLabel(_selectedDay),
              onPrev: () => setState(
                () => _selectedDay = _selectedDay.subtract(
                  const Duration(days: 1),
                ),
              ),
              onNext: () => setState(
                () => _selectedDay = _selectedDay.add(const Duration(days: 1)),
              ),
              prevTooltip: AppStrings.expensesPreviousDayTooltip,
              nextTooltip: AppStrings.expensesNextDayTooltip,
            ),
            const SizedBox(height: AppSpacing.s12),
            Expanded(
              child: DailyExpensesView(
                repo: services.expenses,
                categoryById: categoryById,
                selectedDay: _selectedDay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
