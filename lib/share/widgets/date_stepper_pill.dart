import 'package:flutter/material.dart';
import 'package:money_manager/share/tokens/tokens.dart';
import 'package:money_manager/share/widgets/app_card.dart';

/// Label for a calendar day in the stepper (e.g. "Today", "Jan 15").
String formatDayStepperLabel(DateTime dateLocal) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(dateLocal.year, dateLocal.month, dateLocal.day);
  if (d == today) return 'Today';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}';
}

/// Local calendar date for expense detail rows (e.g. "Apr 3"), never "Today".
String formatExpenseDetailDateLabel(DateTime dateLocal) {
  final d = DateTime(dateLocal.year, dateLocal.month, dateLocal.day);
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}';
}

/// Label for a calendar month in the stepper (e.g. "Jan 2026").
String formatMonthStepperLabel(DateTime month) {
  const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${names[month.month - 1]} ${month.year}';
}

/// Card-style prev/next control for a date or month period (Quick Add, Expenses, etc.).
class DateStepperPill extends StatelessWidget {
  const DateStepperPill({
    super.key,
    required this.dateText,
    required this.onPrev,
    required this.onNext,
    this.expandWidth = false,
    this.leadingIcon = Icons.calendar_today,
    this.prevTooltip,
    this.nextTooltip,
  });

  final String dateText;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  /// When false, caps width at 280 (compact). When true, fills parent width.
  final bool expandWidth;
  final IconData leadingIcon;
  final String? prevTooltip;
  final String? nextTooltip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final card = AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s8),
      color: AppColors.surfaceContainerLowest,
      borderRadius: AppRadius.xl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.onSurfaceVariant,
            tooltip: prevTooltip,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(leadingIcon, size: AppSpacing.s16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s8),
              Text(
                dateText,
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.onSurfaceVariant,
            tooltip: nextTooltip,
          ),
        ],
      ),
    );

    if (expandWidth) {
      return SizedBox(width: double.infinity, child: card);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: card,
    );
  }
}
