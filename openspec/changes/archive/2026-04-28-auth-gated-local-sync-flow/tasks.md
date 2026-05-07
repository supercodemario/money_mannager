## 1. Sync state and repository updates

- [x] 1.1 Add `local_only` to sync status constants and update expense save logic so rows created while unauthenticated are explicitly marked `local_only`.
- [x] 1.2 Add repository/query helpers to count and list unsynced rows (`local_only`, `pending`, `error`) for login and logout guards.
- [x] 1.3 Update sync orchestration APIs to support promoting `local_only` rows to `pending` when user chooses sync.

## 2. Login/signup unsynced-data decision flow

- [x] 2.1 After successful login/signup, detect local-only rows and show a prompt (`Sync now` / `Not now`) only when data exists.
- [x] 2.2 Implement `Sync now` path: promote eligible rows, run push then pull, and keep user signed in.
- [x] 2.3 Implement `Not now` path: preserve `local_only` rows without upload in that auth flow.

## 3. Logout guarded sync screen

- [x] 3.1 Add a dedicated pre-logout sync screen with step/progress states and error reason display.
- [x] 3.2 On failure, provide `Retry` and `Logout without sync` actions; retry re-runs sync pipeline.
- [x] 3.3 On success, complete logout and wipe local DB per product scope; on `Logout without sync`, logout and wipe with explicit warning semantics.

## 4. Validation and regression coverage

- [x] 4.1 Add/adjust tests for login prompt conditions, `local_only` promotion, and sync pipeline ordering (push before pull).
- [x] 4.2 Add/adjust tests for logout guarded flow (success, retry after failure, logout without sync) and local wipe behavior.
- [x] 4.3 Run `dart analyze` and targeted widget/repository tests for touched files.