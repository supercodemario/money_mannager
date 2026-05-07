## Why

The Expenses tab already supports Daily, Monthly, and Recurring views, but the mode control used a generic Material segmented pattern that did not match the **Streamlined Expenses** reference from the Stitch project. Aligning the switcher with that design improves visual consistency with the rest of the product direction and makes the active mode easier to scan.

## What Changes

- Replace the generic mode switcher presentation with a **pill-style track** and **animated sliding selection indicator** aligned to the Stitch “Streamlined Expenses” screen (screen ID `d1ad0576434440de97721995c31530eb`, project `12107255462624662036`).
- Preserve existing behavior: selecting Daily, Monthly, or Recurring still swaps the same underlying views; no change to data loading contracts.
- Indicate selection with the **sliding pill** and **label contrast** only (no segment check icons), after UX review.
- Store or reference Stitch assets under `stitch-reference/` for ongoing UI parity (screenshot + HTML already used for alignment).

## Capabilities

### New Capabilities

- *(none)* — Presentation rules extend the existing Expenses tab capability.

### Modified Capabilities

- `expenses-tab`: Add requirements that describe how the Daily / Monthly / Recurring mode switcher SHALL be presented (pill track, sliding indicator, selection affordances) without changing the functional view-switching requirements already specified.

## Impact

- `lib/features/expenses/view/expenses_screen.dart` and any extracted shared widgets for the mode switcher.
- Optional: `lib/share/tokens/` if new shared colors or spacing constants are introduced for the track (prefer existing tokens where possible).
- Reference assets: `stitch-reference/family-expense-tracker-12107255462624662036/streamlined-expenses/`.