## Why

Recurring payment schedules and their monthly paid markers currently exist only in local Drift storage, so signed-in users cannot restore recurring bills/subscriptions or paid recurring-month state on another device. Syncing both recurring tables lets the recurring templates screen and monthly recurring views recover the same local state after login/manual sync.

## What Changes

- Add Supabase-backed sync for `recurring_payments` templates.
- Add Supabase-backed sync for `recurring_payment_occurrences` monthly paid markers.
- Preserve dependency ordering: recurring templates sync before expenses, and occurrences sync after both templates and expenses.
- Add local sync metadata to both recurring tables.
- Include recurring template/occurrence rows in local-only promotion, manual sync, post-login bootstrap, and retry flows.
- Keep feature UI saving through local repositories only; remote upload/download remains orchestrated by the sync layer.

## Capabilities

### New Capabilities

- `recurring-payments-sync`: Syncs recurring payment templates and recurring payment occurrences between local storage and Supabase.

### Modified Capabilities

- `supabase-phase1-sync`: Expands sync entity ordering and post-login/manual behavior so recurring payments and occurrences participate in cloud sync without presentation-layer remote calls.

## Impact

- Affected local data: `recurring_payments`, `recurring_payment_occurrences`, and related Drift migrations/generated code.
- Affected remote data: Supabase migrations/RLS for household-scoped recurring templates and occurrences.
- Affected sync layer: remote gateways, sync metadata, push/pull ordering, conflict handling, local-only promotion, and retry handling.
- Affected UX: recurring templates screen/manual sync should restore recurring templates and paid monthly recurring state from Supabase.