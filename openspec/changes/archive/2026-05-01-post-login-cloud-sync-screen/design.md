## Context

The Flutter app uses `CloudSyncController` for Supabase session state and `SyncOrchestrator.runManualSync` for push/pull. `AuthScreen` already counts `local_only` expenses after sign-in/sign-up and, when the count is positive, shows an `AlertDialog` and runs sync under a blocking `CircularProgressIndicator` overlay. `SyncBeforeLogoutScreen` already demonstrates a pattern: inject a `runSync` callback that receives `onStage(ManualSyncStage)`, surface stage text, and handle failure with retry.

Project rules favor feature isolation (`lib/features/auth/view/`), token-first strings (`AppStrings`), and keeping domain sync out of direct remote calls from UI—screens should continue to call `SyncOrchestrator` via `AppServices` the same way `AuthScreen` does today.

## Goals / Non-Goals

**Goals:**

- Replace dialog + invisible overlay sync with a **single dedicated post-login sync screen** after successful auth when `local_only` expense count is greater than zero.
- Show **count** of local-only expenses before sync starts.
- Show **stage-based progress** using the same `ManualSyncStage` values the orchestrator already reports (`preparing`, `pushing`, `pulling`).
- Show a clear **success completion** state and a path to exit (e.g. **Done**) back to the auth flow / close `AuthScreen` as today.
- On failure: show error, **Retry**, and **Not now** (defer, keep `local_only`).

**Non-Goals:**

- Changing Supabase schema, RLS, or incremental sync semantics.
- Changing when rows are marked `local_only` vs `pending` on insert.
- Replacing or redesigning `SyncBeforeLogoutScreen` (may share patterns or small shared widgets later, but not required in this change).
- Showing server-side “total rows in Supabase” counts (only local eligibility for this flow unless separately specified).

## Decisions

1. **Trigger unchanged: `local_only` count only after auth**  
   **Why:** Matches current product rule and `ExpenseRepository.countBySyncStatuses` usage in `_handlePostAuthSyncPrompt`. Avoids surprising users who already have `pending` rows auto-uploading via `SyncLifecycle`.  
   **Alternative considered:** Broaden to all `countUnsynced()`—rejected for scope and interaction with background sync.

2. **Navigation: push a full-screen route after session is established**  
   **Why:** Gives room for count, stages, and completion without stacking dialogs. Use `Navigator.push` from `AuthScreen` (or a thin coordinator) and `pop` back on Done / Not now.  
   **Alternative considered:** Replace entire `AuthScreen` body with an inline stepper—rejected to keep `AuthScreen` readable and mirror logout flow.

3. **Reuse `SyncOrchestrator.runManualSync`** with `includeLocalOnly: true`, `includeError: false`, `failFast: true`, and `onStage` wired to UI—same as the current post-dialog sync path.  
   **Why:** No new sync engine; satisfies “presentation layer does not call remote APIs” via existing orchestrator.

4. **Count display**  
   **Why:** Use the same query already used for the gate: `countBySyncStatuses({SyncStatusValue.localOnly})` so the number on screen matches the condition for showing the screen.

5. **Strings**  
   **Why:** Add new keys to `AppStrings` for title, count line, stage labels (may reuse or mirror `cloudSyncSyncBeforeLogout*` strings if product copy should match logout flow—either duplicate keys for clarity or extract shared sync strings in a follow-up).

6. **Optional extraction**  
   If the new screen is structurally similar to `SyncBeforeLogoutScreen`, consider a private shared mixin or a generic `ManualSyncRunnerScreen` in a follow-up change; first implementation can duplicate minimal state machine to reduce cross-feature coupling (per strict feature isolation).

## Risks / Trade-offs

- **[Risk] Double sync with `SyncLifecycle`** → **Mitigation:** Lifecycle sync already runs when `syncAllowed`; manual run after login is acceptable and already happens today. Document that the screen run is explicit user-triggered; avoid starting two concurrent manual runs (disable button while busy).

- **[Risk] User backs out with system back during sync** → **Mitigation:** Use `PopScope(canPop: !busy)` like logout screen, or equivalent, so sync is not accidentally dismissed mid-flight without an explicit choice.

- **[Risk] Copy drift between logout sync and post-login sync** → **Mitigation:** Align stage strings with existing tokens where possible; add a short comment in design/tasks if strings are intentionally duplicated.

## Migration Plan

- Ship UI change behind no remote migration; local DB unchanged.
- No rollback beyond reverting the commit; no data migration.

## Open Questions

- Should **Not now** on the first screen (before sync) use the same copy as today’s dialog body, or shorter headline + detail?
- Should completion show only a checkmark, or also “Uploaded N expenses” (requires counting pending before/after or inferring from repository—optional enhancement)?
