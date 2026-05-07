## 1. Repository queries

- [x] 1.1 Extend `ExpenseRepository` with a stream query to watch expenses within a UTC range ordered by `occurred_at DESC`
- [x] 1.2 Add a repository query to compute monthly totals grouped by `category_id` (sum of `amount_minor`) for a UTC month range

## 2. Expenses feature UI

- [x] 2.1 Create `lib/features/expenses/view/expenses_screen.dart` with a Daily/Monthly switch (Option 1)
- [x] 2.2 Implement Daily view: group fetched expenses by local calendar day and render a simple list
- [x] 2.3 Implement Monthly view: render category totals list for selected month
- [x] 2.4 Wire `AppShell` Expenses tab to show `ExpensesScreen` instead of placeholder

## 3. Strings and polish

- [x] 3.1 Add any new user-visible strings to `AppStrings` (Daily, Monthly, empty states, headings)

## 4. Verification

- [x] 4.1 Add a small test verifying monthly category totals query works (or a widget test for basic render)
- [x] 4.2 Run `flutter test` and fix regressions

