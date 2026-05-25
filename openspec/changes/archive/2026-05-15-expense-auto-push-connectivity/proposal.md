## Why

Logged-in users expect expenses to reach Supabase soon after save when the device is online, while staying safely queued locally when it is not. Today the background sync cycle pushes and pulls all entity types together, and a failed push while offline can mark expenses as `error` even though the only problem is connectivity. Splitting a lightweight **auto** path (expense push only, OS connectivity–gated) from the existing **manual** full sync keeps uploads fast without running unnecessary pulls on every save.

## What Changes

- Add OS-level connectivity awareness before automatic expense uploads; when offline, pending expenses remain `pending` (no push attempt, no `error` solely for being offline).
- Introduce an **auto sync cycle** that uploads **pending expenses only** and does **not** pull remote data.
- Keep the **manual sync cycle** as full push-then-pull for all phase-1 entities (expenses, recurring, expense profile, etc.).
- Trigger auto expense push on: new pending expense rows, session becoming sync-eligible, and connectivity restored.
- Retain local-first saves through repositories; UI still does not call Supabase directly.

## Capabilities

### New Capabilities

- `expense-auto-push-sync`: Automatic, connectivity-gated upload of pending local expenses without pull; offline behavior keeps `pending`.

### Modified Capabilities

- `supabase-phase1-sync`: Clarify that background/automatic sync for expenses follows the auto-push contract; manual and post-login flows retain full push-then-pull.

## Impact

- `lib/sync/sync_orchestrator.dart` — separate auto vs manual entry points; auto path skips pull and non-expense pushes.
- `lib/sync/sync_lifecycle.dart` — wire connectivity listener and auto expense sync triggers.
- `lib/data/repositories/expense_repository.dart` — ensure offline auto failures do not mark `error` when connectivity is the only blocker (orchestrator skips push instead).
- New dependency: `connectivity_plus` (or equivalent) for OS connectivity signal.
- Tests: orchestrator auto vs manual behavior, offline pending retention, connectivity-triggered push.
