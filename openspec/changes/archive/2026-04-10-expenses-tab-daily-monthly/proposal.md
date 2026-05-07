## Why

Users are saving expenses locally now, but the “Expenses” tab is still a placeholder. Users need an easy way to review spend by **day** and by **month**, and to switch between these views quickly.

## What Changes

- Replace the placeholder Expenses tab with a real Expenses screen.
- Add a **Daily / Monthly** switch inside the Expenses screen (Option 1).
- **Daily view**: list expenses grouped by day (e.g. Today, Yesterday), fetched from the local Drift database.
- **Monthly view**: show a category-wise monthly breakdown (category totals for the selected month), fetched from the local Drift database.
- Add minimal repository query APIs to support these reads (list by range and monthly group-by-category totals).

## Capabilities

### New Capabilities

- `expenses-tab`: Expenses tab UI that can switch between Daily and Monthly views and reads data from local storage.

### Modified Capabilities

- *(none)*

## Impact

- **UI**: New feature under `lib/features/expenses/` with one screen and a couple of small widgets.
- **Data**: Extend the local repository layer to support range reads and month aggregation grouped by `category_id`.
- **Navigation**: The bottom nav “Expenses” tab will no longer be a placeholder; it will show the Expenses screen.