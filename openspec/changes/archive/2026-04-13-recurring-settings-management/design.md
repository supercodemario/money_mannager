## Context

Recurring templates live in Drift (`RecurringPayments`) with occurrences in `RecurringPaymentOccurrences`. `RecurringPaymentRepository.watchRowsForMonth` drives both **Expenses → Recurring** and **home** sections via `watchHomeSections`. The Settings **Recurring** grid card currently has a no-op `onTap`. `AddRecurringPaymentScreen` only **inserts** templates today; there is no **update** API on the repository.

## Goals / Non-Goals

**Goals:**

- Add a persisted **scheduling enabled** flag (name in code may be `isEnabled` or `schedulingEnabled`) defaulting **true** for all existing rows.
- Provide a **settings-scoped management screen** listing **all** templates with switch, edit, delete, and FAB → existing add screen.
- Ensure **home** and **Expenses Recurring** streams **exclude disabled** templates **immediately** after toggle off.
- Preserve **paid** rows (occurrence + expense) when a template is disabled.

**Non-Goals:**

- Changing **monthly cadence** or `endMonthKey` semantics (disabled is separate from “ends in month”).
- Server sync / multi-device (local-only behavior matches current app).
- Notifications or reminders based on enabled state.

## Decisions

1. **Column vs separate table**  
   **Decision:** Add a non-nullable boolean column on `RecurringPayments` (e.g. `isEnabled`), default `true`, with a Drift migration bump.  
   **Rationale:** One row per template, simple queries, matches mental model.  
   **Alternative:** Separate `template_settings` table — rejected as unnecessary indirection.

2. **Where to filter**  
   **Decision:** Apply `isEnabled == true` inside repository methods used by **product** UIs (`watchRowsForMonth` as consumed by Expenses Recurring and home), and expose a **separate** stream/query for the management screen that returns **all** templates (still ordered readably, e.g. by title or due day).  
   **Rationale:** Single source of truth; impossible for home and Expenses to diverge accidentally.  
   **Alternative:** Filter in each widget — rejected (error-prone).

3. **Edit flow**  
   **Decision:** Extend `AddRecurringPaymentScreen` to accept an optional **template id** (or `RecurringPayment` model) for **edit** mode: pre-fill fields, call new `updateTemplate` on save; keep **insert** path for FAB “add”.  
   **Rationale:** Reuses validation and UI; matches user expectation of “same form.”  
   **Alternative:** Duplicate screen — rejected.

4. **Delete from management screen**  
   **Decision:** Reuse existing `deleteTemplate` behavior (already clears FK on expenses, removes occurrences, deletes template). Document in tasks that UX should confirm destructive action if not already standardized.

5. **Immediate hide for unpaid current month**  
   **Decision:** No special-case: disabled template is excluded from `watchRowsForMonth` / home mapping **as soon as** `isEnabled` is false, regardless of paid state for that month.  
   **Rationale:** Matches agreed product behavior; paid months remain in expense history via existing expense rows.

## Risks / Trade-offs

- **[Risk] Migration on first launch** → Mitigation: schema version bump + default `true` in migration SQL / companion insert.
- **[Risk] Edit screen scope creep** → Mitigation: tasks keep edit limited to same fields as create; no new fields beyond `isEnabled` in this change unless already on template.
- **[Risk] User confuses “disabled” with “end month”** → Mitigation: copy in UI (spec/settings strings) distinguishes pause vs end date; optional subtitle on management row.

## Migration Plan

1. Ship Drift migration adding column with default `true`.  
2. No backfill script beyond default — existing rows pick up `true`.  
3. Rollback: revert migration in dev only; production rollback would require a down migration (usually omitted for mobile; document as forward-only).

## Open Questions

- None blocking proposal; confirm **exact** column name with codebase conventions (`isEnabled` vs `schedulingEnabled`) during implementation.
