## Context

The current auth flow emphasizes uploading `local_only` rows after login. Existing users who already have Supabase-backed expenses can still land in a state where local Drift data is not hydrated quickly enough for immediate viewing. Sync responsibilities are already separated across `AuthScreen`, `SyncOrchestrator`, and repository merge logic, so this change should extend orchestration and UX without introducing direct remote calls in feature UI.

Constraints:
- Keep local-first behavior and explicit user control for upload paths.
- Reuse household membership resolution and existing merge strategy (LWW by `updated_at`).
- Preserve repository/orchestrator boundaries from `supabase-phase1-sync`.

## Goals / Non-Goals

**Goals:**
- Provide an explicit post-login bootstrap path that pulls Supabase expenses into local storage.
- Make manual cloud-to-local refresh accessible for signed-in users, even with zero `local_only` rows.
- Keep sync progress/failure states visible and retryable.
- Avoid duplicate write storms by sequencing bootstrap and normal background cycles.

**Non-Goals:**
- Redesigning conflict strategy beyond existing LWW behavior.
- Expanding scope to additional entities beyond expenses in this change.
- Changing household authorization model or Supabase schema.

## Decisions

### 1) Introduce explicit bootstrap mode in manual sync
- Decision: Extend manual sync API to support a cloud-first bootstrap mode used immediately after auth.
- Rationale: Existing `runManualSync` already encapsulates push/pull and stage reporting, making it the safest integration point.
- Alternatives considered:
  - Add ad-hoc pull calls in auth UI: rejected to preserve layering.
  - Depend only on background sync lifecycle: rejected because first-login UX remains non-deterministic.

### 2) Require cloud pull eligibility independent of `local_only`
- Decision: Post-login sync entry should trigger when user requests sync (or first signed-in bootstrap) regardless of local unsynced count.
- Rationale: Existing cloud users need hydration even with no local unsynced rows.
- Alternatives considered:
  - Keep current `local_only > 0` gate: rejected because it misses the reported problem.

### 3) Keep merge behavior in repository layer
- Decision: Continue writing remote rows through `ExpenseRepository.applyRemoteExpenseRow`.
- Rationale: Existing LWW and local profile mapping are already centralized there.
- Alternatives considered:
  - Direct table writes from orchestrator: rejected due to duplication and weaker encapsulation.

### 4) Add guarded one-time post-login bootstrap semantics
- Decision: Use sync metadata to track per-session/bootstrap completion and avoid repeated blocking gates.
- Rationale: Prevents forcing users through the same full bootstrap screen repeatedly.
- Alternatives considered:
  - Always block on login: rejected due to UX friction.
  - Never block and rely on background pull: rejected for non-deterministic first experience.

## Risks / Trade-offs

- [Risk] Bootstrap pull delays post-login entry on large datasets.  
  [Mitigation] Keep progress stages explicit; allow retry/defer where appropriate.
- [Risk] Concurrent background sync and manual bootstrap may overlap.  
  [Mitigation] Add orchestration guard/lock so only one sync cycle runs at a time.
- [Risk] Pull-before-push ordering may overwrite newer unsynced local edits if metadata is wrong.  
  [Mitigation] Keep current LWW checks and preserve pending/local-only statuses until explicit promotion.
- [Risk] Additional sync entry points increase QA matrix.  
  [Mitigation] Define scenario-level tasks and regression tests for empty-local/existing-cloud accounts.

## Migration Plan

1. Add new capability spec for post-login cloud bootstrap behavior.
2. Add delta spec updates for `supabase-phase1-sync` to include explicit cloud-to-local manual behavior.
3. Implement orchestrator/auth flow changes behind existing sync boundaries.
4. Validate with manual test paths: new account, existing cloud account with empty local DB, local-only deferred upload, retry failure path.
5. Rollback plan: remove bootstrap gate and retain existing local-only flow if severe regressions appear.

## Open Questions

- Should first-login bootstrap be mandatory before entering shell, or skippable with a warning?
- Should manual cloud refresh live only in auth/post-login flow, or also be exposed in settings?
- Do we need explicit user-facing copy to distinguish "download cloud data" vs "upload local changes" stages?
