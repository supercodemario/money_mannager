## Why

Users need a first-class “Add Expense” flow to record transactions. Integrating the Stitch “Add Expense” screen now provides a polished, token-first UI aligned with the app’s design system and ensures the central “Add” navigation leads to a real feature rather than a placeholder.

## What Changes

- Add a new `add-expense` feature implementing the Stitch “Add Expense” screen UI in Flutter (amount input, date, note, category selection, primary/secondary actions).
- Use token-first styling (`AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`) and centralized strings (`AppStrings`) for all labels.
- Wire bottom navigation’s central “Add” tab to show the new Add Expense screen.

## Capabilities

### New Capabilities

- `add-expense-ui`: A complete Add Expense screen UI that matches the Stitch design and can be reached from the app shell.

### Modified Capabilities

- `bottom-navigation`: The central “Add” tab behavior changes from a placeholder to navigating to the Add Expense screen.

## Impact

- **UI**: Adds a new feature screen and supporting UI components (category grid, amount field, action buttons).
- **Navigation**: Updates the shell tab content for “Add”.
- **Design system compliance**: Requires extending `AppStrings` for the new screen’s labels and any category names.