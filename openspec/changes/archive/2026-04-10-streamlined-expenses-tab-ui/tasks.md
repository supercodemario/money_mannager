## 1. Spec and reference alignment

- [x] 1.1 Confirm Stitch reference assets exist under `stitch-reference/family-expense-tracker-12107255462624662036/streamlined-expenses/` (screenshot + HTML) for visual comparison.
- [x] 1.2 Verify delta spec requirements match intended UX (pill track, animated indicator, no segment check icons).

## 2. Implementation

- [x] 2.1 Implement the pill track + `AnimatedPositioned` sliding indicator with three equal tap targets on `ExpensesScreen`.
- [x] 2.2 Apply shared design tokens for track fill, selected pill, and label colors; track tint lives on `AppColors.streamlinedExpensesTabTrackTint`.
- [x] 2.3 Rely on sliding pill + label contrast for selection only (no check icons on segments).
- [x] 2.4 Preserve existing mode switching to `DailyExpensesView`, `MonthlyExpensesView`, and `RecurringExpensesView`, and preserve recurring FAB behavior.

## 3. Verification

- [x] 3.1 Run analyzer on touched files and smoke-test mode switches on a narrow phone width.
- [x] 3.2 Confirm no layout overflow or clipped labels in the mode control.
