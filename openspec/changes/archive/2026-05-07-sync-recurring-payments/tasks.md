## 1. Data Model And Migrations

- [x] 1.1 Add Supabase migration tables for household-scoped `recurring_payments` and `recurring_payment_occurrences` with RLS, indexes, and foreign keys to households/templates/expenses as appropriate.
- [x] 1.2 Add local Drift sync metadata to `recurring_payments`.
- [x] 1.3 Add local `updated_at` and sync metadata to `recurring_payment_occurrences`, backfilling existing rows from `created_at`.
- [x] 1.4 Decide and implement synced delete behavior for recurring templates and dependent occurrences.
- [x] 1.5 Regenerate Drift outputs and verify existing recurring templates and occurrences migrate without data loss.

## 2. Repository And Remote Gateways

- [x] 2.1 Extend `RecurringPaymentRepository` template create/update/enable/delete paths to assign sync status based on `CloudSyncController.syncAllowed`.
- [x] 2.2 Extend recurring paid occurrence creation/update paths to assign sync status and `updated_at`.
- [x] 2.3 Add repository methods to count/promote/retry/mark synced/mark error for recurring templates and occurrences.
- [x] 2.4 Add repository merge logic for remote recurring templates using last-write-wins by `updated_at`.
- [x] 2.5 Add repository merge logic for remote recurring occurrences using last-write-wins by `updated_at` and safe missing-dependency handling.
- [x] 2.6 Add remote gateways for household-scoped recurring template and occurrence upsert/fetch operations through Supabase.

## 3. Sync Orchestration

- [x] 3.1 Extend `AppServices` wiring so recurring sync dependencies are available without feature UI calling remote APIs.
- [x] 3.2 Extend `SyncOrchestrator` push flow to upload recurring templates before expenses and recurring occurrences after expenses.
- [x] 3.3 Extend `SyncOrchestrator` pull flow to fetch and merge recurring templates before expenses and recurring occurrences after expenses.
- [x] 3.4 Ensure local-only recurring rows are promoted only from explicit authenticated sync paths.
- [x] 3.5 Include recurring template and occurrence unsynced counts in post-login/manual sync preview decisions.
- [x] 3.6 Add or expose a manual sync entry from recurring templates/settings UI that uses sync orchestration rather than direct remote calls.

## 4. UX Verification

- [x] 4.1 Verify recurring templates screen continues to save locally through `RecurringPaymentRepository`.
- [x] 4.2 Verify manual sync from recurring UI restores templates and paid occurrence state from Supabase.
- [x] 4.3 Verify post-login/bootstrap sync restores recurring data before recurring views are shown.
- [x] 4.4 Review sync copy so progress and failures make sense when recurring templates and occurrences are included with cloud data.

## 5. Tests

- [x] 5.1 Add repository tests for signed-in pending and signed-out local-only recurring template saves.
- [x] 5.2 Add repository tests for signed-in pending and signed-out local-only recurring occurrence saves.
- [x] 5.3 Add repository tests for promotion, retry, synced/error transitions, and LWW merge for recurring templates and occurrences.
- [x] 5.4 Add sync orchestrator tests proving push/pull order is templates, expenses, then occurrences.
- [x] 5.5 Add tests for missing dependency handling when a remote occurrence references a missing template or expense.
- [x] 5.6 Add UI or integration tests confirming manual recurring sync restores local recurring screen state.
