## 1. Post-login sync screen

- [x] 1.1 Add `AppStrings` entries for post-login sync title, eligible count line, primary sync CTA, defer CTA, completion title/body, and stage labels (reuse or mirror logout sync wording where product copy should match).
- [x] 1.2 Implement a new full-screen widget under `lib/features/auth/view/` (for example `post_login_cloud_sync_screen.dart`) that accepts a local-only count, a `runSync` callback matching the `ManualSyncStage` pattern used by `SyncBeforeLogoutScreen`, and callbacks for defer and successful completion.
- [x] 1.3 Implement UI states: initial (count + Sync + Not now), running (stages + non-dismissible back), success (completion + Done), failure (message + Retry + Not now); use `PopScope`/`canPop` consistent with logout sync when busy.
- [x] 1.4 Wire the screen from `AuthScreen._handlePostAuthSyncPrompt`: remove the alert-dialog + blocking spinner path for the “sync now” choice; when local-only count is greater than zero, push the new screen instead; on defer or Done after success, return the boolean expected by existing sign-in/sign-up navigation.

## 2. Tests and verification

- [x] 2.1 Add widget tests for the new screen: defer from initial state does not call `runSync`; successful `runSync` shows completion; failure shows error and Retry re-invokes sync; back gesture blocked while busy if applicable.
- [x] 2.2 Update or add tests for `AuthScreen` post-auth flow if any existing tests assert on the old dialog-only behavior.
- [x] 2.3 Run `flutter test` for affected test files and fix regressions.

## 3. Spec and archive readiness

- [x] 3.1 After implementation, confirm UI behavior matches `openspec/changes/post-login-cloud-sync-screen/specs/supabase-phase1-sync/spec.md` scenarios.
- [x] 3.2 On completion of the change, archive per project OpenSpec workflow so `openspec/specs/supabase-phase1-sync/spec.md` receives the merged requirement text.
