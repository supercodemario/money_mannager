import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/recurring/recurring_calendar.dart';

void main() {
  test('effectiveDueDayInMonth clamps to last day in February', () {
    expect(effectiveDueDayInMonth(2026, 2, 31), 28);
    expect(effectiveDueDayInMonth(2024, 2, 30), 29);
  });

  test('monthKeyForDate formats YYYY-MM', () {
    expect(monthKeyForDate(DateTime(2026, 4, 5)), '2026-04');
  });

  test('isUnpaidOverdueForMonth: past month unpaid is overdue', () {
    final selected = DateTime(2025, 3, 1);
    final now = DateTime(2026, 4, 10);
    expect(
      isUnpaidOverdueForMonth(
        selectedMonthStart: selected,
        templateDayOfMonth: 5,
        nowLocal: now,
      ),
      isTrue,
    );
  });

  test('isUnpaidOverdueForMonth: future month is not overdue', () {
    final selected = DateTime(2027, 1, 1);
    final now = DateTime(2026, 4, 10);
    expect(
      isUnpaidOverdueForMonth(
        selectedMonthStart: selected,
        templateDayOfMonth: 5,
        nowLocal: now,
      ),
      isFalse,
    );
  });

  test('isUnpaidOverdueForMonth: current month before due day', () {
    final selected = DateTime(2026, 4, 1);
    final now = DateTime(2026, 4, 3);
    expect(
      isUnpaidOverdueForMonth(
        selectedMonthStart: selected,
        templateDayOfMonth: 10,
        nowLocal: now,
      ),
      isFalse,
    );
  });

  test('isUnpaidOverdueForMonth: current month after due day', () {
    final selected = DateTime(2026, 4, 1);
    final now = DateTime(2026, 4, 15);
    expect(
      isUnpaidOverdueForMonth(
        selectedMonthStart: selected,
        templateDayOfMonth: 10,
        nowLocal: now,
      ),
      isTrue,
    );
  });
}
