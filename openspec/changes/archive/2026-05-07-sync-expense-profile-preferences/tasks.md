## 1. Data Model And Migrations

- [x] 1.1 Add a Supabase migration for auth-user scoped expense profile preferences with `auth_user_id`, monthly income, monthly savings, unpaid-recurring exclusion, `updated_at`, sync metadata as needed, and RLS policies restricted to `auth.uid()`.
- [x] 1.2 Add local Drift sync metadata to `expense_limit_preferences` for local-first upload state and remote merge bookkeeping.
- [x] 1.3 Regenerate Drift outputs and verify existing local profile preference rows migrate without data loss.

## 2. Repository And Remote Gateway

- [x] 2.1 Extend `ExpenseLimitsRepository.upsertPreferences` to assign sync status based on `CloudSyncController.syncAllowed` while preserving local-only behavior when signed out.
- [x] 2.2 Add repository methods to count/promote/retry/mark synced/mark error for expense profile preference sync state.
- [x] 2.3 Add repository merge logic to apply a remote expense profile row using last-write-wins by `updated_at`.
- [x] 2.4 Add a remote gateway for auth-user scoped expense profile upsert and fetch operations through Supabase.

## 3. Sync Orchestration

- [x] 3.1 Extend `AppServices` wiring so expense profile sync dependencies are available without feature UI calling remote APIs.
- [x] 3.2 Extend `SyncOrchestrator` push flow to upload pending expense profile preferences alongside pending expenses.
- [x] 3.3 Extend `SyncOrchestrator` pull flow to fetch and merge the signed-in user's expense profile during background, manual, and post-login bootstrap sync.
- [x] 3.4 Ensure local-only expense profile preferences are promoted only from explicit authenticated sync paths, matching existing local-only expense behavior.

## 4. UX And Copy Verification

- [x] 4.1 Verify `ExpenseLimitsScreen` continues to save locally through `ExpenseLimitsRepository` and loads restored values after profile pull.
- [x] 4.2 Review post-login/manual sync copy so progress and failures make sense when profile preferences are included with cloud data.

## 5. Tests

- [x] 5.1 Add repository tests for signed-in pending profile saves, signed-out local-only profile saves, promotion, retry, and synced/error transitions.
- [x] 5.2 Add sync orchestrator tests for profile upload, profile pull during zero-expense bootstrap, and manual refresh.
- [x] 5.3 Add conflict tests proving newer remote profile rows overwrite local values and older remote rows do not.
- [x] 5.4 Add or update UI-level tests confirming expense-limit settings restore after login/bootstrap without direct Supabase calls from the screen.
