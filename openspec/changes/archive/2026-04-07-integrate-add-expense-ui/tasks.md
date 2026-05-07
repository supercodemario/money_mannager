## 1. Setup

- [x] 1.1 Create `add_expense` feature folder structure (`bloc/`, `data/`, `models/`, `routes/`, `view/`)
- [x] 1.2 Add required `AppStrings` entries for Add Expense screen labels and starter category names

## 2. Add Expense screen UI

- [x] 2.1 Implement `AddExpenseScreen` layout (app bar, amount entry, date + note bento fields, category grid, primary/secondary actions)
- [x] 2.2 Implement category grid selection state and starter category dataset (token-first icon container styling)

## 3. Navigation integration

- [x] 3.1 Wire the shell’s central “Add” tab to display `AddExpenseScreen` (replacing placeholder)
- [x] 3.2 Ensure the screen supports “Cancel”/back navigation behavior consistent with the shell

## 4. Verification

- [x] 4.1 Add/update widget tests to validate Add Expense is reachable via the “Add” tab
- [x] 4.2 Run `flutter test` and fix any regressions