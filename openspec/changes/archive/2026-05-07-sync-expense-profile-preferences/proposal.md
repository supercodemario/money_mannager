## Why

Expense-limit settings currently live only in local Drift storage, so a signed-in user loses their monthly income, savings goal, and recurring-exclusion guidance when they return on a fresh device or after local data is cleared. These values are part of the user's expense profile and should follow the authenticated user through Supabase-backed sync.

## What Changes

- Add auth-user scoped Supabase storage for expense profile preferences.
- Sync `expense_limit_preferences` fields for the signed-in user: monthly income, monthly savings, unpaid-recurring exclusion, and update timestamp.
- Push local profile changes to Supabase when sync is allowed, while preserving local-first behavior when signed out or offline.
- Pull the signed-in user's expense profile during post-login/bootstrap and manual refresh flows, even when there are no expense rows to sync.
- Keep feature UI saving through local repositories only; remote upload/download remains orchestrated by the sync layer.

## Capabilities

### New Capabilities

- `expense-profile-sync`: Syncs auth-user scoped expense profile preferences between local storage and Supabase.

### Modified Capabilities

- `supabase-phase1-sync`: Expands post-login/manual sync behavior so cloud-to-local bootstrap includes the signed-in user's expense profile in addition to expenses.

## Impact

- Affected local data: `expense_limit_preferences` schema and repository behavior.
- Affected remote data: Supabase migration/RLS for auth-user scoped expense profile preferences.
- Affected sync layer: remote gateway, sync metadata, and `SyncOrchestrator` push/pull sequencing.
- Affected UX: expense-limit settings should restore after login/bootstrap without direct Supabase calls from `ExpenseLimitsScreen`.
