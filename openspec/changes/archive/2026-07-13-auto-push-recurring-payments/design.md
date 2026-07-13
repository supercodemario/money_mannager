## Context

Recurring templates/occurrences already mark `pending` when `syncAllowed` and upload during **manual** sync in order: templates → expenses → occurrences. The automatic cycle only pushes expenses. Limits recently gained an explicit post-save profile push; recurring still depends on the Recurring management cloud button or auth login/logout sync—so many users never upload templates.

Constraints: UI must not call Supabase gateways; household-scoped rows; FK order must be preserved (template before expense with `recurring_payment_id`, expense before occurrence).

## Goals / Non-Goals

**Goals:**
- Upload **all pending** recurring templates and occurrences after user mutations when signed in and online.
- Include pending **expenses** in that same ordered push so mark-paid works.
- Skip safely when offline / not signed in; leave rows pending (not error).
- Reuse existing `_pushPendingRecurringTemplates` / `_pushPending` / `_pushPendingRecurringOccurrences`.

**Non-Goals:**
- Changing pull behavior or replacing full manual sync.
- Auto-pull after mutation.
- Schema/RLS changes.
- Pushing expense profile preferences (already handled separately).

## Decisions

### 1. Dedicated ordered push API (not expenses-only auto)

**Choice:** Add `SyncOrchestrator.pushPendingRecurringPayments()` that, when `syncAllowed` and online, runs:
1. `_pushPendingRecurringTemplates`
2. `_pushPending` (expenses)
3. `_pushPendingRecurringOccurrences`

Expose via `ManualSyncHelper.pushPendingRecurringPayments`.

**Why:** Mark-paid creates a pending expense + occurrence; template-only push is insufficient. Reusing existing push helpers preserves household_id / error handling.

**Alternatives considered:**
- Only extend expense auto-watch to recurring tables — still need ordered multi-entity push on each tick; explicit method is clearer for post-mutation.
- Push templates only from UI — breaks mark-paid.

### 2. Trigger after successful local writes

**Choice:** Call the helper from recurring feature flows after successful repository writes when `cloudSync.syncAllowed` (add/edit template, enable/disable/delete if they mark pending, mark paid). Catch/log upload errors; local save remains success.

**Why:** Same pattern as Limits Save → `pushPendingExpenseProfiles`. User expectation: “Save / Mark paid” reaches cloud.

### 3. Also fold into automatic cycle

**Choice:** When the existing auto cycle runs (pending expense watch / connectivity), also run the recurring ordered push (or call the same method after `_pushPending`). Debounce remains shared.

**Why:** “Sync all” covers reconnect and stranded pending rows without opening Recurring sync UI. Avoids leaving templates pending if a mutation forgot a call site.

**Alternatives considered:** Mutation-only triggers — misses reconnect and incomplete call-site coverage.

### 4. No pull in this path

**Choice:** Push only; no `fetchTemplatesSince` / occurrences / expenses pull.

**Why:** Matches expense auto-push; avoids LWW surprises mid-edit.

## Risks / Trade-offs

- [Pushing all pending expenses during recurring push] → Mitigation: acceptable; same pending set manual sync would upload; keeps FK order.
- [Missing call site] → Mitigation: auto cycle also runs the same push.
- [Household_id missing on template] → Mitigation: existing mark-error behavior in `_pushPendingRecurringTemplates`.
- [Duplicate orchestrator instances from ManualSyncHelper] → Mitigation: accept current pattern (same as profile push / manual sync).

## Migration Plan

1. Add orchestrator + helper methods + tests.
2. Wire mutation call sites.
3. Hook auto cycle.
4. Smoke: create template, mark paid → rows appear in Supabase without opening cloud sync screen.
5. Rollback: remove triggers; manual sync still works.

## Open Questions

- None blocking; mark-paid expense inclusion is intentional.
