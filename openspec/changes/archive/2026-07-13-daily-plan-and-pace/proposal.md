## Why

Home shows a single indicative daily number that does not separate the fixed month plan from “what I can spend per remaining day after today.” Real spending over/under that plan makes a pace figure necessary, and users need a day-by-day list to see which days ran hot or cold.

## What Changes

- **BREAKING** (guidance presentation): Replace the single Home indicative-daily pill with **two** daily figures nested under **Monthly remaining**:
  - **Daily plan** — fixed `spendablePool ÷ daysInMonth`
  - **Pace / day** — `remaining ÷ daysAfterToday` (exclude today; 0 when remaining ≤ 0 or no days left)
- Keep savings as a separate control; do not nest it under remaining.
- Add a **month day listing** screen opened by tapping the Daily plan / Pace row: each day shows plan vs actual spent; over plan in red, under (or equal) in green.
- Guidance remains non-blocking.

## Capabilities

### New Capabilities
- `month-day-spend-listing`: Current-month day list comparing Daily plan to actual spent per day, with over/under coloring and navigation from Home.

### Modified Capabilities
- `expense-limits`: Define Daily plan vs Pace / day formulas; Home monthly-remaining block shows both; remove reliance on a single remaining÷daysInMonth Home daily.

## Impact

- `ExpenseLimitsCalculator` / `ExpenseLimitsDerived` — add daily plan + pace helpers; adjust or replace current indicative-daily semantics for Home
- `DashboardMonthlySpendingCard` / balance row — merge dual daily under remaining; tappable entry to listing
- New screen + route for month day spend listing; group expenses by local day for the active month
- Strings, tests for calculator and listing color rules
- Expense Limits settings summary may still show guidance; align labels with Daily plan / Pace where that screen surfaces daily
