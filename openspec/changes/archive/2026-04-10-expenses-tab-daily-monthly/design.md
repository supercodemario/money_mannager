## Context

The app now persists expenses locally using Drift/SQLite (`expenses` table) with fields including `amount_minor`, `category_id`, `note`, and `occurred_at` (UTC epoch ms). The bottom navigation has an “Expenses” tab, but it currently renders a placeholder widget.

## Goals / Non-Goals

**Goals:**

- Provide an Expenses tab screen with a **Daily / Monthly** switch.
- Fetch data from the local Drift database via repository methods (no widget-level SQL).
- Daily view groups expenses by local calendar day.
- Monthly view lists totals grouped by `category_id` for a selected month.
- Keep UI token-first and strings centralized.

**Non-Goals:**

- Category management UI, editing/deleting expenses, or charts (can be added later).
- Remote sync or family aggregation logic beyond reading whatever is in the local DB.

## Decisions

- **Switch UI**: Use a simple in-screen switch (segmented control or tabs) between Daily and Monthly.
- **Daily grouping**: Query a date range (e.g. last 30–90 days) ordered by `occurred_at DESC`, then group in Dart by `(year, month, day)` in local time for correct “day” boundaries.
- **Monthly grouping by category**: Use a Drift query (custom SQL or generated query) to `SUM(amount_minor)` grouped by `category_id` within the month start/end range.
- **Repository surface**: Extend `ExpenseRepository` with:
  - `watchExpensesInRange(startUtcMs, endUtcMs)`
  - `watchMonthlyCategoryTotals(monthStartUtcMs, monthEndUtcMs)`

## Risks / Trade-offs

- **Timezone day boundaries** → Mitigation: always convert stored UTC `occurred_at` to local before grouping into days.
- **Empty-state UX** → Mitigation: design clear empty copy for both views when no expenses exist.

