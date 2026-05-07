## 1. Clarify written spec

- [x] 1.1 Update `openspec/specs/PROJECT_STRUCTURE_SPEC.md` so `widgets/` placement is normative for non-screen feature widgets (align with `design.md` exceptions)

## 2. Refactor dashboard

- [x] 2.1 Create `lib/features/dashboard/widgets/` and move `_BudgetHero`, `_MonthlySpendingCard`, `_UpcomingBillsCard`, and related private widgets out of `dashboard_home_screen.dart`
- [x] 2.2 Keep `DashboardHomeScreen` in `view/` as composition-only; fix imports; run analyzer

## 3. Refactor expenses

- [x] 3.1 Create `lib/features/expenses/widgets/` and move `_DailyExpensesView`, `_MonthlyExpensesView`, `_ExpenseRow`, `_ExpensesEmpty`, and shared helpers (e.g. `_formatMinor` if extracted) out of `expenses_screen.dart`
- [x] 3.2 Keep `ExpensesScreen` in `view/` as composition-only; fix imports; run analyzer

## 4. Verification

- [x] 4.1 Run `flutter test` and fix any regressions
