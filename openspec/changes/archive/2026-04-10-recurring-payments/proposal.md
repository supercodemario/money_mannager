## Why

Users need to plan fixed monthly obligations (rent, utilities, EMIs) separately from ad-hoc spending. Today the app only records actual expenses; there is no persisted notion of “what is still due this month,” and the dashboard upcoming-bills UI is static. This change adds **recurring payment** definitions and a **mark as paid** flow that writes real expense rows so Daily/Monthly views stay the source of truth for money out.

## What Changes

- **Drift schema + repositories** for recurring payment templates (monthly, day-of-month) and per-month paid state linked to expenses.
- **Optional `recurring_payment_id` on expenses** when created from “mark as paid,” so the same category can represent multiple distinct recurring lines without ambiguity.
- **Expenses tab**: third mode **Recurring payments** (rename from “pending”), month navigation aligned with Monthly where applicable, list shows paid vs unpaid, overdue styling when due day has passed and not paid.
- **Mark as paid**: lightweight confirm step with **editable amount** (variable bills), then insert expense + mark occurrence paid.
- **Home dashboard**: replace static upcoming bills with **live data** from the same store as Expenses → Recurring; show **two labeled sections** for quick scan (e.g. overdue vs upcoming).
- **Non-goals for this iteration**: weekly/biweekly recurrence, local push notifications (hooks for “due today” documented for later).

## Capabilities

### New Capabilities

- `recurring-payments`: Monthly recurring templates, user-visible title/label, category, default/suggested amount, day-of-month; unified home + Expenses recurring list; mark paid → persisted expense; overdue/upcoming presentation rules.

### Modified Capabilities

- `expenses-tab`: Extend the Expenses screen to three view modes (Daily, Monthly, **Recurring payments**) and specify recurring list behavior.
- `local-expense-storage`: Extend persisted expense rows with an optional foreign key to recurring payment fulfillment (nullable `recurring_payment_id` or equivalent) so fulfillment is explicit.

## Impact

- **Database**: New table(s), migration(s), possible index on `(recurring_id, year_month)` or similar for queries.
- **Repositories**: `ExpenseRepository` insert overload or optional field; new `RecurringPaymentRepository` (name TBD).
- **UI**: `expenses_screen.dart`, new widgets under `lib/features/expenses/widgets/`, dashboard card under `lib/features/dashboard/`.
- **Strings**: `AppStrings` for new labels (Recurring payments, Overdue, Upcoming, mark paid, etc.).
- **Tests**: Repository and/or widget tests for mark-paid and list behavior.
