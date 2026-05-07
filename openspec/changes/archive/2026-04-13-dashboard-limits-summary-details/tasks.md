## 1. Dashboard limits summary composition

- [x] 1.1 Add or update a dashboard widget to render monthly total expense, remaining monthly amount, current savings set, and current daily limit.
- [x] 1.2 Integrate that widget into `lib/features/dashboard/view/dashboard_home_screen.dart` with appropriate placement and spacing.
- [x] 1.3 Ensure the widget reads from existing local streams/repositories (monthly expense total, limits preferences, and limits derived guidance).

## 2. Derived value and fallback behavior

- [x] 2.1 Compute remaining monthly amount from spendable monthly guidance minus monthly total expense with safe floor behavior.
- [x] 2.2 Define and apply explicit unset placeholders for fields when limits or savings are not configured.
- [x] 2.3 Verify labels clearly communicate guidance values and avoid implying hard enforcement.

## 3. Verification

- [x] 3.1 Run `dart analyze` on touched dashboard/limits files and fix any issues.
- [x] 3.2 Manual sanity-check dashboard: confirm values update when limits are saved/changed and when monthly expenses change.
- [x] 3.3 Validate edge states (no limits set, savings unset, zero remaining) render correctly and consistently.
