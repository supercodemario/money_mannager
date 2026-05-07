## 1. Stitch reference preparation

- [x] 1.1 Create a dedicated folder for the v3 limits reference assets under `stitch/12107255462624662036/screens/refined-expense-limits-v3/`.
- [x] 1.2 Download the hosted Stitch screenshot and HTML for screen `8cc417ddb6a94343a7793468ef9ccc8a` using `curl -L` and save them in that folder.
- [x] 1.3 Confirm the downloaded assets open correctly and use them as the side-by-side implementation reference.

## 2. Limits screen UI refactor

- [x] 2.1 Refactor `ExpenseLimitsScreen` layout to match Stitch v3 section structure (income hero card, dual summary cards, savings goal card, recurring card, save CTA).
- [x] 2.2 Implement savings percentage-goal interaction in UI state, mapping slider changes to savings amount input without changing repository contracts.
- [x] 2.3 Preserve existing validation and save behavior for income/savings/exclude-recurring fields while adapting to the new composition.

## 3. Verification and polish

- [x] 3.1 Run `dart analyze` for touched files and fix any issues.
- [x] 3.2 Perform visual pass against downloaded Stitch screenshot and adjust spacing/radius/typography/icon alignment for close parity.
- [x] 3.3 Sanity-check limits behavior (load existing values, adjust percentage and amount, save, reopen) to ensure persistence and derived summaries remain correct.
