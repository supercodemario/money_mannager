## Context

The app persists expenses via Drift (`Expenses` table) and uses `ExpenseRepository` from UI. Categories come from the in-app catalog (`defaultExpenseCategories`). There is no recurring/bill table yet. The dashboard shows a placeholder “upcoming bills” card. Expenses tab uses `SegmentedButton` for Daily vs Monthly only.

## Goals / Non-Goals

**Goals:**

- Store **recurring payment templates** (monthly, **day-of-month**, title, `category_id`, suggested amount in minor units).
- For each calendar month, track whether each recurring item is **paid** by linking to a **single** created expense row (optional `recurring_payment_id` on expense, or a separate fulfillment row—see Decisions).
- **Mark as paid** from UI: opens confirm with **editable amount** → insert expense with `occurred_at` appropriate to payment date (default: due date or “today” local—see Open Questions) → mark template occurrence paid for that month.
- **Expenses tab**: third segment **Recurring payments**; show list for selected month with **paid / unpaid** and **overdue** indication when local day > due day in month and unpaid.
- **Home**: same data as Expenses recurring; **two labeled sections** (e.g. **Overdue** vs **Upcoming**) for quick view; rows show distinct **title** (not only category).
- Multiple recurring lines **may share the same category**; identity is always the recurring template id.

**Non-Goals:**

- Weekly / non-monthly recurrence (schema may allow extension later).
- Push notifications (document **due day == today** for future local push).
- Server sync (local-only consistent with existing expense storage).

## Decisions

1. **Fulfillment linkage**  
   - **Chosen**: Add nullable `recurring_payment_id` on `Expenses` (FK to recurring template id or a dedicated “occurrence id”—prefer **occurrence** id if we store a row per month; see next).  
   - **Alternative**: Only `RecurringOccurrence` table with `expense_id` nullable FK.  
   - **Recommendation**: `RecurringPayments` table (template) + `RecurringPaymentOccurrences` table (composite: `recurring_id` + `year_month` or month start UTC ms) with `expense_id` nullable, `due_day` denormalized from template for query simplicity. **Mark paid** sets `expense_id` and creates expense with `recurring_payment_id` pointing to **template** id OR store occurrence id on expense—**simplest**: store `recurring_template_id` on expense + `occurrence_month` (YYYY-MM) in occurrence table to avoid duplicate pays.  
   - **Concrete**:  
     - `recurring_payments`: id, title, category_id, amount_minor_suggested, day_of_month (1–31), currency_code, created_at, updated_at, …  
     - `recurring_payment_occurrences`: id, recurring_payment_id, month_key (e.g. `2026-04` string or startUtcMs), expense_id nullable, created_at  
   - When user marks paid, insert expense with `recurring_payment_id` = template id + optional `note` from template title; **uniqueness**: one row per `(recurring_payment_id, month_key)` in occurrences.

2. **Due / overdue**  
   - **Overdue** for month M: local `today` in M, `day > template.day_of_month`, occurrence has no `expense_id`.  
   - **Upcoming** in same month: `day <= day_of_month` and no expense (or not yet due).  
   - **Paid**: `expense_id` set.

3. **Home layout**  
   - Query occurrences for **current calendar month** (or rolling window—default current month).  
   - Split into **Overdue** (unpaid, past due day) and **Upcoming** (unpaid, not due yet or due today without pay—product tweak: “due today” can sit in upcoming).  
   - **Paid** items: optionally show last N paid in home or only in Expenses tab—**design**: **home focuses on unpaid**; paid history primarily in Expenses → Recurring (user asked to show paid status in recurring list).

4. **“Same payment, same category”**  
   - Distinguished by **distinct `recurring_payments.id`**, not by category.

5. **Token-first UI**  
   - New UI uses `lib/share/tokens/` per project rules.

## Risks / Trade-offs

- **Day 29–31**: month shorter than `day_of_month` → clamp to last day of month for due date (document in spec).  
- **Timezone**: use local calendar for month boundaries and day comparison (aligned with existing Daily/Monthly expense views).  
- **Migration**: existing expenses unchanged; new columns/tables nullable.

## Migration Plan

1. Ship Drift migration adding tables + nullable `recurring_payment_id` on `expenses`.  
2. No backfill required for old expenses.  
3. Rollback: feature-flag or revert migration in dev only (production strategy: forward-only).

## Open Questions

- **Default `occurred_at` for mark paid**: end of due day local midnight vs “now” when user taps—prefer **user-selectable date** or default **today** at tap time? (Recommend: default **today** local, allow date edit in confirm if needed—v1 can be today-only.)  
- **Dashboard row limit**: max N items per section to avoid long home screen.
