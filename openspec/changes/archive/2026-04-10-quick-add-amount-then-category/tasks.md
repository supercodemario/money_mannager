## 1. State and validation

- [x] 1.1 Add `QuickAddMode` (or equivalent) and wire transitions between amount and category modes
- [x] 1.2 Implement `amount > 0` gating for entering category mode; disable or block "Select category" when invalid
- [x] 1.3 Clear `_selectedCategoryId` whenever switching back to amount entry mode

## 2. Layout and visibility

- [x] 2.1 Replace whole-screen `ListView` with `Column` + `Expanded` (or equivalent) per design; add localized scroll only if needed for small viewports
- [x] 2.2 Show/hide category block, keypad, "Select category" button, and instant-save hint per mode rules
- [x] 2.3 Make amount row tappable to return to amount mode (with semantics); ensure user can leave category mode without only relying on system back

## 3. Strings and polish

- [x] 3.1 Centralize any new user-visible strings in `AppStrings` if introduced (e.g. "Edit amount")

## 4. Verification

- [x] 4.1 Update or add widget tests for mode visibility and amount gating where practical
- [x] 4.2 Run `flutter test` and fix regressions
