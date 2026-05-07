## 1. Implementation alignment

- 1.0 Confirm **no edits** were made to bottom navigation styling or `AppShell` `_BottomNav` behavior as part of Get Started work (scope isolation).
- 1.1 Verify `AppShell` loads `OnboardingPreferences.isGetStartedCompleted()` (or equivalent), shows loading until resolved, and gates body between Get Started vs `IndexedStack`; bottom navigation remains visible with interaction ignored until complete.
- 1.2 Verify `GetStartedScreen` is standalone (not embedded in `DashboardHomeScreen`) and uses shared tokens/strings as intended.
- 1.3 Verify both Get Started actions call the same completion path that persists `get_started_completed` and swaps to `AppShell`.

## 2. Quality and documentation

- 2.1 Manually test cold start: first launch shows Get Started; after completion, relaunch skips to shell; clear app data to re-test. *(Implementation verified in code; run a device/simulator smoke test for release QA.)*
- 2.2 Confirm `shared_preferences` key name is stable and documented in code next to `OnboardingPreferences` if developers need to reset during QA.
- 2.3 Run `dart analyze` on touched paths after any follow-up tweaks.

## 3. Optional follow-ups (out of minimal scope)

- 3.1 Add Settings entry to replay Get Started by clearing the completion flag (product decision required). *(Deferred: optional; not implemented in this pass.)*

