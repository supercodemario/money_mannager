## Why

After a successful cloud sign-in, users with local-only expenses need a clear, trustworthy moment to upload and merge cloud data. A small alert dialog plus an undifferentiated blocking spinner does not communicate how much will sync, what phase is running, or when the work finished. A dedicated post-login sync screen improves confidence and matches the guarded sync UX pattern already used before logout.

## What Changes

- Replace the post-auth **local-only** flow (dialog + root `CircularProgressIndicator` overlay during sync) with a **full-screen post-login sync** experience.
- The screen shows **how many expenses** are eligible to sync (at minimum: `local_only` count when that is the trigger), a primary **Sync** action, **stage-based progress** (align with `ManualSyncStage`: preparing, pushing, pulling), and an explicit **completion** state before the user returns to the app.
- On sync failure, show the error and offer **Retry** and **Skip for now** (defer keeps rows unsynced per existing rules).
- No change to core sync orchestration semantics (still `SyncOrchestrator.runManualSync` with promotion + push + pull); this is presentation and navigation around the same operations.

## Capabilities

### New Capabilities

- *(none)*

### Modified Capabilities

- `supabase-phase1-sync`: Extend the login/signup local-only sync flow so that, when eligible unsynced local data exists after authentication, the user gets a dedicated screen with counts, explicit sync control, visible stages, completion, and failure recovery—instead of only a modal prompt and blocking spinner.

## Impact

- **UI**: `lib/features/auth/view/auth_screen.dart` (post-auth path), new screen under `lib/features/auth/view/` (or shared sync view if extracted), `AppStrings` for copy.
- **Tests**: Widget tests for the new screen (stages, success dismiss, retry, skip); adjust any tests that assert on the old dialog-only flow.
- **Specs**: Delta under this change for `supabase-phase1-sync`.
