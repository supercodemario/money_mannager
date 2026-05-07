## Why

The Quick Add screen currently shows amount, note, categories, and keypad together in one scrollable column, which feels busy and weakens the “enter amount first, then categorize” story. Splitting the flow into clear **modes** reduces clutter, enforces a valid amount before category pick, and matches the product intent we aligned on in design review.

## What Changes

- Introduce **two UI modes** on Quick Add: **amount entry** vs **category selection**.
- **Amount entry mode:** show date pill, amount (tappable to stay in / return to this mode), note field, and custom keypad plus **Select category** control; **hide** the category grid and the “tap category to save” hint.
- **Category mode:** show date, amount summary (read-only display acceptable), note, and category grid; **hide** keypad and **Select category** button (or replace with a single “Done” / back affordance if needed—see design).
- **Validation:** user may only enter category mode when **amount > 0** (not `0.00`).
- **Re-editing amount:** when the user returns to amount entry mode, **clear** the selected category so they must pick again after changing amount.
- **Copy:** “Tap category to save instantly” (or equivalent) is **visible only in category mode**.
- Prefer **no full-screen `ListView`** where possible; use `Column` + `Expanded` / localized scroll only if small screens require it (design detail).

## Capabilities

### New Capabilities

- `quick-add-two-phase`: Two-phase Quick Add UX (amount-first gating, mode visibility rules, category reset on amount re-edit, conditional hint copy).

### Modified Capabilities

- *(none)* — Existing `add-expense-ui` remains the umbrella for “add expense screen” content; this change scopes **normative behavior** for the Quick Add implementation under `quick-add-two-phase` to avoid risky MODIFIED merges against `add-expense-ui` during archive.

## Impact

- `lib/features/add_expense/view/quick_add_screen.dart`
- Possibly `lib/features/add_expense/widgets/quick_add_*.dart` (pager, keypad) for props or layout tweaks
- Widget tests under `test/` that cover Quick Add navigation and visible strings