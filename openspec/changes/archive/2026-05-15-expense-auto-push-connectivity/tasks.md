## 1. Dependency and connectivity gate

- [x] 1.1 Add `connectivity_plus` to `pubspec.yaml` and run `flutter pub get`
- [x] 1.2 Add a small `ConnectivityGate` (or equivalent) that exposes `bool get isOnline` from OS connectivity (treat `none` as offline)
- [x] 1.3 Unit-test connectivity gate with mocked platform results (online vs offline)

## 2. Orchestrator split (auto vs manual)

- [x] 2.1 Add `runAutoExpenseSync()` on `SyncOrchestrator`: requires `syncAllowed` + connectivity online; pushes pending expenses only; no pull
- [x] 2.2 When auto path is offline, return early without calling `markRemoteError` on pending expenses
- [x] 2.3 Keep `runManualSync()` as full push-then-pull for profiles, recurring, expenses, occurrences
- [x] 2.4 Change background debounced handler in `start()` / `_runCycle` to call `runAutoExpenseSync()` instead of `runManualSync()`
- [x] 2.5 Optionally call `ensureDefaultExpenseHouseholdPreference()` before auto expense push when needed for `household_id`

## 3. Lifecycle and triggers

- [x] 3.1 Subscribe to `connectivity_plus` in `SyncLifecycle` (or orchestrator); on transition to online + `syncAllowed`, schedule `runAutoExpenseSync()`
- [x] 3.2 Ensure `CloudSyncController` listener still schedules auto expense sync (not manual) on session ready
- [x] 3.3 Verify pending expense Drift watch still debounces and triggers auto path only

## 4. Repository and error semantics

- [x] 4.1 Confirm `ExpenseRepository.insert` still sets `pending` when `syncAllowed` (no change if already correct)
- [x] 4.2 Ensure auto push still marks `synced` on success and `error` only on real upsert failures when online
- [x] 4.3 Document that recurring/profile `pending` rows upload only via manual/post-login/logout flows

## 5. Tests

- [x] 5.1 Add orchestrator test: auto cycle pushes expenses, does not invoke pull gateways
- [x] 5.2 Add orchestrator test: auto cycle skipped when offline — expenses stay `pending`
- [x] 5.3 Add orchestrator test: manual sync still runs full push-then-pull
- [x] 5.4 Update any existing sync orchestrator tests that assumed background cycle pulls

## 6. Verification

- [ ] 6.1 Manual QA: save expense online → becomes `synced` within a few seconds without opening settings sync
- [ ] 6.2 Manual QA: airplane mode on while logged in → save stays `pending`, not `error`; turn network on → uploads
- [ ] 6.3 Manual QA: manual sync from settings still pulls recurring/profile/expenses
