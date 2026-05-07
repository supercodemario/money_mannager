## 1. Sync Orchestration Updates

- [x] 1.1 Extend `SyncOrchestrator.runManualSync` with an explicit mode that supports pull-only/cloud-bootstrap execution when local-only rows are zero.
- [x] 1.2 Add guard logic so only one sync cycle runs at a time across lifecycle-triggered and manual-triggered paths.
- [x] 1.3 Ensure stage callbacks remain consistent (`preparing`, `pushing`, `pulling`) and document how stages behave for pull-only runs.

## 2. Auth and Post-Login Flow

- [x] 2.1 Update post-auth decision logic in `auth_screen.dart` so existing cloud users can run bootstrap sync even without `local_only` rows.
- [x] 2.2 Update post-login sync UI copy/state handling to represent both upload+download and download-only bootstrap paths.
- [x] 2.3 Track bootstrap completion state to avoid repeatedly forcing the same blocking post-login prompt after a successful run.

## 3. Manual Refresh Entry Point

- [x] 3.1 Add a signed-in manual sync action (outside local-only gating) that triggers cloud-to-local refresh on demand.
- [x] 3.2 Wire the manual action to orchestrator mode selection and error/retry handling without direct remote calls from feature UI.

## 4. Verification and Regression Coverage

- [x] 4.1 Add/extend tests for post-login bootstrap behavior when local DB is empty and cloud has data.
- [x] 4.2 Add/extend tests for existing local-only flow to ensure upload/defer semantics remain unchanged.
- [x] 4.3 Add/extend tests for manual signed-in cloud refresh with zero pending/local-only rows.
- [x] 4.4 Run targeted QA scenarios for sign-in, defer, retry, and logout with unsynced rows to confirm no behavioral regressions.
