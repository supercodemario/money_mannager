## 1. Schema and persistence

- [x] 1.1 Add Drift tables for recurring payment templates and per-month occurrences (with `expense_id` nullable), plus migration
- [x] 1.2 Add nullable `recurring_payment_id` to `Expenses` table + migration; regenerate Drift code
- [x] 1.3 Define uniqueness rules (e.g. one occurrence per template per month key) and document day 29–31 clamping in code comments or small helper

## 2. Repositories

- [x] 2.1 Implement `RecurringPaymentRepository` (CRUD templates, watch occurrences for month, mark paid → insert expense + link occurrence)
- [x] 2.2 Extend `ExpenseRepository.insertExpense` (or equivalent) to accept optional `recurringPaymentId`
- [x] 2.3 Expose queries needed for home: current month unpaid split into overdue vs upcoming

## 3. Expenses tab UI

- [x] 3.1 Add `ExpensesMode.recurring` (or equivalent), third segment label **Recurring payments** via `AppStrings`
- [x] 3.2 Implement recurring list widget(s) under `lib/features/expenses/widgets/` (paid/unpaid, overdue styling, month navigation)
- [x] 3.3 Implement mark-as-paid flow: confirm sheet with **editable amount**, then persist expense and occurrence

## 4. Home dashboard

- [x] 4.1 Replace static `DashboardUpcomingBillsCard` content with live data: **Overdue** and **Upcoming** labeled sections, row title + amount + due context
- [x] 4.2 Wire `AppServices` / DI for recurring repository access from dashboard

## 5. Strings and polish

- [x] 5.1 Add all new user-visible strings to `AppStrings` (recurring, overdue, upcoming, mark paid, section headers, empty states)

## 6. Verification

- [x] 6.1 Add tests for occurrence logic (overdue vs upcoming, same category two templates) and/or repository integration
- [x] 6.2 Run `flutter test` and `flutter analyze`; fix regressions
