## Context

Expense-limit preferences are stored locally in Drift as `expense_limit_preferences` and are edited from `ExpenseLimitsScreen` through `ExpenseLimitsRepository`. The current Supabase sync implementation only uploads and pulls expense rows through `SyncOrchestrator` and `ExpenseRemoteGateway`; the Supabase migration has no remote table for expense-limit/profile preferences.

The product decision for this change is Option A: expense profile preferences are scoped to the authenticated Supabase user, not to a household. Expenses remain household-scoped, but each signed-in user owns their own income/savings guidance.

Constraints:
- Feature UI must continue to save through local repositories only.
- Sync must preserve local-first behavior when signed out or Supabase is unavailable.
- Post-login bootstrap and manual refresh should hydrate profile preferences along with expense rows.

## Goals / Non-Goals

**Goals:**
- Persist expense profile preferences in Supabase per authenticated user.
- Upload local profile preference changes when sync is available or explicitly promoted after login.
- Pull the signed-in user's remote profile preferences during post-login bootstrap and manual refresh.
- Keep sync orchestration centralized outside the settings feature UI.

**Non-Goals:**
- Sharing expense profile preferences across household members.
- Syncing broader app preferences such as language, currency, or number format.
- Redesigning the phase-1 conflict model beyond last-write-wins by `updated_at`.
- Changing the existing household model for expense rows.

## Decisions

### 1) Scope remote profile rows by auth user

Decision: Create an auth-user scoped remote table for expense profile preferences keyed by `auth_user_id`.

Rationale: The profile contains personal income and savings guidance. Scoping by household would unintentionally make one member's income/savings assumptions overwrite or expose another member's settings.

Alternatives considered:
- Household-scoped row: rejected because the user explicitly selected Option A and the data is personal profile guidance.
- Embed fields in `households`: rejected because it couples personal preferences to shared expense data.

### 2) Keep the local table as the source of UI truth

Decision: Continue using `expense_limit_preferences` for reads/writes from `ExpenseLimitsScreen`, adding sync metadata locally as needed.

Rationale: This preserves the existing local-first UX and the established boundary where screens do not call Supabase directly.

Alternatives considered:
- Save directly to Supabase from settings: rejected because it violates the sync-layer boundary and breaks offline/local-first behavior.

### 3) Add profile sync beside expense sync in the orchestrator

Decision: Extend `SyncOrchestrator` to push/pull the expense profile through a dedicated remote gateway/repository methods, sequenced with existing manual/background sync cycles.

Rationale: The orchestrator already serializes sync work and is used by post-login bootstrap, manual refresh, and lifecycle sync. Reusing it avoids a second sync pipeline.

Alternatives considered:
- A separate profile-only sync service: rejected for now because phase-1 sync is small and shared orchestration keeps concurrency easier to reason about.

### 4) Use last-write-wins by `updated_at`

Decision: Resolve profile conflicts using the same LWW shape as expenses: a remote profile row only overwrites local state when its `updated_at` is newer than the local row.

Rationale: The profile is a single small settings row, so LWW is predictable and consistent with existing phase-1 sync behavior.

Alternatives considered:
- Field-level merge: rejected as unnecessary complexity for three preference fields.
- Server timestamp conflict resolution: deferred because local rows already use epoch milliseconds and existing sync compares `updated_at`.

## Risks / Trade-offs

- [Risk] Adding sync metadata to `expense_limit_preferences` requires a local migration.  
  [Mitigation] Add nullable/defaulted sync columns and keep existing rows readable before they are promoted.
- [Risk] Pulling a remote profile after login could overwrite newer unsigned local edits if local rows are promoted incorrectly.  
  [Mitigation] Preserve `local_only` until the user explicitly syncs and compare `updated_at` before applying remote rows.
- [Risk] Remote RLS mistakes could expose personal income/savings settings.  
  [Mitigation] Use `auth_user_id = auth.uid()` policies for select/insert/update/delete and avoid household membership access.
- [Risk] Existing post-login sync copy talks mainly about expenses.  
  [Mitigation] Keep copy generic enough for "cloud data" or update it where needed during implementation.

## Migration Plan

1. Add a Supabase migration for the auth-user scoped expense profile preferences table and RLS policies.
2. Add local Drift sync metadata for `expense_limit_preferences`.
3. Extend repository and remote gateway APIs for profile push/pull/merge.
4. Extend orchestrator push/pull flows so profile preferences participate in post-login bootstrap and manual refresh.
5. Add tests for save-then-upload, login bootstrap pull, local-only promotion, and LWW conflict behavior.
6. Rollback by disabling profile sync orchestration; local preference storage remains intact.

## Open Questions

- Should an existing local profile preference row be automatically promoted after login whenever there are no local-only expense rows, or only when the user starts the post-login sync action?
- Should the manual sync UI surface profile sync failures separately from expense sync failures, or report one combined sync failure?
