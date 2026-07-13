## 1. Orchestrator push path

- [x] 1.1 Add `SyncOrchestrator.pushPendingRecurringPayments` that, when signed in and online, runs templates → expenses → occurrences push (no pull)
- [x] 1.2 Expose `ManualSyncHelper.pushPendingRecurringPayments` for feature call sites
- [x] 1.3 Invoke the same path from the automatic expense sync cycle so stranded pending recurring uploads

## 2. Mutation call sites

- [x] 2.1 After successful add/edit recurring template save, push when `syncAllowed`
- [x] 2.2 After mark-paid (and other pending occurrence/template mutations in UI), push when `syncAllowed`
- [x] 2.3 Ensure enable/disable/delete template flows that mark pending also trigger push

## 3. Tests and verify

- [x] 3.1 Unit-test ordered push and offline skip (rows stay pending, not error)
- [x] 3.2 Smoke: create template + mark paid while signed in → rows appear in Supabase without opening Recurring cloud sync
