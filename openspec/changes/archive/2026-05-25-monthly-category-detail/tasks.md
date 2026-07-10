## 1. Dependencies and strings

- [x] 1.1 Add `fl_chart` to `pubspec.yaml` and run `flutter pub get`
- [x] 1.2 Add `AppStrings` tokens: Transactions/Trend tab labels, `expensePaidByLabel`, `expenseFamilyLabel`, `expenseFamilyUnset`, `expenseFamilyUnknown`, category detail title/tooltips as needed

## 2. Data layer

- [x] 2.1 Add `watchCategoryExpensesInMonthWithCreator` to `ExpenseRepository` (category filter + creator join, month UTC range, desc by `occurred_at`)
- [x] 2.2 Add `watchCategoryDailyTotalsInMonth` (or equivalent) returning per-local-day sums for charting
- [x] 2.3 Add unit tests for category-filtered month query and daily aggregation (timezone/month boundary case)

## 3. Household name resolution

- [x] 3.1 Load household id → display name map on category detail (via existing family list / gateway fetch)
- [x] 3.2 Implement family label resolver with unset/unknown fallbacks per spec

## 4. UI — navigation and shell

- [x] 4.1 Make `MonthlyExpensesView` category rows tappable; push `MonthlyCategoryDetailScreen` with `categoryId`, `month`, category metadata
- [x] 4.2 Implement `MonthlyCategoryDetailScreen`: AppBar title (category + month), `DateStepperPill`, two-segment Transactions/Trend pill

## 5. UI — Transactions tab

- [x] 5.1 Add `CategoryMonthExpenseCard` widget (amount + date primary; Paid by / Family secondary; optional note)
- [x] 5.2 Wire Transactions tab to repository stream; empty state; tokenized labels

## 6. UI — Trend tab

- [x] 6.1 Build daily series from repository data (pad missing days with zero for selected month length)
- [x] 6.2 Implement `LineChart` with `AppColors`/theme styling; empty-month presentation

## 7. Verification

- [x] 7.1 Manual QA: tap category from Monthly → cards match totals → change month on detail → chart updates
- [x] 7.2 Run `flutter test` for new repository tests
