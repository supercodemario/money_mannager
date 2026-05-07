// Day-of-month clamping: templates may use day 29–31; [effectiveDueDayInMonth] maps those to the
// last valid calendar day in shorter months (e.g. Jan 31 in February → Feb 28/29).

/// Month key in local calendar: `YYYY-MM` (e.g. `2026-04`).
String monthKeyForDate(DateTime localDate) {
  return '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}';
}

/// First day of month for a [monthKey] like `2026-04`.
DateTime firstDayOfMonthKey(String monthKey) {
  final parts = monthKey.split('-');
  final y = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  return DateTime(y, m, 1);
}

/// Clamps [dayOfMonth] to the number of days in `(year, month)` so day 31
/// becomes the last day in February.
int effectiveDueDayInMonth(int year, int month, int dayOfMonth) {
  final lastDay = DateTime(year, month + 1, 0).day;
  if (dayOfMonth < 1) return 1;
  if (dayOfMonth > lastDay) return lastDay;
  return dayOfMonth;
}

/// Unpaid item should show overdue styling for [selectedMonth] (first of month)
/// relative to "now" in local time.
bool isUnpaidOverdueForMonth({
  required DateTime selectedMonthStart,
  required int templateDayOfMonth,
  required DateTime nowLocal,
}) {
  final y = selectedMonthStart.year;
  final m = selectedMonthStart.month;
  final due = effectiveDueDayInMonth(y, m, templateDayOfMonth);
  final firstThisMonth = DateTime(nowLocal.year, nowLocal.month, 1);
  final firstSelected = DateTime(y, m, 1);
  if (firstSelected.isAfter(firstThisMonth)) return false;
  if (firstSelected.isBefore(firstThisMonth)) return true;
  return nowLocal.day > due;
}

/// For home (current month only): unpaid and past due day.
bool isUnpaidOverdueCurrentMonth({
  required int templateDayOfMonth,
  required DateTime nowLocal,
}) {
  final y = nowLocal.year;
  final m = nowLocal.month;
  final due = effectiveDueDayInMonth(y, m, templateDayOfMonth);
  return nowLocal.day > due;
}

/// For home (current month only): unpaid and not yet past due day (includes due today).
bool isUnpaidUpcomingCurrentMonth({
  required int templateDayOfMonth,
  required DateTime nowLocal,
}) {
  final y = nowLocal.year;
  final m = nowLocal.month;
  final due = effectiveDueDayInMonth(y, m, templateDayOfMonth);
  return nowLocal.day <= due;
}
