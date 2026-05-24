## Why

Monthly mode on the Expenses tab shows category totals but offers no way to inspect *which* transactions contributed or how spending varied day-by-day within the month. Users need a focused drill-down after tapping a category: organized transaction details (amount, date, who paid, which family/household) and a within-month spending trend for that category.

## What Changes

- Make each category row in **Monthly** mode tappable; navigate to a new **category detail** screen for the selected month and category.
- Add a two-tab detail experience: **Transactions** (card rows with amount, date, paid-by, family, optional note) and **Trend** (line chart of daily category totals for the selected month only).
- Add repository queries: expenses in month filtered by `category_id` (with creator profile join), and daily category totals for charting.
- Resolve **Family** labels from `expense.household_id` via the user’s known households (batch map from cloud/sync); sensible fallbacks when `household_id` is null or offline.
- Add `fl_chart` (or equivalent) dependency for the Trend tab line chart.
- Add localized string tokens for paid-by and family labels on detail rows.

## Capabilities

### New Capabilities

- `monthly-category-detail`: Drill-down screen from Monthly category totals—Transactions tab (organized expense cards), Trend tab (daily line chart within selected month), month stepper on detail screen.

### Modified Capabilities

- `expenses-tab`: Monthly category rows SHALL be navigable to category detail; requirements for Monthly mode extended to describe drill-down entry.

## Impact

- `lib/features/expenses/` — new detail screen and widgets; tap handling on `MonthlyExpensesView`.
- `lib/data/repositories/expense_repository.dart` — new watch/query methods.
- `lib/share/tokens/app_strings.dart` — new labels.
- `pubspec.yaml` — chart package dependency.
- `openspec/specs/expenses-tab/spec.md` — delta via change specs.
- Tests under `test/` for repository aggregation and optional widget smoke tests.
