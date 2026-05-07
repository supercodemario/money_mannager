## Why

New users need a clear introduction to HomeRatio (tracking, limits, logging expenses) without embedding that UI into the dashboard home. Formalizing this flow in OpenSpec keeps onboarding behavior testable, reviewable, and distinct from core home functionality.

## What Changes

- Capture requirements for a **standalone first-run “Get Started” experience** shown before the main app shell.
- Define **persistent completion** so users who finish (or skip exploration) are not forced through the flow again on every launch.
- Document **separation of concerns**: onboarding does not reuse the home app bar or dashboard layout; the main shell appears only after onboarding completes.
- Align specs with the existing implementation (`AppShell` onboarding gate, `GetStartedScreen`, `OnboardingPreferences`) or track any intentional gaps.
- **Explicitly out of scope:** This change MUST NOT alter **bottom navigation styling** (selection chrome, colors, layout of `AppShell` bottom nav). Onboarding is a separate screen; shell chrome stays as implemented unless a dedicated navigation change is proposed elsewhere.

## Capabilities

### New Capabilities

- `get-started-onboarding`: First-run Get Started screen, completion persistence, and gating of the main application shell.

### Modified Capabilities

- None (app entry orchestration is introduced as a new concern; existing capability specs remain unchanged unless a future change links onboarding to another domain explicitly).

## Impact

- **App entry:** `MaterialApp.home` is `AppShell`, which chooses onboarding body vs main tabs while keeping the shell bottom bar visible.
- **Persistence:** `shared_preferences` (or equivalent) stores onboarding completion independently of expense limits and domain data.
- **UX:** Dashboard and bottom navigation **style and behavior** stay unchanged once the user reaches the shell (and this change does not refactor bottom nav); tutorial content lives on its own screen.
