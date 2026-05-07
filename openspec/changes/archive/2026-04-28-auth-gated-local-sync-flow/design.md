## Context

The app is local-first and currently syncs expenses to Supabase only when an authenticated session exists. Existing orchestration uploads rows marked `pending` and then pulls remote changes. Rows created while signed out are kept locally, but today they are not explicitly represented as user-deferred sync data, and logout can proceed without a structured preflight sync UX.

## Goals / Non-Goals

**Goals:**

- Represent unsigned local captures with an explicit sync state (`local_only`).
- On login/signup, detect local-only rows and ask user whether to sync now.
- On logout, enforce a sync preflight with a dedicated progress screen and clear failure actions.
- Wipe local DB only after successful pre-logout sync or explicit user confirmation to logout without sync.

**Non-Goals:**

- Expanding sync scope beyond current phase-1 entities.
- Background scheduling redesign (retain current orchestrator model).
- Changing Supabase schema for this flow; behavior is orchestrator/state-driven.

## Decisions

1. **Add `local_only` sync state**
  - **Why:** Makes unsynced local ownership explicit and queryable for prompts/guards.
  - **Alternative considered:** Reusing `null` sync status; rejected due to ambiguity and fragile business logic.
2. **Login/signup prompt is user-controlled**
  - **Decision:** If local-only data exists at authentication time, present a decision prompt (`Sync now` / `Not now`).
  - **Why:** Avoid implicit upload surprises while preserving one-tap sync.
  - **Alternative considered:** Auto-sync immediately on login; rejected for user consent and account-switch safety.
3. **Dedicated sync-before-logout screen**
  - **Decision:** Logout with unsynced data routes through a screen with progress states and failure actions (`Retry`, `Logout without sync`).
  - **Why:** A multi-step operation needs persistent feedback and explicit escape hatch.
  - **Alternative considered:** Dialog-only spinner; rejected as insufficient for retries and error reasoning.
4. **Pre-logout sync ordering**
  - **Decision:** Preflight sync performs local-only promotion to `pending` (if user opted), then push, then pull, then logout+wipe.
  - **Why:** Preserves latest local changes before destructive wipe and leaves local cache consistent with cloud state.

## Risks / Trade-offs

- **[Risk] User fatigue from prompts** → **Mitigation:** Prompt only when qualifying local-only rows exist.
- **[Risk] Account-switch data leakage concern** → **Mitigation:** Prompt text explicitly states target account and sync consequence.
- **[Risk] Sync failure loop blocks logout** → **Mitigation:** Provide explicit `Logout without sync` action with data-loss warning.
- **[Risk] Data wipe scope confusion** → **Mitigation:** Define deterministic wipe behavior in tasks and acceptance tests.

## Migration Plan

- Add `local_only` to sync status constants and repository writes for unsigned sessions.
- Add query helpers for unsynced/local-only counts.
- Introduce login/signup prompt flow before enabling upload of local-only rows.
- Implement sync-before-logout screen and orchestration API.
- Add/adjust tests for prompt conditions, retry path, and wipe behavior.

## Open Questions

- Should `Logout without sync` be guarded by a second confirm dialog?
- Should categories/preferences be wiped with expenses, or only sync-scoped entities?