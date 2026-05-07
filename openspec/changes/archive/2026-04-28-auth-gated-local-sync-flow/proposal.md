## Why

The current sync flow only uploads rows already marked pending, which leaves a gap for data captured while signed out. Users need explicit control at login and logout so local data is either safely synced to Supabase or clearly acknowledged as unsynced before local wipe.

## What Changes

- Introduce a local sync state (`local_only`) for rows created while no authenticated session is available.
- Add a login/signup decision prompt when local-only data exists: user can choose to sync now or keep data local for now.
- Add a logout preflight that detects unsynced data, runs sync before sign-out, and blocks destructive logout behind explicit user choice when sync fails.
- Add a dedicated sync progress screen for logout flow with actionable failure UI (`Retry`, `Logout without sync`).

## Capabilities

### New Capabilities

- *(none)*

### Modified Capabilities

- `supabase-phase1-sync`: Extend auth-gated sync behavior with `local_only` lifecycle, login-time user prompt, and logout-time guarded sync with progress/failure UX.

## Impact

- **Code paths**: `CloudSyncController`, `SyncOrchestrator`, `ExpenseRepository` sync-status handling, auth/settings UI flow.
- **UI**: New sync progress screen during logout and prompt at login/signup when local-only rows are present.
- **Data model**: New sync-status state and pre-logout wipe guard behavior.