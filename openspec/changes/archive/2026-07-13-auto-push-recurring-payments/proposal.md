## Why

Recurring templates and mark-paid occurrences are saved locally as `pending`, but the automatic sync cycle only uploads **expenses**. Unless the user opens Recurring cloud sync or runs post-login/logout sync, rows never reach Supabase—so household members and reinstalls miss recurring data. Users need every recurring change to upload when signed in, the same way expenses (and Limits save) already push.

## What Changes

- After recurring mutations (create/update/toggle/delete template, mark paid / related occurrence writes), when cloud sync is allowed and the device is online, the sync layer SHALL upload **all pending recurring templates**, then **pending expenses** (mark-paid creates expenses), then **pending recurring occurrences**, without requiring a full pull.
- Extend or complement the automatic sync path so pending recurring work is not left stranded until a manual sync screen is opened.
- Keep UI local-first: screens still write only through repositories; upload remains orchestrator-owned.
- Offline / signed-out: keep `pending` / `local_only`; do not mark `error` solely for being offline.

## Capabilities

### New Capabilities

- `recurring-auto-push-sync`: Automatic / on-mutation upload of pending recurring templates and occurrences (with dependency-ordered expense push when needed), without pull.

### Modified Capabilities

- `recurring-payments-sync`: Clarify that upload MAY run from the auto/on-mutation push path in addition to full manual sync, while preserving household scope and template→expense→occurrence order.

## Impact

- `SyncOrchestrator` — new push-pending-recurring entry (ordered templates → expenses → occurrences)
- `ManualSyncHelper` — UI/orchestrator helper for post-mutation push
- Recurring feature screens/sheets — trigger helper after successful local writes when `syncAllowed`
- Optional: auto cycle watches / includes pending recurring (not expenses-only)
- Tests for ordered push and offline skip
- Supabase tables unchanged (`recurring_payments`, `recurring_payment_occurrences`, expenses)
