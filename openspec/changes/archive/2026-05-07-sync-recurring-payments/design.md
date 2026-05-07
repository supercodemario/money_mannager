## Context

Recurring payment data is currently local-only. Drift stores templates in `recurring_payments` and monthly paid markers in `recurring_payment_occurrences`. Expenses already sync to Supabase and may reference recurring templates through `expenses.recurring_payment_id`.

The product decision for this change is to sync both recurring tables:
- `recurring_payments`: schedule/template data.
- `recurring_payment_occurrences`: per-month paid marker linked to a template and, when paid, an expense.

Because occurrences depend on both templates and expenses, sync ordering is part of the design, not an implementation detail.

## Goals / Non-Goals

**Goals:**
- Persist recurring payment templates in Supabase.
- Persist recurring payment occurrence rows in Supabase.
- Restore recurring templates screen state and monthly paid state through manual/post-login sync.
- Preserve local-first behavior when signed out or Supabase is unavailable.
- Keep UI code saving through repositories and orchestration, not direct Supabase calls.

**Non-Goals:**
- Changing recurring payment UX or due-date semantics.
- Redesigning expense sync conflict behavior.
- Supporting cross-household recurring templates.
- Backfilling historical cloud rows outside normal sync paths.

## Decisions

### 1) Scope recurring rows to household

Decision: Remote recurring templates and occurrences are household-scoped, matching expenses.

Rationale: Recurring bills are part of the shared expense domain and occurrence rows can point to household expense rows.

Alternatives considered:
- Auth-user scoped recurring rows: rejected because expenses are household-scoped and recurring rows participate in expense relationships.

### 2) Mirror both local recurring tables remotely

Decision: Add Supabase tables for both `recurring_payments` and `recurring_payment_occurrences`, aligned with local fields plus sync metadata.

Rationale: The user wants recurring templates and monthly paid state restored exactly as local Drift stores them.

Alternatives considered:
- Sync templates only and derive occurrences from expenses: simpler, but rejected because occurrence rows are now explicitly in sync scope.

### 3) Enforce dependency order in sync

Decision: Push and pull recurring entities in this order:
1. recurring payment templates
2. expenses
3. recurring payment occurrences

Rationale: Occurrences reference templates and expenses. Expenses can reference templates. This order avoids local and remote foreign-key failures.

Alternatives considered:
- Sync occurrences before expenses: rejected because `expense_id` may not exist yet.
- Sync expenses before templates: rejected because `recurring_payment_id` may not exist locally yet.

### 4) Add `updated_at` and sync metadata to occurrences

Decision: Add local `updated_at`, `remote_id`, `sync_status`, and `server_updated_at` to `recurring_payment_occurrences`.

Rationale: Occurrences currently only have `created_at`, which is insufficient for last-write-wins conflict handling and retryable sync state.

Alternatives considered:
- Use `created_at` as the conflict timestamp: rejected because occurrence rows can change when an expense is attached later.

### 5) Use last-write-wins by `updated_at`

Decision: Resolve recurring template and occurrence conflicts by comparing `updated_at` and applying the newer version.

Rationale: This matches the existing phase-1 sync model and keeps behavior predictable.

Alternatives considered:
- Field-level merge: rejected as unnecessary for the current data shape.

## Risks / Trade-offs

- [Risk] Pull ordering bugs can break foreign keys.  
  [Mitigation] Make ordering explicit in orchestrator tests: templates before expenses before occurrences.
- [Risk] Occurrence rows can conflict with expense deletion or missing expense references.  
  [Mitigation] Pull occurrences only after expenses and define missing-reference behavior during implementation.
- [Risk] Adding `updated_at` to occurrences requires migration defaults.  
  [Mitigation] Backfill existing occurrence `updated_at` from `created_at`.
- [Risk] Hard-deleting templates can conflict with historical expenses and occurrences.  
  [Mitigation] Decide implementation behavior for synced deletes, likely tombstone/disabled state rather than immediate hard delete.

## Migration Plan

1. Add Supabase migration for household-scoped recurring templates and occurrences with RLS.
2. Add local Drift sync metadata to `recurring_payments`.
3. Add local `updated_at` and sync metadata to `recurring_payment_occurrences`.
4. Extend `RecurringPaymentRepository` with sync status, promotion, retry, mark synced/error, and remote merge helpers.
5. Add remote gateways for recurring templates and occurrences.
6. Extend `SyncOrchestrator` push/pull ordering around existing expense sync.
7. Add tests for local-only saves, upload/pull, conflict handling, dependency ordering, and manual recurring screen sync.

## Open Questions

- Should synced recurring template deletion use a dedicated `is_deleted` column, or map delete to `is_enabled = false`?
- If an occurrence references a missing expense after pull, should sync skip that occurrence, keep it pending/error, or create it with null `expense_id`?
