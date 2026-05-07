## Context

Quick Add already used the date stepper pill (`DateStepperPill`) for choosing the expense date. The Expenses tab Daily view previously queried a **multi-day** window and grouped results by day; Monthly used a **plain Row** for month navigation. Product direction was to **reuse** the pill component and align navigation UX.

## Goals / Non-Goals

**Goals:**

- One shared **stepper pill** implementation with optional **full width** for Expenses vs compact width for Quick Add.
- **Daily**: user-selected **local calendar day** drives `watchExpensesInRange` over `[day start, next day start)` in UTC.
- **Monthly** and **Recurring**: month navigation lives next to Daily in **ExpensesScreen** (one shared month pill when mode is Monthly or Recurring); `MonthlyExpensesView` and `RecurringExpensesView` render **list body only**.
- Shared **formatters** for pill labels (`formatDayStepperLabel`, `formatMonthStepperLabel`).

**Non-Goals:**

- Further recurring-specific chrome beyond the shared month pill (unless needed later).
- Backend or schema changes beyond existing `ExpenseRepository` range queries.

## Decisions

1. **State ownership**

   - `ExpensesScreen` holds `_selectedDay` and `_month` so both pills and child views stay in sync.
   - **Alternative:** state inside each child — rejected to avoid duplicate headers and to keep pills above `Expanded` content.

2. **Repository API**

   - Reuse `watchExpensesInRange` with a **one-day** window — no new repository method.
   - **Alternative:** `watchExpensesForDay` — rejected as unnecessary duplication.

3. **Widget API**

   - Extend `DateStepperPill` with `expandWidth`, `leadingIcon`, tooltips rather than forking a second widget.
   - **Alternative:** duplicate layout in Expenses — rejected for maintenance.

## Risks / Trade-offs

- **[Risk] Users expect scrolling history across many days in one list** → **Mitigation:** Daily mode uses explicit day stepping; document in UI that prev/next changes the day.
- **[Risk] Long labels on small screens** → **Mitigation:** pill uses same typography as Quick Add; monitor overflow in QA.

## Migration Plan

- Ship as app update; no data migration.
- Rollback: revert commits touching Expenses and `DateStepperPill`.

## Open Questions

- _(none)_
