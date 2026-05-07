## 1. Shared widget and strings

- [x] 1.1 Extend `DateStepperPill` (`lib/share/widgets/`) with `expandWidth`, `leadingIcon`, `prevTooltip`, `nextTooltip`, and export `formatDayStepperLabel` / `formatMonthStepperLabel`.
- [x] 1.2 Add `AppStrings` for previous/next **day** tooltips and wire Quick Add to shared formatters.

## 2. Expenses tab integration

- [x] 2.1 Hold `selectedDay` and month state on `ExpensesScreen`; render full-width stepper pills for Daily, Monthly, and Recurring above the list (month pill shared for Monthly + Recurring).
- [x] 2.2 Pass `selectedDay` into `DailyExpensesView` and query `watchExpensesInRange` for a single local day only.
- [x] 2.3 Remove inline month header from `MonthlyExpensesView`; keep category totals list only.
- [x] 2.4 Remove inline month header from `RecurringExpensesView`; use the same month `DateStepperPill` as Monthly.

## 3. Verification

- [x] 3.1 Run analyzer on touched files and sanity-check day/month stepping and empty states.
